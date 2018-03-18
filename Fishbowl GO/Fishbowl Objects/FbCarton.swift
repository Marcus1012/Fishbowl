//
//  FbCarton.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbCarton: Mappable {
    var ID: Int = 0
    var ShipID: Int = 0
    var CartonNum: Int = 1
    var TrackingNum: String = ""
    var FreightWeight: Float = 0.0
    var NewFlag: Bool = true
    var ShippingItems = FbShippingItems()
    //var FreightAmount: Float = 0.0
    var notMapped_FreightAmount: Float = 0.0
    
    init() {}
    init(cartonNumber: Int) {
        CartonNum = cartonNumber
    }
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        CartonNum <- map["CartonNum"]
        TrackingNum = forceMapString(map, key: "TrackingNum")
        ShipID <- map["ShipID"]
        ID <- map["ID"]
        FreightWeight <- map["FreightWeight"]
        ShippingItems <- map["ShippingItems"]
        notMapped_FreightAmount <- map["FreightAmount"]
    }

    // Removes the entire item from the ShippingItems
    func removeItem(itemNumber: String) -> Bool {
        if ShippingItems.removeItem(itemNumber) {
            updateFreightWeight()
            return true
        }
        return false
    }
    
    func removeAllItems() {
        ShippingItems.removeAllItems()
        updateFreightWeight()
    }
    
    func setItemQuantity(itemNumber: String, quantity: Int) {
        ShippingItems.setItemQuantity(itemNumber, quantity: quantity)
        updateFreightWeight()
    }
    
    func addShippingItem(item: FbShippingItem) {
        ShippingItems.addShippingItem(item)
        updateFreightWeight()
    }
    
    func itemsRemaining() -> Int {
        return ShippingItems.itemsRemaining()
    }

    func getShippingItemsCopy() -> FbShippingItems {
        return (ShippingItems.copyWithZone(nil) as! FbShippingItems)
    }
    
    func mergeShippingItem(item: FbShippingItem) {
        ShippingItems.mergeShippingItem(item)
        updateFreightWeight()
    }
    
    private func updateFreightWeight() {
        FreightWeight = ShippingItems.getTotalWeight()
    }
    
    func resetShipId() {
        ID = 0
        ShipID = 0
        NewFlag = true
    }

    func resetAll() {
        resetShipId()
        CartonNum = 1
        TrackingNum = ""
        FreightWeight = 0.0
        notMapped_FreightAmount = 0.0
        removeAllItems()
    }
}
