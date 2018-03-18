//
//  UnitCostTableViewCell.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/28/17.
//  Copyright © 2017 RPM Consulting. All rights reserved.
//

import UIKit

class UnitCostCell: UITableViewCell {

    @IBOutlet weak var fieldUnitCost: UITextField!
    
    
    func getUnitCost() -> Float {
        return fieldUnitCost.floatValue
    }

    override func reset() {
        super.reset()
        fieldUnitCost.text = ""
    }
    
}
