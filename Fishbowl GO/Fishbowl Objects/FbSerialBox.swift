//
//  FbSerialBox.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper

class FbSerialBox: Mappable {
    
    var SerialNumList = FbSerialNumList()
    var TagID: Int = -1
    var SerialID: Int = -1
    var Committed: Bool = false
    
    init() {}
    init(number: String, partTracking: FbPartTracking) {
        SerialNumList.addSerialNumber(number, partTracking: partTracking)
    }
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbSerialBox()
        
        copy.TagID = TagID
        copy.SerialID = SerialID
        copy.Committed = Committed
        copy.SerialNumList = (SerialNumList.copyWithZone(nil) as! FbSerialNumList)
        
        return copy
    }

    // Mappable
    func mapping(map: Map) {
        SerialNumList <- map["SerialNumList"]
        TagID <- map["TagID"]
        SerialID <- map["SerialID"]
        Committed <- map["Committed"]
    }
    
    func getAllSerialNumbers() -> [String] {
        return SerialNumList.getAllSerialNumbers()
    }
}
