//
//  PickPartTrackSerialTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 10/10/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import ObjectMapper


class PickPartTrackSerialTableViewController: UITableViewController, SerialNumberDelegate, UITextFieldDelegate {

    
    @IBOutlet var serialNumberText: UITextView!
    
    @IBOutlet var quantityField: UITextField!
    @IBOutlet var partLabel: UILabel!
    @IBOutlet var fromLocation: LocationTextField!
    @IBOutlet var toLocation: LocationTextField!
    @IBOutlet weak var uomLabel: UILabel!

    @IBOutlet weak var fromLocationLock: LockButton!
    @IBOutlet weak var toLocationLock: LockButton!
    
    @IBOutlet weak var scanFromLocationButton: UIButton!
    @IBOutlet weak var scanToLocationButton: UIButton!

    private var errorTitle = "Pick Error"
    private var serials = [String]()
    private var pick: FbPick?
    var part: FbPart!

    // Set on scene/form validation
    private var validFromLocation   = FbLocation()
    private var validToLocation     = FbLocation()
    private var validQuantity: Int  = 0
    private var validTracking       = [String]()
    private var validPart           = FbPart()
    private var autoCommit          = false
    
    var partNumber: String = ""
    var pickItem: FbPickItem!
    var delegate: PickOrderDelegate?

    
    // MARK: - Actions
    @IBAction func btnSavePick(sender: AnyObject) {
        if validFormInputs() {
            doSavePickPartRequest()
        }
    }
    
    @IBAction func fromLockToggle(sender: LockButton) {
        fromLocation.setEnable(sender.isLocked)
        scanFromLocationButton.enabled = sender.isLocked
    }

    @IBAction func toLockToggle(sender: LockButton) {
        toLocation.setEnable(sender.isLocked)
        scanToLocationButton.enabled = sender.isLocked
    }

    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        serialNumberText.text = "(enter serial numbers)"
        
        // Set delegate so location field can lookup the tag/location name
        fromLocation.lookupDelegate = locationCache
        toLocation.lookupDelegate = locationCache

        quantityField.delegate = self
        fromLocation.delegate = self
        toLocation.delegate = self
        quantityField.addDismissButton()
        
        if let pickItem  = self.pickItem {
            validPart = pickItem.Part
            
            partLabel.text = validPart.getFullName()
            let fromLocName = pickItem.Location.getFullName()
            if fromLocName.characters.count > 0 {
                fromLocation.text = fromLocName
            } else {
                disableFromLocationCell()
            }
            let destLocation = pickItem.DestinationTag.Tag.Location
            toLocation.text = destLocation.getFullName()
            quantityField.text = "\(pickItem.Quantity)"
            uomLabel.text = "\(pickItem.UOM.Code)"
            if validPart.getType() != Constants.PartType.Inventory {
                disableFromLocationCell()
            }
            populateAutoCommitTracking(pickItem)

        } else {
            sendGetPartRequest()
        }
    }
    
    private func populateAutoCommitTracking(pickitem: FbPickItem?) {
        if let pickItem = pickItem {
            if pickItem.Tracking.hasSerialTracking() {
                let newSerials = pickItem.getAllSerialNumbers()
                if newSerials.count > 0 {
                    // disable serial input control... must accept pre-populated serial numbers
                    autoCommit = true
                    saveSerials(newSerials)
                }
            }
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

        switch segueId {
            case "choose_from_location_segue":
                let navController = segue.destinationViewController as! UINavigationController
                let destViewController = navController.childViewControllers[0] as! LocationTableViewController
                destViewController.delegate = self.fromLocation
                destViewController.setInitialSelection(self.fromLocation.locationId)
                break
                
            case "choose_to_location_segue":
                let navController = segue.destinationViewController as! UINavigationController
                let destViewController = navController.childViewControllers[0] as! LocationTableViewController
                destViewController.delegate = self.toLocation
                destViewController.setInitialSelection(self.toLocation.locationId)
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
                
            case "scan_to_location_segue":
                let navController = segue.destinationViewController as! UINavigationController
                let destViewController = navController.childViewControllers[0] as! ScannerViewController
                destViewController.delegate = self.toLocation
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
        
        // Don't allow segue if To Location is locked
        if toLocationLock.isLocked && identifier == "choose_to_location_segue" {
            return false
        }
        
        // Don't allow serial number segue if auto-commit was used...
        if autoCommit {
            return false
        }
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case fromLocation:
            quantityField.becomeFirstResponder()
            break
        case quantityField:
            toLocation.becomeFirstResponder()
            break
        case toLocation:
            if validFormInputs() {
                doSavePickPartRequest()
            }
            break
        default:
            textField.resignFirstResponder() // close the keyboard on <return>
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
        if indexPath.section == 4 && indexPath.row == 0 { // serial numbers section
            return 150
        }
        return 44
    }
    
    // MARK: - Delegate Functions
    func saveSerials(list: [String]) {
        serials.removeAll()
        serials.appendContentsOf(list)
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
        var (valid, fbLocation) = locationCache.validLocation(fromLocation.stringValue);
        if !valid {
            invokeAlertMessage("Location Error", msgBody: "From-location is invalid", delegate: self)
            return false
        }
        validFromLocation = fbLocation!
        
        // Validate To-Location
        (valid, fbLocation) = locationCache.validLocation(toLocation.stringValue)
        if !valid {
            invokeAlertMessage("Location Error", msgBody: "To-location is invalid", delegate: self)
            return false
        }
        validToLocation = fbLocation!

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

    private func doSavePickPartRequest() {
        // Save pick information to parent
        if let delegate = self.delegate {
           
            if let curPickItem = self.pickItem {
                let pickItem = curPickItem.copyWithZone(nil) as! FbPickItem
                pickItem.Location = validFromLocation
                pickItem.DestinationTag.Tag.Location = validToLocation
                pickItem.Quantity = validQuantity
                pickItem.Part = validPart
                
                let trackingItem = FbTrackingItem()
                if let partTracking = part.PartTrackingList.getPartTrackingByType(Constants.TrackingType.SerialNumber) {
                    trackingItem.setPartTracking(partTracking.copyWithZone(nil) as! FbPartTracking)
                    for (_, value) in validTracking.enumerate() { // enumerate serial #s
                        trackingItem.addSerialNumber(value, partTracking: partTracking)
                    }
                }
                pickItem.addTrackingItem(trackingItem)
                delegate.savePickItem(pickItem)
            }
        }
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    private func disableFromLocationCell() {
        fromLocationLock.lock()
        fromLocationLock.enabled = false
        fromLocation.enabled = false
        scanFromLocationButton.enabled = false
        fromLocation.text = "N/A"
    }
    
}
