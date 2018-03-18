//
//  PackCellQuantity.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 11/15/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit

class PackCellQuantity: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var quantityField: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
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
