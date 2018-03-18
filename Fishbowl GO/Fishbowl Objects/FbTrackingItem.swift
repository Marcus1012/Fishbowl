//
//  FbTrackingItem.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbTrackingItem: Mappable {
    var TrackingValue = ""
    var PartTracking  = FbPartTracking()
    var SerialBoxList = FbSerialBoxList()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbTrackingItem()

        copy.TrackingValue = TrackingValue
        copy.PartTracking = PartTracking.copyWithZone(nil) as! FbPartTracking
        copy.SerialBoxList = SerialBoxList.copyWithZone(nil) as! FbSerialBoxList
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        TrackingValue = forceMapString(map, key: "TrackingValue")
        PartTracking <- map["PartTracking"]
        SerialBoxList <- map["SerialBoxList"]
    }
    
    func addSerialNumber(number: String, partTracking: FbPartTracking) {
        SerialBoxList.addSerialBoxWithNumber(number, partTracking: partTracking)
    }
    
    func hasSerialTracking() -> Bool {
        return PartTracking.TrackingTypeID == Constants.TrackingType.SerialNumber
    }
    
    func setPartTracking(partTracking: FbPartTracking) {
        PartTracking = partTracking
    }
    
    func setTrackingValue(tracking: String) {
        if PartTracking.isDateType() {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            if let dateObj = dateFormatter.dateFromString(tracking) {
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                TrackingValue = dateFormatter.stringFromDate(dateObj)
                return
            }
        }
        TrackingValue = tracking
    }
    
    func getAllSerialNumbers() -> [String] {
        return SerialBoxList.getAllSerialNumbers()
    }
}
