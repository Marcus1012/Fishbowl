//
//  FbWOItem.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
/*
 <WOItem>
	<ID>int</ID>
	<MOItemID>DB int</MOItemID>
	<TypeID>DB int</TypeID>
	<Part>Part object</Part>
	<Description>string</Description>
	<Cost>string</Cost>
	<DateScheduled>2019-11-04T00:00:00</DateScheduled>
	<InstructionNote />
	<InstructionURL />
	<QtyScrapped>int</QtyScrapped>
	<QtyToFulfill>int</QtyToFulfill>
	<QtyUsed>int</QtyUsed>
	<DestLocation>
        <Location>Location object</Location>
	</DestLocation>
	<UOM>UOM object</UOM>
	<Tracking />
	<SortID>int</SortID>
 </WOItem>
*/

import Foundation
import ObjectMapper


class FbWOItem: Mappable {
    var ID: UInt = 0
    var MOItemID: UInt = 0
    var TypeID: UInt = 0
    var Part = FbPart()
    var Description: String = ""
    var Cost: String = ""
    var DateScheduled: String = ""
    var InstructionNote: String = ""
    var InstructionURL: String = ""
    var QtyScrapped: Float = 0
    var QtyToFulfill: Float = 0
    var QtyUsed: Int = 0
    var Tracking = FbTracking()
    var SortID: UInt = 0
    var DestLocation = FbDestLocation()
    var OriginalQtyToFulfill: Int = 0
    var UOM = FbUom()
    var ConsumeItems = FbConsumeItems()
    
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbWOItem()

        copy.ID = ID
        copy.MOItemID = MOItemID
        copy.TypeID = TypeID
        copy.Part = Part.copyWithZone(zone) as! FbPart
        copy.Description = Description
        copy.Cost = Cost
        copy.DateScheduled = DateScheduled
        copy.InstructionNote = InstructionNote
        copy.InstructionURL = InstructionURL
        copy.QtyScrapped = QtyScrapped
        copy.QtyToFulfill = QtyToFulfill
        copy.QtyUsed = QtyUsed
        copy.Tracking = Tracking.copyWithZone(zone) as! FbTracking
        copy.SortID = SortID
        copy.DestLocation = DestLocation.copyWithZone(zone) as! FbDestLocation
        copy.OriginalQtyToFulfill = OriginalQtyToFulfill
        copy.UOM = UOM.copyWithZone(zone) as! FbUom
        copy.ConsumeItems = ConsumeItems.copyWithZone(zone) as! FbConsumeItems

        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        ID <- map["ID"]
        MOItemID <- map["MOItemID"]
        TypeID <- map["TypeID"]
        Description = forceMapString(map, key: "Description")
        DestLocation <- map["DestLocation"]
        Tracking <- map["Tracking"]
        DateScheduled <- map["DateScheduled"]
        SortID <- map["SortID"]
        InstructionNote  = forceMapString(map, key: "InstructionNote")
        OriginalQtyToFulfill <- map["OriginalQtyToFulfill"]
        Cost = forceMapString(map, key: "Cost")
        QtyScrapped <- map["QtyScrapped"]
        QtyToFulfill <- map["QtyToFulfill"]
        QtyUsed <- map["QtyUsed"]
        Part <- map["Part"]
        InstructionURL = forceMapString(map, key: "InstructionURL")
        UOM <- map["UOM"]
        ConsumeItems <- map["ConsumeItems"]
    }
    
    /*
     Should this work order item be displayed in the list of picked/consumed items?
     Criteria... should be displayed if not an inventory or non-inventory type
     Also should be displayed if sum of Consume Items sub-objects is > 0
    */
    func shouldDisplay() -> Bool {
        if Part.TypeID != Constants.PartType.Inventory && Part.TypeID != Constants.PartType.NonInventory {
            return true
        }
        return ConsumeItems.getQuantitySum() > 0 ? true : false
    }
    
    func getQuantityWithUom() -> String {
        return String(format: "%@ %@", QtyToFulfill.cleanValue, UOM.Code)
    }
    
    func getQuantityToFulfill() -> String {
        return QtyToFulfill.cleanValue
    }
    
    func extractConsumeItems(consumeItems: FbConsumeItems) {
        for item in ConsumeItems.ConsumeItem {
            let newItem = item.copyWithZone(nil) as! FbConsumeItem
            consumeItems.append(newItem)
        }
    }
    
    func hasConsumableItems() -> Bool {
        return ConsumeItems.hasConsumableItems()
    }
    
    func isFinishedGoodType() -> Bool {
        if TypeID == Constants.BomItemType.FinishedGood || TypeID == Constants.BomItemType.RepairFinishedGood {
            return true
        }
        return false
    }
    
    func setDestinationLocation(location: FbLocation?) {
        DestLocation.setLocation(location!)
    }
    
    func setTracking(trackingItem: FbTrackingItem) {
        Tracking.setTrackingItem(trackingItem)
    }
    
    func addTracking(trackingItem: FbTrackingItem) {
        Tracking.addTrackingItem(trackingItem)
    }
    
}
