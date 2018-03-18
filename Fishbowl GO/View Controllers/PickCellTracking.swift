//
//  PickCellTracking.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 10/3/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit


class PickCellTracking: UITableViewCell, UITextFieldDelegate {
    
    private var dateDisplayFormat = "MM/dd/yyyy"
    private var dateServerFormat = "yyyy-MM-dd"

    var isDateType: Bool = false {
        didSet {
            if isDateType {
                trackingField.placeholder = "MM/DD/YYYY"
            }
        }
    }
    
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
            //datePicker.addTarget(self, action: Selector("datePickerChange"), forControlEvents: .ValueChanged)
            datePicker.addTarget(self, action: #selector(PickCellTracking.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        trackingField.text = formatter.stringFromDate(sender.date)
    }
    
    func setTextLabel(text: String) {
        trackingField.text = text
    }
    
    func setTypeLabel(text: String) {
        trackingTypeLabel.text = text
    }
    
    func getTrackingValue() -> String {
        var trackingValue = ""
        if isDateType {
            let nsDate = NSDate(dateString: trackingField.stringValue, format: dateDisplayFormat)
            trackingValue = nsDate.getFormattedDate(dateServerFormat)+"T00:00:00"
        } else {
            trackingValue = trackingField.stringValue
        }
        return trackingValue
    }
}
