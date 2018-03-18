//
//  ReceivePartTrackAllTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 4/18/17.
//  Copyright © 2017 Fishbowl Inventory. All rights reserved.
//

import UIKit
import ObjectMapper
import SVProgressHUD


class ReceivePartTrackAllTableViewController: UITableViewController, PartCellDelegate, AddSerialNumberDelegate, SetLocationDelegate, SetQuantityDelegate, UITextFieldDelegate {

    typealias PartHandlerCallback  = (String) -> Void
    typealias CustomCellFunction = (indexPath: NSIndexPath) -> UITableViewCell
    class sectionDataItem {
        var sectionTitle: String!
        var rowCount: Int
        var rowCountFunc: () -> Int
        var cellFunc: CustomCellFunction!
        
        init(title: String, rowFunc: ()->Int, cellFunc: CustomCellFunction) {
            self.sectionTitle = title
            self.rowCountFunc = rowFunc
            self.cellFunc = cellFunc
            self.rowCount = 0
        }
    }

    private let titlePart     = "Part"
    private let titleLocation = "Location"
    private let titleQuantity  = "Quantity / Tracking"
    private let titleSerial   = "Serial Numbers"
    
    private var sectionData = [sectionDataItem]()
    private var serials = [String]()
    private var tracking = [String]()
    private var tableSections = 0
    var partNumber: String = ""
    var Item: FbReceiveItem!
    var delegate: ReceiveOrderDelegate?
    var assignedQuantity: Int = 0

    private var serialNumbersNeeded:Int = 0
    private var validPart = FbPart() {
        didSet {
            tableSections = calculateTableSections()
        }
    }
    private var validLocation: FbLocation?
    private var validQuantity: Int = 0

    // MARK: - Actions
    @IBAction func btnReceiveItem(sender: AnyObject) {
        if validFormInputs() {
            doReceivePartRequest()
        }
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionData.removeAll() // remove any entries if previously initialized.
        sectionData.append(sectionDataItem(title: titlePart,     rowFunc: singleRow,               cellFunc: partCell))
        sectionData.append(sectionDataItem(title: titleLocation, rowFunc: singleRow,               cellFunc: locationCell))
        sectionData.append(sectionDataItem(title: titleQuantity, rowFunc: quantitySectionRowCount, cellFunc: quantityCell))
        sectionData.append(sectionDataItem(title: titleSerial,   rowFunc: serialSectionRowCount,   cellFunc: serialCell))
        
        if let item  = self.Item {
            validPart = item.Part
            setQuantity(item.Quantity)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        if let item = self.Item {
            setQuantity(item.Quantity)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
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
        validPart.setLocked(isLocked)
    }

    // Called when quantity cell is done editing
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
        // Add the serial number... check for duplicates, also check to see if we still need serials
        if serials.count < serialNumbersNeeded {
            if !serials.contains({$0.caseInsensitiveCompare(serialNumber) == .OrderedSame}) {
                serials.append(serialNumber)
                let section = getSectionNumber(titleSerial)
                if section != -1 {
                    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: serials.count, inSection: section)], withRowAnimation: .Automatic)
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section < sectionData.count {
            let cell = sectionData[indexPath.section].cellFunc(indexPath: indexPath)
            sectionData[indexPath.section].rowCount += 1
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
            let section = getSectionNumber(titleQuantity)
            if indexPath.section == section && indexPath.row > 0 {
                return 50
            }
        }
        return 44
    }
    
    // only allow swipe to delete in the serial number cells
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row > 0 && getSectionNumber(titleSerial) == indexPath.section && hasSerialTracking() {
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Remove") { (action, indexPath) in
            let index = indexPath.row - 1 // first two cells are a Quantity and SerialAdder
            let selectedSerial = self.serials[index]
            let section = self.getSectionNumber(self.titleSerial)
            if selectedSerial.characters.count > 0 && section != -1 {
                self.serials.removeAtIndex(index)
                self.sectionData[section].rowCount -= 1
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                self.updateSerialTrackingCells(self.serials.count, total: self.serialNumbersNeeded)
            }
        }
        deleteAction.backgroundColor = UIColor.redColor()
        return [deleteAction]
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

    private func partCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReceiveCellPart") as! PickCellPart
        cell.partLabel.text = validPart.getFullName()
        return cell
    }
    
    private func locationCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = NSBundle.mainBundle().loadNibNamed("ScannableLocationCell", owner: self, options: nil)?.first as! ScannableLocationCell
        cell.setDelegate(Constants.Field.Location, delegate: self)
        cell.setLocationCache(locationCache)
        if let location = validLocation {
            cell.setValue(location.getFullName())
            cell.setLock(location.getLock())
        }
        return cell
    }
    
    // Creates the cells in the Quantity section (quantity cell & tracking cells too)
    private func quantityCell(indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil

        if indexPath.row > 0 && hasTracking() {
            cell = trackingCell(indexPath.row)
        }
        
        if cell == nil {
            let qtyCell = NSBundle.mainBundle().loadNibNamed("QuantityCell", owner: self, options: nil)?.first as! QuantityCell
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
            cell = serialAdderCell()
        }
        
        return cell!
    }

    private func serialAdderCell() -> UITableViewCell {
        let cell = NSBundle.mainBundle().loadNibNamed("SerialNumberAdderCell", owner: self, options: nil)?.first as! SerialNumberAdderCell
        cell.setDelegate(self)
        cell.setSerailDelegate(self)
        return cell
    }
    
    // index is the row index in the table view section
    // Need to get the Nth non-serial (type 40) tracking item from the part tracking list
    private func trackingCell(index: Int) -> UITableViewCell {
        let cell = NSBundle.mainBundle().loadNibNamed("TrackingCell", owner: self, options: nil)?.first as! TrackingCell
        cell.setDelegate(self)
        let trackingIndex = index - 1
        if trackingIndex >= 0 {
            cell.setTrackInfo(validPart.PartTrackingList.getNthNonSerialTracking(trackingIndex))
        }
        return cell
    }
    
    private func updatePartCell(partNum: String) {
        if let cell = getDefaultCell(titlePart) {
            let partCell = cell as! ScannablePartCell
            partCell.setValue(partNum)
        }
    }
    
    private func updateTableCells() {
        updatePartCell(partNumber)
        removeTrackingCells()
        serials.removeAll()
        tracking.removeAll()
        tableView.beginUpdates()
        if hasTracking() {
            addRegularTrackingCells(validPart)
        }
        if hasSerialTracking() {
            addSerialTrackingCells()
        }
        tableView.endUpdates()
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
    
    private func addSerialTrackingCells() {
        let section = getSectionNumber(titleSerial)
        if section != -1 {
            // First, setup the "adder" cell
            sectionData[section].rowCount += 1
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: section)], withRowAnimation: .Automatic)
        }
    }
    
    private func addRegularTrackingCells(part: FbPart) {
        // add the regular tracking cells to the "quantity" section
        let section = getSectionNumber(titleQuantity)
        if section != -1 {
            for (index, _) in part.PartTrackingList.PartTracking.enumerate() {
                sectionData[section].rowCount += 1
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: index + 1, inSection: section)], withRowAnimation: .Automatic)
            }
        }
    }
    
    private func removeTrackingCells() {
        let section = getSectionNumber(titleQuantity)
        if section != -1 {
            while sectionData[section].rowCount > 1 {
                sectionData[section].rowCount -= 1
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: section)], withRowAnimation: .Automatic)
            }
        }
    }
    
    private func removeSerialCells() {
        let section = getSectionNumber(titleSerial)
        if section != -1 {
            
        }
    }

    // MARK: - Helper functions
    private func hasSerialTracking() -> Bool {
        return validPart.hasSerialTracking()
    }
    
    private func hasTracking() -> Bool { // other tracking (non-serialized)
        return validPart.hasTracking()
    }

    // Is the part number entered in the text field the same as the current part we already have?
    // Case-insensative compare.
    private func isSamePart(partNum: String) -> Bool {
        if validPart.Num.caseInsensitiveCompare(partNum) == NSComparisonResult.OrderedSame {
            return true
        }
        return false
    }

    private func getPart(partNum: String) {
        if partNum.characters.count > 0 {
            getPartFromServer(partNum, handler: { (num) in
                self.partNumber = num
                self.updateTableCells()
            })
        }
    }
    
    private func getPartFromServer(part:String, handler: PartHandlerCallback) {
        validPart = FbPart()
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
    
    private func setQuantityFocus() {
        if let cell = getDefaultCell(titleQuantity) {
            let quantityCell = cell as! QuantityCell
            quantityCell.setAsFirstResponder()
        }
    }
    
    private func updateSerialTrackingCells(num: Int, total: Int) {
        if let cell = getSectionCell(titleSerial, row: 0) {
            if cell is SerialNumberAdderCell {
                let serialAdder = cell as! SerialNumberAdderCell
                serialAdder.updateStatusLabel(num, total: total)
            }
        }
    }

    private func validateQuantity(sectionTitle: String) -> (Bool, Int) {
        if let cell = getDefaultCell(titleQuantity) {
            let quantityCell = cell as! QuantityCell
            let quantity = Int(quantityCell.getQuantity())
            if quantity > 0 {
                return (true, quantity)
            }
        }
        invokeAlertMessage("Quantity Error", msgBody: "Quantity is invalid", delegate: self)
        return (false, 0)
    }
    
    private func validFormInputs() -> Bool {
        var valid = false
        
        // Validate Location
        (valid, validLocation) = validateLocation(titleLocation)
        if !valid {
            return false
        }

        // Validate quantity
        (valid, self.validQuantity) = validateQuantity(titleQuantity)
        if !valid {
            return false
        }

        // Validate Serial Tracking (if needed)
        if hasSerialTracking() {
            if serials.count < Int(validQuantity) {
                invokeAlertMessage("Tracking Error", msgBody: "To few seraial numbers specified", delegate: self)
                return false
            } else if serials.count > Int(validQuantity) {
                invokeAlertMessage("Tracking Error", msgBody: "Too many seraial numbers specified", delegate: self)
                return false
            }
        }

        // Validate other tracking (if needed)
        tracking.removeAll()
        if hasTracking() {
            let section = getSectionNumber(titleQuantity)
            let trackingRows = tableView.numberOfRowsInSection(section) - 1

            for row in 0..<trackingRows {
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row + 1, inSection: section)) as! TrackingCell
                if cell.trackingField.stringValue.isEmpty {
                    var field = ""
                    if let partTracking = validPart.PartTrackingList.getNthNonSerialTracking(row) {
                        field += partTracking.Name.isEmpty ? "" : " for \(partTracking.Name)"
                    }
                    invokeAlertMessage("Tracking Error", msgBody: "Tracking value was not specified"+field, delegate: self)
                    cell.becomeFirstResponder()
                    return false
                }
                tracking.append(cell.trackingField.stringValue)
            }
        }
        return true
    }
    
    private func doReceivePartRequest() {
        // Save receive information to parent
        if let delegate = self.delegate {
            let receipt = FbReceivedReceipt()
            let id = Item.ID
            
            assignedQuantity += validQuantity
            let tracking = getValidTracking()
            
            receipt.ItemType = Constants.ReceiptItemStatus.Entered // Set to 10
            receipt.setLocationId(validLocation!.LocationID)
            receipt.setQuantity(Int(validQuantity))
            receipt.setTracking(tracking)
            delegate.saveReceivedItem(id, receivedReceipt: receipt)
        }
        navigationController?.popViewControllerAnimated(true)
    }

    private func getValidTracking() -> FbTracking? {
        let fbTracking = FbTracking()

        // Get serial tracking if it exists...
        if serials.count > 0 {
            if let partTracking = validPart.PartTrackingList.getPrimaryTracking() {
                let newItem = FbTrackingItem()
                newItem.setPartTracking(partTracking)
                for trackingItem in serials {
                    newItem.addSerialNumber(trackingItem, partTracking: partTracking)
                }
                fbTracking.addTrackingItem(newItem)
            }
        }
        
        if tracking.count > 0 {
            for (index, trackingItem) in tracking.enumerate() {
                let newItem = FbTrackingItem()
                newItem.setPartTracking(validPart.PartTrackingList.PartTracking[index])
                newItem.setTrackingValue(trackingItem)
                fbTracking.addTrackingItem(newItem)
            }
        }
        
        return fbTracking.TrackingItem.count > 0 ? fbTracking : nil
    }
    
    private func validateLocation(sectionTitle: String) -> (Bool, FbLocation?) {
        if let cell = getDefaultCell(sectionTitle) {
            let locCell = cell as! ScannableLocationCell
            let (valid, fbLocation) = locationCache.validLocation(locCell.getLocation())
            if valid  && (fbLocation != nil) {
                let newLocation = fbLocation!.getFullName()
                locCell.setValue(newLocation)
                return (valid, fbLocation)
            } else {
                invokeAlertMessage("Location Error", msgBody: "\(sectionTitle) is invalid", delegate: self)
            }
            
        } else {
            invokeAlertMessage("Location Error", msgBody: "\(sectionTitle) is invalid", delegate: self)
        }
        return (false, nil)
    }

}
