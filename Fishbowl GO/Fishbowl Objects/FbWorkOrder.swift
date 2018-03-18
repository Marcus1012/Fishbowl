//
//  FbWorkOrder.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
/*
 Fishbowl API Documentation
 
 <WO>
	<ID>int</ID>
	<Num>string</Num>
	<Type>DB String</Type>
	<TypeID>DB int</TypeID>
	<MOItemID>DB int</MOItemID>
	<WOItems>
        <WOItem>Work Order Item object</WOItem>
	</WOItems>
	<Cost>int</Cost>
	<Location>
        <Location>Location object</Location>
	</Location>
	<LocationGroup>Location Group object</LocationGroup>
	<Note />
	<StatusID>DB int</StatusID>
	<QBClass>DB string</QBClass>
	<QBClassID>DB int</QBClassID>
	<QtyOrdered>int</QtyOrdered>
	<QtyTarget>int</QtyTarget>
	<DateCreated>date/time</DateCreated>
	<DateFinished>date/time</DateFinished>
	<DateLastModified>date/time</DateLastModified>
	<DateScheduled>date/time</DateScheduled>
	<DateStarted>date/time</DateStarted>
	<User>User object</User>
 </WO>
*/

import Foundation
import ObjectMapper


class FbWorkOrder: Mappable {

    var ID: Int = 0
    var Num: String = ""
    var Type: String = ""
    var TypeID: Int = 0
    var MOItemID: Int = 0
    var WOItems = FbWOItems()
    var Cost: Float = 0.0
    var Location = FbLocationList()
    var LocationGroup = FbLocationGroupList()
    var Note: String = ""
    var StatusID: UInt = 0
    var QBClass: String = ""
    var QBClassID: Int = 0
    var QtyOrdered: Int = 0
    var QtyTarget: Int = 0
    var DateCreated: String = ""
    var DateFinished: String = ""
    var DateLastModified: String = ""
    var DateScheduled: String = ""
    var DateScheduledToStart: String = ""
    var DateStarted: String = ""
    var User = FbUserList()
    
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbWorkOrder()

        copy.ID = ID
        copy.Num = Num
        copy.Type = Type
        copy.TypeID = TypeID
        copy.MOItemID = MOItemID
        copy.WOItems = WOItems.copyWithZone(zone) as! FbWOItems
        copy.Cost = Cost
        copy.Location = Location.copyWithZone(zone) as! FbLocationList
        copy.LocationGroup = LocationGroup.copyWithZone(zone) as! FbLocationGroupList
        copy.Note = Note
        copy.StatusID = StatusID
        copy.QBClass = QBClass
        copy.QBClassID = QBClassID
        copy.QtyOrdered = QtyOrdered
        copy.QtyTarget = QtyTarget
        copy.DateCreated = DateCreated
        copy.DateFinished = DateFinished
        copy.DateLastModified = DateLastModified
        copy.DateScheduled = DateScheduled
        copy.DateScheduledToStart = DateScheduledToStart
        copy.DateStarted = DateStarted
        copy.User = User.copyWithZone(zone) as! FbUserList
        return copy
    }

    // Mappable
    func mapping(map: Map) {
        ID <- map["ID"]
        Num = forceMapString(map, key: "Num")
        Type = forceMapString(map, key: "Type")
        TypeID <- map["TypeID"]
        MOItemID <- map["MOItemID"]
        WOItems <- map["WOItems"]
        Cost <- map["Cost"]
        Note = forceMapString(map, key: "Note")
        StatusID <- map["StatusID"]
        QBClass = forceMapString(map, key: "QBClass")
        QBClassID <- map["QBClassID"]
        QtyOrdered <- map["QtyOrdered"]
        QtyTarget <- map["QtyTarget"]
        DateCreated <- map["DateCreated"]
        DateFinished <- map["DateFinished"]
        DateLastModified <- map["DateLastModified"]
        DateScheduled <- map["DateScheduled"]
        DateScheduledToStart <- map["DateScheduledToStart"]
        DateStarted <- map["DateStarted"]
        Location <- map["Location"]
        LocationGroup <- map["LocationGroup"]
        User <- map["User"]
    }

    func extractConsumeItems(consumeItems: FbConsumeItems) {
        WOItems.extractConsumeItems(consumeItems)
    }
    
    func getFinishedGoodItem() -> FbWOItem? {
        return WOItems.getFinishedGoodItem()
    }
    
}
