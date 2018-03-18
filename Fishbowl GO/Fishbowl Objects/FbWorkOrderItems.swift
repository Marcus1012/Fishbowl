//
//  FbWOItems.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbWOItems: Mappable {
    var WOItem = [FbWOItem]()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbWOItems()
        for item in WOItem {
            let woItem = item.copyWithZone(zone) as! FbWOItem
            copy.WOItem.append(woItem)
        }
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        WOItem <- map["WOItem"]
        if WOItem.count <= 0 {
            var workItem: FbWOItem?
            workItem <- map["WOItem"]
            WOItem.append(workItem!)
        }
    }
    
    func extractConsumeItems(consumeItems: FbConsumeItems) {
        for item in WOItem {
            item.extractConsumeItems(consumeItems)
        }
    }
    
    func getFinishedGoodItem() -> FbWOItem? {
        for item in WOItem {
            if item.isFinishedGoodType() {
                return item
            }
        }
        return nil
    }
}
