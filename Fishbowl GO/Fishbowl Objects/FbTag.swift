//
//  FbTag.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbTag: Mappable {
    var TypeID: UInt = 0
    var AccountID: UInt = 0
    var Num: Int  = -1
    var PartNum: String = ""
    var TagID: UInt = 0
    var Quantity: UInt = 0
    var QuantityCommitted: UInt = 0
    var DateCreated: String = ""
    var Location: FbLocation = FbLocation()
    
    init() {}
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbTag()

        copy.TypeID = TypeID
        copy.AccountID = AccountID
        copy.Num = Num
        copy.PartNum = PartNum
        copy.TagID = TagID
        copy.Quantity = Quantity
        copy.QuantityCommitted = QuantityCommitted
        copy.DateCreated = DateCreated
        copy.Location = Location.copyWithZone(zone) as! FbLocation
        
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        TypeID <- map["TypeID"]
        AccountID <- map["AccountID"]
        Num <- map["Num"]
        PartNum = forceMapString(map, key: "PartNum")
        TagID <- map["TagID"]
        Quantity <- map["Quantity"]
        QuantityCommitted <- map["QuantityCommitted"]
        DateCreated <- map["DateCreated"]
        Location <- map["Location"]
    }

    func setNum(num: Int) {
        Num = num
    }
    
    func getLocation() -> FbLocation {
        return Location
    }
    
    func setLocation(location: FbLocation) {
        Location = location
    }

}
