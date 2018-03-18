//
//  FbPartTrackingList.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//


import Foundation
import ObjectMapper


class FbPartTrackingList: Mappable {
    var PartTracking = [FbPartTracking]()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbPartTrackingList()
        
        for item in PartTracking {
            let newItem = (item.copyWithZone(zone) as! FbPartTracking)
            copy.PartTracking.append(newItem)
        }
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        PartTracking <- map["PartTracking"]
        if PartTracking.count <= 0 {
            var partTracking: FbPartTracking?
            partTracking <- map["PartTracking"]
            PartTracking.append(partTracking!)
        }
    }
    
    func getPartTrackingByType(type: UInt) -> FbPartTracking? {
        for (_, partTracking) in PartTracking.enumerate() {
            if partTracking.TrackingTypeID == type {
                return partTracking
            }
        }
        return nil
    }
    
    func getTrackingCount() -> Int {
        return PartTracking.count
    }
    
    func getNonSerialTrackingCount() -> Int {
        var count: Int = 0
        for partTracking in PartTracking {
            if partTracking.TrackingTypeID != Constants.TrackingType.SerialNumber {
                count += 1
            }
        }
        return count
    }
    
    func getPrimaryTracking() -> FbPartTracking? {
        for partTracking in PartTracking {
            if partTracking.Primary {
                return partTracking
            }
        }
        return nil
    }
    
    func getNthNonSerialTracking(n: Int) -> FbPartTracking? {
        var curIndex: Int = 0
        
        for partTracking in PartTracking {
            if partTracking.TrackingTypeID != Constants.TrackingType.SerialNumber {
                if n == curIndex {
                    return partTracking
                }
                curIndex += 1
            }
        }
        return nil
    }
}
