//
//  CompatibleRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiCompatibleRequest : FbiRequest {
    var CompatibleRq : compatibleCore
    
    init(version: String, edition: String) {
        CompatibleRq = compatibleCore(version: version, edition: edition)
    }
    
}

class compatibleCore {
    var Version: String = ""
    var Edition: String = ""
    
    init(version: String, edition: String) {
        Version = version
        Edition = edition
    }
}
