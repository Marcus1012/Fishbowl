//
//  PickCellQuantity.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 10/3/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit


class PickCellQuantity: UITableViewCell, UITextFieldDelegate {
    
    
    @IBOutlet var quantityField: UITextField!
    @IBOutlet var uomLabel: UILabel!
    
    override func didMoveToSuperview() {
        quantityField.addDismissButton()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func closeKeyboard() {
        self.quantityField.endEditing(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        closeKeyboard()
    }
}
