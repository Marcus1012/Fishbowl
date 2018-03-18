//
//  FbUomConversions.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper

class FbUomConversions: Mappable {
    
    var UOMConversion = [FbUomConversion]()
    
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        UOMConversion <- map["UOMConversion"]
        if UOMConversion.count <= 0 {
            var conversion: FbUomConversion?
            conversion <- map["UOMConversion"]
            UOMConversion.append(conversion!)
        }
    }
}
