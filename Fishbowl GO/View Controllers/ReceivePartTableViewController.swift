//
//  ReceivePartTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 10/16/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import ObjectMapper


class ReceivePartTableViewController: UITableViewController, UITextFieldDelegate {
    
    
    
    @IBOutlet var partLabel: UILabel!
    @IBOutlet var toLocation: LocationTextField!
    @IBOutlet var quantity: UITextField!
    @IBOutlet weak var uomLabel: UILabel!
    
    @IBOutlet var toLocationLock: LockButton!

    var receiveItem: FbReceiveItem!
    var assignedQuantity: Int = 0
    var partNumber: String = ""
    var delegate: ReceiveOrderDelegate?

    
    // MARK: - Actions
    @IBAction func save(sender: AnyObject) {
        if let del = delegate {
            let receipt = FbReceivedReceipt()
            let id = receiveItem.ID
            
            receipt.ItemType = Constants.ReceiptItemStatus.Entered // set to 10
            assignedQuantity += quantity.integerValue
            receipt.setLocationId(toLocation.locationId)
            receipt.setQuantity(quantity.integerValue)
            del.saveReceivedItem(id, receivedReceipt: receipt)
        }
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func locationLockToggle(sender: LockButton) {
        toLocation.setEnable(sender.isLocked)
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        toLocation.delegate = self
        quantity.delegate = self

        // Initialize the components...
        partLabel.text = receiveItem.getFullName()
        let qty = Int(receiveItem.Quantity) - assignedQuantity
        quantity.text = String(qty)
        uomLabel.text = receiveItem.Part.UOM.Code
        if let location: FbLocation = locationCache.getLocationById(receiveItem.SuggestedLocationID) {
            toLocation.text = location.getFullName()
            toLocation.locationId = receiveItem.SuggestedLocationID
        }
        toLocation.lookupDelegate = locationCache
        quantity.addDismissButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {

        if (identifier == "choose_location_segue") && locationCache.getCount() <= 0 {
            return false
        }
        
        // Don't allow segue if To Location is locked
        if toLocationLock.isLocked && (identifier == "scan_location_segue" || identifier == "choose_location_segue") {
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navController = segue.destinationViewController as! UINavigationController
        
        guard let segueId = segue.identifier else { return }
        
        if segueId == "choose_location_segue" {
            let destViewController = navController.childViewControllers[0] as! LocationTableViewController
            destViewController.delegate = self.toLocation
        } else if segueId == "scan_location_segue" {
            let destViewController = navController.childViewControllers[0] as! ScannerViewController
            destViewController.delegate = self.toLocation
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

    // MARK: - Text Field Handling
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
            case toLocation:
                quantity.becomeFirstResponder()
                break
            case quantity:
                save(self)
                break
                
            default:
                textField.resignFirstResponder()
                break
        }
        return true
    }


}
