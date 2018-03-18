//
//  LockButton.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 2/25/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit

class LockButton: UIButton {
    
    // Images
    let lockedImage = UIImage(named: "locked-20")! as UIImage
    let unlockedImage = UIImage(named: "unlocked-20")! as UIImage
    
    // Bool property
    var isLocked: Bool = false {
        didSet {
            if isLocked == true {
                self.setImage(lockedImage, forState: .Normal)
            } else {
                self.setImage(unlockedImage, forState: .Normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(CheckBox.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.isLocked = false
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self {
            if isLocked == true {
                isLocked = false
            } else {
                isLocked = true
            }
        }
    }
    
    func lock() {
        self.isLocked = true
    }

    func unlock() {
        self.isLocked = false
    }

}
