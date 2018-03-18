//
//  FbDestLoation.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//


import Foundation
import ObjectMapper


class FbDestLocation: Mappable {
    var Location = FbLocation()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbDestLocation()

        copy.Location = Location.copyWithZone(zone) as! FbLocation
        
        return copy
    }
    // Mappable
    func mapping(map: Map) {
        Location <- map["Location"]
    }
    
    func setLocation(location: FbLocation) {
        Location = location
    }
}
