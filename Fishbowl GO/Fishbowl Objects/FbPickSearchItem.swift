//
//  FbPickSearchItem.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbPickSearchItem: Mappable {
    var orderValue:      String = ""
    var number:          String = ""
    var pickId:          UInt = 0
    var priority:        String = ""
    var dateScheduled:   String = ""
    var orderTypeNumber: String = ""

    required init(_ map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        orderValue = forceMapString(map, key: "OrderValue")
        number = forceMapString(map, key: "Number")
        pickId <- map["PickID"]
        priority = forceMapString(map, key: "Priority")
        dateScheduled = forceMapString(map, key: "DateScheduled")
        orderTypeNumber = forceMapString(map, key: "OrderTypeNumber")
    }

}
