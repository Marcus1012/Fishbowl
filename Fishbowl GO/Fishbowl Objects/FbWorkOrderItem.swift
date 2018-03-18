//
//  FbWorkOrderItem.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper

class FbWorkOrderItem: Mappable {
    var status: String = ""
    var woNum: String = ""
    var type: String = ""
    var moNum: UInt = 0
    var moId: UInt = 0
    var id: UInt = 0
    var bomNum: String = ""
    var bomId: UInt = 0
    var dateScheduledFulfillment: String = ""
    
    required init(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        status = forceMapString(map, key: "Status")
        woNum  = forceMapString(map, key: "WONum")
        type = forceMapString(map, key: "Type")
        moNum <- map["MONum"]
        moId <- map["MOID"]
        id <- map["ID"]
        bomNum = forceMapString(map, key: "BOMNum")
        bomId <- map["BOMID"]
        dateScheduledFulfillment <- map["DateScheduledFulfillment"]
    }
    
}
