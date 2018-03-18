//
//  TrackingCell.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 1/12/17.
//  Copyright © 2017 RPM Consulting. All rights reserved.
//

import UIKit
import DatePickerDialog


class TrackingCell: UITableViewCell {

    private var dateFormat = "MM/dd/yyyy"
    private var isDateType: Bool = false
    private var dateVal: NSDate?
   
    @IBOutlet weak var trackingTypeLabel: UILabel!
    @IBOutlet weak var trackingField: UITextField!
    @IBOutlet var btnChooseDate: UIButton!

    
    // MARK: - Actions
    @IBAction func btnChooseDate(sender: AnyObject) {
        var defaultDate = NSDate()
        if let curDate = getDate() {
            defaultDate = curDate
        }
        DatePickerDialog().show("Choose Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: defaultDate, datePickerMode: .Date) {
            (nsDate) -> Void in
            if let date = nsDate {
                self.dateVal = date
                self.trackingField.text = date.getFormattedDate("MM/dd/yyyy")
            }
        }

    }
    
    
    // MARK: - Helper Functions
    private func getDate() -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.dateFromString(trackingField.stringValue)
    }
    
    func setDelegate(delegate: UITextFieldDelegate) {
        trackingField.delegate = delegate
    }
    
    func getValue() -> String {
        if isDateType {
            if let date = getDate() {
                dateVal = date
                return date.getFormattedDate("yyyy-MM-dd")+"T00:00:00"
            }
        }
        return trackingField.stringValue
    }
    
    override func reset() {
        super.reset()
        trackingField.reset()
    }

    
    func setTrackInfo(trackingInfo: FbPartTracking?) {
        if let info = trackingInfo {
            setTypeLabel("\(info.Abbr):")
            trackingField.placeholder = info.Name
            isDateType = info.isDateType()
            if isDateType {
                btnChooseDate.hidden = false
            }
        }
    }
    
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
    
    func setDateType(isDate: Bool) {
        isDateType = isDate
        if isDateType {
            trackingField.placeholder = "MM/DD/YYYY"
        }
    }
    
    private func setTypeLabel(text: String) {
        trackingTypeLabel.text = text
    }
}
