//
//  AddInventoryRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 8/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiAddInventoryRequest : FbiRequest {
    var AddInventoryRq : addInventoryCore
    
    init(partNumber: String, locationTagNum: Int, quantity: UInt, unitCost: Float) {
        AddInventoryRq = addInventoryCore(partNumber: partNumber, locationTagNum: locationTagNum, quantity: quantity, unitCost: unitCost)
    }

    func addNote(note: String) {
        AddInventoryRq.Note = note
    }
    
    func addTracking(part: FbPart, trackingValues: [String]) {
        let tracking = FbTracking()
        
        for (index, value) in trackingValues.enumerate() {
            let trackingItem = FbTrackingItem()
            trackingItem.setTrackingValue(value)
            trackingItem.PartTracking = part.PartTrackingList.PartTracking[index]
            tracking.addTrackingItem(trackingItem)
        }
        AddInventoryRq.addTracking(tracking)
    }
    
    func addSerialTracking(part: FbPart, trackingValues: [String]) {
        let tracking = FbTracking()
        let trackingItem = FbTrackingItem()
        
        if let partTracking = part.PartTrackingList.getPartTrackingByType(Constants.TrackingType.SerialNumber) {
            trackingItem.setPartTracking(partTracking.copyWithZone(nil) as! FbPartTracking)
            for (_, value) in trackingValues.enumerate() { // enumerate serial #s
                trackingItem.addSerialNumber(value, partTracking: partTracking)
            }
            tracking.addTrackingItem(trackingItem)
        }
        AddInventoryRq.addTracking(tracking)
    }

}

class addInventoryCore {
    
    var PartNum: String = ""
    var Tracking: AnyObject!
    var Quantity: UInt = 0
    var LocationTagNum: Int = 0
    var TagNum: Int = 0
    var Note: String? = nil
    var UOMID: Int = 0
    var Cost: Float = 0
    
    
    init(partNumber: String, locationTagNum: Int, quantity: UInt, unitCost: Float) {
        PartNum = partNumber
        LocationTagNum = locationTagNum
        Quantity = quantity
        Cost = unitCost
    }
    
    func addTracking(tracking: FbTracking) {
        if Tracking == nil {
            Tracking = FbTracking()
        }
        
        let currentTracking = Tracking as! FbTracking
        currentTracking.addTracking(tracking)
    }
}
