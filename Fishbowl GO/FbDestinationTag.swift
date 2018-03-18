//
//  FbDestinationTag.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbDestinationTag: Mappable {
    var Tag: FbTag = FbTag()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbDestinationTag()
        
        copy.Tag = Tag.copyWithZone(zone) as! FbTag
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        Tag <- map["Tag"]
    }
    
    func getLocation() -> FbLocation {
        return Tag.getLocation()
    }
    
    func setLocation(location: FbLocation) {
        Tag.setLocation(location)
    }
}
