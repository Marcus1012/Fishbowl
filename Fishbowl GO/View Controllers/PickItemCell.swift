//
//  PickItemCell.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/3/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit


class PickItemCell: UITableViewCell {

    @IBOutlet var status: UILabel!
    @IBOutlet var part: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var quantity: UILabel!
    
    var partName: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
