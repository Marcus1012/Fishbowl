//
//  FbSerialBoxList.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper

class FbSerialBoxList: Mappable {
    
    var SerialBox = [FbSerialBox]()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbSerialBoxList()
        
        for serialBox in SerialBox {
            let newSerialBox = (serialBox.copyWithZone(nil) as! FbSerialBox)
            copy.SerialBox.append(newSerialBox)
        }
        
        return copy
    }

    
    // Mappable
    func mapping(map: Map) {
        SerialBox <- map["SerialBox"]
        
        SerialBox <- map["SerialBox"]
        if SerialBox.count <= 0 {
            var serialBox: FbSerialBox?
            serialBox <- map["SerialBox"]
            SerialBox.append(serialBox!)
        }
    }
    
    func addSerialBoxWithNumber(number: String, partTracking: FbPartTracking) {
        let serialBox = FbSerialBox(number: number, partTracking: partTracking)
        SerialBox.append(serialBox)
    }
    
    func getAllSerialNumbers() -> [String] {
        var serials = [String]()
        for serialBox in SerialBox {
            let newSerials = serialBox.getAllSerialNumbers()
            serials.appendContentsOf(newSerials)
        }
        return serials
    }
}
