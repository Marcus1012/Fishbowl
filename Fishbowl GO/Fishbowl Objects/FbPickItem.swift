//
//  FbPickItem.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbPickItem: Mappable {
    var SourceTagID:    UInt    = 0 // (this element is in XML for SavePickRq sent by Android)
    var OrderID:        UInt    = 0
    var PickItemType:   UInt    = 0
    var OrderTypeID:    UInt    = 0
    var SoItemId:       Int     = 0
    var WoItemId:       Int     = 0
    var Note:           String  = ""
    var SlotNumber:     Int     = 0
    var PickItemID:     Int     = 0
    var Status:         UInt    = 0
    var Quantity:       Int     = 0
    var AltNumber:      String  = ""
    var OrderNum:       String  = ""
    var OrderType:      String  = ""
    var Tracking       = FbTracking()
    var UOM            = FbUom()   
    var Location       = FbLocation()
    var DestinationTag = FbDestinationTag()
    var Part           = FbPart()  
    var Tag            = FbTag()   
    var AvailablePickLocations = FbAvailablePickLocations()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbPickItem()
        
        copy.SourceTagID = SourceTagID
        copy.OrderID = OrderID
        copy.PickItemType = PickItemType
        copy.OrderTypeID = OrderTypeID
        copy.SoItemId = SoItemId
        copy.WoItemId = WoItemId
        copy.Note = Note
        copy.SlotNumber = SlotNumber
        copy.PickItemID = PickItemID
        copy.Status = Status
        copy.Quantity = Quantity
        copy.AltNumber = AltNumber
        copy.OrderNum = OrderNum
        copy.OrderType = OrderType
        
        copy.Tracking = Tracking.copyWithZone(zone) as! FbTracking
        copy.UOM = UOM.copyWithZone(zone) as! FbUom
        copy.Location = Location.copyWithZone(zone) as! FbLocation
        copy.DestinationTag = DestinationTag.copyWithZone(zone) as! FbDestinationTag
        copy.Part = Part.copyWithZone(zone) as! FbPart
        copy.Tag = Tag.copyWithZone(zone) as! FbTag
        
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        OrderID     <- map["OrderID"]
        PickItemType <- map["PickItemType"]
        OrderTypeID <- map["OrderTypeID"]
        SoItemId    <- map["SoItemId"]
        WoItemId    <- map["WoItemId"]
        Note        = forceMapString(map, key: "Note")
        SlotNumber  <- map["SlotNumber"]
        PickItemID  <- map["PickItemID"]
        Status      <- map["Status"]
        Quantity    <- map["Quantity"]
        AltNumber   = forceMapString(map, key: "AltNumber")
        OrderNum    = forceMapString(map, key: "OrderNum")
        OrderType   = forceMapString(map, key: "OrderType")
        /*
        if let orderNumberString = map["OrderNum"].currentValue as? String {
            OrderNum = orderNumberString
        } else if let num = map["OrderNum"].currentValue as? UInt {
            OrderNum = "\(num)"
        } else {
            OrderNum <- map["OrderNum"]
        }
        */
        
        Tracking       <- map["Tracking"]
        UOM            <- map["UOM"]
        Part           <- map["Part"]
        Location       <- map["Location"]
        DestinationTag <- map["DestinationTag"]
        Tag            <- map["Tag"]
    }
    
    func matchesPartNumber(partNum: String, checkForUpcMatch: Bool = false) -> Bool {
        return Part.matchesPartNumber(partNum, checkForUpcMatch: checkForUpcMatch)
    }
    
    func setStatus(status: UInt) {
        self.Status = status
    }
    
    func getStatus() -> UInt {
        return Status
    }
    
    func getDestinationLocation() -> FbLocation {
        return DestinationTag.getLocation()
    }
    
    func setDestinationLocation(location: FbLocation) {
        DestinationTag.setLocation(location)
    }
    
    func setDestinationTagNum(num:Int) {
        DestinationTag.Tag.setNum(num)
    }
    
    func getLocation() -> FbLocation {
        return Location
    }
    
    func setLocation(location: FbLocation) {
        Location = location
    }
    
    func setTracking(tracking: FbTracking) {
        Tracking = tracking
    }
    
    func addTrackingItem(item: FbTrackingItem) {
        Tracking.addTrackingItem(item)
    }
    
    func addQuantity(quantity: Int) {
        Quantity += quantity
    }
    
    // Returns the actual number of quantity that was removed
    // Pass quantity < 0 to "remove all"
    func subtractQuantity(quantity: Int) -> Int {
        var decrimentQuantity: Int = 0
        
        if quantity < 0 {
            decrimentQuantity = Quantity
        } else {
            decrimentQuantity = (quantity > Quantity) ? Quantity : quantity
        }
        Quantity -= decrimentQuantity
        return decrimentQuantity
    }
    
    func hasTracking() -> Bool {
        return Part.hasTracking()
    }
    
    func getPartType() -> UInt {
        return Part.getType()
    }
    
    func getAllSerialNumbers() -> [String] {
        return Tracking.getAllSerialNumbers()
    }
}
