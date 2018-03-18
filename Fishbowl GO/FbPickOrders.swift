//
//  FbPickOrders.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbPickOrders: Mappable {
    var PickOrder = [FbPickOrder]()

    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbPickOrders()
        
        for item in PickOrder {
            let newItem = (item.copyWithZone(zone) as! FbPickOrder)
            copy.PickOrder.append(newItem)
        }
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        PickOrder <- map["PickOrder"]
        if PickOrder.count <= 0 {
            var pickOrder: FbPickOrder?
            pickOrder <- map["PickOrder"]
            PickOrder.append(pickOrder!)
        }
    }
    
}
