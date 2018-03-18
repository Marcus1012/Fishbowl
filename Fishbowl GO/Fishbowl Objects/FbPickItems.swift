//
//  FbPickItems.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbPickItems: Mappable {
    var PickItem = [FbPickItem]()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbPickItems()
        
        for item in PickItem {
            let newItem = (item.copyWithZone(zone) as! FbPickItem)
            copy.PickItem.append(newItem)
        }
        return copy
    }

    // Mappable
    func mapping(map: Map) {
        PickItem <- map["PickItem"]
        if PickItem.count <= 0 {
            var pickItem: FbPickItem?
            pickItem <- map["PickItem"]
            PickItem.append(pickItem!)
        }
    }
    
    func getPickItem(index: Int) -> FbPickItem? {
        if index >= 0 && index < PickItem.count {
            return PickItem[index]
        }
        return nil
    }
    
    func add(item: FbPickItem) {
        PickItem.append(item)
    }
    
    /*
        Lookup a pick item by its name (and location if provided).
        If no location provided, just find first item by the name.
        Name is compared case-INsensitive
    */
    func lookupPickItem(partNumber: String, location:FbLocation? = nil) -> (Int, FbPickItem?) {
        for (index, item) in PickItem.enumerate() {
            if let location = location {
                if item.matchesPartNumber(partNumber, checkForUpcMatch: true) && item.Location == location {
                    return (index, item)
                }
            } else {
                if item.matchesPartNumber(partNumber, checkForUpcMatch: true) {
                    return (index, item)
                }
            }
        }
        
        // If location was provided but we didn't find the item, try searching without the source location
        // (could be that the item is being picked from a different location)
        if location != nil {
            for (index, item) in PickItem.enumerate() {
                if item.matchesPartNumber(partNumber, checkForUpcMatch: true) {
                    return (index, item)
                }
            }
        }
        return (-1, nil)
    }

    // Lookup a pick item by its ID
    func lookupPickItem(id: Int) -> (Int, FbPickItem?) {
        for (index, item) in PickItem.enumerate() {
            if id == item.PickItemID {
                return (index, item)
            }
        }
        return (-1, nil)
    }
    
    func resetQuantity(quantity: Int) {
        for item in PickItem {
            item.Quantity = quantity
        }
    }
    
    func allItemsPicked() -> Bool {
        for item in PickItem {
            if item.Quantity > 0 || item.Status != Constants.PickStatus.Finished {
                return false
            }
        }
        return true
    }
    
    func removeAtIndex(index: Int) {
        PickItem.removeAtIndex(index)
    }
    
    func removeItemsWithStatus(statuses: [UInt]) {
        for (index, item) in PickItem.enumerate().reverse() {
            if statuses.contains(item.Status) {
                PickItem.removeAtIndex(index)
            }
        }
    }

    func removeItemsWithZeroQuantity() {
        for (index, item) in PickItem.enumerate().reverse() {
            if item.Quantity <= 0 {
                PickItem.removeAtIndex(index)
            }
        }
    }
    
    func removeAll() {
        PickItem.removeAll()
    }
}
