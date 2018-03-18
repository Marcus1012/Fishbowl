//
//  FbReceivedReceipt.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbReceivedReceipt: Mappable {
    
    struct ItemTypes {
        static let NONE = 1
        static let STOCK = 10
        static let REJECT = 20
        static let SCRAP = 30
    }
    
    private static let TypeDescription: [Int: String] = [
        ItemTypes.NONE:   "None",
        ItemTypes.STOCK:  "Stock",
        ItemTypes.REJECT: "Reject",
        ItemTypes.SCRAP:  "Scrap"
    ]
    
    //var Tracking: String = ""
    var Tracking = FbTracking()
    var ItemType: UInt = 0
    var LocationID: Int = 0
    var Quantity: Int = 0
    var Reason: String = ""
    var Responsible: String =  "0" // Who is responsible for item being rejected?
    
    init() {}
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbReceivedReceipt()
        
        copy.Tracking = Tracking.copyWithZone(zone) as! FbTracking
        copy.ItemType = ItemType
        copy.LocationID = LocationID
        copy.Quantity = Quantity
        copy.Reason = Reason

        
        return copy
    }
    // Mappable
    func mapping(map: Map) {
        Tracking <- map["Tracking"]
        ItemType <- map["ItemType"]
        LocationID <- map["LocationID"]
        Quantity <- map["Quantity"]
        Reason = forceMapString(map, key: "Reason")
        
    }

    func getTracking() -> FbTracking {
        return Tracking
    }
    
    func setLocationId(locationId: Int) {
        LocationID = locationId
    }
    
    func setQuantity(quantity: Int) {
        Quantity = quantity
    }
    
    func setTracking(tracking: FbTracking?) {
        if let tracking = tracking {
            Tracking = tracking
        }
    }
}
