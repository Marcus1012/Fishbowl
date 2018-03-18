//
//  ReceivePartTrackTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 10/3/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import ObjectMapper


class ReceivePartTrackTableViewController: UITableViewController {

    class CustomPartSection {
        var name: String
        var cellCount: Int
        var cellIdent: String
        
        required init(name:String, count:Int, ident:String) {
            self.name = name
            self.cellCount = count
            self.cellIdent = ident
        }
    }

    
    private var errorTitle = "Receive Error"
    
    var partNumber: String = ""
    var Item: FbReceiveItem!
    var assignedQuantity: Int = 0
    var delegate: ReceiveOrderDelegate?
    var currentLocationField: LocationTextField? = nil
    
    private var customSections: [CustomPartSection] =
    [
        CustomPartSection(name: "Part",count: 1, ident:"ReceiveCellPart"),
        CustomPartSection(name: "Location",count: 1, ident:"ReceiveCellLocation"),
        CustomPartSection(name: "Quantity / Tracking",count: 1, ident:"ReceiveCellQuantity"),
    ]


    // Set when user selects them in the scene
    private var validLocation = FbLocation()
    private var validTracking     = [String]()
    private var validPart         = FbPart()
    private var validQuantity: Int = 0

    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        if let item = self.Item {
            validPart = item.Part
            updateSectionRowCounts()
            tableView.reloadData()
        } else {
            sendGetPartRequest()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }
        
        if segueId == "scan_some_location" && currentLocationField != nil {
            let navController = segue.destinationViewController as! UINavigationController
            let destViewController = navController.childViewControllers[0] as! ScannerViewController
            destViewController.delegate = currentLocationField
        } else if segueId == "choose_location" {
            let navController = segue.destinationViewController as! UINavigationController
            let destViewController = navController.childViewControllers[0] as! LocationTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! PickCellLocation
                setDelegateCallback(cell.locationField)
            }
            destViewController.delegate = currentLocationField

        }
    }
    
    func setDelegateCallback(field: LocationTextField) {
        currentLocationField = field
    }
    
    // MARK: - Actions
    @IBAction func save(sender: AnyObject) {
        if validFormInputs() {
            doReceivePartRequest()
        }
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row > 0 {
            return 55
        }
        return 44
    }
    
    // MARK: - Cell Creation Helper Functions
    private func partNumberCell(cellIdentity: String, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity) as! PickCellPart
        cell.partLabel.text = validPart.getFullName()
        return cell
    }
    
    private func locationCell(cellIdentity: String, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity) as! PickCellLocation
        cell.setDelegate = setDelegateCallback
        cell.setLocationCache(locationCache)
        if Item != nil {
            if let location: FbLocation = locationCache.getLocationById(Item.SuggestedLocationID) {
                let locName = location.getFullName()
                if locName.characters.count > 0 {
                    cell.setLocationText(locName)
                } else {
                    cell.disable()
                }
            }
        }
        return cell
    }
    
    private func quantityOrTrackCell(cellIdentity: String, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
            case 0: // First cell in this section lets us specify the quantity...
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity) as! PickCellQuantity
                if Item != nil {
                    cell.quantityField.text = "\(Item.Quantity)"
                    cell.uomLabel.text = Item.Part.UOM.Code
                }
                return cell
            default:
                if (validPart.SerializedFlag) {
                    // If we are serialized, we need a cell for each quantity....
                    // user will enter the serial number for each of the qty...
                    //
                    let cell = tableView.dequeueReusableCellWithIdentifier("ReceiveCellTracking") as! PickCellTracking
                    cell.setTextLabel("")
                    let partTracking: FbPartTracking = (validPart.PartTrackingList.PartTracking[indexPath.row - 1])
                    cell.setTypeLabel(partTracking.Abbr + ":")
                    cell.isDateType = partTracking.isDateType() // This is a Date tracking field
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("ReceiveCellTracking") as! PickCellTracking
                    cell.setTextLabel("")
                    let partTracking: FbPartTracking = (validPart.PartTrackingList.PartTracking[indexPath.row - 1])
                    cell.setTypeLabel(partTracking.Abbr + ":")
                    cell.isDateType = partTracking.isDateType() // This is a Date tracking field
                    return cell
                }
        }
    }
    
    // MARK: - Server Requests
    private func sendGetPartRequest()
    {
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiPartGetRequest(number: self.partNumber, getImage: false)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest) { (ticket, response) in
            self.GetPartResponse(ticket, response: response)
        }
    }
    
    // MARK: - Response Handlers
    private func GetPartResponse(ticket: FbTicket, response: FbResponse)
    {
        var errorMessage: String = ""
        var wasSuccessful = false
        if response.isValid(Constants.Response.partGet) {
            let partStatus = response.getJson()["statusCode"].intValue
            if partStatus == 1000 {
                wasSuccessful = true
                let data = String(response.getJson()["Part"])
                if let fbPart = Mapper<FbPart>().map(data) {
                    validPart = fbPart
                    if validPart.PartTrackingList.PartTracking.count <= 0 {
                        // try to decode a single part tracking object
                        let partData = String(response.getJson()["Part"]["PartTrackingList"]["PartTracking"])
                        if let partTracking = Mapper<FbPartTracking>().map(partData) {
                            validPart.PartTrackingList.PartTracking.append(partTracking)
                        }
                    }
                }
                updateSectionRowCounts()
                tableView.reloadData()
            } else {
                errorMessage = response.getJson()["statusMessage"].stringValue
            }
        } else {
            errorMessage = getFBStatusMessage(response.getStatus())
        }
        
        if !wasSuccessful {
            invokeAlertMessage(errorTitle, msgBody: errorMessage, delegate: self)
        }
    }

    // -----------------------
    // For the quantity/tracking section in the table, if we have tracking, then
    // there is one cell for the quantity and cells for each of the tracking
    // types...
    // -----------------------
     private func updateSectionRowCounts() {
        for section in customSections {
            if section.cellIdent == "ReceiveCellQuantity" {
                section.cellCount = 1 // default is 1 cell
                if validPart.TrackingFlag {
                    section.cellCount = 1 + validPart.getTrackingCount()
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func doReceivePartRequest() {
        // Save receive information to parent
        if let delegate = self.delegate {
            let receipt = FbReceivedReceipt()
            let id = Item.ID

            assignedQuantity += validQuantity
            let tracking = getValidTracking()
            
            receipt.ItemType = Constants.ReceiptItemStatus.Entered
            receipt.setLocationId(validLocation.LocationID)
            receipt.setQuantity(validQuantity)
            receipt.setTracking(tracking)
            delegate.saveReceivedItem(id, receivedReceipt: receipt)
        }
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    private func getValidTracking() -> FbTracking? {
        if validTracking.count > 0 {
            let tracking = FbTracking()
            for (index, trackingItem) in validTracking.enumerate() {
                let newItem = FbTrackingItem()
                newItem.setPartTracking(validPart.PartTrackingList.PartTracking[index])
                newItem.setTrackingValue(trackingItem)
                tracking.addTrackingItem(newItem)
            }
            return tracking
        }
        return nil
    }
    
    private func validFormInputs() -> Bool {
        // Validate Location
        var indexPath = NSIndexPath(forItem: 0, inSection: 1) // From Location
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PickCellLocation
        let (valid, fbLocation) = locationCache.validLocation(cell.locationField.stringValue);
        if !valid {
            invokeAlertMessage("Location Error", msgBody: "Location is invalid", delegate: self)
            return false
        }
        validLocation = fbLocation!
        
        // Validate quantity
        indexPath = NSIndexPath(forItem: 0, inSection: 2) // From Location
        let cellQuantity = tableView.cellForRowAtIndexPath(indexPath) as! PickCellQuantity
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
                let cellTracking = tableView.cellForRowAtIndexPath(indexPath) as! PickCellTracking
                let trackingValue = cellTracking.trackingField.stringValue
                if trackingValue.characters.count <= 0 {
                    invokeAlertMessage("Tracking Error", msgBody: "Tracking field is empty", delegate: self)
                    return false
                }
                validTracking.append(trackingValue)
                index += 1
            }
        }
        
        return true
    }
}
