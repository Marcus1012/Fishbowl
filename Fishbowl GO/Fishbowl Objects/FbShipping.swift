//
//  FbShipping.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbShipping: Mappable {
    var ServiceItems: Bool = false
    var Status: UInt = 0
    var ShipmentNumber: String = ""
    var OrderNumber: String = ""
    var CartonCount: Int = 0
    var DateLastModified: String = ""
    var Contact: String = ""
    var Cartons = FbCartons()
    var OrderType: String = ""
    var ID: Int = 0
    var Carrier: String = ""
    //var Address = FbAddress()
    //var CreatedDate: String = ""
    //var CustomFields = FbCustomFields()
    //var Note: String = ""
    //var FOB: String = ""
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        Status <- map["Status"]
        ShipmentNumber = forceMapString(map, key: "ShipmentNumber")
        OrderNumber = forceMapString(map, key: "OrderNumber")
        CartonCount <- map["CartonCount"]
        Contact = forceMapString(map, key: "Contact")
        Cartons <- map["Cartons"]
        OrderType = forceMapString(map, key: "OrderType")
        ID <- map["ID"]
        Carrier = forceMapString(map, key: "Carrier")
        DateLastModified <- map["DateLastModified"]
    
        //CreatedDate <- map["CreatedDate"]
        //Address <- map["Address"]
        //Note <- map["Note"]
        //FOB <- map["FOB"]
        //CustomFields <- map["CustomFields"]
    }
    
    func removeItem(itemNumber: String) {
        Cartons.removeItem(itemNumber)
    }
    
    func setItemQuantity(itemNumber: String, quantity: Int) {
        Cartons.setItemQuantity(itemNumber, quantity: quantity)
    }
    
    func setStatus(status: UInt) {
        Status = status
    }
    
    func itemsRemaining() -> Int {
        return Cartons.itemsRemaining()
    }

    func getShippingItemsCopy() -> FbShippingItems {
        let shippingItems = Cartons.getShippingItemsCopy()
        return shippingItems
    }
    
    func mergeShippingItems(items: FbShippingItems) {
        //Cartons.removeAll()
        for item in items.ShippingItem {
            Cartons.mergeShippingItem(item)
        }
        CartonCount = Cartons.getCount()
    }
    
    func addCarton(number: Int) {
        Cartons.addCarton(number)
        CartonCount = Cartons.getCount()
    }
}
