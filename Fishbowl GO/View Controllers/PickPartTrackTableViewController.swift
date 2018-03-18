//
//  PickPartTrackTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 10/3/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import ObjectMapper


class CustomSection {
    var name: String
    var cellCount: Int
    var cellIdent: String
    
    required init(name:String, count:Int, ident:String) {
        self.name = name
        self.cellCount = count
        self.cellIdent = ident
    }
}


class PickPartTrackTableViewController: UITableViewController, UITextFieldDelegate {

    private var pick: FbPick?
    private var errorTitle = "Pick Error"
    private var fieldList = [UITextField]()
    
    var partNumber: String = ""
    var pickItem: FbPickItem!
    var part: FbPart!
    var delegate: PickOrderDelegate?

    
    var currentLocationField: LocationTextField? = nil
    
    private var customSections: [CustomSection] =
    [
        CustomSection(name: "Part",count: 1, ident:"PickCellPart"),
        CustomSection(name: "From Location",count: 1, ident:"PickCellLocation"),
        CustomSection(name: "Quantity / Tracking",count: 1, ident:"PickCellQuantity"),
        CustomSection(name: "To Location",count: 1, ident:"PickCellLocation")
    ]


    // Set when user selects them in the scene
    private var validFromLocation = FbLocation()
    private var validToLocation   = FbLocation()
    private var validTracking     = [String]()
    private var validPart         = FbPart()
    private var validQuantity: Int = 0

    func setPick(pick: FbPick) {
        self.pick = pick
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        fieldList.removeAll()
        if let pickItem = self.pickItem {
            validPart = pickItem.Part
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        for (index, field) in fieldList.enumerate() {
            if textField == field {
                if index < (fieldList.count - 1) {
                    fieldList[index+1].becomeFirstResponder()
                } else {
                    if validFormInputs() {
                        doSavePickPartRequest()
                    }
                }
                return true
            }
        }
        textField.resignFirstResponder() // close the keyboard on <return>
        return true
    }

    // MARK: - Actions
    @IBAction func btnSavePick(sender: AnyObject) {
        if validFormInputs() {
            doSavePickPartRequest()
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
            case 1: // From location display section
                return fromLocationCell(section.cellIdent, tableView: tableView, indexPath: indexPath)
            case 2: // Quantity / tracking display section
                return quantityOrTrackCell(section.cellIdent, tableView: tableView, indexPath: indexPath)
            case 3: // To location display section
                return toLocationCell(section.cellIdent, tableView: tableView, indexPath: indexPath)
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
    
    private func fromLocationCell(cellIdentity: String, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity) as! PickCellLocation
        cell.setDelegate = setDelegateCallback
        cell.setLocationCache(locationCache)
        cell.locationField.delegate = self
        if pickItem != nil {
            let fromLocName = pickItem.Location.getFullName()
            if fromLocName.characters.count > 0 {
                cell.setLocationText(fromLocName)
            } else {
                cell.disable()
            }
        }
        fieldList.append(cell.locationField)
        return cell
    }
    
    private func toLocationCell(cellIdentity: String, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity) as! PickCellLocation
        cell.setDelegate = setDelegateCallback
        cell.setLocationCache(locationCache)
        cell.locationField.delegate = self
        if pickItem != nil {
            let destLocation = pickItem.DestinationTag
            cell.locationField.text = destLocation.Tag.Location.getFullName()
        }
        fieldList.append(cell.locationField)
        return cell
    }
    
    private func quantityOrTrackCell(cellIdentity: String, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
            case 0: // First cell in this section lets us specify the quantity...
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentity) as! PickCellQuantity
                if pickItem != nil {
                    cell.quantityField.text = "\(pickItem.Quantity)"
                    cell.uomLabel.text = pickItem.UOM.Code
                }
                cell.quantityField.delegate = self
                fieldList.append(cell.quantityField)
                return cell
            default:
                if (validPart.SerializedFlag) {
                    // If we are serialized, we need a cell for each quantity....
                    // user will enter the serial number for each of the qty...
                    let cell = tableView.dequeueReusableCellWithIdentifier("PickCellTracking") as! PickCellTracking
                    cell.setTextLabel("")
                    let partTracking: FbPartTracking = (validPart.PartTrackingList.PartTracking[indexPath.row - 1])
                    cell.setTypeLabel(partTracking.Abbr + ":")
                    cell.isDateType = partTracking.isDateType() // This is a Date tracking field
                    cell.trackingField.delegate = self
                    populateAutoCommitTracking(pickItem, cell: cell, index: indexPath.row - 1)
                    fieldList.append(cell.trackingField)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("PickCellTracking") as! PickCellTracking
                    cell.setTextLabel("")
                    let partTracking: FbPartTracking = (validPart.PartTrackingList.PartTracking[indexPath.row - 1])
                    cell.setTypeLabel(partTracking.Abbr + ":")
                    cell.isDateType = partTracking.isDateType() // This is a Date tracking field
                    cell.trackingField.delegate = self
                    populateAutoCommitTracking(pickItem, cell: cell, index: indexPath.row - 1)
                    fieldList.append(cell.trackingField)
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
            if section.cellIdent == "PickCellQuantity" {
                section.cellCount = 1 // default is 1 cell
                if validPart.TrackingFlag {
                    section.cellCount = 1 + part.PartTrackingList.PartTracking.count
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func populateAutoCommitTracking(pickitem: FbPickItem?, cell: PickCellTracking, index: Int) {
        if let pickItem = pickItem {
            if let trackingItem = pickItem.Tracking.getNthNonSerialTracking(index) {
                if trackingItem.TrackingValue.characters.count > 0 {
                    cell.trackingField.text = trackingItem.TrackingValue
                    cell.trackingField.enabled = false // don't allow user input if has auto-committed tracking
                }
            }
        }
    }

    private func doSavePickPartRequest() {
        // Save pick information to parent
        if let delegate = self.delegate {
            if let curPickItem = self.pickItem {
                let pickItem = curPickItem.copyWithZone(nil) as! FbPickItem
                pickItem.Location = validFromLocation
                pickItem.DestinationTag.Tag.Location = validToLocation
                pickItem.Quantity = validQuantity
                pickItem.Part = validPart
                pickItem.Tracking.TrackingItem.removeAll()
                for (index, value) in validTracking.enumerate() {
                    let trackingItem = FbTrackingItem()
                    trackingItem.TrackingValue = value
                    trackingItem.PartTracking = pickItem.Part.PartTrackingList.PartTracking[index]
                    pickItem.Tracking.TrackingItem.append(trackingItem)
                }
                delegate.savePickItem(pickItem)
            }
        }
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    private func validFormInputs() -> Bool {
        // Validate From-Location
        var indexPath = NSIndexPath(forItem: 0, inSection: 1) // From Location
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! PickCellLocation
        var (valid, fbLocation) = locationCache.validLocation(cell.locationField.stringValue);
        if !valid {
            invokeAlertMessage("Location Error", msgBody: "From-location is invalid", delegate: self)
            return false
        }
        validFromLocation = fbLocation!
        
        // Validate To-Location
        indexPath = NSIndexPath(forItem: 0, inSection: 3) // To Location
        cell = tableView.cellForRowAtIndexPath(indexPath) as! PickCellLocation
        (valid, fbLocation) = locationCache.validLocation(cell.locationField.stringValue);
        if !valid {
            invokeAlertMessage("Location Error", msgBody: "To-location is invalid", delegate: self)
            return false
        }
        validToLocation = fbLocation!
        
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
                let trackingValue = cellTracking.getTrackingValue()
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
