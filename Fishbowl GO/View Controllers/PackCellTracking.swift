//
//  PackCellTracking.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 11/15/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit

class PackCellTracking: UITableViewCell {

    private var isDateType: Bool = false
    
    @IBOutlet weak var trackingTypeLabel: UILabel!
    @IBOutlet weak var trackingField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setDateType(isDate: Bool) {
        isDateType = isDate
        if isDateType {
            trackingField.placeholder = "MM/DD/YYYY"
        }
    }
    
    func setTextLabel(text: String) {
        if isDateType {
            let dateArr = text.characters.split{$0 == "T"}.map(String.init)
            trackingField.text = dateArr[0]
        } else {
            trackingField.text = text
        }
    }

    func setTypeLabel(text: String) {
        trackingTypeLabel.text = text
    }
}
