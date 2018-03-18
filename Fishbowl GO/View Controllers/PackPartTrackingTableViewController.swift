//
//  PackPartTrackingTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 11/2/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import Foundation


func singleCellSection(shipItem: FbShippingItem) -> Int {
    return 1
}

func trackingCellSection(shipItem: FbShippingItem) -> Int {
    var count: Int = 1 // Always have 1 (for quantity)
    
    if shipItem.Tracking.TrackingItem.count > 0 {
        for (_, item) in shipItem.Tracking.TrackingItem.enumerate() {
            if item.PartTracking.TrackingTypeID != Constants.TrackingType.SerialNumber {
                count += 1
            }
        }
    }
    return count
}

func serialCellSection(shipItem: FbShippingItem) -> Int {
    var count: Int = 0
    if shipItem.Tracking.TrackingItem.count > 0 {
        for (_, item) in shipItem.Tracking.TrackingItem.enumerate() {
            if item.PartTracking.TrackingTypeID == Constants.TrackingType.SerialNumber {
                /*
                if let serialBoxList = item.SerialBoxList {
                    count += serialBoxList.SerialBox.count
                }
                */
                count += item.SerialBoxList.SerialBox.count
            }
        }
    }
    return count
}



class PackPartTrackingTableViewController: UITableViewController {

    typealias SectionRowCountClosure  = (FbShippingItem) -> Int
    typealias SectionCellClosure = (FbShippingItem, UITableView, NSIndexPath) -> UITableViewCell
    
    class CustomPackSection {
        var title: String
        var cellCountClosure: SectionRowCountClosure
        
        required init(title:String, handler:SectionRowCountClosure) {
            self.title = title
            self.cellCountClosure = handler
        }
    }
    
    private var customSections: [CustomPackSection] = [
        CustomPackSection(title: "Product",              handler: singleCellSection),
        CustomPackSection(title: "Quantity / Tracking",  handler: trackingCellSection),
        CustomPackSection(title: "Serial Numbers",       handler: serialCellSection)
    ]
    
    var shippingItem: FbShippingItem?
    var delegate: PackOrderDelegate?
    var validQuantity: Int = 0
    var cartonNumber: Int = -1

    
    // MARK: - Actions
    @IBAction func btnSave(sender: AnyObject) {
        if validFormInputs() {
            doSavePackPartRequest()
        }
    }
    
    func validFormInputs() -> Bool {
        
        // Validate quantity
        let indexPath = NSIndexPath(forItem: 0, inSection: 1) // Quantity cell
        let cellQuantity = tableView.cellForRowAtIndexPath(indexPath) as! PackCellQuantity
        if cellQuantity.quantityField.integerValue <= 0 {
            invokeAlertMessage("Quantity Error", msgBody: "Quantity is invalid", delegate: self)
            return false
        }
        validQuantity = cellQuantity.quantityField.integerValue
        return true
    }
    
    func doSavePackPartRequest() {
        // Save packed part to delegate
        if let del = delegate {
            if let curShippingItem = shippingItem {
                let shipItem = curShippingItem.copyWithZone(nil) as! FbShippingItem
                shipItem.setQuantityShipped(validQuantity)
                shipItem.CartonName = cartonNumber
                del.savePackItem(shipItem)
            }
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let shipItem = shippingItem {
            if shipItem.hasSerialTracking() {
                return customSections.count
            }
        }
        return 2 // default is just product name & quantity
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < customSections.count {
            return customSections[section].title
        }
        return ""
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let shipItem = shippingItem {
            return customSections[section].cellCountClosure(shipItem)
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let section = customSections[indexPath.section]
        if let item = self.shippingItem {
            switch indexPath.section {
            case 0: // Product number/part number
                let cell = UITableViewCell()
                cell.textLabel?.text = item.getFullName()
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.userInteractionEnabled = false
                return cell
                
            case 1: // Quantity / tracking value (non-serial number tracking)
                //print("qty-tracking... index path: \(indexPath.section), \(indexPath.row)")
                let cell = quantityOrTrackCell(item, tableView: tableView, indexPath: indexPath)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                return cell
                
            case 2: // Serial number tracking
                let cell = serialNumberCell(item, tableView: tableView, indexPath: indexPath)
                return cell
                
            default:// Do nothing
                break
            }
        }
        /*
        if customSections[indexPath.section].cellClosure != nil {
            if let getCellClosure  = customSections[indexPath.section].cellClosure {
                return getCellClosure(shippingItem!, tableView, indexPath)
            }
        }
        */
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // get the cell... determine the type of cell...
        // 
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell is PackCellSerial {
                if (cell.accessoryType == UITableViewCellAccessoryType.Checkmark) {
                    cell.accessoryType = UITableViewCellAccessoryType.None;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark;
                }
                adjustQuantityFromChecked(tableView)
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row > 0 {
            return 55
        }
        return 44
    }
    
    // MARK: - Cell Creating Methods
    private func partNumberCell(shipItem: FbShippingItem, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PackCellPart") as! PackCellPart
        cell.partLabel.text = shipItem.getFullName()
        return cell
    }

    
    private func quantityOrTrackCell(shipItem: FbShippingItem, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: // First cell in this section lets us specify the quantity...
            let cell = tableView.dequeueReusableCellWithIdentifier("PackCellQuantity") as! PackCellQuantity
            cell.quantityField.text = "\(shipItem.QtyShipped)"
            return cell
            
        default:
            let index = indexPath.row - 1
            if let trackingItem = shipItem.getNthNonSerialTracking(index) {
                let cell = tableView.dequeueReusableCellWithIdentifier("PackCellTracking") as! PackCellTracking
                cell.setTypeLabel(trackingItem.PartTracking.Abbr)
                cell.setDateType(trackingItem.PartTracking.isDateType())
                cell.setTextLabel(trackingItem.TrackingValue)
                return cell
            }
            break
        }
        return UITableViewCell()
    }
    
    
    private func serialNumberCell(shipItem: FbShippingItem, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PackCellSerial") as! PackCellSerial
        if let serialNumber = shipItem.getNthSerialNumber(indexPath.row) {
            cell.serialNumber.text = serialNumber.Number
        }
        return cell
    }

    private func setQuantityCellTotal(tableView: UITableView, total: Int) {
        let indexPath = NSIndexPath(forRow: 0, inSection: 1)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PackCellQuantity
        cell.quantityField.text = "\(total)"
    }
    
    private func getCheckedSerialNumberCount(tableView: UITableView) -> Int {
        var count: Int = 0
        let section = 2 // Serial number section

        let rows = tableView.numberOfRowsInSection(section)
        for row in 0..<rows {
            let indexPath = NSIndexPath(forRow: row, inSection: section)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! PackCellSerial
            if (cell.accessoryType == UITableViewCellAccessoryType.Checkmark) {
                count += 1
            }
        }
        return count
    }
    
    private func adjustQuantityFromChecked(tableView: UITableView) {
        let checkedCount = getCheckedSerialNumberCount(tableView)
        setQuantityCellTotal(tableView, total: checkedCount)
        
    }
}
