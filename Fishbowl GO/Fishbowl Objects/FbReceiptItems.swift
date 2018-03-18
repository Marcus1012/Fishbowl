//
//  FbReceiptItems.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper

class FbReceiptItems: Mappable {
    
    var ReceiveItem = [FbReceiveItem]()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }

    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbReceiptItems()
        
        for item in ReceiveItem {
            let newItem = (item.copyWithZone(zone) as! FbReceiveItem)
            copy.ReceiveItem.append(newItem)
        }
        
        return copy
    }

    // Mappable
    func mapping(map: Map) {
        ReceiveItem <- map["ReceiveItem"]
        if ReceiveItem.count <= 0 {
            var receiveItem: FbReceiveItem?
            receiveItem <- map["ReceiveItem"]
            ReceiveItem.append(receiveItem!)
        }
    }
    
    func append(item: FbReceiveItem) {
        ReceiveItem.append(item)
    }
    
    func removeAllItems() {
        ReceiveItem.removeAll()
    }
    
    func getCount() -> Int {
        return ReceiveItem.count
    }
    
    func getItemIndex(id: UInt) -> Int {
        for (index, item) in ReceiveItem.enumerate() {
            if item.ID == id {
                return index
            }
        }
        return -1
    }
        
    func getItemByIndex(index: Int) -> FbReceiveItem? {
        if index >= 0 && index < getCount() {
            return ReceiveItem[index]
        }
        return nil
    }
    
    func getItemById(id: UInt) -> FbReceiveItem? {
        for item in ReceiveItem {
            if item.ID == id {
                return item
            }
        }
        return nil
    }
    
    func getPart(partNumber: String) -> FbPart? {
        for item in ReceiveItem {
            if item.Part.matchesPartNumber(partNumber) {
                return item.Part
            }
        }
        return nil
    }
    
    private func removeItemById(id: UInt) {
        for (index, item) in ReceiveItem.enumerate() {
            if item.ID == id {
                ReceiveItem.removeAtIndex(index)
                break
            }
        }
    }
    
    private func findExistingItem(itemId: UInt) -> FbReceiveItem? {
        for curItem in ReceiveItem {
            if curItem.ID == itemId {
                return curItem
            }
        }
        return nil
    }
    
    func addReceivedReceipt(itemId: UInt, receipt: FbReceivedReceipt?) {
        if let existingItem = findExistingItem(itemId) {
            existingItem.addReceivedReceipt(receipt)
        }
    }
    
    // Find the item the matches the one passed in... then
    // decriment the quantity.  If quantity goes to zero, remove
    // item from our list.
    func receive(itemId: UInt, quantity: Int ) {
        if let foundItem = findExistingItem(itemId) {
            foundItem.decrimentQuantity(quantity)
            if foundItem.Quantity <= 0 {
                removeItemById(foundItem.ID)
            }
        }
    }
}
