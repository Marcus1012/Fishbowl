//
//  FbInventoryQuantity.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper

class FbInventoryQuantity: Mappable {
    
    var InvQty = [FbInventory]()
    
    required init(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        InvQty <- map["InvQty"]
        if InvQty.count <= 0 {
            var fbInventory = FbInventory()
            fbInventory <- map["InvQty"]
            InvQty.append(fbInventory)
        }
    }
    
}
