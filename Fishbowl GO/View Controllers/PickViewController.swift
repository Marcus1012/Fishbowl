//
//  PickViewController.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/23/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import ObjectMapper

protocol PickDelegate {
    func pickOrderSaved(pick: FbPick?)
}

class PickViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  FBScannerDelegate, UITextFieldDelegate, PickDelegate {

    private var needRefresh = false
    private let errorTitle = "Pick Error"


    var totalRows = 0
    var pickOrderList = [FbPickSearchItem]()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var orderNumber: ScannableTextField!
    @IBOutlet var btnOpenOrder: UIButton!
    
    // MARK: - Actions
    @IBAction func btnOpenOrder(sender: AnyObject) {
        if orderNumber.text!.isEmpty {
            invokeAlertMessage("Pick", msgBody: "Order number is required", delegate: self)
        }
    }
    
    @IBAction func btnReload(sender: AnyObject) {
        orderNumber.text = ""
        sendPickListRequest()
    }
    
    @IBAction func btnAction(sender: AnyObject) {

    }
    
    @IBAction func scan(sender: AnyObject) {

    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        self.orderNumber.delegate = self
        sendPickListRequest()
    }
    
    override func viewDidAppear(animated: Bool) {
        if needRefresh {
            orderNumber.text = ""
            sendPickListRequest()
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {

        if identifier == "seguePick" {
            if !validateOrderNumber(orderNumber.text!) {
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }

        if segueId == "seguePick" {
            setNavigationBackItem(orderNumber.stringValue)
            let vc = segue.destinationViewController as! PickOrderViewController
            vc.orderNumber = orderNumber.stringValue
            vc.delegate = self
        } else if segueId   == "segueScan" {
            let navController = segue.destinationViewController as! UINavigationController
            let vc = navController.childViewControllers[0] as! ScannerViewController
            vc.delegate = self
        }
    }

    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        super.dismissViewControllerAnimated(flag, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
            case orderNumber:
                if validateOrderNumber(orderNumber.stringValue) {
                    performSegueWithIdentifier("seguePick", sender: self)
                }
                break
            default:
                textField.resignFirstResponder() // close the keyboard on <return>
        }
        return true
    }

    // MARK: - Server Requests
    func sendPickListRequest()
    {
        // For Pick List request, is the plugin setting configured to get ALL or just
        // pick list items that are "in progress" (pickShowOnlyInProgress)
        let status = (g_pluginSettings.getSetting(Constants.Options.pickShowOnlyInProgress) == true) ? Constants.Property.statusStarted : "5"
        let count = moduleSettings.loadSetting(Constants.Module.Pick, setting: "Orders", defaultValue: 99) as! UInt
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiPickListRequest(count: count, status: status)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "List updated") { (ticket, response) in
            self.PickListResponse(ticket, response: response)
        }
    }
    
    func PickListResponse(ticket: FbTicket, response: FbResponse)
    {
        pickOrderList.removeAll()
        totalRows  = 0
        if response.isValid(Constants.Response.pickQuery) {
            needRefresh = false
            let itemList = response.getJson()["PickSearchItem"]
            switch itemList.type {
            case .Array:
                for(_, item) in itemList {
                    let data = String(item)
                    if let pickItem = Mapper<FbPickSearchItem>().map(data) {
                        pickOrderList.append(pickItem)
                    }
                }
                break
            case .Dictionary:
                let data = String(itemList)
                if let pickItem = Mapper<FbPickSearchItem>().map(data) {
                    pickOrderList.append(pickItem)
                }
                break
            default: break
            }
            totalRows = (pickOrderList.count)
            tableView.reloadData()
        } else {
            invokeAlertMessage(errorTitle, msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        }
    }
    
    // MARK: - Table View Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalRows;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath) as! PickOrderCell
        let orderNumber: String = pickOrderList[indexPath.row].number
        let priority: String = pickOrderList[indexPath.row].priority
        var dateScheduled = pickOrderList[indexPath.row].dateScheduled
        let dateArr = dateScheduled.characters.split{$0 == "T"}.map(String.init)
        dateScheduled = dateArr[0]
        cell.orderNumber!.text = orderNumber
        cell.priority!.text = priority
        cell.scheduledDate!.text = dateScheduled
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as! PickOrderCell
        if let text = currentCell.orderNumber?.text {
            orderNumber.text = text
            btnOpenOrder.enabled = true
            if moduleSettings.loadSetting(Constants.Module.General, setting: "AutoSelect", defaultValue: true) as! Bool {
                performSegueWithIdentifier("seguePick", sender: self)
            }
        }
    }
    
    // MARK: - Delegate Methods
    func pickOrderSaved(pick: FbPick?) {
        needRefresh = true
    }
    
    func receivedScanCode(code: String) {
        orderNumber.text = code
        let (index, exists) = itemInList(code)
        if exists {
            if tableView.selectRowAtSectionRow(index, inSection: 0, animated: true, scrollPosition: UITableViewScrollPosition.Middle) {
                let rowToSelect = NSIndexPath(forRow: index, inSection: 0)
                tableView(tableView, didSelectRowAtIndexPath: rowToSelect)
            }
        }
    }

    // MARK: - Support Methods
    private func validateOrderNumber(orderNumber: String) -> Bool {
        var valid = false
        var index = -1
        
        // Check to see if part number text field is empty... if it is, show alert and return false
        if !orderNumber.isEmpty {
            (index, valid) = itemInList(orderNumber)
            if valid {
                self.orderNumber.text = pickOrderList[index].number
            }
        }
        
        if !valid {
            invokeAlertMessage(errorTitle, msgBody: "Invalid order number", delegate: self)
            
        }
        return valid
    }
    
    private func itemInList(orderNum: String) -> (Int, Bool) {
        for (index, item) in pickOrderList.enumerate() {
            if item.number.caseInsensitiveCompare(orderNum) == .OrderedSame {
            //if item.number == orderNum {
                return (index, true)
            }
        }
        return (-1, false)
    }
    

}

















