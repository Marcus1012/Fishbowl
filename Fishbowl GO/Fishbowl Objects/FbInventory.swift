//
//  FbInventory.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper

class FbInventory: Mappable {
    var QtyAvailable: UInt = 0
    var Tracking: String = ""
    var QtyOnHand: UInt = 0
    var QtyCommitted: UInt = 0
    var Part: FbPart?
    var Location: FbLocation?
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        QtyAvailable <- map["QtyAvailable"]
        Tracking = forceMapString(map, key: "Tracking")
        QtyOnHand <- map["QtyOnHand"]
        QtyCommitted <- map["QtyCommitted"]
        Part <- map["Part"]
        Location <- map["Location"]
    }
    
}
