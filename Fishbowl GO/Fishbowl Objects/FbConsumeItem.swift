//
//  FbConsumeItem.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//


import Foundation
import ObjectMapper


class FbConsumeItem: Mappable {

    var WOItemID: Int = 0
    var UOM = FbUom()
    var Tracking: String = ""
    var PickItem = FbPickItem()
    var Part = FbPart()
    var Quantity: Float = 0.0
    var ID: Int = 0
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbConsumeItem()
        
        copy.WOItemID = WOItemID
        copy.UOM = UOM.copyWithZone(zone) as! FbUom
        copy.Tracking = Tracking
        copy.PickItem = PickItem.copyWithZone(zone) as! FbPickItem
        copy.Part = Part.copyWithZone(zone) as! FbPart
        copy.Quantity = Quantity
        copy.ID = ID

        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        WOItemID    <- map["WOItemID"]
        UOM         <- map["UOM"]
        Tracking    = forceMapString(map, key: "Tracking")
        PickItem    <- map["PickItem"]
        Part        <- map["Part"]
        Quantity    <- map["Quantity"]
        ID          <- map["ID"]
    }
}
