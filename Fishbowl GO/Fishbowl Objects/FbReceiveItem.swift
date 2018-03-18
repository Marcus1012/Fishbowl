//
//  FbReceiveItem.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper

/*
 public enum Status {
 NONE(1, "None"),
 ENTERED(10, "Entered"),
 RECONCILED(20, "Reconciled"),
 RECEIVED(30, "Received"),
 FULFILLED(40, "Fulfilled"),
 ;
 */


class FbReceiveItem: Mappable {
    
    private static let StatusDescription: [UInt: String] = [
        1: "None",
        10: "Entered",
        20: "Reconciled",
        30: "Received",
        40: "Fulfilled"
    ]
    
    var ItemStatus: UInt = 0
    var Description: String = ""
    var LinkedOrders: String = ""
    var LandedUnitCost: Float = 0
    var ItemType: UInt = 0
    var ItemNum: String = ""
    var TrackingNum: String = ""
    var LineNum: UInt = 0
    var OrderType: UInt = 0
    var ReceiptID: UInt = 0
    var OrderNum: String = ""
    var PackageCount: UInt = 0
    var PoItemId: UInt = 0
    var ID: UInt = 0
    var SuggestedLocationID: Int = 0
    var UOMID: UInt = 0
    var OriginalUnitCost: Float = 0
    var DeliverTo: String = ""
    var OrderItemType: UInt = 0
    var PartTypeID: UInt = 0
    var Quantity: Int = 0
    var CarrierID: UInt = 0
    var BilledUnitCost: Float = 0
    var UOMName: String = ""
    
    var DateLastModified: String = ""
    var DateScheduled: String = ""
    
    var Part = FbPart()
    var ReceivedReceipts = FbReceivedReceipts()

    init() {}
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbReceiveItem()

        copy.ItemStatus = ItemStatus
        copy.Description = Description
        copy.LinkedOrders = LinkedOrders
        copy.LandedUnitCost = LandedUnitCost
        copy.ItemType = ItemType
        copy.ItemNum = ItemNum
        copy.TrackingNum = TrackingNum
        copy.LineNum = LineNum
        copy.OrderType = OrderType
        copy.ReceiptID = ReceiptID
        copy.OrderNum = OrderNum
        copy.PackageCount = PackageCount
        copy.PoItemId = PoItemId
        copy.ID = ID
        copy.SuggestedLocationID = SuggestedLocationID
        copy.UOMID = UOMID
        copy.OriginalUnitCost = OriginalUnitCost
        copy.DeliverTo = DeliverTo
        copy.OrderItemType = OrderItemType
        copy.PartTypeID = PartTypeID
        copy.Quantity = Quantity
        copy.CarrierID = CarrierID
        copy.BilledUnitCost = BilledUnitCost
        copy.UOMName = UOMName
        copy.DateLastModified = DateLastModified
        copy.DateScheduled = DateScheduled
        copy.Part = Part.copyWithZone(zone) as! FbPart
        copy.ReceivedReceipts = ReceivedReceipts.copyWithZone(zone) as! FbReceivedReceipts

        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        ItemStatus <- map["ItemStatus"]
        Description = forceMapString(map, key: "Description")
        LinkedOrders = forceMapString(map, key: "LinkedOrders")
        LandedUnitCost <- map["LandedUnitCost"]
        ItemType <- map["ItemType"]
        ItemNum = forceMapString(map, key: "ItemNum")
        TrackingNum = forceMapString(map, key: "TrackingNum")
        LineNum <- map["LineNum"]
        OrderType <- map["OrderType"]
        ReceiptID <- map["ReceiptID"]
        PackageCount <- map["PackageCount"]
        PoItemId <- map["PoItemId"]
        ID <- map["ID"]
        Quantity <- map["Quantity"]
        SuggestedLocationID <- map["SuggestedLocationID"]
        UOMID <- map["UOMID"]
        OriginalUnitCost <- map["OriginalUnitCost"]
        DeliverTo = forceMapString(map, key: "DeliverTo")
        OrderItemType <- map["OrderItemType"]
        PartTypeID <- map["PartTypeID"]
        CarrierID <- map["CarrierID"]
        BilledUnitCost <- map["BilledUnitCost"]
        UOMName = forceMapString(map, key: "UOMName")
        Part <- map["Part"]
        ReceivedReceipts <- map["ReceivedReceipts"]
        DateScheduled <- map["DateScheduled"]
        DateLastModified <- map["DateLastModified"]
        OrderNum = forceMapString(map, key: "OrderNum")
    }
    
    func getItemStatusDescription() -> String {
        guard let status = FbReceiveItem.StatusDescription[ItemStatus] else { return "" }
        return status
    }
    
    func getFullName() -> String {
        return "\(ItemNum)-\(Description)"
    }
    
    func getTracking() -> FbTracking? {
        if ReceivedReceipts.getCount() > 0 {
            return ReceivedReceipts.getTrackingAtIndex(0)
        }
        return nil
    }
    
    func matches(item: FbReceiveItem?) -> Bool {
        if item != nil {
            if item?.ItemNum == self.ItemNum {
                return true
            }
        }
        return false
    }
    
    func decrimentQuantity(quantity: Int) {
        if quantity <= Quantity {
            Quantity -= quantity
        } else {
            Quantity = 0
        }
    }
    
    func setLocationId(id: Int) {
        SuggestedLocationID = id
    }
    
    func setQuantity(quantity: Int) {
        Quantity = quantity
    }
    
    func setTracking(tracking: FbTracking?) {
        raise(0)
        _ = 1 / Int((tracking?.hasSerialTracking())!)
    }
    
    func removeAllReceipts() {
        ReceivedReceipts.removeAll()
    }
    
    func addReceivedReceipt(receipt: FbReceivedReceipt?) {
        if let receipt = receipt {
            let copyReceipt = receipt.copyWithZone(nil) as! FbReceivedReceipt
            ReceivedReceipts.add(copyReceipt)
        }
    }
}
