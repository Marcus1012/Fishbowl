//
//  FbLocationGroup.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
/*
 Fishbowl API Documentation:
 
 <LocationGroup>
	<LocationGroupID>int</LocationGroupID>
	<LocationGroupName>string (REQUIRED)</LocationGroupName>
	<UsersDefaultLG>boolean</UsersDefaultLG>
 </LocationGroup>
*/

import Foundation
import ObjectMapper


class FbLocationGroup: Mappable {

    var LocationGroupID: Int = 0
    var LocationGroupName: String = ""
    var UsersDefaultLG: Bool = false
    var DefaultQBClassID: Int = 0
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbLocationGroup()
        
        copy.LocationGroupID = LocationGroupID
        copy.LocationGroupName = LocationGroupName
        copy.UsersDefaultLG = UsersDefaultLG
        copy.DefaultQBClassID = DefaultQBClassID
        
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        LocationGroupID <- map["LocationGroupID"]
        LocationGroupName = forceMapString(map, key: "LocationGroupName")
        UsersDefaultLG <- map["UsersDefaultLG"]
        DefaultQBClassID <- map["DefaultQBClassID"]
    }
}
