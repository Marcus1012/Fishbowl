//
//  ReceiveOrderViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/29/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper


protocol ReceiveOrderDelegate {
    func saveReceivedItem(itemId: UInt, receivedReceipt: FbReceivedReceipt?)
}


class ReceiveOrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ReceiveOrderDelegate, FBScannerDelegate {

    class SaveItem {
        var itemId: UInt
        var quantity: Int
        var locationId: Int
        var tracking: FbTracking?
        
        required init(id: UInt, quantity: Int, locationId: Int, tracking: FbTracking?) {
            self.itemId = id
            self.quantity = quantity
            self.locationId = locationId
            self.tracking = tracking
        }
        
        func matches(itemId:UInt, locationId: Int) -> Bool {
            return self.itemId == itemId && self.locationId == locationId
        }
    }
    
    class SaveItems {
        var items = [SaveItem]()
        
        func add(id: UInt, quantity: Int, locationId: Int, tracking: FbTracking?) {
            items.append(SaveItem(id: id, quantity: quantity, locationId: locationId, tracking: tracking))
        }
        
        func getTotalQuantity(itemId: UInt, locationId: Int) -> Int {
            var sum: Int = 0
            for item in items {
                if item.matches(itemId, locationId: locationId) {
                    sum += item.quantity
                }
            }
            return sum
        }
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var partNumberField: UITextField!
    
    var fbTicket: FbReceiveTicket = FbReceiveTicket()
    var orderNumber : String = ""
    var delegate: OrderSavedDelegate?
    private var receiptItems = FbReceiptItems() // items (w/qty) that still need to be received - model for table view
    private var receipt: FbReceipt?                     // main receiving object, items are put in items list as they are received.
    private var saveItems: SaveItems = SaveItems()
    private var validPart: FbPart?
    private var selectedReceiveItem: FbReceiveItem?
    private var errorTitle = "Receive Error"
    private var needRefresh = false

    
    
    // MARK: - Delegate Methods
    func receivedScanCode(code: String) {
        partNumberField.text = code
        if moduleSettings.autoSelecteEnabled() {
            btnReceive(self)
        }
    }

    func saveReceivedItem(itemId: UInt, receivedReceipt: FbReceivedReceipt?) {
        guard let recReceipt = receivedReceipt else { return }
        if recReceipt.Quantity > 0 {
            needRefresh = true
        }
        
        if let receipt = self.receipt {
            receipt.addItemReceipt(itemId, receipt: receivedReceipt)
        }
        receiptItems.receive(itemId, quantity: recReceipt.Quantity)
    }
    
   
    // MARK: - Actions
    @IBAction func btnReceive(sender: AnyObject) {
        if setSelectedReceiveItem(partNumberField.stringValue) {
            if shouldShowEdit() {
                if selectedReceiveItem != nil {
                    prepAndPerformSegue(selectedReceiveItem!)
                }
            } else {
                if let item = selectedReceiveItem {
                    let index = receiptItems.getItemIndex(item.ID)
                    for recReceipt in item.ReceivedReceipts.ReceivedReceipt {
                        recReceipt.ItemType = Constants.ReceiptItemStatus.Entered // set to 10
                        saveReceivedItem(item.ID, receivedReceipt: recReceipt)
                    }
                    updateCell(item, index: index)
                    checkSaveReceiptNeeded()
                }
            }
        }
    }

    @IBAction func btnReload(sender: AnyObject) {
        sendGetReceiptRequest()
    }
    
    @IBAction func save(sender: AnyObject) {
        saveReceipt { (success) in
            if success {
                invokeConfirm("Receive Order", message: "Order has been received", okText: "Continue", cancelText: "", okHandler: self.dismissHandler, cancelHandler: nil, delegate: self)
            }
        }
    }
    func dismissHandler(action:UIAlertAction) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - Overrides
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !checkSaveReceiptNeeded() {
            reloadIfNeeded()
        }
        /*
        if allItemsReceived() {
            saveReceipt({ (success) in
                if success {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
        } else {
            tableView.reloadData()
        }
        */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.partNumberField.delegate = self

        sendGetReceiptRequest()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }
        
        if segueId == "segueScanReceiving" {
            let navController = segue.destinationViewController as! UINavigationController
            let destViewController = navController.childViewControllers[0] as! ScannerViewController
            destViewController.delegate = self
        }
        
        let showEdit: Bool = g_pluginSettings.getSetting(Constants.Options.receiveShowEditAlways)
        // Check to see if tracking info is required,
        // if so, then we must show edit.
        if showEdit {
            
        } else {
            
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
            case "segueReceiveItem":
                return false
            
            default:
                break
        }
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
   
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
            case partNumberField:
                btnReceive(self)
                break
            default:
                textField.resignFirstResponder()
                break
        }
        return true
    }

    // MARK: - Table Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receiptItems.getCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CustomReceivePartCell", forIndexPath: indexPath) as! ReceiveOrderPartCell
        if let item = receiptItems.getItemByIndex(indexPath.row) {
            cell.part.text = item.getFullName()
            cell.status.text = item.getItemStatusDescription()
            cell.location.text = "(unknown location)"
            let remainQuantity = Int(item.Quantity)
            if remainQuantity <= 0 {
                cell.userInteractionEnabled = false
                cell.backgroundColor = UIColor(red: 0xAB, green: 0x46, blue: 0x46)
            }
            cell.quantity.text = "\(remainQuantity) \(item.Part.UOM.Code)"
            guard let location: FbLocation = locationCache.getLocationById(item.SuggestedLocationID) else {
                return cell
            }
            cell.location.text = location.getFullName()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedReceiveItem = receiptItems.getItemByIndex(indexPath.row)
        if selectedReceiveItem != nil {
            partNumberField.text = selectedReceiveItem?.ItemNum
        }
        
        if moduleSettings.autoSelecteEnabled() {
            btnReceive(self)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }

    // MARK: - Helper functions
    private func checkSaveReceiptNeeded() -> Bool {
        if allItemsReceived() {
            saveReceipt({ (success) in
                if success {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
            return true
        }
        return false
    }
    
    private func reloadIfNeeded() {
        if needRefresh {
            tableView.reloadData()
            needRefresh = false
        }
    }
    
    private func updateCell(item: FbReceiveItem, index: Int) {
        if index >= 0 {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if item.Quantity <= 0 {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            } else {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! ReceiveOrderPartCell
                cell.quantity.text = "\(item.Quantity)"
            }
            
        }
    }

    private func allItemsReceived() -> Bool {
        return receiptItems.getCount() > 0 || receipt == nil ? false : true
    }
    
    private func setSelectedReceiveItem(itemNum: String) -> Bool {
        for item in receiptItems.ReceiveItem {
            if item.ItemNum == itemNum {
                selectedReceiveItem = item
                return true
            }
        }
        invokeAlertMessage("Invalid Part", msgBody: "Unable to find the specified part in this order", delegate: self)
        return false
    }
    
    private func getSegueIdentifier(fbPart: FbPart?) -> String {
        var vcIdentifier = "receivePartStandard"
        guard let part = fbPart else { return vcIdentifier }
        
        if part.TrackingFlag {
            vcIdentifier = "receivePartTracking"
            if part.SerializedFlag {
                vcIdentifier = "receivePartSerial"
            }
            vcIdentifier = "receivePartTrackingAll"
        }
        return vcIdentifier
    }
    
    private func shouldShowEdit() -> Bool {
        let showEdit = g_pluginSettings.getSetting(Constants.Options.receiveShowEditAlways)
        if showEdit {
            return true
        }
        // If the item is tracked, we always want to show the "edit" scene
        guard let item = selectedReceiveItem else { return false }
        return item.Part.hasTracking()
    }
    
    func prepAndPerformSegue(receiveItem: FbReceiveItem) {
        // Get part info from server (based on part number)...
        guard let item = selectedReceiveItem else { return }
        let partNum = item.ItemNum
        sendGetPartRequest(partNum) { (success) in
            if success {
                self.setNavigationBackItem(partNum)
                let storyboardId = self.getSegueIdentifier(self.validPart)
                switch storyboardId {
                case "receivePartTrackingAll":
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier(storyboardId) as! ReceivePartTrackAllTableViewController
                    vc.partNumber = partNum
                    vc.Item = item
                    vc.partNumber = partNum
                    //vc.assignedQuantity = self.saveItems.getTotalQuantity(item.ID, locationId: item.SuggestedLocationID)
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                    
                // Is there standard part tracking
                case "receivePartTracking":
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier(storyboardId) as! ReceivePartTrackTableViewController
                    vc.Item = item
                    vc.partNumber = partNum
                    vc.assignedQuantity = self.saveItems.getTotalQuantity(item.ID, locationId: item.SuggestedLocationID)
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                    
                // Is there serial number tracking?
                case "receivePartSerial":
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier(storyboardId) as! ReceivePartTrackSerialTableViewController
                    vc.partNumber = partNum
                    vc.Item = item
                    //vc.pickItem = pickItemList[indexPath.row]
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                    
                // Is there NO tracking?
                default: // "receivePartStandard"
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("receivePartStandard") as! ReceivePartTableViewController
                    vc.partNumber = partNum
                    vc.receiveItem = item
                    vc.delegate = self
                    vc.assignedQuantity = self.saveItems.getTotalQuantity(item.ID, locationId: item.SuggestedLocationID)
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                }
            }
        }
    }
    
    private func saveReceipt(handler: (Bool) -> Void ) {
        sendSaveReceiptRequest { (success) in
            if success {
                if let del = self.delegate {
                    del.orderSaved(nil) // notify delegate that order was saved
                }
            } else {
                invokeAlertMessage(self.errorTitle, msgBody: "An error occured while attempting to receive order", delegate: self)
            }
            handler(success)
        }
    }
    
    private func relocateReceiveItems(source: FbReceiptItems, dest: FbReceiptItems) {
        let status = Constants.ReceiptItemStatus.Entered
        for item in source.ReceiveItem {
            if item.ItemStatus == status {
                let newItem = item.copyWithZone(nil) as! FbReceiveItem
                dest.append(newItem)
                item.removeAllReceipts()
            }
        }
    }
    
    // MARK: - Server Requests
    private func sendSaveReceiptRequest(handler: (Bool) -> Void )
    {
        if let receipt = self.receipt {
            let fbMessageRequest = FbMessageRequest(
                key: g_apiKey,
                requestObj: FbiSaveReceiptRequest(receipt: receipt)
            )
            connectionFishbowl.connectAndSendRequest(fbMessageRequest) { (ticket, response) in
                handler(self.saveReceiptResponse(ticket, response: response))
            }
        }
    }
    
    func saveReceiptResponse(ticket: FbTicket, response: FbResponse) -> Bool
    {
        var errorMessage: String = ""
        var wasSuccessful = false
        if response.isValid(Constants.Response.saveReceipt) {
            let packStatus = response.getJson()["statusCode"].intValue
            if packStatus == 1000 {
                wasSuccessful = true
            } else {
                errorMessage = response.getJson()["statusMessage"].stringValue
            }
        } else {
            errorMessage = getFBStatusMessage(response.getStatus())
        }
        
        if !wasSuccessful {
            invokeAlertMessage(errorTitle, msgBody: errorMessage, delegate: self)
            resetOrder(receipt)
        }
        return wasSuccessful
    }

    private func sendGetReceiptRequest()
    {
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiReceiptRequest(orderNumber: fbTicket.OrderNumber, orderType: fbTicket.OrderType, locationGroup: fbTicket.LocationGroupID)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "") { (ticket, response) in
            self.getReceiptResponse(ticket, response: response)
        }
    }
    
    private func getReceiptResponse(ticket: FbTicket, response: FbResponse)
    {
        if response.isValid(Constants.Response.receipt) {
            let data = String(response.getJson()["Receipt"])
            receipt = Mapper<FbReceipt>().map(data)
            resetOrder(receipt)
        } else {
            invokeAlertMessage("Receiving Error", msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        }

    }
    
    private func resetOrder(currentReceipt: FbReceipt?) {
        if let curReceipt = currentReceipt {
            // Make a new receiptitems object... get all ReceiptItem objects
            // from 'receipt' and put in new list... as items are "received"
            // move them back into the 'receipt' object.
            receiptItems.removeAllItems()
            relocateReceiveItems(curReceipt.ReceiptItems, dest: receiptItems)
            tableView.reloadData()
        }
    }
    
    private func sendGetPartRequest(partNumber: String, completion: (Bool) -> Void )
    {
        // Get the part from the Receipt object
        if let receipt = self.receipt {
            if let part = receipt.getPart(partNumber) {
                validPart = part
                completion(true)
            }
        }
    }
    
}
