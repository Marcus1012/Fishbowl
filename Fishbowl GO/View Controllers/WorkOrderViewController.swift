//
//  WorkOrderViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/6/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper


class WorkOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FBScannerDelegate, FBWorkOrderDelegate {
    
    private let errorTitle = "Work Order Error"
    private var ConsumeItems = FbConsumeItems()
    private var WorkOrder: FbWorkOrder?
    private var savedOrderNumber: String = ""
    private var needRefresh = true
    
    var workOrderList = [FbWorkOrderItem]()
    var totalRows = 0
    
    @IBOutlet var orderNumber: UITextField!
    @IBOutlet var btnOpenOrder: UIButton!
    @IBOutlet var tableView: UITableView!
    

    // MARK: - Actions
    @IBAction func btnReload(sender: AnyObject) {
        refreshWorkOrderList()
    }
    
    @IBAction func btnOpenWorkOrder(sender: AnyObject) {
        if validateOrderNumber(orderNumber.stringValue) {
            sendWorkOrderRequest(orderNumber.stringValue)
        }
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        self.orderNumber.delegate = self
    }

    override func viewDidAppear(animated: Bool) {
        if needRefresh {
            refreshWorkOrderList()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "segueWorkOrderDetail" {
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }

        if segueId == "segueWorkOrderDetail" {
            setNavigationBackItem(orderNumber.stringValue)
            let vc = segue.destinationViewController as! WorkOrderDetailViewController
            vc.delegate = self
        } else if segueId   == "segueScan" {
            let navController = segue.destinationViewController as! UINavigationController
            let vc = navController.childViewControllers[0] as! ScannerViewController
            vc.delegate = self
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder() // close the keyboard on <return>
        btnOpenWorkOrder(self)
        return true
    }

    // MARK: - Table View Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as! WorkOrderCell
        if let text = currentCell.number.text {
            orderNumber.text = text
            //textFieldShouldReturn(orderNumber)
            if moduleSettings.loadSetting(Constants.Module.General, setting: Constants.Settings.AutoSelect, defaultValue: true) as! Bool {
                if validateOrderNumber(orderNumber.stringValue) {
                    sendWorkOrderRequest(orderNumber.stringValue)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalRows;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CustomWorkOrderCell", forIndexPath: indexPath) as! WorkOrderCell
        
        var dateScheduled = workOrderList[indexPath.row].dateScheduledFulfillment
        let dateArr = dateScheduled.characters.split{$0 == "T"}.map(String.init)
        dateScheduled = dateArr[0]
        
        cell.number.text = workOrderList[indexPath.row].woNum
        cell.scheduled.text = dateScheduled
        cell.status.text = workOrderList[indexPath.row].status
        
        return cell
    }
    
    // MARK: - Delegate Methods
    func receivedScanCode(code: String) {
        orderNumber.text = code
        if itemInList(code) {
            if shouldPerformSegueWithIdentifier("segueWorkOrderDetail", sender: self) {
                performSegueWithIdentifier("segueWorkOrderDetail", sender: self)
            }
        }
    }
    
    func getWorkOrder() -> FbWorkOrder? {
        return WorkOrder
    }
    
    func workOrderSaved(orderNumber: String) {
        savedOrderNumber = orderNumber
        needRefresh = true
    }
    
    // MARK: - Server Requests
    private func sendWorkOrderListRequest()
    {
        let workOrderStatus = g_pluginSettings.getSetting(Constants.Options.workorderShowAllOpen) ? Constants.WorkOrderStatus.All : Constants.WorkOrderStatus.Started
        let count = moduleSettings.loadSetting(Constants.Module.WorkOrder, setting: "Orders", defaultValue: 99) as! UInt
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiWorkOrderListRequest(count: count, status: workOrderStatus)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "List updated") { (ticket, response) in
            self.WorkOrderListResponse(ticket, response: response)
        }

    }
    
    private func WorkOrderListResponse(ticket: FbTicket, response: FbResponse)
    {
        workOrderList.removeAll()
        totalRows = 0
        if response.isValid(Constants.Response.workOrderList) {
            let itemList = response.getJson()["WOSearch"]
            switch itemList.type {
                case .Array:
                    for (_, item) in itemList {
                        let data = String(item)
                        if let workItem = Mapper<FbWorkOrderItem>().map(data) {
                            workOrderList.append(workItem)
                        }
                    }
                    break
                case .Dictionary:
                    let data = String(itemList)
                    if let workItem = Mapper<FbWorkOrderItem>().map(data) {
                        workOrderList.append(workItem)
                    }
                    break
                default: break
                
            }
            totalRows = workOrderList.count
            tableView.reloadData()
            needRefresh = false
        } else {
            invokeAlertMessage(errorTitle, msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        }
    }
    
    private func sendWorkOrderRequest(orderNumber: String)
    {
        ConsumeItems.removeAll(false)
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiWorkOrderRequest(orderNum: orderNumber)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest) { (ticket, response) in
            self.workOrderResponse(ticket, response: response)
        }
    }
    
    private func workOrderResponse(ticket: FbTicket, response: FbResponse)
    {
        if response.isValid(Constants.Response.workOrder) {
            let workOrderJson = response.getJson()["WO"]
            WorkOrder = Mapper<FbWorkOrder>().map(String(workOrderJson))
            if let wo = WorkOrder {
                wo.extractConsumeItems(ConsumeItems)
            }
            
            if ConsumeItems.hasConsumableItems() {
                performSegueWithIdentifier("segueWorkOrderDetail", sender: self)
            } else {
                invokeAlertMessage(errorTitle, msgBody: "Work order \(orderNumber.stringValue) has not been picked.  The Work Order cannot be fulfilled until the pick has been finished.", delegate: self)
            }
        } else {
            invokeAlertMessage(errorTitle, msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        }
    }
    
    // MARK: - Support Methods
    private func refreshWorkOrderList() {
        orderNumber.text = ""
        sendWorkOrderListRequest()
    }
    
    private func itemInList(orderNum: String) -> Bool {
        for item in workOrderList {
            if item.woNum == orderNum {
                return true
            }
        }
        return false
    }

    private func validateOrderNumber(orderNumber: String) -> Bool {
        var valid = false
        
        if !orderNumber.isEmpty {
            valid = itemInList(orderNumber)
        }
        
        if !valid {
            invokeAlertMessage(errorTitle, msgBody: "Invalid work order number", delegate: self)
        }
        return valid
    }

}
