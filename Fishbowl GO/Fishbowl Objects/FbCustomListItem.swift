//
//  FbCustomListItem.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
/*
 Fishbowl API Documentation:
 
 <CustomListItem>
	<ID>int</ID>
	<Name>string</Name>
	<Description>string</Description>
 </CustomListItem>
*/

import Foundation
import ObjectMapper


class FbCustomListItem: Mappable {
    var ID: UInt = 0
    var Name: String = ""
    var Description: String = ""
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        ID <- map["ID"]
        Name = forceMapString(map, key: "Name")
        Description = forceMapString(map, key: "Description")
    }
}
