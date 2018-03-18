//
//  ShipViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/25/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import ObjectMapper


class ShipViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FBScannerDelegate {

    private var errorTitle = "Ship Error"
    
    var shipList: JSON?
    var totalRows = 0
    private var shipSearchList = [FbShipSearchItem]()
    
    @IBOutlet var orderNumber: UITextField!
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Actions
    @IBAction func btnOpenOrder(sender: AnyObject) {
        if orderNumber.stringValue.characters.count > 0 {
            sendShipOrderRequest()
        } else {
            invokeAlertMessage(errorTitle, msgBody: "Invalid order specified", delegate: self)
        }
    }
    
    @IBAction func btnReload(sender: AnyObject) {
        orderNumber.text = ""
        sendShipListRequest()
    }
    
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        self.orderNumber.delegate = self
        sendShipListRequest()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }

        if segueId   == "segueScan" {
            let navController = segue.destinationViewController as! UINavigationController
            let vc = navController.childViewControllers[0] as! ScannerViewController
            vc.delegate = self
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
            case orderNumber:
                btnOpenOrder(self)
                break
            default:
                textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - Server Requests
    func sendShipListRequest()
    {
        // For Ship List request, is the plugin setting configured to get ALL or just
        // ship list items that are "entered" (shipIncludeEntered)
        // To get "all" include the status of 5
        // To get just the ones ready to ship use status: 20
        
        var status: UInt = Constants.ShipStatus.Packed // shipstatus: "packed"
        let shipIncludeEntered = g_pluginSettings.getSetting(Constants.Options.shipIncludeEntered)
        if Bool(shipIncludeEntered) {
            status = 5
        }
        let count = moduleSettings.loadSetting(Constants.Module.Ship, setting: "Orders", defaultValue: 99) as! UInt

        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            id: g_userId,
            requestObj: FbiShipListRequest(count: count, status: status)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "List updated") { (ticket, response) in
            self.ShipListResponse(ticket, response: response)
        }

    }
    
    func sendShipOrderRequest()
    {
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiShipOrderRequest(number: orderNumber.stringValue)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest) { (ticket, response) in
            self.ShipOrderResponse(ticket, response: response, orderNumber: self.orderNumber.stringValue)
        }
    }
    
    // MARK: - Response Handlers
    func ShipListResponse(ticket: FbTicket, response: FbResponse)
    {
        shipSearchList.removeAll()
        totalRows = 0
        if response.isValid(Constants.Response.shipList) { // success?
            shipList = response.getJson()["ShipSearchItem"]
            if let list = shipList {
                switch list.type {
                    case .Array:
                        for (_, item) in list {
                            let data = String(item)
                            if let searchItem = Mapper<FbShipSearchItem>().map(data) {
                                shipSearchList.append(searchItem)
                            }
                        }
                        totalRows = list.count
                        break
                    
                    case .Dictionary:
                        let data = list.rawString()
                        if let searchItem = Mapper<FbShipSearchItem>().map(data) {
                            shipSearchList.append(searchItem)
                        }
                        break
                    
                    default: break
                }
                totalRows = shipSearchList.count
                tableView.reloadData()
            }
        }
    }
    
    func ShipOrderResponse(ticket: FbTicket, response: FbResponse, orderNumber: String="")
    {
        if( response.getStatus() == 1000 && response.getName() == Constants.Response.shipOrder ) {
            let statusCode = response.getJson()["statusCode"].int!
            switch Int(statusCode) {
                case 1000: // success
                    self.orderNumber.text = ""
                    self.orderNumber.becomeFirstResponder()
                    sendShipListRequest() // refresh the list
                    break
                case 5200...5299:
                    let message = response.getJson()["statusMessage"].string
                    let newMessage = message!.stringByReplacingOccurrencesOfString("_________", withString: orderNumber)
                    invokeAlertMessage("Shipping", msgBody: newMessage, delegate: self)
                    break
                default:
                    invokeAlertMessage("Shipping", msgBody: "An error occured: \(statusCode)", delegate: self)
                    break
            }
        } else {
            let status = response.getStatus()
            invokeAlertMessage(errorTitle, msgBody: getFBStatusMessage(status), delegate: self)
        }
    }
    
    // MARK: - Table View Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalRows;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("ShipOrderCell", forIndexPath: indexPath) as! ShipOrderCell
        
        if indexPath.row < shipSearchList.count {
            let item = shipSearchList[indexPath.row]
            cell.orderNumber.text = item.ShipNumber
            cell.carrier.text = item.Carrier
            let dateScheduled = item.DateScheduled
            let dateArr = dateScheduled.characters.split{$0 == "T"}.map(String.init)
            cell.scheduledDate.text = dateArr[0]
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as! ShipOrderCell
        if let text = currentCell.orderNumber?.text {
            orderNumber.text = text
            if moduleSettings.loadSetting(Constants.Module.General, setting: "AutoSelect", defaultValue: true) as! Bool {
                sendShipOrderRequest()
            }
        }
    }
    
    // MARK: - Delegate Methods
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
    
    private func itemInList(orderNum: String) -> (Int, Bool) {
        for (index, item) in shipSearchList.enumerate() {
            if item.ShipNumber.caseInsensitiveCompare(orderNum) == .OrderedSame {
                return (index, true)
            }
        }
        return (-1, false)
    }
    
}
