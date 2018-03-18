//
//  PackViewController.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/25/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import ObjectMapper
//import DZNEmptyDataSet

protocol PackDelegate {
    func packOrderSaved(packedOrder: AnyObject?)
}

class PackViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UITextFieldDelegate, FBScannerDelegate, PackDelegate {

    var totalRows = 0
    var packItemList = [FbShipSearchItem]()
    var packList: JSON?
    private var needRefresh = false

    
    @IBOutlet var orderNumber: UITextField!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var table: UITableView!
    @IBOutlet weak var btnPrint: UIBarButtonItem!
    
    // MARK: - Actions
    @IBAction func btnPackItem(sender: AnyObject) {
        if orderNumber.text!.isEmpty {
            invokeAlertMessage("Pack", msgBody: "Order number is required", delegate: self)
        }
    }
    
    @IBAction func btnReload(sender: AnyObject) {
        orderNumber.text = ""
        sendPackListRequest()
    }

    // Currently the button tied to this method is hidden/disabled.
    // To enable, remove the call to btnPrint.hide() that is found below
    // in this class.
    @IBAction func btnPrint(sender: AnyObject) {
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            id: g_userId,
            requestObj: FbiPrintReportRequest(moduleName: "Shipping", shipId: 95)
        )
        print(fbMessageRequest)
        invokeAlertMessage("Not Implemented", msgBody: "The print packing list feature is not yet implemented.", delegate: self)
    }

    // MARK: - Table Delegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalRows;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.table.dequeueReusableCellWithIdentifier("PackOrderCell", forIndexPath: indexPath) as! PackOrderCell

        var dateScheduled = packItemList[indexPath.row].DateScheduled
        let dateArr = dateScheduled.characters.split{$0 == "T"}.map(String.init)
        dateScheduled = dateArr[0]

        cell.orderNumber.text = packItemList[indexPath.row].ShipNumber
        cell.carrier.text = packItemList[indexPath.row].Carrier
        cell.scheduled.text = dateScheduled
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as! PackOrderCell
        if let text = currentCell.orderNumber.text {
            orderNumber.text = text
            if moduleSettings.loadSetting(Constants.Module.General, setting: "AutoSelect", defaultValue: true) as! Bool {
                performSegueWithIdentifier("seguePack", sender: self)
            }
        }
    }
    
    // MARK: - Server Requests
    func sendPackListRequest()
    {
        let count = moduleSettings.loadSetting(Constants.Module.Pack, setting: "Orders", defaultValue: 99) as! UInt
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            id: g_userId,
            requestObj: FbiShipListRequest(count: count, status: 10)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "List updated") { (ticket, response) in
            self.PackListResponse(ticket, response: response)
        }
        
    }
    
    private func PackListResponse(ticket: FbTicket, response: FbResponse)
    {
        packItemList.removeAll()
        totalRows = 0
        if response.isValid(Constants.Response.shipList) {
            let itemList = response.getJson()["ShipSearchItem"]
            switch itemList.type {
                case .Array:
                    for (_, item) in itemList {
                        let data = String(item)
                        if let packItem = Mapper<FbShipSearchItem>().map(data) {
                            packItemList.append(packItem)
                        }
                    }
                    break
                case .Dictionary:
                    let data = String(itemList)
                    if let packItem = Mapper<FbShipSearchItem>().map(data) {
                        packItemList.append(packItem)
                    }
                    break
                default:break
            }
            totalRows = (packItemList.count)
            table.reloadData()
        } else {
            invokeAlertMessage("Pack Error", msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        }
    }
    
    // MARK: - Delegate Methods
    func packOrderSaved(packedOrder: AnyObject?) {
        needRefresh = true
    }
    
    func receivedScanCode(code: String) {
        orderNumber.text = code
        let (index, exists) = itemInList(code)
        if exists {
            if table.selectRowAtSectionRow(index, inSection: 0, animated: true, scrollPosition: UITableViewScrollPosition.Middle) {
                let rowToSelect = NSIndexPath(forRow: index, inSection: 0)
                tableView(table, didSelectRowAtIndexPath: rowToSelect)
            }
        }
    }
    
    private func itemInList(orderNum: String) -> (Int, Bool) {
        for (index, item) in packItemList.enumerate() {
            if item.ShipNumber.caseInsensitiveCompare(orderNum) == .OrderedSame {
                return (index, true)
            }
        }
        return (-1, false)
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        btnPrint.hide()
        sendPackListRequest()
    }
    
    override func viewDidAppear(animated: Bool) {
        if needRefresh {
            orderNumber.text = ""
            sendPackListRequest()
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "seguePack" {
            if !validateOrderNumber(orderNumber.text!) {
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }

        if segueId == "seguePack" {
            setNavigationBackItem(orderNumber.stringValue)
            let destViewController = segue.destinationViewController as! PackOrderTableViewController
            destViewController.orderNum = orderNumber.stringValue
            destViewController.delegate = self
        } else if segueId   == "segueScanPack" {
            let navController = segue.destinationViewController as! UINavigationController
            let destViewController = navController.childViewControllers[0] as! ScannerViewController
            destViewController.delegate = self
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
            case orderNumber:
                if validateOrderNumber(orderNumber.stringValue) {
                    performSegueWithIdentifier("seguePack", sender: self)
                }
                break
            default:
                textField.resignFirstResponder()
        }
        return true
    }

    
    // MARK: - Support Methods
    private func validateOrderNumber(orderNumber: String) -> Bool {
        var valid = false
        
        // Check to see if part number text field is empty... if it is, show alert and return false
        if !orderNumber.isEmpty {
            valid = itemInList(orderNumber)
        }
        
        if !valid {
            invokeAlertMessage("Pack Error", msgBody: "Invalid part number", delegate: self)
        }
        return valid
    }
    
    private func itemInList(orderNum: String) -> Bool {
        for item in packItemList {
            if item.ShipNumber == orderNum {
                return true
            }
        }
        return false
    }
}
