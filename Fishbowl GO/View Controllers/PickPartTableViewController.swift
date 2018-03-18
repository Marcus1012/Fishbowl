//
//  PickPartTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import ObjectMapper


class PickPartTableViewController: UITableViewController, UITextFieldDelegate {

    private var errorTitle = "Pick Error"
    var part: FbPart?
    var partNumber: String = ""
    var pickItem: FbPickItem!
    var delegate: PickOrderDelegate?

    
    @IBOutlet var partLabel: UILabel!
    
    @IBOutlet var fromLocation: LocationTextField!
    @IBOutlet var toLocation: LocationTextField!
    @IBOutlet var quantity: UITextField!
    @IBOutlet weak var uomLabel: UILabel!
    
    @IBOutlet var fromLocationLock: LockButton!
    @IBOutlet var toLocationLock: LockButton!
    
    @IBOutlet weak var scanFromLocationButton: UIButton!
    @IBOutlet weak var scanToLocationButton: UIButton!
    
    // Set when user selects them in the scene
    private var validFromLocation = FbLocation()
    private var validToLocation   = FbLocation()
    private var validPart         = FbPart()
    private var validQuantity: Int = 0
    
    // MARK: - Actions
    @IBAction func fromLockToggle(sender: LockButton) {
        fromLocation.setEnable(sender.isLocked)
        scanFromLocationButton.enabled = sender.isLocked
    }
    
    @IBAction func toLockToggle(sender: LockButton) {
        toLocation.setEnable(sender.isLocked)
        scanToLocationButton.enabled = sender.isLocked
    }
    
    @IBAction func btnSavePick(sender: AnyObject) {
        if validFormInputs() {
            doSavePickPartRequest()
        }
    }

    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        for currentView in tableView.subviews {
            if let scrollView = currentView as? UIScrollView {
                scrollView.delaysContentTouches = false;
            }
        }
        
        if let pickItem = self.pickItem {
            validPart = pickItem.Part
        } else {
            sendGetPartRequest()
        }
        displayPartInfo()
        if validPart.getType() != Constants.PartType.Inventory {
            disableFromLocationCell()
        }
        
        // Set delegate so location field can lookup the tag/location name
        fromLocation.lookupDelegate = locationCache
        toLocation.lookupDelegate = locationCache
        
        fromLocation.delegate = self
        quantity.delegate = self
        quantity.addDismissButton()
        toLocation.delegate = self
        
        tableView.reloadData()
    }
    
    private func displayPartInfo() {
        partLabel.text = validPart.getFullName()

        // Grab what we can from self.pickItem
        if let pickItem  = self.pickItem {
            let fromLocName = pickItem.Location.getFullName()
            if fromLocName.characters.count > 0 {
                fromLocation.text = fromLocName
            } else {
                disableFromLocationCell()
            }
            let destLocation = pickItem.DestinationTag.Tag.Location
            toLocation.text = destLocation.getFullName()
            quantity.text = "\(pickItem.Quantity)"
            uomLabel.text = pickItem.UOM.Code
        }
    }
    
    private func disableFromLocationCell() {
        fromLocationLock.lock()
        fromLocationLock.enabled = false
        fromLocation.enabled = false
        scanFromLocationButton.enabled = false
        fromLocation.text = "N/A"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        // Don't allow segue if the From Location is locked
        if fromLocationLock.isLocked && identifier == "choose_from_location_segue2" {
            return false
        }
        
        // Don't allow segue if To Location is locked
        if toLocationLock.isLocked && identifier == "choose_to_location_segue" {
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navController = segue.destinationViewController as! UINavigationController
        
        guard let segueId = segue.identifier else { return }

        if segueId == "choose_from_location_segue2" {
            let destViewController = navController.childViewControllers[0] as! LocationTableViewController
            destViewController.delegate = self.fromLocation
        } else if segueId == "choose_to_location_segue" {
            let destViewController = navController.childViewControllers[0] as! LocationTableViewController
            destViewController.delegate = self.toLocation
        } else if segueId == "scan_from_location_segue" {
            let destViewController = navController.childViewControllers[0] as! ScannerViewController
            destViewController.delegate = self.fromLocation
        } else if segueId == "scan_to_location_segue" {
            let destViewController = navController.childViewControllers[0] as! ScannerViewController
            destViewController.delegate = self.toLocation
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
            case fromLocation:
                quantity.becomeFirstResponder()
                break
            case quantity:
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
    
    // MARK: - Server Requests
    func sendGetPartRequest()
    {
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiPartGetRequest(number: partNumber, getImage: false)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest) { (ticket, response) in
            self.getPartResponse(ticket, response: response)
        }
    }
    
    // MARK: - Response Handlers
    func getPartResponse(ticket: FbTicket, response: FbResponse)
    {
        var errorMessage: String = ""
        var wasSuccessful = false
        if response.isValid(Constants.Response.partGet) {
            let partStatus = response.getJson()["statusCode"].intValue
            if partStatus == 1000 {
                wasSuccessful = true
                let data = String(response.getJson()["Part"])
                guard let validPart = Mapper<FbPart>().map(data) else { return }
                self.validPart = validPart
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
    private func doSavePickPartRequest() {
        // Save serial numbers to parent
        if let del = delegate {
            
            if let curPickItem = self.pickItem {
                let pickItem = curPickItem.copyWithZone(nil) as! FbPickItem
                pickItem.setLocation(validFromLocation)
                pickItem.DestinationTag.Tag.Location = validToLocation
                pickItem.Quantity = validQuantity
                pickItem.Part = validPart
                del.savePickItem(pickItem)
            }
            
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func validFormInputs() -> Bool {
        // Validate From-Location
        if validPart.getType() == Constants.PartType.Inventory {
            let (valid, fbLocation) = locationCache.validLocation(fromLocation.stringValue);
            if !valid {
                invokeAlertMessage("Location Error", msgBody: "From-location is invalid", delegate: self)
                return false
            }
            fromLocation.text = fbLocation?.getFullName()
            validFromLocation = fbLocation!
        }
        
        // Validate To-Location
        let (valid, fbLocation) = locationCache.validLocation(toLocation.stringValue);
        if !valid {
            invokeAlertMessage("Location Error", msgBody: "To-location is invalid", delegate: self)
            return false
        }
        toLocation.text = fbLocation?.getFullName()
        validToLocation = fbLocation!
        
        // Validate quantity
        if quantity.integerValue <= 0 {
            invokeAlertMessage("Quantity Error", msgBody: "Quantity is invalid", delegate: self)
            return false
        }
        validQuantity = quantity.integerValue
        
        // Validate part
        if validPart.Num.characters.count <= 0 {
            invokeAlertMessage("Part Error", msgBody: "Part is invalid", delegate: self)
            return false
        }
        
        return true
    }

    
}
