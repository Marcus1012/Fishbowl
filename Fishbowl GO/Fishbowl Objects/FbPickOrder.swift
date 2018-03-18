//
//  FbPickOrder.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper

class FbPickOrder: Mappable {

    var OrderType: String = ""
    var OrderNum: String = ""
    var OrderTypeID: UInt = 0
    var Note: String = ""
    var OrderID: UInt = 0
    var OrderTo: String = ""
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbPickOrder()
        
        copy.OrderType = OrderType
        copy.OrderNum = OrderNum
        copy.OrderTypeID = OrderTypeID
        copy.Note = Note
        copy.OrderID = OrderID
        copy.OrderTo = OrderTo

        return copy
    }
    // Mappable
    func mapping(map: Map) {
        OrderType = forceMapString(map, key: "OrderType")
        OrderNum = forceMapString(map, key: "OrderNum")
        OrderTypeID <- map["OrderTypeID"]
        Note = forceMapString(map, key: "Note")
        OrderID <- map["OrderID"]
        OrderTo = forceMapString(map, key: "OrderTo")
    }
    
}
