//
//  FbUom.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper

class FbUom: Mappable {
    var Active:     Bool = false
    var UOMID:      UInt =  0
    var Code:       String = ""
    var Integral:   Bool = false
    var Type:       String = ""
    var Name:       String = ""
    var UOMConversions = FbUomConversions()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbUom()
        
        copy.Active = Active
        copy.UOMID = UOMID
        copy.Code = Code
        copy.Integral = Integral
        copy.Type = Type
        copy.Name = Name
        
        return copy
    }

    // Mappable
    func mapping(map: Map) {
        Active         <- map["Active"]
        UOMID          <- map["UOMID"]
        Code           = forceMapString(map, key: "Code")
        Integral       <- map["Integral"]
        Type           <- map["Type"]
        Name           <- map["Name"]
        UOMConversions <- map["UOMConversions"]
    }
    
}
