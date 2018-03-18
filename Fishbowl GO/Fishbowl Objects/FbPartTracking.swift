//
//  FbPartTracking.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper

class FbPartTracking: Mappable {
    
    var Active: Bool = false
    var Description: String = ""
    var PartTrackingID: UInt = 0
    var TrackingTypeID: UInt = 0
    var Primary: Bool = false
    var SortOrder: Int = 0
    var Abbr: String = ""
    var Name: String = ""
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbPartTracking()
        
        copy.Active = Active
        copy.Description = Description
        copy.PartTrackingID = PartTrackingID
        copy.TrackingTypeID = TrackingTypeID
        copy.Primary = Primary
        copy.SortOrder = SortOrder
        copy.Abbr = Abbr
        copy.Name = Name
        
        return copy
    }

    // Mappable
    func mapping(map: Map) {
        Active <- map["Active"]
        Description = forceMapString(map, key: "Description")
        PartTrackingID <- map["PartTrackingID"]
        TrackingTypeID <- map["TrackingTypeID"]
        Primary <- map["Primary"]
        SortOrder <- map["SortOrder"]
        Abbr = forceMapString(map, key: "Abbr")
        Name = forceMapString(map, key: "Name")
    }
    
    func isDateType() -> Bool {
        if (TrackingTypeID == Constants.TrackingType.Date || TrackingTypeID == Constants.TrackingType.ExpirationDate) {
            return true
        }
        return false
    }
    
}
