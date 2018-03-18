//
//  ScannableTextField.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/14/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit


class ScannableTextField: UITextField, FBScannerDelegate {

    func setEnable(isEnabled: Bool) {
        enabled = isEnabled
        userInteractionEnabled = isEnabled
    }
    
    // MARK: - Delegate Methods
    
    func receivedScanCode(code: String) {
        self.text = code
    }
    
}
