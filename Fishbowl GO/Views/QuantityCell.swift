//
//  QuantityCell.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 1/10/17.
//  Copyright © 2017 RPM Consulting. All rights reserved.
//

import UIKit

class QuantityCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var quantity: UITextField!
    @IBOutlet weak var uomLabel: UILabel!
    
    private var delegate: SetQuantityDelegate?
    
    override func didMoveToSuperview() {
        quantity.delegate = self
        quantity.addDismissButton()
    }
    
    func setDelegate(delegate: SetQuantityDelegate) {
        self.delegate = delegate
    }
    
    func getQuantity() -> UInt {
        let val = quantity.integerValue
        if val > 0 {
            return UInt(val)
        }
        return 0
    }
    
    func setValue(value: Int) {
        quantity.text = ""
        if value > 0 {
            quantity.text = "\(value)"
        }
    }

    func setAsFirstResponder() {
        becomeFirstResponder()
        quantity.becomeFirstResponder()
    }
 
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        quantity.resignFirstResponder() // close keyboard on return
        return true
    }

    
    override func reset() {
        super.reset()
        quantity.reset()
    }
    
    // MARK: - Delegate Methods
    func textFieldDidEndEditing(textField: UITextField) {
        if let del = delegate {
            del.setQuantity(textField.integerValue)
        }
    }
}
