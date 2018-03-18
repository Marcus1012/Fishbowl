//
//  FbAvailablePickLocations.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbAvailablePickLocations: Mappable {

    var LocationID: Int = 0
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        LocationID <- map["LocationID"]
    }
}
