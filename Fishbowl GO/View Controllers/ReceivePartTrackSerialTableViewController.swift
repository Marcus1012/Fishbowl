//
//  ReceivePartTrackSerialTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 10/10/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import ObjectMapper


class ReceivePartTrackSerialTableViewController: UITableViewController, SerialNumberDelegate {

    @IBOutlet var serialNumberText: UITextView!
    @IBOutlet var quantityField: UITextField!
    @IBOutlet weak var uomLabel: UILabel!
    @IBOutlet var partLabel: UILabel!
    @IBOutlet var fromLocation: LocationTextField!

    @IBOutlet weak var fromLocationLock: LockButton!
    @IBOutlet weak var scanFromLocationButton: UIButton!

    private var errorTitle = "Receive Error"
    private var serials = [String]()
    private var pick: FbPick?

    // Set on scene/form validation
    private var validLocation       = FbLocation()
    private var validQuantity: Int  = 0
    private var validTracking       = [String]()
    private var validPart           = FbPart()
    
    var partNumber: String = ""
    var Item: FbReceiveItem!
    var delegate: ReceiveOrderDelegate?
    var assignedQuantity: Int = 0

    
    // MARK: - Actions
    @IBAction func btnReceivePart(sender: AnyObject) {
        if validFormInputs() {
            doReceivePartRequest()
        }
    }
    
    @IBAction func fromLockToggle(sender: LockButton) {
        fromLocation.setEnable(sender.isLocked)
        scanFromLocationButton.enabled = sender.isLocked
    }

    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        serialNumberText.text = "(enter serial numbers)"
        
        // Set delegate so location field can lookup the tag/location name
        fromLocation.lookupDelegate = locationCache

        if let item  = self.Item {
            validPart = item.Part
            
            partLabel.text = validPart.getFullName()
            let locationName = getLocationName()
            if locationName.characters.count > 0 {
                fromLocation.text = locationName
            } else {
                disableFromLocationCell()
            }
            
            let qty = Int(Item.Quantity) - assignedQuantity
            quantityField.text = String(qty)
            uomLabel.text = validPart.UOM.Code
            if validPart.getType() != Constants.PartType.Inventory {
                disableFromLocationCell()
            }
        } else {
            sendGetPartRequest()
        }
        
    }
    
    func getLocationName() -> String {
        if Item != nil {
            if let location: FbLocation = locationCache.getLocationById(Item.SuggestedLocationID) {
                return location.getFullName()
            }
        }
        return ""
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

        switch segueId {
            case "choose_from_location_segue":
                let navController = segue.destinationViewController as! UINavigationController
                let destViewController = navController.childViewControllers[0] as! LocationTableViewController
                destViewController.delegate = self.fromLocation
                destViewController.setInitialSelection(self.fromLocation.locationId)
                break
                
            case "add_serial_numbers_segue":
                setNavigationBackItem("Cancel")
                let destViewController = segue.destinationViewController as! ChooseSerialsViewController
                destViewController.delegate = self
                destViewController.serials = serials // send current lists
                destViewController.maxSerials = Int(quantityField.stringValue)!
                break

            case "scan_from_location_segue":
                let navController = segue.destinationViewController as! UINavigationController
                let destViewController = navController.childViewControllers[0] as! ScannerViewController
                destViewController.delegate = self.fromLocation
                break
            
            default:
            break
        }

    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        // Don't allow segue if the From Location is locked
        if fromLocationLock.isLocked && identifier == "choose_from_location_segue" {
            return false
        }
        
        return true
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0){
            return 30 // CGFloat.min
        }
        return 20
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 3 && indexPath.row == 0 { // serial numbers section
            return 150
        }
        return 44
    }
    
    // MARK: - Delegate Functions
    func saveSerials(list: [String]) {
        serials = list
        if serials.count > 0 {
            serialNumberText.text = serials.joinWithSeparator("\n")
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
    
    // MARK: - Helper Functions
    func setPick(pick: FbPick) {
        self.pick = pick
    }

    private func validFormInputs() -> Bool {
        // Validate From-Location
        let (valid, fbLocation) = locationCache.validLocation(fromLocation.stringValue);
        if !valid {
            invokeAlertMessage("Location Error", msgBody: "From-location is invalid", delegate: self)
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
        if serials.count < validQuantity {
            invokeAlertMessage("Tracking Error", msgBody: "To few seraial numbers specified", delegate: self)
            return false
        } else if serials.count > validQuantity {
            invokeAlertMessage("Tracking Error", msgBody: "Too many seraial numbers specified", delegate: self)
            return false
        }
        validTracking = serials
        return true
    }

    private func doReceivePartRequest() {
        // Save receive information to parent
        if let delegate = self.delegate {
            let receipt = FbReceivedReceipt()
            let id = Item.ID
            
            assignedQuantity += quantityField.integerValue
            let tracking = getValidTracking()

            receipt.ItemType = Constants.ReceiptItemStatus.Entered // Set to 10
            receipt.setLocationId(validLocation.LocationID)
            receipt.setQuantity(quantityField.integerValue)
            receipt.setTracking(tracking)
            delegate.saveReceivedItem(id, receivedReceipt: receipt)
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func getValidTracking() -> FbTracking? {
        if validTracking.count > 0 {
            let tracking = FbTracking()
            if let partTracking = validPart.PartTrackingList.getPrimaryTracking() {
                let newItem = FbTrackingItem()
                newItem.setPartTracking(partTracking)
                for trackingItem in validTracking {
                    newItem.addSerialNumber(trackingItem, partTracking: partTracking)
                }
                tracking.addTrackingItem(newItem)
                return tracking
            }
        }
        return nil
    }

    private func disableFromLocationCell() {
        fromLocationLock.lock()
        fromLocationLock.enabled = false
        fromLocation.enabled = false
        scanFromLocationButton.enabled = false
        fromLocation.text = "N/A"
    }
    
}
