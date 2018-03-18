//
//  LocationTextField.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/14/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit


class LocationTextField: ScannableTextField, FBLocationDelegate {
    var locationId: Int = 0
    var lookupDelegate: FBLocationLookupDelegate? = nil
    

    // MARK: - Delegate Methods
    func didSelectLocation(location: FbLocation) {
        self.text = location.getFullName()
        self.locationId = location.LocationID
    }
    
    override func receivedScanCode(code: String) {
        var scanCode = code
        if let lookupDelegate = self.lookupDelegate {
            if let location = lookupDelegate.lookupLocation(code) {
                scanCode = location.getFullName()
            }
        }
        super.receivedScanCode(scanCode)
    }

    
    func getCurrentLocation() -> FbLocation? {
        if let lookupDelegate = self.lookupDelegate {
            return lookupDelegate.lookupLocation(self.stringValue)
        }
        return nil
    }
}
