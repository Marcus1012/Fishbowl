//
//  FbPick.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbPick: Mappable {
    var Status: String = ""
    var TypeID: UInt = 0
    var DateStarted: String = ""
    var DateCreated: String = ""
    var DateScheduled: String = ""
    var DateLastModified: String = ""
    var UserName: String = ""
    var PickID: UInt = 0
    var Priority: String = ""
    var PickItems = FbPickItems()
    var LocationGroupID: UInt = 0
    var Type: String = ""
    var Number: String = ""
    var StatusID: UInt = 0
    var PriorityID: UInt = 0
    var PickOrders = FbPickOrders()

    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbPick()
        
        copy.Status = Status
        copy.TypeID = TypeID
        copy.DateStarted = DateStarted
        copy.DateCreated = DateCreated
        copy.DateScheduled = DateScheduled
        copy.DateLastModified = DateLastModified
        copy.UserName = UserName
        copy.PickID = PickID
        copy.Priority = Priority
        copy.LocationGroupID = LocationGroupID
        copy.Type = Type
        copy.Number = Number
        copy.StatusID = StatusID
        copy.PriorityID = PriorityID
        copy.PickItems = PickItems.copyWithZone(zone) as! FbPickItems
        copy.PickOrders = PickOrders.copyWithZone(zone) as! FbPickOrders
        return copy
    }

    // Mappable
    func mapping(map: Map) {
        Status = forceMapString(map, key: "Status")
        TypeID <- map["TypeID"]
        UserName = forceMapString(map, key: "UserName")
        PickID <- map["PickID"]
        Priority  = forceMapString(map, key: "Priority")
        LocationGroupID <- map["LocationGroupID"]
        Type = forceMapString(map, key: "Type")
        Number = forceMapString(map, key: "Number")
        StatusID <- map["StatusID"]
        PriorityID <- map["PriorityID"]
        PickItems <- map["PickItems"]
        PickOrders <- map["PickOrders"]
        
        DateStarted <- map["DateStarted"]
        DateCreated <- map["DateCreated"]
        DateScheduled <- map["DateScheduled"]
    }
    
    /*
        Gets the pick item at the given index for items with the
        requested status.
    */
    func getPickItem(index: Int, withStatus: UInt) -> FbPickItem? {
        var curIndex = 0
        for (_, item) in PickItems.PickItem.enumerate() {
            if item.Status == withStatus {
                if curIndex == index {
                    return item
                }
                curIndex += 1
            }
        }
        return nil
    }
    
    func getPickItem(partNum: String) -> FbPickItem? {
        let (_, item) = PickItems.lookupPickItem(partNum)
        return item
    }
    
    func getPickItem(id: Int) -> FbPickItem? {
        let (_, item) = PickItems.lookupPickItem(id)
        return item
    }
    
    /*
        Check to see if a pick exists (lookup by part number).
    */
    func pickItemExists(partNumber: String) -> Bool {
        for (_, item) in PickItems.PickItem.enumerate() {
            if item.Part.Num == partNumber {
                return true
            }
        }
        return false
    }
    
    /*
        Get the index of the item with the given number, and the given status
        Returns -1 if part not found.
    */
    func getPickItemIndex(partNumber: String, withStatus: UInt) -> Int {
        var curIndex = -1
        for (_, item) in PickItems.PickItem.enumerate() {
            if item.Status == withStatus {
                curIndex += 1
                if partNumber.caseInsensitiveCompare(item.Part.Num) == NSComparisonResult.OrderedSame {
                    return curIndex
                }
            }
        }
        return -1
    }
    
    
    /*
        Pass in 0 to get the total count of all pick items
    */
    func getItemCount(withStatus: UInt) -> Int {
        var count: Int = 0
        if withStatus == 0 {
            return PickItems.PickItem.count
        }
        for (_, item) in PickItems.PickItem.enumerate() {
            count += (item.Status == withStatus ? 1 : 0)
        }
        return count
    }
    
    func getPickItemsCopy() -> FbPickItems {
        return PickItems.copyWithZone(nil) as! FbPickItems
    }
    
    // Any items on the pick that have zero qty should be removed
    private func removeZeroQtyItems() {
        PickItems.removeItemsWithZeroQuantity()
    }
    
    func replacePickedItems(pickedItems: FbPickItems) {
        // Find the pick items, by ID, that match the picked items... decriment their quantity
        // and leave their status as-is.
        for pickItem in pickedItems.PickItem {
            if let existingItem = getPickItem(pickItem.PickItemID) {
                existingItem.subtractQuantity(pickItem.Quantity)
            }
        }
        removeZeroQtyItems()
        
        // Set pick item ID to zero for items that have been picked (partialy at least)
        for pickItem in pickedItems.PickItem {
            if let existingItem = getPickItem(pickItem.PickItemID) {
                existingItem.PickItemID = 0
            }
        }

        // Now, add the picked items to the pick...
        for pickItem in pickedItems.PickItem {
            PickItems.add(pickItem)
        }
    }
    
}



















