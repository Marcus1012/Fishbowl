//
//  MoveInventoryTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 1/9/17.
//  Copyright © 2017 RPM Consulting. All rights reserved.
//

import UIKit
import ObjectMapper
import SVProgressHUD


class CycleInventoryTableViewController: UITableViewController, AddSerialNumberDelegate, SetLocationDelegate, SetQuantityDelegate, PartCellDelegate, UITextFieldDelegate {

    typealias PartHandlerCallback  = (String) -> Void
    typealias CustomCellFunction = (indexPath: NSIndexPath) -> UITableViewCell
    class sectionDataItem {
        var sectionTitle: String!
        //var rowCount: Int
        var rowCountFunc: () -> Int
        var cellFunc: CustomCellFunction!
        
        init(title: String, rowFunc: ()->Int, cellFunc: CustomCellFunction) {
            self.sectionTitle = title
            self.rowCountFunc = rowFunc
            self.cellFunc = cellFunc
            //self.rowCount = 0
        }
    }
    
    private let errorTitle = "Cycle Error"
    private let quantityTitle = "Quantity / Tracking"
    private let locationTitle = "Location"
    private let titleSerial   = "Serial Numbers"
    private let partTitle =  "Part"
    private var sectionData = [sectionDataItem]()
    private var currentField: ScannableTextField!
    private var serials = [String]()
    private var tracking = [String]()
    private var tableSections = 0
    private var partNumber: String = ""

    private var serialNumbersNeeded:Int = 0
    private var validPart: FbPart! {
        didSet {
            tableSections = calculateTableSections()
        }
    }
    private var validLocation: FbLocation?
    private var validQuantity: UInt = 0

    
    // MARK: - Actions
    @IBAction func btnCycle(sender: AnyObject) {
        validFormInputs { (valid) in
            if valid {
                self.doCycleRequest(self.validPart)
            }
        }
    }
    
    // MARK: - Server Requests
    func doCycleRequest(part: FbPart) {

        let cycleRequest = FbiCycleCountRequest(partNumber: validPart.Num, locationId: (validLocation?.LocationID)!, quantity: validQuantity)
        if hasSerialTracking() {
            cycleRequest.addSerialTracking(part, trackingValues: serials)
        }
        
        if hasTracking() {
            cycleRequest.addTracking(part, trackingValues: tracking)
        }

        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: cycleRequest
        )
        
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "Request processed") { (ticket, response) in
            let isValid = self.ValidateCycleResponse(ticket, response: response)
            if isValid {
                self.resetFormInputs()
            }
        }
    }
    
    private func ValidateCycleResponse(ticket: FbTicket, response: FbResponse) -> Bool
    {
        if response.isValid(Constants.Response.cycleCount) {
            let partStatus = response.getJson()["statusCode"].intValue
            if partStatus != 1000 {
                let statusMessage = response.getJson()["statusMessage"].stringValue
                invokeAlertMessage(errorTitle, msgBody: statusMessage, delegate: self)
                return false
            }
            return true
        }
        invokeAlertMessage(errorTitle, msgBody: "Invalid server response", delegate: self)
        return false
    }
    
    // -----------------------
    // For the quantity/tracking section in the table, if we have tracking, then
    // there is one cell for the quantity and cells for each of the tracking
    // types...
    // -----------------------
    private func quantitySectionRowCount() -> Int {
        var count: Int = 1
        if validPart.TrackingFlag {
            count += validPart.getNonSerialTrackingCount()
        }
        return count
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "ScannablePartCell", bundle: nil), forCellReuseIdentifier: "ScannablePartCell")
        tableView.registerNib(UINib(nibName: "ScannableLocationCell", bundle: nil), forCellReuseIdentifier: "ScannableLocationCell")
        tableView.registerNib(UINib(nibName: "QuantityCell", bundle: nil), forCellReuseIdentifier: "QuantityCell")
        tableView.registerNib(UINib(nibName: "SerialNumberAdderCell", bundle: nil), forCellReuseIdentifier: "SerialNumberAdderCell")
        tableView.registerNib(UINib(nibName: "TrackingCell", bundle: nil), forCellReuseIdentifier: "TrackingCell")

        sectionData.removeAll() // remove any entries if previously initialized.
        sectionData.append(sectionDataItem(title: locationTitle, rowFunc: singleRow,               cellFunc: locationCell))
        sectionData.append(sectionDataItem(title: partTitle,     rowFunc: singleRow,               cellFunc: partCell))
        sectionData.append(sectionDataItem(title: quantityTitle, rowFunc: quantitySectionRowCount, cellFunc: quantityCell))
        sectionData.append(sectionDataItem(title: titleSerial,   rowFunc: serialSectionRowCount,   cellFunc: serialCell))
        
        validPart = FbPart()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sectionData.count {
            return sectionData[section].rowCountFunc()
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < sectionData.count {
            return sectionData[section].sectionTitle
        }
        return ""
    }

    private func getTrackingRowCount() -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section < sectionData.count {
            let cell = sectionData[indexPath.section].cellFunc(indexPath: indexPath)
            // sectionData[indexPath.section].rowCount += 1
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if hasSerialTracking() {
            let section = getSectionNumber(titleSerial)
            if indexPath.section == section && indexPath.row == 0 {
                return 70
            }
        }
        
        if hasTracking() {
            let section = getSectionNumber(quantityTitle)
            if indexPath.section == section && indexPath.row > 0 {
                return 50
            }
        }
        return 44
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row > 0 && getSectionNumber(titleSerial) == indexPath.section && hasSerialTracking() {
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Normal, title: "Remove") { (action, indexPath) in
            let index = indexPath.row - 1 // First cell is a SerialAdder
            let selectedSerial = self.serials[index]
            if selectedSerial.characters.count > 0 && indexPath.section != -1 {
                self.serials.removeAtIndex(index)
                //self.sectionData[indexPath.section].rowCount -= 1
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                self.updateSerialTrackingCells(self.serials.count, total: self.serialNumbersNeeded)
            }
        }
        delete.backgroundColor = UIColor.redColor()
        return [delete]
    }
    

    private func deleteSerialNumber(indexPath: NSIndexPath) {
        let index = indexPath.row - 2 // first two cells are a Quantity and SerialAdder
        serials.removeAtIndex(index)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        updateSerialTrackingCells(serials.count, total: serialNumbersNeeded)
    }
    
    private func locationCell(indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = NSBundle.mainBundle().loadNibNamed("ScannableLocationCell", owner: self, options: nil)?.first as! ScannableLocationCell
        let cell = tableView.dequeueReusableCellWithIdentifier("ScannableLocationCell", forIndexPath: indexPath) as! ScannableLocationCell

        cell.setDelegate(Constants.Field.Location, delegate: self)
        cell.setLocationCache(locationCache)
        if let location = validLocation {
            cell.setValue(location.getFullName())
            cell.setLock(location.getLock())
        }
        return cell
    }
    
    private func partCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScannablePartCell", forIndexPath: indexPath) as! ScannablePartCell

        cell.setDelegate(self)
        cell.setValue(partNumber)
        cell.setLock(validPart.getLocked())
        return cell
    }
    
    // Creates the cells in the Quantity section (serial & tracking cells too)
    private func quantityCell(indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        if indexPath.row > 0  && hasTracking() {
            cell = trackingCell(indexPath)
        }
        
        if cell == nil {
            let qtyCell = tableView.dequeueReusableCellWithIdentifier("QuantityCell", forIndexPath: indexPath) as! QuantityCell
            qtyCell.setDelegate(self)
            qtyCell.setValue(serialNumbersNeeded)
            cell = qtyCell
        }
        return cell!
    }
    
    // Creates the cells in the serial number section)
    private func serialCell(indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        if indexPath.row > 0 && hasSerialTracking() {
            // serial numbers are just displayed in a generic table view cell
            cell = UITableViewCell()
            cell?.textLabel?.text = serials[indexPath.row - 1]
        }
        
        if cell == nil { // creat the "adder" cell
            cell = serialAdderCell(indexPath)
        }
        
        return cell!
    }

    private func serialAdderCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SerialNumberAdderCell", forIndexPath: indexPath) as! SerialNumberAdderCell
        cell.setDelegate(self)
        cell.setSerailDelegate(self)
        return cell
    }
    
    private func trackingCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackingCell", forIndexPath: indexPath) as! TrackingCell
        cell.setDelegate(self)
        let trackingIndex = indexPath.row - 1
        if trackingIndex >= 0 {
            cell.setTrackInfo(validPart.PartTrackingList.getNthNonSerialTracking(trackingIndex))
        }
        return cell
    }
    
    private func calculateTableSections() -> Int {
        var excludeSections: Int = 1
        if hasSerialTracking() {
            excludeSections = 0
        }
        return sectionData.count - excludeSections
    }

    private func singleRow() -> Int {
        return 1
    }
    
    private func serialSectionRowCount() -> Int {
        return (1 + serials.count)
    }


    private func updatePartCell(partNum: String) {
        if let cell: ScannablePartCell = getDefaultCell() {
            cell.setValue(partNum)
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }
        switch segueId {
            case "segue_settings":
                // do nothing
                break
            default:
                let navController = segue.destinationViewController as! UINavigationController
                let destViewController = navController.childViewControllers[0] as! ScannerViewController
                destViewController.delegate = currentField
                break
        }
    }

    private func setQuantityFocus() {
        if let cell: QuantityCell = getDefaultCell() {
            cell.setAsFirstResponder()
        }
    }
    
    private func setPartFocus() {
        if let cell: ScannablePartCell = getDefaultCell() {
            cell.setAsFirstResponder()
        }
    }
    
    // MARK: - Delegate Methods
    func setPart(partNumber: String) {
        if !isSamePart(partNumber) {
            clearTrackingCells()
            self.partNumber = partNumber
            getPart(partNumber, completion: {
                self.setQuantityFocus()
            })
        }
    }
    
    func togglePartLock(isLocked: Bool) {
        validPart.setLocked(isLocked)
    }
    
    func setQuantity(quantity: Int) {
        serialNumbersNeeded = quantity
        updateSerialTrackingCells(serials.count, total: serialNumbersNeeded)
    }
    
    func setLocation(context: Int, fbLocation: FbLocation?) {
        switch context {
            case Constants.Field.Location:
                validLocation = fbLocation
                break
            default:
                break
        }
    }
    
    func addSerialNumber(serialNumber: String) -> (num:Int, total:Int) {
        // Add the serial number... check for duplicates
        // and also check to see if we still need serials
        if serials.count < serialNumbersNeeded {
            
            if !serials.contains({$0.caseInsensitiveCompare(serialNumber) == .OrderedSame}) {
                serials.append(serialNumber)
                let section = getSectionNumber(titleSerial)
                if section != -1 {
                    //sectionData[section].rowCount += 1
                    tableView.beginUpdates()
                    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: serials.count, inSection: section)], withRowAnimation: .Automatic)
                    tableView.endUpdates()
                }
            } else {
                SVProgressHUD.showErrorWithStatus("Duplicate serial number")
            }
        } else {
            SVProgressHUD.showErrorWithStatus("No more serial numbers needed")
        }
        return (serials.count, serialNumbersNeeded)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func updateSerialTrackingCells(num: Int, total: Int) {
        if let cell: SerialNumberAdderCell = getDefaultCell() {
            cell.updateStatusLabel(num, total: total)
        }
    }
    
    // Is the part number entered in the text field the same as the current part we already have?
    // Case-insensative compare.
    private func isSamePart(partNum: String) -> Bool {
        if validPart.Num.caseInsensitiveCompare(partNum) == NSComparisonResult.OrderedSame {
            return true
        }
        return false
    }
    
    // MARK: - Helper Methods
    private func getPart(partNum: String, completion: ()->Void) {
        if partNum.characters.count > 0 {
            getPartFromServer(partNum, handler: { (num) in
                self.partNumber = num
                self.serials.removeAll()
                self.tracking.removeAll()
                self.tableView.reloadData()
                completion()
            })
        }
    }

    private func getPartFromServer(part:String, handler: PartHandlerCallback) {
        //validPart = FbPart()
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiPartGetRequest(number: part, getImage: false)
        )
        
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "") { (ticket, response) in
            let (isValid, fbPart) = self.ValidatePartResponse(ticket, response: response)
            if !isValid {
                SVProgressHUD.showErrorWithStatus("Part not found")
                handler("")
            }
            if let part = fbPart {
                self.validPart = part
                handler(part.Num)
            }
        }
    }

    private func ValidatePartResponse(ticket: FbTicket, response: FbResponse) -> (Bool, FbPart?)
    {
        if response.isValid(Constants.Response.partGet) {
            // check the "sub" status... status on the actual PartGetRs object...
            var status = response.getJson()[Constants.Property.statusCode].intValue
            if status == 1000 {
                let data = String(response.getJson()["Part"])
                if let part = Mapper<FbPart>().map(data) {
                    return (true, part)
                }
                status = 1012 // Set to general error
            }
        }
        return (false, nil)
    }

    private func getSectionNumber(name: String) -> Int {
        for (index, section) in sectionData.enumerate() {
            if section.sectionTitle.caseInsensitiveCompare(name) == NSComparisonResult.OrderedSame {
                return index
            }
        }
        return -1
    }
    
    private func getSectionCell(sectionTitle: String, row: Int) -> UITableViewCell? {
        var cell: UITableViewCell? = nil
        let section = getSectionNumber(sectionTitle)
        if section != -1 {
            cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section))
        }
        return cell
    }

    private func getDefaultCell() -> ScannablePartCell? {
        let cell = getSectionCell(partTitle, row: 0)
        if cell != nil {
            if cell! .isKindOfClass(ScannablePartCell) {
                return cell as? ScannablePartCell
            }
        }
        return nil
    }
    
    private func getDefaultCell() -> ScannableLocationCell? {
        let cell = getSectionCell(locationTitle, row: 0)
        if cell != nil {
            if cell! .isKindOfClass(ScannableLocationCell) {
                return cell as? ScannableLocationCell
            }
        }
        return nil
    }
    
    private func getDefaultCell() -> QuantityCell? {
        let cell = getSectionCell(quantityTitle, row: 0)
        if cell != nil {
            if cell! .isKindOfClass(QuantityCell) {
                return cell as? QuantityCell
            }
        }
        return nil
    }
    
    private func getDefaultCell() -> SerialNumberAdderCell? {
        let cell = getSectionCell(titleSerial, row: 0)
        if cell != nil {
            if cell! .isKindOfClass(SerialNumberAdderCell) {
                return cell as? SerialNumberAdderCell
            }
        }
        return nil
    }
    
    private func validateLocation() -> (Bool, FbLocation?) {
        if let cell: ScannableLocationCell = getDefaultCell() {
            let (valid, fbLocation) = locationCache.validLocation(cell.getLocation())
            if valid  && (fbLocation != nil) {
                let newLocation = fbLocation!.getFullName()
                cell.setValue(newLocation)
                return (valid, fbLocation)
            } else {
                invokeAlertMessage("Location Error", msgBody: "\(locationTitle) is invalid", delegate: self)
            }
            
        } else {
            invokeAlertMessage("Location Error", msgBody: "\(locationTitle) is invalid", delegate: self)
        }
        return (false, nil)
    }
    
    private func validateQuantity() -> (Bool, UInt) {
        if let cell: QuantityCell = getDefaultCell() {
            let quantity = cell.getQuantity()
            if quantity > 0 {
                return (true, quantity)
            }
        }
        invokeAlertMessage("Quantity Error", msgBody: "Quantity is invalid", delegate: self)
        return (false, 0)
    }
    
    private func validFormInputs(handler: (Bool)->Void) {
        var valid = false
        
        (valid, validLocation) = validateLocation()
        if !valid {
            handler(false)
            return
        }
        
        validatePart(partTitle) { (partNum) in
            (valid, self.validQuantity) = self.validateQuantity()
            if !valid {
                handler(false)
                return
            }

            if self.hasSerialTracking() { // validate serial number tracking values
                if !self.validateSerialTracking(self.validQuantity) {
                    invokeAlertMessage("Tracking Error", msgBody: "Incorrect number of serial numbers", delegate: self)
                    handler(false)
                    return
                }
            }
            
            if self.hasTracking() { // validate the tracking values
                if !self.validateTracking() {
                    invokeAlertMessage("Tracking Error", msgBody: "Tracking values are invalid", delegate: self)
                    handler(false)
                    return
                }
            }
            handler(true)
        }
    }
    
    private func validateTracking() -> Bool {
        var trackingRow = 1
        tracking.removeAll()
        while let cell = getSectionCell(quantityTitle, row: trackingRow) {
            let trackCell = cell as! TrackingCell
            let value = trackCell.getValue()
            if value.characters.count > 0 {
                tracking.append(value)
            }
            trackingRow += 1
        }

        if tracking.count == validPart.getNonSerialTrackingCount() {
            return true
        }
        return false
    }
    
    private func validateSerialTracking(quantity: UInt) -> Bool {
        if UInt(serials.count) != quantity {
            return false
        }
        return true
    }
    
    private func validatePart(sectionTitle: String, handler: (String)->Void) {
        if let cell: ScannablePartCell = getDefaultCell() {
            if !validPart.matchesPartNumber(cell.part.stringValue, checkForUpcMatch: true) {
                if partNumber.characters.count > 0 {
                    getPartFromServer(partNumber, handler: { (partNum) in
                        self.partNumber = partNum
                        handler(partNum)
                    })
                }
            } else {
                handler(validPart.Num)
            }
        }
    }
    
    private func resetFormInputs() {
        var partLocked = false
        
        if let locationCell: ScannableLocationCell = getDefaultCell() {
            if !locationCell.isLocked() {
                validLocation = nil
                locationCell.reset()
            }
        }

        if let cell: ScannablePartCell = getDefaultCell() {
            partLocked = cell.isLocked()
            if !cell.isLocked() {
                validPart = FbPart()
                partNumber = ""
                cell.reset()
            }
        }

        if let cell: QuantityCell = getDefaultCell() {
            validQuantity = 0
            serialNumbersNeeded = 0
            cell.reset()
        }

        clearTrackingCells()
        tracking.removeAll()
        serials.removeAll()
        tableView.reloadData()
        if partLocked {
            setQuantityFocus()
        } else {
            setPartFocus()
        }
    }
    
    private func clearTrackingCells() {
        var trackingRow = 1
        while let cell = getSectionCell(quantityTitle, row: trackingRow) {
            if cell .isKindOfClass(TrackingCell) {
                let trackCell = cell as! TrackingCell
                trackCell.reset()
                trackingRow += 1
            }
        }
    }
    
    private func hasSerialTracking() -> Bool {
        return validPart.hasSerialTracking()
    }
    
    private func hasTracking() -> Bool { // other tracking (non-serialized)
        return validPart.hasTracking()
    }

}
