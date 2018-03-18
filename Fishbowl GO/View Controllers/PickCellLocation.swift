//
//  PickCellLocation.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 10/3/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit


class PickCellLocation: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var btnLock: LockButton!
    @IBOutlet var btnScan: UIButton!
    @IBOutlet var locationField: LocationTextField!
    
    var setDelegate: ((field: LocationTextField)-> Void)? //add this extra var

    
    @IBAction func toggleLock(sender: LockButton) {
        locationField.enabled = !locationField.enabled
        btnScan.enabled = !btnScan.enabled
    }
    
    @IBAction func btnScan(sender: UIButton) {
        if setDelegate != nil {
            setDelegate!(field: locationField)
        }
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
    
    func setLocationText(text: String) {
        locationField.text = text
    }
    
    func disable() {
        btnLock.lock()
        btnLock.enabled = false
        locationField.enabled = false
        locationField.text = "N/A"
        btnScan.enabled = false
    }
    
    func setLocationCache(cache: LocationCache) {
        locationField.lookupDelegate = cache
    }
}
