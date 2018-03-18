//
//  FbSerialNumList.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper

class FbSerialNumList: Mappable {
    
    var SerialNum = [FbSerialNum]()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }

    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbSerialNumList()
        
        for serialNum in SerialNum {
            let newSerialNum = (serialNum.copyWithZone(nil) as! FbSerialNum)
            copy.SerialNum.append(newSerialNum)
        }
        
        return copy
    }

    // Mappable
    func mapping(map: Map) {
        //SerialNum <- map["SerialNum"]
        
        SerialNum <- map["SerialNum"]
        if SerialNum.count <= 0 {
            var serialNum: FbSerialNum?
            serialNum <- map["SerialNum"]
            SerialNum.append(serialNum!)
        }
    }
    
    func addSerialNumber(number: String, partTracking: FbPartTracking) {
        let serialNumber = FbSerialNum(serialNumber: number, partTracking: partTracking)
        SerialNum.append(serialNumber)
    }
    
    func getAllSerialNumbers() -> [String] {
        var serials = [String]()
        for serialNum in SerialNum {
            serials.append(serialNum.Number)
        }
        return serials
    }
}
