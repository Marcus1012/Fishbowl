//
//  WorkOrderFinishTrackingTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 12/5/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit

class WorkOrderFinishTrackingTableViewController: UITableViewController {
    
    class TrackingAndValue {
        var value: String = ""
        var partTracking: FbPartTracking?
        init(value: String, partTracking: FbPartTracking?) {
            self.value = value
            self.partTracking = partTracking
        }

    }
    
    private var customSections: [CustomSection] =
        [
            CustomSection(name: "Finished Good",count: 1, ident:"WorkOrderCellPart"),
            CustomSection(name: "Location",count: 1, ident:"WorkOrderCellLocation"),
            CustomSection(name: "Quantity / Tracking",count: 1, ident:"WorkOrderCellQuantity"),
    ]

    private var workOrder: FbWorkOrder?
    private var validLocation = FbLocation()
    private var validQuantity: Int = 0
    private var validTracking = [TrackingAndValue]()
    private var validPart = FbPart()
    private var currentLocationField: LocationTextField? = nil

    var delegate: FbWorkOrderSavedDelegate?

    
    // MARK: - Actions
    @IBAction func btnSave(sender: AnyObject) {
        if validFormInputs() {
            doFinishWorkOrderRequest()
        }
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        //validPart = pickItem.Part
        updateSectionRowCounts()
        tableView.reloadData()

    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "choose_location" {
            let cell = sender as! WorkOrderCellLocation
            if cell.isLocked() {
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }
        
        if segueId == "scan_location" && currentLocationField != nil {
            let navController = segue.destinationViewController as! UINavigationController
            let destViewController = navController.childViewControllers[0] as! ScannerViewController
            destViewController.delegate = currentLocationField
        } else if segueId == "choose_location" {
            let navController = segue.destinationViewController as! UINavigationController
            let destViewController = navController.childViewControllers[0] as! LocationTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! WorkOrderCellLocation
                cell.setLocationCache(locationCache)
            }
            destViewController.delegate = currentLocationField
        }
    }
    
    func setDelegateCallback(field: LocationTextField) {
        currentLocationField = field
    }
    
    // MARK: - Table Handling
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return customSections.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return customSections[section].name
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customSections[section].cellCount
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row > 0 {
            return 55
        }
        return 44
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = customSections[indexPath.section]
        switch indexPath.section {
            case 0: // Part number display section
                return partNumberCell(section.cellIdent, tableView: tableView, indexPath: indexPath)
            case 1: // Location display section
                return locationCell(section.cellIdent, tableView: tableView, indexPath: indexPath)
            case 2: // Quantity / tracking display section
                return quantityOrTrackCell(section.cellIdent, tableView: tableView, indexPath: indexPath)
            default: // do nothing
                print("Unknown table cell type")
                break
        }
        
        return UITableViewCell()
    }

    private func partNumberCell(cellIdentity: String, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity) as! WorkOrderCellPart
        cell.partLabel.text = validPart.getFullName()
        return cell
    }

    private func locationCell(cellIdentity: String, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity) as! WorkOrderCellLocation
        cell.setDelegate = setDelegateCallback
        cell.setLocationCache(locationCache)
        return cell
    }

    private func quantityOrTrackCell(cellIdentity: String, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: // First cell in this section lets us specify the quantity...
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity) as! WorkOrderCellQuantity
            if let workOrder = self.workOrder {
                cell.quantityField.text = "\(workOrder.QtyOrdered)"
            }
            return cell
        default:
            if (validPart.SerializedFlag) {
                // If we are serialized, we need a cell for each quantity....
                // user will enter the serial number for each of the qty...
                //
                let cell = tableView.dequeueReusableCellWithIdentifier("WorkOrderCellTracking") as! WorkOrderCellTracking
                cell.setTextLabel("")
                let partTracking: FbPartTracking = (validPart.PartTrackingList.PartTracking[indexPath.row - 1])
                cell.setTypeLabel(partTracking.Abbr + ":")
                cell.setDateType(partTracking.isDateType())
                cell.setUserData(validPart.PartTrackingList.PartTracking[indexPath.row - 1])
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("WorkOrderCellTracking") as! WorkOrderCellTracking
                cell.setTextLabel("")
                let partTracking: FbPartTracking = (validPart.PartTrackingList.PartTracking[indexPath.row - 1])
                cell.setTypeLabel(partTracking.Abbr + ":")
                cell.setDateType(partTracking.isDateType())
                cell.setUserData(validPart.PartTrackingList.PartTracking[indexPath.row - 1])
                return cell
            }
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        print("accessory tapped!!!! section: \(indexPath.section), row: \(indexPath.row)")
    }
    
    // MARK: - Helper Functions
    func setWorkOrder(workOrder: FbWorkOrder?) {
        self.workOrder = workOrder
        if let wo = self.workOrder {
            if let item = wo.getFinishedGoodItem() {
                validPart = item.Part
            }
        }
    }
    
 
    // -----------------------
    // For the quantity/tracking section in the table, if we have tracking, then
    // there is one cell for the quantity and cells for each of the tracking
    // types...
    // -----------------------
    private func updateSectionRowCounts() {
        for section in customSections {
            if section.cellIdent == "WorkOrderCellQuantity" {
                section.cellCount = 1 // default is 1 cell
                if validPart.TrackingFlag {
                    section.cellCount = 1 + validPart.PartTrackingList.PartTracking.count
                }
            }
        }
    }
    
    private func validFormInputs() -> Bool {
        // Validate location
        var indexPath = NSIndexPath(forItem: 0, inSection: 1) // Location
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! WorkOrderCellLocation
        let (valid, fbLocation) = locationCache.validLocation(cell.locationField.stringValue);
        if !valid {
            invokeAlertMessage("Location Error", msgBody: "Location is invalid", delegate: self)
            return false
        }
        validLocation = fbLocation!
        
        // Validate quantity
        indexPath = NSIndexPath(forItem: 0, inSection: 2) // From Location
        let cellQuantity = tableView.cellForRowAtIndexPath(indexPath) as! WorkOrderCellQuantity
        if cellQuantity.quantityField.integerValue <= 0 {
            invokeAlertMessage("Quantity Error", msgBody: "Quantity is invalid", delegate: self)
            return false
        }
        validQuantity = cellQuantity.quantityField.integerValue
        
        // Validate Tracking Fields/Cells
        validTracking.removeAll()
        if customSections[2].cellCount > 1 {
            var index = 1
            while index < customSections[2].cellCount {
                indexPath = NSIndexPath(forItem: index, inSection: 2) // Tracking Cell
                let cellTracking = tableView.cellForRowAtIndexPath(indexPath) as! WorkOrderCellTracking
                let trackingValue = cellTracking.trackingField.stringValue
                if trackingValue.characters.count <= 0 {
                    invokeAlertMessage("Tracking Error", msgBody: "Tracking field is empty", delegate: self)
                    return false
                }
                let item = TrackingAndValue(value: trackingValue, partTracking: cellTracking.getUserData() as! FbPartTracking?)
                validTracking.append(item)
                index += 1
            }
        }
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
        
        // Set the tracking values
        if let finishedGoodItem = workOrderToSave.getFinishedGoodItem() {
            finishedGoodItem.QtyUsed = validQuantity
            if finishedGoodItem.Part.hasTracking() {
                for tracking in validTracking {
                    if let partTracking = tracking.partTracking {
                        let trackingItem = FbTrackingItem()
                        trackingItem.setPartTracking(partTracking)
                        trackingItem.setTrackingValue(tracking.value)
                        finishedGoodItem.addTracking(trackingItem)
                    }
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
