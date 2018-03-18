//
//  FbConsumeItems.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbConsumeItems: Mappable {
    var ConsumeItem = [FbConsumeItem]()

    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbConsumeItems()
        
        for item in ConsumeItem {
            let newItem = (item.copyWithZone(zone) as! FbConsumeItem)
            copy.ConsumeItem.append(newItem)
        }
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        ConsumeItem <- map["ConsumeItem"]
        if ConsumeItem.count <= 0 {
            var consumeItem: FbConsumeItem?
            consumeItem <- map["ConsumeItem"]
            if let conItem = consumeItem {
                ConsumeItem.append(conItem)
            }
        }
    }
    
    func getCount() -> Int {
        return ConsumeItem.count
    }
 
    func hasConsumableItems() -> Bool {
        return ConsumeItem.count > 0 ? true : false
    }

    func getItemAtIndex(index: Int) -> FbConsumeItem? {
        if index >= 0 && index < ConsumeItem.count {
            return ConsumeItem[index]
        }
        return nil
    }
    
    func getQuantitySum() -> Float {
        var sum: Float = 0.0
        for item in ConsumeItem {
            sum += item.Quantity
        }
        return sum
    }
    
    func append(item: FbConsumeItem) {
        ConsumeItem.append(item)
    }
    
    func removeAll(keepCapacity: Bool) {
        ConsumeItem.removeAll(keepCapacity: keepCapacity)
    }
}
