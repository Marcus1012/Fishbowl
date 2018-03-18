//
//  WorkOrderCellTracking.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 12/7/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit

class WorkOrderCellTracking: UITableViewCell, UITextFieldDelegate {

    private var isDateType: Bool = false
    private var userData: AnyObject? // caller can use this to store an arbitrary object reference.
    
    @IBOutlet var trackingTypeLabel: UILabel!
    @IBOutlet var trackingField: UITextField!
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func closeKeyboard() {
        self.trackingField.endEditing(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        closeKeyboard()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if isDateType {
            let datePicker = UIDatePicker()
            textField.inputView = datePicker
            datePicker.addTarget(self, action: #selector(WorkOrderCellTracking.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        trackingField.text = formatter.stringFromDate(sender.date)
    }
    
    func setUserData(data: AnyObject?) {
        userData = data
    }
    
    func getUserData() -> AnyObject? {
        return userData
    }
    
    func setDateType(isDate: Bool) {
        isDateType = isDate
        if isDateType {
            trackingField.placeholder = "MM/DD/YYYY"
        }
    }
    
    func setTextLabel(text: String) {
        trackingField.text = text
    }
    
    func setTypeLabel(text: String) {
        trackingTypeLabel.text = text
    }
}
