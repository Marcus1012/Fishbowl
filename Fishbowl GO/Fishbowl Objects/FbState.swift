//
//  FbState.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//


import Foundation
import ObjectMapper


class FbState: Mappable {
    var Code: String = ""
    var ID: UInt = 0
    var Name: String = ""
    var CountryID: UInt = 0
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        Code = forceMapString(map, key: "Code")
        CountryID <- map["CountryID"]
        ID <- map["ID"]
        Name = forceMapString(map, key: "Name")
    }
}
