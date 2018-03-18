//
//  FbShipSearchItem.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbShipSearchItem: Mappable {
    var Status:       String = ""
    var OrderType:    String = ""
    var ShipToNum:    UInt = 0
    var ShipID:       UInt = 0
    var ShipNumber:   String = ""
    var OrderNumber:  String = ""
    var ShipTo:       String = ""
    var DateScheduled:String = ""
    var Carrier:      String = ""

    required init(_ map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        Status        = forceMapString(map, key: "Status")
        OrderType     = forceMapString(map, key: "OrderType")
        ShipToNum     <- map["ShipToNum"]
        ShipID        <- map["ShipID"]
        ShipNumber    = forceMapString(map, key: "ShipNumber")
        OrderNumber   = forceMapString(map, key: "OrderNumber")
        ShipTo        = forceMapString(map, key: "ShipTo")
        DateScheduled = forceMapString(map, key: "DateScheduled")
        Carrier       = forceMapString(map, key: "Carrier")
    }

}
