//
//  PickOrderCell.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/30/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit


class PickOrderCell : UITableViewCell {
    
    @IBOutlet var orderNumber: UILabel? = UILabel()
    @IBOutlet var scheduledDate: UILabel? = UILabel()
    @IBOutlet var priority: UILabel! = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
