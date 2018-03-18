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


class MoveInventoryTableViewController: UITableViewController, AddSerialNumberDelegate, SetLocationDelegate, SetQuantityDelegate, PartCellDelegate, UITextFieldDelegate {

    typealias PartHandlerCallback  = (String) -> Void
    typealias CustomCellFunction = (indexPath: NSIndexPath) -> UITableViewCell
    struct sectionDataItem {
        var sectionTitle: String!
        var rowCount: Int
        var cellFunc: CustomCellFunction!
    }

    private let quantityTitle = "Quantity"
    private let fromTitle = "From Location"
    private let toTitle = "To Location"
    private let partTitle =  "Part"
    private var sectionData = [sectionDataItem]()
    private var currentField: ScannableTextField!
    private var serials = [String]()
    private var tracking = [String]()
    private var partNumber: String = ""

    private var serialNumbersNeeded:Int = 0
    private var validPart: FbPart?
    private var validFromLocation: FbLocation?
    private var validToLocation: FbLocation?
    private var validQuantity: UInt = 0

    
    // MARK: - Actions
    @IBAction func btnSave(sender: AnyObject) {
        validFormInputs { (valid) in
            if valid {
                self.doMoveRequest()
            }
        }
    }
    
    // MARK: - Server Requests
    func doMoveRequest() {
        let moveRequest = FbiMoveRequest(part: validPart!, source: validFromLocation!, destination: validToLocation!, quantity: validQuantity)
        if hasSerialTracking() {
            moveRequest.addSerialTracking(serials)
        } else if hasTracking() {
            moveRequest.addTracking(tracking)
        }
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: moveRequest
        )
        
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "Request processed") { (ticket, response) in
            let isValid = self.ValidateMoveResponse(ticket, response: response)
            if isValid {
                self.resetFormInputs()
            }
        }
        
        
    }
    
    private func ValidateMoveResponse(ticket: FbTicket, response: FbResponse) -> Bool
    {
        let msgTitle = "Move Error"
        if response.isValid(Constants.Response.move) {
            let partStatus = response.getJson()["statusCode"].intValue
            if partStatus != 1000 {
                let statusMessage = response.getJson()["statusMessage"].stringValue
                invokeAlertMessage(msgTitle, msgBody: statusMessage, delegate: self)
                return false
            }
            return true
        }
        invokeAlertMessage(msgTitle, msgBody: "Invalid server response", delegate: self)
        return false
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionData = [
            sectionDataItem(sectionTitle: fromTitle, rowCount: 1, cellFunc: fromLocationCell),
            sectionDataItem(sectionTitle: partTitle, rowCount: 1, cellFunc: partCell),
            sectionDataItem(sectionTitle: quantityTitle, rowCount: 1, cellFunc: quantityCell),
            sectionDataItem(sectionTitle: toTitle, rowCount: 1, cellFunc: toLocationCell),
        ]
        
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
        return sectionData.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sectionData.count {
            return sectionData[section].rowCount
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
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if hasSerialTracking() {
            let section = getSectionNumber(quantityTitle)
            if indexPath.section == section && indexPath.row == 1 {
                return 70
            }
        } else if hasTracking() {
            let section = getSectionNumber(quantityTitle)
            if indexPath.section == section && indexPath.row > 0 {
                return 50
            }
        }
        return 44
    }
    
    // only allow swipt to delete in the serial number cells
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row > 1 && getSectionNumber(quantityTitle) == indexPath.section && hasSerialTracking() {
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Normal, title: "Remove") { (action, indexPath) in
            let index = indexPath.row - 2 // first two cells are a Quantity and SerialAdder
            let selectedSerial = self.serials[index]
            let section = self.getSectionNumber(self.quantityTitle)
            if selectedSerial.characters.count > 0 && section != -1 {
                self.serials.removeAtIndex(index)
                self.sectionData[section].rowCount -= 1
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                self.updateSerialTrackingCells(self.serials.count, total: self.serialNumbersNeeded)
            }
        }
        return [delete]
    }
    

    private func deleteSerialNumber(indexPath: NSIndexPath) {
        let index = indexPath.row - 2 // first two cells are a Quantity and SerialAdder
        serials.removeAtIndex(index)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        updateSerialTrackingCells(serials.count, total: serialNumbersNeeded)
    }
    
    private func fromLocationCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = NSBundle.mainBundle().loadNibNamed("ScannableLocationCell", owner: self, options: nil)?.first as! ScannableLocationCell
        cell.setDelegate(Constants.Field.FromLocation, delegate: self)
        cell.setLocationCache(locationCache)
        if let location = validFromLocation {
            cell.setValue(location.getFullName())
            cell.setLock(location.getLock())
        }
        return cell
    }
    
    private func toLocationCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = NSBundle.mainBundle().loadNibNamed("ScannableLocationCell", owner: self, options: nil)?.first as! ScannableLocationCell
        cell.setDelegate(Constants.Field.ToLocation, delegate: self)
        cell.setLocationCache(locationCache)
        if let location = validToLocation {
            cell.setValue(location.getFullName())
            cell.setLock(location.getLock())
        }
        return cell
    }
    
    private func partCell(indexPath: NSIndexPath) -> UITableViewCell {
        print("loading PART location cell nib")
        let cell = NSBundle.mainBundle().loadNibNamed("ScannablePartCell", owner: self, options: nil)?.first as! ScannablePartCell
        cell.setDelegate(self)
        cell.setValue(partNumber)
        if let part = validPart {
            cell.setLock(part.getLocked())
        }
        return cell
    }
    
    // Creates the cells in the Quantity section (serial & tracking cells too)
    private func quantityCell(indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        if hasSerialTracking() {
            if indexPath.row == 1 {
                cell = serialAdderCell()
            } else if indexPath.row > 1 {
                // serial numbers are just displayed in a generic table view cell
                cell = UITableViewCell()
                cell?.textLabel?.text = serials[indexPath.row - 2]
            }
        } else if hasTracking() {
            cell = trackingCell(indexPath.row - 1)
        }
        
        if cell == nil {
            let qtyCell = NSBundle.mainBundle().loadNibNamed("QuantityCell", owner: self, options: nil)?.first as! QuantityCell
            qtyCell.setDelegate(self)
            qtyCell.setValue(serialNumbersNeeded)
            cell = qtyCell
        }
        return cell!
    }
    
    private func serialAdderCell() -> UITableViewCell {
        let cell = NSBundle.mainBundle().loadNibNamed("SerialNumberAdderCell", owner: self, options: nil)?.first as! SerialNumberAdderCell
        cell.setDelegate(self)
        cell.setSerailDelegate(self)
        return cell
    }
    
    private func trackingCell(index: Int) -> UITableViewCell {
        let cell = NSBundle.mainBundle().loadNibNamed("TrackingCell", owner: self, options: nil)?.first as! TrackingCell
        cell.setDelegate(self)
        if let part = validPart {
            if let primaryPartTracking = part.PartTrackingList.getPrimaryTracking() {
                cell.setTrackInfo(primaryPartTracking)
            } else {
                cell.setTrackInfo(part.PartTrackingList.PartTracking[index])
            }
        }
        
        return cell
    }

    private func updatePartCell(partNum: String) {
        if let cell = getDefaultCell(partTitle) {
            let partCell = cell as! ScannablePartCell
            partCell.setValue(partNum)
        }
    }
    
    private func updateTableCells() {
        guard let part = validPart else { return }
        updatePartCell(partNumber)
        removeTrackingCells()
        serials.removeAll()
        tracking.removeAll()
        if hasSerialTracking() {
            addSerialTrackingCells()
        } else if hasTracking() {
            addRegularTrackingCells(part)
        }
    }
    
    private func addSerialTrackingCells() {
        let section = getSectionNumber(quantityTitle)
        if section != -1 {
            // First, setup the "adder" cell
            sectionData[section].rowCount += 1
            tableView.beginUpdates()
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: section)], withRowAnimation: .Automatic)
            tableView.endUpdates()
        }
    }
    
    private func addRegularTrackingCells(part: FbPart) {
        // add the regular tracking cells to the "quantity" section
        let section = getSectionNumber(quantityTitle)
        if section != -1 {
            tableView.beginUpdates()
            if part.PartTrackingList.getPrimaryTracking() != nil {
                sectionData[section].rowCount += 1
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: section)], withRowAnimation: .Automatic)
            } else {
                for (index, _) in part.PartTrackingList.PartTracking.enumerate() {
                    sectionData[section].rowCount += 1
                    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: index + 1, inSection: section)], withRowAnimation: .Automatic)
                }
            }
            tableView.endUpdates()
        }
    }
    
    private func removeTrackingCells() {
        let section = getSectionNumber(quantityTitle)
        if section != -1 {
            while sectionData[section].rowCount > 1 {
                sectionData[section].rowCount -= 1
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: section)], withRowAnimation: .Automatic)
            }
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }
        print("Prepare for segue: \(segueId)")
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
        if let cell = getDefaultCell(quantityTitle) {
            let quantityCell = cell as! QuantityCell
            quantityCell.setAsFirstResponder()
        }
    }
    
    // MARK: - Delegate Methods
    func setPart(partNumber: String) {
        if !isSamePart(partNumber) {
            self.partNumber = partNumber
            getPart(partNumber)
        }
        setQuantityFocus()
    }

    func togglePartLock(isLocked: Bool) {
        if let part = validPart {
            part.setLocked(isLocked)
        }
    }
    
    func setQuantity(quantity: Int) {
        var qty: UInt = 0
        
        qty = (quantity < 0) ? 0 : UInt(quantity)
        validQuantity = qty
        serialNumbersNeeded = Int(qty)
        updateSerialTrackingCells(serials.count, total: serialNumbersNeeded)
    }
    
    func setLocation(context: Int, fbLocation: FbLocation?) {
        switch context {
            case Constants.Field.FromLocation:
                validFromLocation = fbLocation
                break
            case Constants.Field.ToLocation:
                validToLocation = fbLocation
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
                let section = getSectionNumber(quantityTitle)
                if section != -1 {
                    sectionData[section].rowCount += 1
                    tableView.beginUpdates()
                    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: serials.count + 1, inSection: section)], withRowAnimation: .Automatic)
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

    /*
    func textFieldDidEndEditing(textField: UITextField) {
        if quantityTextField == textField {
            serialNumbersNeeded = (quantityTextField?.integerValue)!
            quantityTextField?.text = "\(serialNumbersNeeded)"
            updateSerialTrackingCells(serials.count, total: serialNumbersNeeded)
        }
    }
    */

    private func updateSerialTrackingCells(num: Int, total: Int) {
        if let cell = getSectionCell(quantityTitle, row: 1) {
            if cell is SerialNumberAdderCell {
                let serialAdder = cell as! SerialNumberAdderCell
                serialAdder.updateStatusLabel(num, total: total)
            }
        }
    }
    
    // Is the part number entered in the text field the same as the current part we already have?
    // Case-insensative compare.
    private func isSamePart(partNum: String) -> Bool {
        if let part = validPart {
            if part.Num.caseInsensitiveCompare(partNum) == NSComparisonResult.OrderedSame {
                return true
            }
        }
        return false
    }
    
    // MARK: - Helper Methods
    private func getPart(partNum: String) {
        if partNum.characters.count > 0 {
            getPartFromServer(partNum, handler: { (num) in
                self.partNumber = num
                self.updateTableCells()
            })
        }
    }

    private func getPartFromServer(part:String, handler: PartHandlerCallback) {
        validPart = nil
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
                self.validPart = fbPart
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
    
    private func getDefaultCell(sectionTitle: String) -> UITableViewCell? {
        return getSectionCell(sectionTitle, row: 0)
    }
    
    private func validateLocation(sectionTitle: String, location: FbLocation?) -> Bool {
        if location != nil {
            return true
        } else {
            invokeAlertMessage("Location Error", msgBody: "\(sectionTitle) is invalid", delegate: self)
        }
        return false
    }
    
    private func validateQuantity(sectionTitle: String) -> Bool{
        if validQuantity > 0 {
            return true
        }
        invokeAlertMessage("Quantity Error", msgBody: "Quantity is invalid", delegate: self)
        return false
    }
    
    private func validFormInputs(handler: (Bool) -> Void ) {
        
        if !validateLocation(fromTitle, location: validFromLocation) {
            return handler(false)
        }

        if !validateLocation(toTitle, location: validToLocation) {
            return handler(false)
        }
        
        validatePart(partTitle) { 
            if self.validPart == nil {
                invokeAlertMessage("Part Error", msgBody: "Part is invalid", delegate: self)
                return handler(false)
            }

            if !self.validateQuantity(self.quantityTitle) {
                return handler(false)
            }

            if self.hasSerialTracking() { // validate serial number tracking values
                if !self.validateSerialTracking(self.validQuantity) {
                    invokeAlertMessage("Tracking Error", msgBody: "Incorrect number of serial numbers", delegate: self)
                    return handler(false)
                }
            } else if self.hasTracking() { // validate the tracking values
                if !self.validateTracking() {
                    invokeAlertMessage("Tracking Error", msgBody: "Tracking values are invalid", delegate: self)
                    return handler(false)
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

        let section = getSectionNumber(quantityTitle)
        if section != -1 {
            let trackingCountNeeded = sectionData[section].rowCount - 1
            if tracking.count == trackingCountNeeded {
                return true
            }
        }
        return false
    }
    
    private func validateSerialTracking(quantity: UInt) -> Bool {
        if UInt(serials.count) != quantity {
            return false
        }
        return true
    }
    
    private func validatePart(sectionTitle: String, completion: (() -> Void)? = nil ) {
        if let cell = getDefaultCell(sectionTitle) {
            let partCell = cell as! ScannablePartCell
            partNumber = partCell.part.stringValue
            if partNumber.characters.count > 0 {
                getPartFromServer(partNumber, handler: { (num) in
                    self.partNumber = num
                    if let completion = completion {
                        completion()
                    }
                })
            }
        }
    }
    
    private func resetFormInputs() {
        if let cell = getDefaultCell(fromTitle) {
            validFromLocation = nil
            cell.reset()
        }
        if let cell = getDefaultCell(toTitle) {
            validToLocation = nil
            cell.reset()
        }
        if let cell = getDefaultCell(quantityTitle) {
            validQuantity = 0
            cell.reset()
            removeTrackingValues()
        }
        if let cell = getDefaultCell(partTitle) {
            let partCell = cell as! ScannablePartCell
            if !partCell.isLocked() {
                partCell.reset()
                validPart = nil
                removeTrackingCells()  // remove ALL tracking related cells
            }
        }
    }
    
    private func removeSerialNumberCells() {
        let section = getSectionNumber(quantityTitle)
        if section != -1 {
            while sectionData[section].rowCount > 2 {
                sectionData[section].rowCount -= 1
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: section)], withRowAnimation: .Automatic)
            }
        }
    }
    
    private func removeTrackingValues() {
        if hasSerialTracking() {
            removeSerialNumberCells()
            serials.removeAll()
            tracking.removeAll()
        } else if hasTracking() {
            clearTrackingCells()
        }
    }
    
    private func clearTrackingCells() {
        var trackingRow = 1
        while let cell = getSectionCell(quantityTitle, row: trackingRow) {
            let trackCell = cell as! TrackingCell
            trackCell.reset()
            trackingRow += 1
        }
    }
    
    private func hasSerialTracking() -> Bool {
        if let part = validPart {
            return part.hasSerialTracking()
        }
        return false
    }
    
    private func hasTracking() -> Bool { // other tracking (non-serialized)
        if let part = validPart {
            return part.hasTracking()
        }
        return false
    }

}
