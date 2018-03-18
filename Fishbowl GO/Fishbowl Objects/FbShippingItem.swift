//
//  FbShippingItem.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbShippingItem: Mappable, NSCopying {
    var UPC: String = ""
    var ProductNumber: String = ""
    var IsNew: String = "false"
    var Cost: UInt = 0
    var Weight: Float = 0
    var CartonID: Int = 0
    var UOM = FbUom()
    var TagNum: String = ""
    var SoItemId: UInt = 0
    var CartonName: Int = 0
    var OrderLineItem: UInt = 0
    var ProductDescription: String = ""
    var QtyShipped: Int = 0
    var DisplayWeight: Float = 0
    var ShipItemID: Int = -1
    var SKU: String = ""
    var Tracking = FbTracking()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbShippingItem()
        
        copy.UPC = UPC
        copy.ProductNumber = ProductNumber
        copy.IsNew = IsNew
        copy.Cost = Cost
        copy.Weight = Weight
        copy.CartonID = CartonID
        copy.TagNum = TagNum
        copy.SoItemId = SoItemId
        copy.CartonName = CartonName
        copy.OrderLineItem = OrderLineItem
        copy.ProductDescription = ProductDescription
        copy.QtyShipped = QtyShipped
        copy.DisplayWeight = DisplayWeight
        copy.ShipItemID = ShipItemID
        copy.SKU = SKU
        copy.UOM = (UOM.copyWithZone(zone) as! FbUom)
        copy.Tracking = (Tracking.copyWithZone(zone) as! FbTracking)
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        ProductNumber = forceMapString(map, key: "ProductNumber")
        IsNew <- map["IsNew"]
        Cost <- map["Cost"]
        Weight <- map["Weight"]
        CartonID <- map["CartonID"]
        UOM <- map["UOM"]
        TagNum <- map["TagNum"]
        SoItemId <- map["SoItemId"]
        CartonName <- map["CartonName"]
        OrderLineItem <- map["OrderLineItem"]
        ProductDescription = forceMapString(map, key: "ProductDescription")
        QtyShipped <- map["QtyShipped"]
        DisplayWeight <- map["DisplayWeight"]
        ShipItemID <- map["ShipItemID"]
        SKU = forceMapString(map, key: "SKU")
        Tracking <- map["Tracking"]

        UPC = forceMapString(map, key: "UPC")
    }
    
    func hasTracking() -> Bool {
        if Tracking.TrackingItem.count > 0 {
            return true
        }
        return false
    }
    
    func hasSerialTracking() -> Bool {
        return Tracking.hasSerialTracking()
    }
    
    func getFullName() -> String {
        var name = "\(ProductNumber)"
        if ProductDescription.characters.count > 0 {
            name += "-\(ProductDescription)"
        }
        return name
    }

    // 0-based index for gettng tracking items that are NOT serial numbers
    func getNthNonSerialTracking(index: Int) -> FbTrackingItem? {
        return Tracking.getNthNonSerialTracking(index)
    }
    
    // 0-based index for getting tracking items that ARE serial numbers
    func getNthSerialNumber(index:Int) -> FbSerialNum? {
        return Tracking.getNthSerialNumber(index)
    }
    
    func setQuantityShipped(qty: Int) {
        QtyShipped = qty
    }
    
    func decrementQuantityShipped(quantity: Int) {
        if quantity > QtyShipped {
            setQuantityShipped(0)
        } else  {
            setQuantityShipped(QtyShipped - quantity)
        }
    }
    
    func matchesPartNumber(partNumber: String, checkForUpcMatch: Bool = false) -> Bool {
        if ProductNumber.caseInsensitiveCompare(partNumber) == NSComparisonResult.OrderedSame {
            return true
        } else if checkForUpcMatch && UPC.caseInsensitiveCompare(partNumber) == NSComparisonResult.OrderedSame {
            return true
        }
        return false
    }
    
}
