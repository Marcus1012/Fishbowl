//
//  MoveRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiMoveRequest : FbiRequest {
    var MoveRq : moveCore
    
    init(part: AnyObject, source: FbLocation, destination: FbLocation, quantity: UInt) {
        MoveRq = moveCore(part: part, source: source, destination: destination, quantity: quantity)
    }
    
    func addTracking(trackingValues: [String]) {
        let tracking = FbTracking()
        
        for (index, value) in trackingValues.enumerate() {
            let trackingItem = FbTrackingItem()
            let part = MoveRq.Part as! FbPart
            trackingItem.setTrackingValue(value)
            trackingItem.PartTracking = part.PartTrackingList.PartTracking[index]
            tracking.addTrackingItem(trackingItem)
        }

        MoveRq.Tracking = tracking
        
    }
    
    func addSerialTracking(trackingValues: [String]) {
        let tracking = FbTracking()
        let part = MoveRq.Part as! FbPart
        let trackingItem = FbTrackingItem()

        if let partTracking = part.PartTrackingList.getPartTrackingByType(Constants.TrackingType.SerialNumber) {
            trackingItem.setPartTracking(partTracking.copyWithZone(nil) as! FbPartTracking)
            for (_, value) in trackingValues.enumerate() { // enumerate serial #s
                trackingItem.addSerialNumber(value, partTracking: partTracking)
            }
            tracking.addTrackingItem(trackingItem)
        }
        MoveRq.Tracking = tracking
    }
    
}

class SourceLocation {
    var Location: FbLocation
    init(location: FbLocation) {
        Location = location
    }
}

class moveCore {
    class NestedLocation {
        var Location: FbLocation
        init(location: FbLocation) {
            Location = location
        }
    }
    var SourceLocation: NestedLocation
    var Tracking: AnyObject!
    var Part: AnyObject
    var Quantity: UInt = 0
    var DestinationLocation: NestedLocation
    
    init(part: AnyObject, source: FbLocation, destination: FbLocation, quantity: UInt) {
        Part = part
        SourceLocation = NestedLocation(location: source)
        DestinationLocation = NestedLocation(location: destination)
        Quantity = quantity
    }
}
