//
//  FbCartons.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//


import Foundation
import ObjectMapper


class FbCartons: Mappable {
    var Carton = [FbCarton]()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        Carton <- map["Carton"]
        if Carton.count <= 0 {
            var carton: FbCarton?
            carton <- map["Carton"]
            Carton.append(carton!)
        }
    }
    
    func resetAllShipIds() {
        for carton in Carton {
            carton.resetShipId()
        }
        
    }
    
    func removeItem(itemNumber: String) {
        for carton in Carton {
            if carton.removeItem(itemNumber) {
                return
            }
        }
    }
    
    func removeAll() {
        Carton.removeAll()
    }
    
    func resetAll() {
        for carton in Carton {
            carton.resetAll()
        }
    }
    
    func removeAllItems() {
        for carton in Carton {
            carton.removeAllItems()
            carton.FreightWeight = 0
        }
    }
    
    func setItemQuantity(itemNumber: String, quantity: Int) {
        for carton in Carton {
            carton.setItemQuantity(itemNumber, quantity: quantity)
        }
    }
    
    func itemsRemaining() -> Int {
        var remaining = 0
        for carton in Carton {
            remaining += carton.itemsRemaining()
        }
        return remaining
    }
    
    func getShippingItemsCopy() -> FbShippingItems {
        let shippingItems = FbShippingItems()
        
        for carton in Carton {
            let items = carton.getShippingItemsCopy()
            shippingItems.addShippingItems(items.ShippingItem)
        }
        return shippingItems
    }
    
    func mergeShippingItem(item: FbShippingItem) {
        if item.CartonName < 1 {
            return
        }
        
        if let carton = getCarton(item.CartonName) {
            carton.mergeShippingItem(item)
        }
    }
    
    func addCarton(number: Int) -> FbCarton? {
        if number < 1 {
            return nil
        }

        for carton in Carton {
            if carton.CartonNum == number {
                return carton
            }
        }
        let newCarton = FbCarton(cartonNumber: number)
        Carton.append(newCarton)
        return newCarton
    }
    
    func getCount() -> Int {
        return Carton.count
    }
    
    private func getCarton(cartonNumber: Int) -> FbCarton? {
        for carton in Carton {
            if carton.CartonNum == cartonNumber {
                return carton
            }
        }
        return addCarton(cartonNumber)
    }

}
