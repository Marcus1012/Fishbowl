//
//  ReceiveViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/29/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import ObjectMapper

protocol OrderSavedDelegate {
    func orderSaved(order: AnyObject?)
}


class ReceiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FBScannerDelegate, OrderSavedDelegate {
    
    private var errorTitle = "Receiving Error"
    private var needRefresh = false
    
    var receiveList: JSON?
    var receivingList = [FbReceiveTicket]()
    var selectedOrderIndex: Int = -1

    @IBOutlet var orderNumber: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnOpenOrder: UIButton!
    
    // MARK: - Actions
    @IBAction func btnReload(sender: AnyObject) {
        sendReceiveListRequest()
    }
    
    @IBAction func btnOpenOrder(sender: AnyObject) {
        if orderNumber.text!.isEmpty {
            invokeAlertMessage("Receiving", msgBody: "Order number is required", delegate: self)
        }
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        self.orderNumber.delegate = self
        
        sendReceiveListRequest()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if needRefresh {
            sendReceiveListRequest()
        }
    }
   
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "segueReceive" {
            if !validateOrderNumber(orderNumber.stringValue) {
                return false
            }
        }

        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }

        if segueId == "segueReceive" {
            selectedOrderIndex = getOrderNumberIndex(orderNumber.stringValue)
            setNavigationBackItem(orderNumber.stringValue)
            let destViewController = segue.destinationViewController as! ReceiveOrderViewController
            destViewController.orderNumber = orderNumber.stringValue
            destViewController.fbTicket = receivingList[selectedOrderIndex]
            destViewController.delegate = self
        } else if segueId == "segueScanReceiving" {
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
                    performSegueWithIdentifier("segueReceive", sender: self)
                }
                break
            default:
                textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - Delegate Methods
    func receivedScanCode(code: String) {
        orderNumber.text = code
        checkAutoAdvance("segueReceive")
    }
    
    func orderSaved(order: AnyObject?) {
        needRefresh = true
    }
    
    // MARK: - Server Requests
    func sendReceiveListRequest()
    {
        let count = moduleSettings.loadSetting(Constants.Module.Receive, setting: "Orders", defaultValue: 99) as! UInt
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiReceivingListRequest(count: count, status: 2)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "List updated") { (ticket, response) in
            self.ReceiveListResponse(ticket, response: response)
        }

    }
    
    func ReceiveListResponse(ticket: FbTicket, response: FbResponse)
    {
        receivingList.removeAll()

        if response.isValid(Constants.Response.receivingList) {
            let itemList = response.getJson()["ReceiveTicket"]
            if itemList.type == .Array {
                for  (_, item) in itemList {
                    let data = String(item)
                    if let ticket = Mapper<FbReceiveTicket>().map(data) {
                        receivingList.append(ticket)
                    }
                }
            } else {
                let data = itemList.rawString()
                if let ticket = Mapper<FbReceiveTicket>().map(data) {
                    receivingList.append(ticket)
                }
                
            }
            tableView.reloadData()
        } else {
            invokeAlertMessage(errorTitle, msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        }
    }
    
    // MARK: - Helper Functions
    private func getOrderNumberIndex(orderNum: String) -> Int {
        for (index, item) in receivingList.enumerate() {
            let orderNumber = item.getOrderNumber()
            if orderNumber.caseInsensitiveCompare(orderNum) == NSComparisonResult.OrderedSame {
                return index
            }
        }
        return -1
    }
    
    private func checkAutoAdvance(segueName: String) {
        if moduleSettings.loadSetting(Constants.Module.General, setting: "AutoSelect", defaultValue: true) as! Bool {
            selectedOrderIndex = getOrderNumberIndex(orderNumber.stringValue)
            if selectedOrderIndex >= 0 {
                performSegueWithIdentifier(segueName, sender: self)
            }
        }
    }
    
    private func validateOrderNumber(orderNumber: String) -> Bool {
        var valid = false
        var index = 0
        
        // Check to see if part number text field is empty... if it is, show alert and return false
        if !orderNumber.isEmpty {
            (index, valid) = itemInList(orderNumber)
        }
        
        if !valid {
            invokeAlertMessage(errorTitle, msgBody: "Invalid order number", delegate: self)
        } else {
            self.orderNumber.text = receivingList[index].getOrderNumber()
        }
        return valid
    }
    
    private func itemInList(orderNum: String) -> (Int, Bool) {
        for (index, item) in receivingList.enumerate() {
            if item.matchesOrderNumber(orderNum) {
                return (index, true)
            }
        }
        return (-1, false)
    }
    
    // MARK: - Table View Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivingList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CustomReceiveCell", forIndexPath: indexPath) as! ReceiveOrderCell
        let item = receivingList[indexPath.row]
        cell.order.text = item.getOrderNumber()
        cell.vendor!.text = item.VendorName
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as! ReceiveOrderCell
        if let text = currentCell.order?.text {
            orderNumber.text = text
            //textFieldShouldReturn(orderNumber)
            checkAutoAdvance("segueReceive")
        }
    }

    

}
