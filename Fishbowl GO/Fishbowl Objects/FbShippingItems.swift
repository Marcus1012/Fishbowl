//
//  FbShippingItems
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbShippingItems: Mappable {
    var ShippingItem = [FbShippingItem]()

    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbShippingItems()
        
        for item in ShippingItem {
            let newItem = (item.copyWithZone(nil) as! FbShippingItem)
            copy.ShippingItem.append(newItem)
        }
        return copy
    }

    // Mappable
    func mapping(map: Map) {
        ShippingItem <- map["ShippingItem"]
        if ShippingItem.count <= 0 {
            var shippingItem: FbShippingItem?
            shippingItem <- map["ShippingItem"]
            ShippingItem.append(shippingItem!)
        }
    }
    
    func removeItem(itemNumber: String) -> Bool {
        for (idx, item) in ShippingItem.enumerate() {
            if item.ProductNumber.caseInsensitiveCompare(itemNumber) == NSComparisonResult.OrderedSame {
                ShippingItem.removeAtIndex(idx)
                return true
            }
        }
        return false
    }
    
    func removeAllItems() {
        ShippingItem.removeAll()
    }
    
    func getItemByNumber(itemNumber: String, checkForUpcMatch: Bool = false) -> FbShippingItem? {
        for (_, item) in ShippingItem.enumerate() {
            if item.matchesPartNumber(itemNumber, checkForUpcMatch: checkForUpcMatch) {
                return item
            }
        }
        return nil
    }
    
    func setItemQuantity(itemNumber: String, quantity: Int) {
        if let item = getItemByNumber(itemNumber) {
            item.QtyShipped = quantity
        }
    }
    
    /*
        Decrement the item quantity by the specified amount...
        If quantity goes to zero, remove the item from the list if desired
    */
    func decrementItemQuantity(itemNumber: String, quantity: Int, removeOnZero: Bool = true) {
        if let item = getItemByNumber(itemNumber) {
            item.decrementQuantityShipped(quantity)
            if item.QtyShipped == 0 && removeOnZero {
                removeItem(itemNumber)
            }
        }
    }

    func addShippingItem(item: FbShippingItem) {
        ShippingItem.append(item)
    }
    
    func addShippingItems(items: [FbShippingItem]) {
        ShippingItem += items
    }
    
    /*
        Looks for an existing item matching by product number, if found
        the existing item's quantity is set to the passed-in item's quantity;
        otherwise, the item is appended to the shipping item list.
    */
    func mergeShippingItem(item: FbShippingItem) {
        if let curItem = getItemByNumber(item.ProductNumber) {
            curItem.setQuantityShipped(item.QtyShipped)
            curItem.ShipItemID = item.ShipItemID
        } else {
            addShippingItem(item)
        }
    }
    
    func itemsRemaining() -> Int {
        var remaining = 0
        
        for (_, item) in ShippingItem.enumerate() {
            remaining += item.QtyShipped
        }
        return remaining
    }

    func getTotalWeight() -> Float {
        var totalWeight: Float = 0
        
        for item in ShippingItem {
            totalWeight += (Float(item.QtyShipped) * item.Weight)
        }
        return totalWeight
    }
    
    func debugPrint() {
        for item in ShippingItem {
            print("  \(item.ProductNumber), \(item.QtyShipped)")
        }
    }
    
    // Checks to see if a shipitem exists with the specified ID
    func shipItemExists(id: Int) -> Bool {
        for item in ShippingItem {
            if item.ShipItemID == id {
                return true
            }
        }
        return false
    }

}
