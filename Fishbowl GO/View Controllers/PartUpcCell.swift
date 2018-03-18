//
//  PartUpcCell.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/27/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit


class PartUpcCell: UITableViewCell {

    var delegate: PartDelegate?
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet var upcLabel: UILabel!
    @IBOutlet weak var upc: UITextField!
 
    @IBAction func btnSaveUpc(sender: AnyObject) {
        if let del = delegate {
            del.partUpcSave(upc.stringValue)
        }
        
    }
    
    func setEnable(enable: Bool) {
        btnSave.enabled = enable
        upc.enabled = enable
    }
}
