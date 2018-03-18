//
//  FbCountry.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//


import Foundation
import ObjectMapper


class FbCountry: Mappable {
    var ID: UInt = 0
    var Code: String = ""
    var Name: String = ""
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        ID <- map["ID"]
        Code = forceMapString(map, key: "Code")
        Name = forceMapString(map, key: "Name")
    }
}
