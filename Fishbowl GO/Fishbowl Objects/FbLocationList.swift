//
//  FbLocationList.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
/*
 Fishbowl API Documentation:
 
 <Location>
     <Location>
        ...
     </Location>
 </Location>
*/

import Foundation
import ObjectMapper


class FbLocationList: Mappable {

    var Location = [FbLocation]()

    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbLocationList()

        for location in Location {
            let newLocation = location.copyWithZone(zone) as! FbLocation
            copy.Location.append(newLocation)
        }
        
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        Location <- map["Location"]
        if Location.count <= 0 {
            var newLocation: FbLocation?
            newLocation <- map["Location"]
            Location.append(newLocation!)
        }
    }
}
