//
//  FbReceiveTicket.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbReceiveTicket: Mappable {
    var VendorName:     String = ""
    var OrderType:      UInt = 0
    var LocationGroupID:UInt = 0
    var OrderNumber:    String = ""
    
    init() {}
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // required init(_ map: Map) { }
    
    // Mappable
    func mapping(map: Map) {
        VendorName = forceMapString(map, key: "VendorName")
        OrderType <- map["OrderType"]
        LocationGroupID <- map["LocationGroupID"]
        OrderNumber = forceMapString(map, key: "OrderNumber")
    }

    func getOrderNumber() -> String {
        return getOrderPrefix() + OrderNumber
    }
    
    func matchesOrderNumber(number: String) -> Bool {
        let orderNumber = getOrderNumber()
        return orderNumber.caseInsensitiveCompare(number) == .OrderedSame
    }
    
    private func getOrderPrefix() -> String {
        var prefix = ""
        switch OrderType {
            case 10:
                prefix = "P"
            case 20:
                prefix = "S"
            case 30:
                prefix = "W"
            case 40:
                prefix = "T"
            default:
                prefix = ""
        }
        return prefix
    }

    
}
