//
//  FbShipment.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbShipment: Mappable {
    var Status: UInt = 0
    //var Address: FbAddress?
    var ShipmentNumber: String = ""
    var OrderNumber: String = ""
    var CartonCount: UInt = 0
    var DateLastModified: NSDate?
    var Contact: String = ""
    var OrderType: String = ""
    var Note: String = ""
    var CreatedDate: NSDate?
    var FOB: String = ""
    var ID: UInt =  0
    var Carrier: String = ""
    var Cartons = [FbCarton]()

    required init(_ map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        Status <- map["Status"]
        //Address <- map["Address"]
        ShipmentNumber = forceMapString(map, key: "ShipmentNumber")
        OrderNumber = forceMapString(map, key: "OrderNumber")
        CartonCount <- map["CartonCount"]
        DateLastModified <- map["DateLastModified"]
        Contact = forceMapString(map, key: "Contact")
        OrderType = forceMapString(map, key: "OrderType")
        Note = forceMapString(map, key: "Note")
        CreatedDate <- map["CreatedDate"]
        FOB = forceMapString(map, key: "FOB")
        ID <- map["ID"]
        Carrier = forceMapString(map, key: "Carrier")
        
        // Handle either Array or Single item in list
        Cartons <- map["Cartons.Carton"]
        if Cartons.count <= 0 {
            var item: FbCarton?
            item <- map["Cartons.Carton"]
            Cartons.append(item!)
        }
    }
    
    func removeItem(itemNumber: String) {
        for carton in Cartons {
            if carton.removeItem(itemNumber) {
                return
            }
        }
    }

}
