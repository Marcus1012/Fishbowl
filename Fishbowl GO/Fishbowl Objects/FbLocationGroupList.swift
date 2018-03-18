//
//  FbLocationGroupList.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
/*
 Fishbowl API Documentation:
 
 <LocationGroup>
     <LocationGroup>
        ...
     </LocationGroup>
 </LocationGroup>
*/

import Foundation
import ObjectMapper


class FbLocationGroupList: Mappable {

    var LocationGroup = [FbLocationGroup]()

    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbLocationGroupList()

        for locationGroup in LocationGroup {
            let newLocationGroup = locationGroup.copyWithZone(zone) as! FbLocationGroup
            copy.LocationGroup.append(newLocationGroup)
        }
        
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        LocationGroup <- map["LocationGroup"]
        if LocationGroup.count <= 0 {
            var newLocationGroup: FbLocationGroup?
            newLocationGroup <- map["LocationGroup"]
            LocationGroup.append(newLocationGroup!)
        }
    }
}
