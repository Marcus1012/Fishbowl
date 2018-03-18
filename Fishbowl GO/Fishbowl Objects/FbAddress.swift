//
//  FbAddress.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//


import Foundation
import ObjectMapper


class FbAddress: Mappable {

    var Zip: String = ""
    var Attn: String = ""
    var Type: String = ""
    var Residential: Bool = false
    var State = FbState()
    var Street: String = ""
    var Country = FbCountry()
    var ID: UInt = 0
    var City: String = ""
    var Default: Bool = false
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        Zip = forceMapString(map, key: "Zip")
        Attn = forceMapString(map, key: "Attn")
        Type = forceMapString(map, key: "Type")
        Residential <- map["Residential"]
        State <- map["State"]
        Street = forceMapString(map, key: "Street")
        Country <- map["Country"]
        ID <- map["ID"]
        City = forceMapString(map, key: "City")
        Default <- map["Default"]
    }
}
