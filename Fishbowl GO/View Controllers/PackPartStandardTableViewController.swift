//
//  PackPartStandardTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 10/19/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit

class PackPartStandardTableViewController: UITableViewController, UITextFieldDelegate {
    
    var shippingItem: FbShippingItem?
    var delegate: PackOrderDelegate?
    private var cartonNumber: Int = 1

    @IBOutlet var partLabel: UILabel!
    @IBOutlet var quantity: UITextField!
    
    
    // MARK: - Actions
    @IBAction func btnSave(sender: AnyObject) {
        if validFormInputs() {
            doSavePackPartRequest()
        }
    }
    
    // MARK: - Helper Functions
    func doSavePackPartRequest() {
        // Save packed part to delegate
        if let del = delegate {
            if let curShippingItem = shippingItem {
                let shipItem = curShippingItem.copyWithZone(nil) as! FbShippingItem
                shipItem.setQuantityShipped(quantity.integerValue)
                shipItem.CartonName = cartonNumber
                shipItem.CartonID = 0
                del.savePackItem(shipItem)
            }
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    func setCartonNumber(number: Int) {
        cartonNumber = number
    }

    private func validFormInputs() -> Bool {
        if let shippingItem = self.shippingItem {
            if quantity.integerValue <= 0 {
                invokeAlertMessage("Pack Error", msgBody: "A valid quantity must be specified", delegate: self)
                return false
            } else if quantity.integerValue > Int(shippingItem.QtyShipped) {
                invokeAlertMessage("Pack Error", msgBody: "Quantity cannot be greater than order amount", delegate: self)
                return false
            }
        }
        return true
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        quantity.delegate = self
        quantity.becomeFirstResponder()
        if let item = shippingItem {
            partLabel.text  = item.getFullName()
            quantity.text = "\(item.QtyShipped)"
        }
        quantity.addDismissButton()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case quantity:
            if validFormInputs() {
                doSavePackPartRequest()
            }
            break
        default:
            textField.resignFirstResponder()
        }
        return true
    }

}
