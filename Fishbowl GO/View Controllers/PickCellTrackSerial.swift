//
//  PickCellTrackSerial.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 10/3/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit


class xxPickCellTrackSerial: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var serialLabel: UILabel!
    @IBOutlet var serialNumber: UITextField!
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func closeKeyboard() {
        self.serialNumber.endEditing(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        closeKeyboard()
    }
    
}
