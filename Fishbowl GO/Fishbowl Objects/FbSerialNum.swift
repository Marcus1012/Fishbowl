//
//  FbSerialNum.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper

class FbSerialNum: Mappable {
    
    var SerialNumID: Int = -1
    var Number: String = ""
    var SerialID: Int = -1
    var PartTracking = FbPartTracking()
    
    init() {}
    init(serialNumber: String) {
        Number = serialNumber
    }
    convenience init(serialNumber: String, partTracking: FbPartTracking) {
        self.init(serialNumber: serialNumber)
        PartTracking = partTracking
    }
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbSerialNum()
        
        copy.SerialNumID = SerialNumID
        copy.Number = Number
        copy .SerialID = SerialID
        copy.PartTracking = (PartTracking.copyWithZone(nil) as! FbPartTracking)
        return copy
    }

    // Mappable
    func mapping(map: Map) {
        SerialNumID     <- map["SerialNumID"]
        SerialID        <- map["SerialID"]
        PartTracking    <- map["PartTracking"]
        Number          = forceMapString(map, key: "Number")
    }
    
}
