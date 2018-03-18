//
//  SerialNumberTableViewCell.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 11/2/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit

class SerialNumberTableViewCell: UITableViewCell {
    
    
    @IBOutlet var serialNumber: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
