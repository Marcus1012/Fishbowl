//
//  WorkOrderFinishSerialTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 12/5/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit

class WorkOrderFinishSerialTableViewController: UITableViewController {
    
    // -----------------------------------------------------------------------------
    // MARK: Data source for product items table
    class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
        private var maxSerials: Int = 0
        private var selectedSerial: String = ""
        private var serialNumbers = [String]()
        var parent: WorkOrderFinishSerialTableViewController! = nil
       
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return serialNumbers.count
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let item = serialNumbers[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("SerialNumberCell")! as UITableViewCell
            cell.textLabel?.text = item
            return cell
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            //parent.unpackedItemSelected(items.ShippingItem[indexPath.row])
        }
        
        func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
            let delete = UITableViewRowAction(style: .Normal, title: "Remove") { (action, indexPath) in
                self.selectedSerial = self.serialNumbers[indexPath.row]
                if self.selectedSerial.characters.count > 0 {
                    self.deleteSerialNumber(tableView, indexPath: indexPath)
                }
            }
            return [delete]
            
        }
        
        func deleteSerialNumber(tableView: UITableView, indexPath: NSIndexPath) {
            let index = indexPath.row
            serialNumbers.removeAtIndex(index)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            parent.updateInfoLabel()
        }
        
        func removeItem(tableView: UITableView, serialNumber: String) {
            for (idx, item) in serialNumbers.enumerate() {
                if item == serialNumber {
                    serialNumbers.removeAtIndex(idx)
                    // delete cell from tableview...
                    let indexPath = NSIndexPath(forItem: idx, inSection: 0)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    break
                }
            }
        }
        
        func addSerialNumber(tableView: UITableView, number: String) {
            if serialNumbers.contains(number) {
                invokeAlertMessage("Serial Number Error", msgBody: "Duplicate serial number found", delegate: parent)
            } else if serialNumbers.count >= maxSerials {
                invokeAlertMessage("Serial Number Error", msgBody: "Maximum number of serial numbers reached", delegate: parent)
            } else {
                serialNumbers.append(number)
                // Update Table Data
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: serialNumbers.count-1, inSection: 0)], withRowAnimation: .Automatic)
                tableView.endUpdates()

            }
        }
        
        func getSerialNumberCount() -> Int {
            return serialNumbers.count
        }
        
        func getSerialNumbers() -> [String] {
            return serialNumbers
        }
        
        func setMaxSerialNumbers(count: Int) {
            maxSerials = count
        }
    }
    // -----------------------------------------------------------------------------

    
    private var part : FbPart?
    private var workOrder: FbWorkOrder?
    private var dataSource = DataSource()
    private var validLocation = FbLocation()
    private var validQuantity: Int  = 0
    private var validTracking = [String]()

    var delegate: FbWorkOrderSavedDelegate?

    @IBOutlet weak var finishedGoodLabel: UILabel!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var workOrderLocation: LocationTextField!
    @IBOutlet weak var tableViewItems: UITableView!
    @IBOutlet weak var serialNumberField: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBAction func quantityValueChanged(sender: AnyObject) {
        updateInfoLabel()
    }
    
    // MARK: - Actions
    @IBAction func btnAddSerial(sender: AnyObject) {
        let number = serialNumberField.stringValue
        if number.characters.count > 0 {
            dataSource.addSerialNumber(tableViewItems, number: number)
            updateInfoLabel()
            serialNumberField.becomeFirstResponder()
            serialNumberField.selectedTextRange = serialNumberField.textRangeFromPosition(serialNumberField.beginningOfDocument, toPosition: serialNumberField.endOfDocument)
            
        }
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        if validFormInputs() {
            doFinishWorkOrderRequest()
        }
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.parent = self
        tableViewItems.dataSource = dataSource
        tableViewItems.delegate = dataSource
        workOrderLocation.lookupDelegate = locationCache
        guard let part = self.part else { return }
        finishedGoodLabel.text = part.getFullName()
        guard let workOrder = self.workOrder else { return }
        quantityField.text = "\(workOrder.QtyTarget)"
        quantityField.addDismissButton()
        dataSource.setMaxSerialNumbers(workOrder.QtyTarget)
        updateInfoLabel()
    }
    
    /*
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }
        
        switch segueId {
        case "choose_location_serial_segue":
            let navController = segue.destinationViewController as! UINavigationController
            let destViewController = navController.childViewControllers[0] as! LocationTableViewController
            destViewController.delegate = self.workOrderLocation
            destViewController.setInitialSelection(self.workOrderLocation.locationId)
            break
            
        case "scan_location_serial_segue":
            let navController = segue.destinationViewController as! UINavigationController
            let destViewController = navController.childViewControllers[0] as! ScannerViewController
            destViewController.delegate = self.workOrderLocation
            break
            
        default:
            break
        }
        
    }
    
    // MARK: - Helper Functions
    func setWorkOrder(workOrder: FbWorkOrder?) {
        if workOrder != nil {
            self.workOrder = workOrder
            guard let item = workOrder!.getFinishedGoodItem() else { return }
            self.part = item.Part
        }
        
    }

    private func updateInfoLabel() {
        // Do any additional setup after loading the view.
        let maxSerials = quantityField.integerValue
        dataSource.setMaxSerialNumbers(maxSerials)
        let serialCount = dataSource.getSerialNumberCount()
        let remaining = maxSerials - serialCount
        infoLabel.text = "Added \(serialCount) of \(maxSerials) serial numbers, \(remaining) remaining"
    }
    
    private func validFormInputs() -> Bool {
        // Validate Location
        let (valid, fbLocation) = locationCache.validLocation(workOrderLocation.stringValue);
        if !valid {
            invokeAlertMessage("Location Error", msgBody: "Location is invalid", delegate: self)
            return false
        }
        validLocation = fbLocation!
        
        // Validate quantity
        if quantityField.integerValue <= 0 {
            invokeAlertMessage("Quantity Error", msgBody: "Quantity is invalid", delegate: self)
            return false
        }
        validQuantity = quantityField.integerValue
        
        // Validate Serial Tracking Fields/Cells
        validTracking.removeAll()
        if dataSource.getSerialNumberCount() < validQuantity {
            invokeAlertMessage("Tracking Error", msgBody: "To few seraial numbers specified", delegate: self)
            return false
        } else if dataSource.getSerialNumberCount() > validQuantity {
            invokeAlertMessage("Tracking Error", msgBody: "Too many seraial numbers specified", delegate: self)
            return false
        }
        validTracking = dataSource.getSerialNumbers()
        
        return true
    }
    
    private func doFinishWorkOrderRequest() {
        guard let workOrder = self.workOrder else { return }
        
        let workOrderToSave = workOrder.copyWithZone(nil) as! FbWorkOrder
        workOrderToSave.StatusID = Constants.WorkOrderStatus.Fulfilled
        if let item = workOrderToSave.getFinishedGoodItem() {
            item.setDestinationLocation(validLocation)
        }
        // Set the quantity
        workOrderToSave.QtyTarget = validQuantity
        
        // Set the serial numbers
        if let finishedGoodItem = workOrderToSave.getFinishedGoodItem() {
            if finishedGoodItem.Part.hasTracking() {
                finishedGoodItem.QtyUsed = validQuantity
                if let partTracking = finishedGoodItem.Part.PartTrackingList.getPartTrackingByType(Constants.TrackingType.SerialNumber) {
                    let trackingItem = FbTrackingItem()
                    trackingItem.setPartTracking(partTracking)
                    for serial in validTracking {
                        trackingItem.SerialBoxList.addSerialBoxWithNumber(serial, partTracking: partTracking)
                    }
                    finishedGoodItem.setTracking(trackingItem)
                }
            }
        }
        
        sendSaveWorkOrderRequest(workOrderToSave) { (success) in
            if success {
                if let del = self.delegate {
                    del.workOrderSaved(workOrderToSave)
                }
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    // MARK: - Server Requests
    private func sendSaveWorkOrderRequest(workOrder: FbWorkOrder, handler: (Bool) -> Void ) {
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiSaveWorkOrderRequest(workOrder: workOrder)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest) { (ticket, response) in
            handler(self.saveWorkOrderResponse(ticket, response: response))
        }
    }
    
    private func saveWorkOrderResponse(ticket: FbTicket, response: FbResponse) -> Bool
    {
        if response.isValid(Constants.Response.saveWorkOrder) {
            return true
        } else {
            invokeAlertMessage("Work Order Error", msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        }
        return false
    }
}
