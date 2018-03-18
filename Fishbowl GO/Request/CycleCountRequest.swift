//
//  CycleCountRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiCycleCountRequest : FbiRequest {
    var CycleCountRq : cycleCountCore
    
    init(partNumber: String, locationId: Int, quantity: UInt) {
        CycleCountRq = cycleCountCore(partNumber: partNumber, locationId: locationId, quantity: quantity)
    }

    func addTracking(part: FbPart, trackingValues: [String]) {
        let tracking = FbTracking()
        
        for (index, value) in trackingValues.enumerate() {
            let trackingItem = FbTrackingItem()
            trackingItem.setTrackingValue(value)
            trackingItem.PartTracking = part.PartTrackingList.PartTracking[index]
            tracking.addTrackingItem(trackingItem)
        }
        CycleCountRq.addTracking(tracking)
    }
    
    func addSerialTracking(part: FbPart, trackingValues: [String]) {
        let tracking = FbTracking()
        //let part = CycleCountRq.Part as! FbPart
        let trackingItem = FbTrackingItem()
        
        if let partTracking = part.PartTrackingList.getPartTrackingByType(Constants.TrackingType.SerialNumber) {
            trackingItem.setPartTracking(partTracking.copyWithZone(nil) as! FbPartTracking)
            for (_, value) in trackingValues.enumerate() { // enumerate serial #s
                trackingItem.addSerialNumber(value, partTracking: partTracking)
            }
            tracking.addTrackingItem(trackingItem)
        }
        CycleCountRq.addTracking(tracking)
    }

}

class cycleCountCore {
    var PartNum: String = ""
    var LocationID: Int = 0
    var Quantity: UInt = 0
    var statusCode: UInt = 0
    var Tracking: AnyObject!

    
    init(partNumber: String, locationId: Int, quantity: UInt) {
        PartNum = partNumber
        LocationID = locationId
        Quantity = quantity
    }
    
    func addTracking(tracking: FbTracking) {
        if Tracking == nil {
            Tracking = FbTracking()
        }
        
        let currentTracking = Tracking as! FbTracking
        currentTracking.addTracking(tracking)
    }
}
