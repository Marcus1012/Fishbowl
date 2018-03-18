//
//  WorkOrderCellLocation.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 12/7/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit

class WorkOrderCellLocation: UITableViewCell, UITextFieldDelegate {
    
    private var lockedState = false
    
    @IBOutlet var btnLock: LockButton!
    @IBOutlet var btnScan: UIButton!
    @IBOutlet var locationField: LocationTextField!
    
    var setDelegate: ((field: LocationTextField)-> Void)? //add this extra var
    
    
    @IBAction func toggleLock(sender: LockButton) {
        locationField.enabled = !locationField.enabled
        btnScan.enabled = !btnScan.enabled
        lockedState = !lockedState
    }
    
    @IBAction func btnScan(sender: UIButton) {
        if setDelegate != nil {
            setDelegate!(field: locationField)
        }
    }
    
    func isLocked() -> Bool {
        return lockedState
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func closeKeyboard() {
        self.locationField.endEditing(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        closeKeyboard()
    }

    func setLocationCache(cache: LocationCache) {
        locationField.lookupDelegate = cache
    }
}
