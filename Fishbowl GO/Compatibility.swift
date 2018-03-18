//
//  Compatability.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/4/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class Compatibility {
    var license:    String = ""
    var compatible: Bool = false
    var status:     Int = 0
    
    func isFullVersion() -> Bool {
        return license == "FULL" ? true : false
    }
    
    func reset() {
        license = ""
        compatible = false
        status = 0
    }
}
