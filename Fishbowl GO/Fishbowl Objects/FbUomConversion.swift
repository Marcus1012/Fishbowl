//
//  FbUomConversion.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
/*
 {
 "ToUOMCode": "pr",
 "ConversionFactor": 2,
 "ConversionMultiply": 1,
 "MainUOMID": 1,
 "ToUOMID": 17
 }
 */
import Foundation
import ObjectMapper

class FbUomConversion: Mappable {
    
    var ToUOMCode:          String = ""
    var ConversionFactor:   Float = 0
    var ConversionMultiply: Float = 0
    var MainUOMID:          UInt = 0
    var ToUOMID:            UInt = 0
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        ToUOMCode = forceMapString(map, key: "ToUOMCode")
        ConversionFactor <- map["ConversionFactor"]
        ConversionMultiply <- map["ConversionMultiply"]
        MainUOMID <- map["MainUOMID"]
        ToUOMID <- map["ToUOMID"]
    }
    
}
