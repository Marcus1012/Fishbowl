//
//  FbTracking.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbTracking: Mappable {
    var TrackingItem = [FbTrackingItem]()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbTracking()
    
        for item in TrackingItem {
            let newItem = item.copyWithZone(zone) as! FbTrackingItem
            copy.TrackingItem.append(newItem)
        }
        
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        TrackingItem <- map["TrackingItem"]
        if TrackingItem.count <= 0 {
            var trackingItem: FbTrackingItem?
            trackingItem <- map["TrackingItem"]
            TrackingItem.append(trackingItem!)
        }
    }
    
    func addTrackingItem(item: FbTrackingItem) {
        TrackingItem.append(item)
    }
    
    func addTracking(tracking: FbTracking) {
        for item in tracking.TrackingItem {
            self.addTrackingItem(item)
        }
    }
    
    func setTrackingItem(item: FbTrackingItem) {
        TrackingItem.removeAll()
        addTrackingItem(item)
    }
    
    func hasSerialTracking() -> Bool {
        for trackingItem in TrackingItem {
            if trackingItem.hasSerialTracking() {
                return true
            }
        }
        return false
    }
    
    // 0-based index for gettng tracking items that are NOT serial numbers
    func getNthNonSerialTracking(index: Int) -> FbTrackingItem? {
        var count: Int = 0
        for (_, item) in TrackingItem.enumerate() {
            if item.PartTracking.TrackingTypeID != Constants.TrackingType.SerialNumber {
                if count == index {
                    return item
                }
                count += 1
            }
        }
        return nil
    }
    
    // 0-based index for gettng tracking items that are NOT serial numbers
    func getNthSerialNumber(index:Int) -> FbSerialNum? {
        var count: Int = 0
        for item in TrackingItem {
            if item.PartTracking.TrackingTypeID == Constants.TrackingType.SerialNumber {
                for serialBox in item.SerialBoxList.SerialBox {
                    for serialNum in serialBox.SerialNumList.SerialNum {
                        if count == index {
                            return serialNum
                        }
                        count += 1
                    }
                }
            }
        }
        return nil
    }
    
    func getAllSerialNumbers() -> [String] {
        var serials = [String]()
        for item in TrackingItem {
            if item.hasSerialTracking() {
                serials.appendContentsOf(item.getAllSerialNumbers())
            }
        }
        return serials
    }
    
}
