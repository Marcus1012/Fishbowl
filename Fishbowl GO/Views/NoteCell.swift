//
//  NoteTableViewCell.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/28/17.
//  Copyright © 2017 RPM Consulting. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {


    @IBOutlet weak var fieldNote: UITextField!

    override func reset() {
        super.reset()
        fieldNote.text = ""
    }
    
}
