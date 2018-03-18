//
//  PartViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/23/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import ObjectMapper
import SVProgressHUD


protocol PartDelegate {
    func partImageSaved(image: UIImage?)
    func partUpcSave(upc: String)
}

class PartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, FBScannerDelegate, PartDelegate {

    var partNum: String = ""
    var sectionTitles: [String] = [String]()
    var sectionCells: [Int] = [Int]()
    var imageRowHeight: CGFloat = 44.0 // default image row height

    private var validPart = Mapper<FbPart>().map("")
    private var validInventoryQuantity = Mapper<FbInventoryQuantity>().map("")
    private var partImage: UIImage?
    private var newImage: UIImage? = nil
    
    @IBOutlet var partNumber: UITextField!
    @IBOutlet var detailTable: UITableView!

    // MARK: - Actions
    @IBAction func btnShowPart(sender: AnyObject) {
        partNum = partNumber.stringValue
        if partNum.characters.count <= 0 {
            invokeAlertMessage("Part Error", msgBody: "Please enter part number or UPC", delegate: self)
        } else {
            updateAndDisplayPart(partNum)
        }
    }
    
    private func saveUpc(upc: String) -> Bool {
        if let part = validPart {
            let updateProducts = g_pluginSettings.getSetting(Constants.Options.partUpdateProductUpc)
            let fbMessageRequest = FbMessageRequest(
                key: g_apiKey,
                id: g_userId,
                requestObj: FbiSaveUpcRequest(part: part.Num, upc: upc, updateProducts: updateProducts)
            )
            connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "Request sent") { (ticket, response) in
                let isValid = self.ValidateSaveUpcResponse(ticket, response: response)
                if isValid {
                    SVProgressHUD.showSuccessWithStatus("UPC Saved")
                } else {
                    SVProgressHUD.showErrorWithStatus("UPC Error")
                }
            }

        }
        return false
    }
    
    private func ValidateSaveUpcResponse(ticket: FbTicket, response: FbResponse) -> Bool
    {
        var status = 1000
        var statusMessage = ""
        
        if response.isValid(Constants.Response.saveUpc) {
            status = response.getJson()["statusCode"].intValue
            if status != 1000 {
                statusMessage = response.getJson()["statusMessage"].stringValue
            }
        } else {
            status = response.getStatus()
        }
        if status != 1000 {
            if statusMessage.characters.count == 0 {
                statusMessage = getFBStatusMessage(status)
            }
            dispatch_async(dispatch_get_main_queue()) {
                invokeAlertMessage("UPC Error", msgBody: getFBStatusMessage(status), delegate: self)
            }
            return false
        }
        return true
    }

    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionTitles = ["Description", "Details", "Inventory"]
        sectionCells = [1, 3, 0]
        partNumber.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        if newImage != nil {
            detailTable.reloadData()

        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }

        if segueId == "segueScan" {
            let navController = segue.destinationViewController as! UINavigationController
            let destViewController = navController.childViewControllers[0] as! ScannerViewController
            destViewController.delegate = self
        } else if segueId == "show_part_image_segue" {
            if let part = validPart {
                setNavigationBackItem(part.Num)
                let destViewController = segue.destinationViewController as! PartImageViewController
                destViewController.image = partImage
                destViewController.partNumber = partNum
                destViewController.delegate = self
            }
        }
    }
    
    // MARK: - Text Field Handlers
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
            case partNumber:
                btnShowPart(self)
                break
            default:
                textField.resignFirstResponder()
        }
        return true
    }

    // MARK: - Delegate Methods
    func receivedScanCode(code: String) {
        partNumber.text = code
        partNum = partNumber.stringValue
        if partNum.characters.count > 0 {
            updateAndDisplayPart(partNum)
        }
    }
    
    func partImageSaved(image: UIImage?) {
        newImage = image
        partImage = image
    }
    
    func partUpcSave(upc: String) {
        if saveUpc(upc) {
            invokeAlertMessage("Success", msgBody: "UPC was saved successfully", delegate: self)
        }
    }

    // MARK: - Table Control Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionCells[section]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 { // inventory section
            return 52.0
        } else if indexPath.section == 1 { // details section...
            if indexPath.row == 2 { // image row
                return imageRowHeight
            }
        }
        return 44.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        indexPath.section
        
        switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("cell_description") as! PartDescriptionCell
                cell.descriptionLabel.text = ""
                if let part = validPart {
                    cell.descriptionLabel.text = part.Description
                }
                return cell;
            
            case 1:
                switch indexPath.row {
                    case 0: // UOM
                        let cell = tableView.dequeueReusableCellWithIdentifier("cell_details_uom") as! PartUomCell
                        cell.uomLabel.text = "UOM:"
                        if let part = validPart {
                            let uom = part.UOM
                            cell.uomLabel.text = "UOM: \(uom.Name) (\(uom.Code))"
                        }
                        return cell

                    case 1: // UPC
                        let cell = tableView.dequeueReusableCellWithIdentifier("cell_details_upc") as! PartUpcCell
                        cell.upcLabel.text = "UPC:"
                        cell.delegate = self
                        if let part = validPart {
                            cell.upc.text = part.UPC
                        }
                        cell.setEnable(g_moduleAccess.hasAccess(g_username, group: Constants.defaultRightsGroup, feature: Constants.Rights.AllowSaveUpc))
                        return cell

                    case 2: // Image
                        let cell = tableView.dequeueReusableCellWithIdentifier("cell_details_image") as! PartImageCell
                        if let img = partImage {
                            cell.partImage.image = img
                            imageRowHeight = max(min(img.size.height, 150), 45)
                        }
                        return cell

                    default:
                        break
                }
                break
            
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("cell_details_inventory") as! PartInventoryCell
                cell.locationLabel.text = ""
                cell.onHandLabel.text = ""
                cell.availableLabel.text = ""
                cell.committedLabel.text = ""
                if let inventory = validInventoryQuantity {
                    if let location = inventory.InvQty[indexPath.row].Location {
                        let label = "\(location.LocationGroupName)-\(location.Name)"
                        cell.locationLabel.text = label
                    }
                    
                    var qty = inventory.InvQty[indexPath.row].QtyOnHand
                    cell.onHandLabel.text = "On Hand: \(qty)"
                    qty = inventory.InvQty[indexPath.row].QtyAvailable
                    cell.availableLabel.text = "Available: \(qty)"
                    qty = inventory.InvQty[indexPath.row].QtyCommitted
                    cell.committedLabel.text = "Committed: \(qty)"
                }
                return cell
            
            default: // do nothing
                break;
        }
        
        return UITableViewCell()
    }
    
    // MARK: - Helper Functions
    private func updateAndDisplayPart(part: String) { // PartNumber OR a UPC
        
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiPartGetRequest(number: part, getImage: true)
        )
        
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: nil) { (ticket, response) in
            
            let (isValid, fbPart) = self.ValidatePart(ticket, response: response)
            dispatch_async(dispatch_get_main_queue(), {
                if isValid {
                    self.partNumber.resignFirstResponder()
                    SVProgressHUD.showSuccessWithStatus("Part loaded")
                    self.decodePart(fbPart!)
                } else {
                    SVProgressHUD.showErrorWithStatus("Invalid part")
                }
            })
        }
    }
    
    private func decodePart(fbPart: FbPart) {
        validPart = fbPart
        partImage = decodeImageToView(fbPart)
        partNumber.text = fbPart.Num
        partNum = fbPart.Num // If UPC was used, update the part number so inventory request will work
        
        let indexPath = NSIndexPath(forRow: 1, inSection: 1)
        if let part = validPart {
            let cell = (detailTable.cellForRowAtIndexPath(indexPath) as! PartUpcCell)
            cell.upc.text = part.UPC
        }
        
        // Get the inventory...
        getPartInventory(partNum) { (success) in
            if success {
                self.sectionCells[2] = 0
                if let inventory = self.validInventoryQuantity {
                    self.sectionCells[2] = inventory.InvQty.count
                }
                self.imageRowHeight = 44.0 // reset image row to default height
                self.detailTable.reloadData()
            }
        }
    }
    
    private func decodeImageToView(part: FbPart) -> UIImage {
        var img = UIImage(named: "camera_large")!
        let toArray = part.Image.componentsSeparatedByString("\r\n")
        let backToString = toArray.joinWithSeparator("")
        if let imageData1 = NSData(base64EncodedString: backToString, options: []) {
            if imageData1.length > 0 {
                img = UIImage(data: imageData1)!
            }
        }
        return img
    }
    
    private func ValidatePart(ticket: FbTicket, response: FbResponse) -> (Bool, FbPart?)
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
    
    private func getPartInventory(part: String, handler: (Bool) -> Void ) {
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiInventoryQuantityRequest(part: part)
        )
        
        connectionFishbowl.connectAndSendRequest(fbMessageRequest) { (ticket, response) in
            let (isValid, fbInventoryQuantity) = self.ValidateInventoryQuantity(ticket, response: response)
            if isValid {
                self.validInventoryQuantity = fbInventoryQuantity
                handler(true)
            } else {
                invokeAlertMessage("Inventory Error", msgBody: "Unable to get part inventory information", delegate: self)
                handler(false)
            }
        }
    }
    
    private func ValidateInventoryQuantity(ticket: FbTicket, response: FbResponse) -> (Bool, FbInventoryQuantity?) {
        if response.isValid(Constants.Response.inventoryQuantity) {
            let status = response.getJson()[Constants.Property.statusCode].intValue // check sub-status
            if status == 1000 {
                // let data = String(response.getJson()["InvQty"])
                let data = String(response.getJson())
                if let inventory = Mapper<FbInventoryQuantity>().map(data) {
                    return (true, inventory)
                }
            }
        }
        return (false, nil)
    }
}
