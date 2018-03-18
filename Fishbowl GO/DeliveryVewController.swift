//
//  DeliveryVewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import ObjectMapper


protocol SignatureDelegate {
    func signatureAccepted(orderNumber: String)
}

class DeliveryVewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FBScannerDelegate, SignatureDelegate {

    private var errorTitle = "Delivery Error"
    
    var deliveryList = [FbShipSearchItem]()
    var totalRows = 0
    var shouldRefresh = true
    
    @IBOutlet var orderNumber: UITextField!
    @IBOutlet var tableView: UITableView!
    
    
    // MARK: - Actions
    @IBAction func btnReload(sender: AnyObject) {
        orderNumber.text = ""
        sendDeliveryRequest()
    }
    
    // MARK: - Overrides
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if shouldRefresh {
            orderNumber.text = ""
            sendDeliveryRequest()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.orderNumber.delegate = self
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder() // close the keyboard on <return>
        return true
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if identifier == "segueDelivery" {
            if !validateOrderNumber(orderNumber.stringValue) {
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }

        if segueId == "segueDelivery" {
            setNavigationBackItem(orderNumber.stringValue)
            let vc = segue.destinationViewController as! DeliverySignatureViewController
            vc.orderNumber = orderNumber.stringValue
            vc.delegate = self

        } else if segueId   == "segueScan" {
            let navController = segue.destinationViewController as! UINavigationController
            let vc = navController.childViewControllers[0] as! ScannerViewController
            vc.delegate = self
        }
    }
    
    // MARK: - Delegate Methods
    func receivedScanCode(code: String) {
        orderNumber.text = code
        if itemInList(code) {
            performSegueWithIdentifier("segueDelivery", sender: self)
        }
    }
    
    func signatureAccepted(orderNumber: String) {
        shouldRefresh = true
    }
    
    // MARK: - Table View Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as! DeliveryCell
        if let text = currentCell.number.text {
            orderNumber.text = text
            textFieldShouldReturn(orderNumber)
        }
        
        if moduleSettings.loadSetting(Constants.Module.General, setting: "AutoSelect", defaultValue: true) as! Bool {
            performSegueWithIdentifier("segueDelivery", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalRows;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CustomDeliveryCell", forIndexPath: indexPath) as! DeliveryCell
        
        var dateScheduled = deliveryList[indexPath.row].DateScheduled
        let dateArr = dateScheduled.characters.split{$0 == "T"}.map(String.init)
        dateScheduled = dateArr[0]
        cell.number.text = deliveryList[indexPath.row].ShipNumber
        cell.scheduled.text = dateScheduled
        cell.carrier.text = deliveryList[indexPath.row].Carrier
        return cell
    }
    
    // MARK: - Support Methods
    private func itemInList(orderNum: String) -> Bool {
        for item in deliveryList {
            if item.ShipNumber == orderNum {
                return true
            }
        }
        return false
    }

    private func validateOrderNumber(orderNumber: String) -> Bool {
        var valid = false
        
        // Check to see if part number text field is empty... if it is, show alert and return false
        if !orderNumber.isEmpty {
            valid = itemInList(orderNumber)
        }
        
        if !valid {
            invokeAlertMessage(errorTitle, msgBody: "Invalid order number", delegate: self)
        }
        return valid
    }

    
    // MARK: - Server Requests
    private func sendDeliveryRequest()
    {
        var status: UInt = Constants.ShipStatus.Packed // shipstatus: "packed"
        if g_pluginSettings.getSetting(Constants.Options.shipIncludeEntered) {
            status = 5
        }

        let count = moduleSettings.loadSetting(Constants.Module.Delivery, setting: "Orders", defaultValue: 99) as! UInt
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiShipListRequest(count: count, status: status)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "List updated") { (ticket, response) in
            self.DeliveryResponse(ticket, response: response)
        }
    }
    
    private func DeliveryResponse(ticket: FbTicket, response: FbResponse)
    {
        deliveryList.removeAll()
        totalRows = 0
        if response.isValid(Constants.Response.shipList) {
            shouldRefresh = false
            let itemList = response.getJson()["ShipSearchItem"]
            switch itemList.type {
            case .Array:
                for (_, item) in itemList {
                    let data = String(item)
                    if let deliveryItem = Mapper<FbShipSearchItem>().map(data) {
                        deliveryList.append(deliveryItem)
                    }
                }
                break
            case .Dictionary:
                let data = String(itemList)
                if let deliveryItem = Mapper<FbShipSearchItem>().map(data) {
                    deliveryList.append(deliveryItem)
                }
                break
            default: break
                
            }
            totalRows = deliveryList.count
            tableView.reloadData()
        } else {
            invokeAlertMessage(errorTitle, msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        }
    }
}
