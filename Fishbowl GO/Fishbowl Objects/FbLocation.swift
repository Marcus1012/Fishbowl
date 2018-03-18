//
//  FbLocation.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
/*
 <Location>
	<LocationID>int</LocationID>
	<TypeID>int</TypeID>
	<ParentID>int</ParentID>
	<Name>string</Name>
	<Description>string</Description>
	<CountedAsAvailable>boolean</CountedAsAvailable>
	<Default>boolean</Default>
	<Active>boolean</Active>
	<Pickable>boolean</Pickable>
	<Receivable>boolean</Receivable>
	<LocationGroupID>int</LocationGroupID>
	<LocationGroupName>string</LocationGroupName>
	<EnforceTracking>boolean</EnforceTracking>
	<SortOrder>int</SortOrder>
 </Location>
*/
import Foundation
import ObjectMapper
//import Cache

func ==(lhs: FbLocation, rhs: FbLocation) -> Bool {
    return lhs.Name == rhs.Name && lhs.LocationGroupName == rhs.LocationGroupName
}

class FbLocation: Mappable {
    var LocationID: Int = 0
    var TypeID: Int = 0
    var ParentID: Int = 0
    var Name: String = ""
    var Description: String = ""
    var CountedAsAvailable: Bool = false
    var Default: Bool = true
    var Active: Bool = false
    var Pickable: Bool = false
    var Receivable: Bool = false
    var LocationGroupID: UInt = 0
    var LocationGroupName: String = ""
    var EnforceTracking: Bool = false
    var SortOrder: UInt  = 0
    
    var TagID: Int = 0      // not documented
    var TagNumber: Int = 0  // not documented
    
    private var notMapped_Locked: Bool = false // is the location locked? (via lock icon in UI)

    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbLocation()
        
        copy.Default = Default
        copy.Description = Description
        copy.Receivable = Receivable
        copy.CountedAsAvailable = CountedAsAvailable
        copy.SortOrder = SortOrder
        copy.TagID = TagID
        copy.TypeID = TypeID
        copy.ParentID = ParentID
        copy.EnforceTracking = EnforceTracking
        copy.Name = Name
        copy.Active = Active
        copy.Pickable = Pickable
        copy.LocationID = LocationID
        copy.TagNumber = TagNumber
        copy.LocationGroupName = LocationGroupName
        copy.LocationGroupID = LocationGroupID
        
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        Default <- map["Default"]
        Receivable <- map["Receivable"]
        CountedAsAvailable <- map["CountedAsAvailable"]
        SortOrder <- map["SortOrder"]
        TagID <- map["TagID"]
        TypeID <- map["TypeID"]
        ParentID <- map["ParentID"]
        EnforceTracking <- map["EnforceTracking"]
        Active <- map["Active"]
        Pickable <- map["Pickable"]
        LocationID <- map["LocationID"]
        TagNumber <- map["TagNumber"]
        LocationGroupID <- map["LocationGroupID"]

        Name  = forceMapString(map, key: "Name")
        Description = forceMapString(map, key: "Description")
        LocationGroupName = forceMapString(map, key: "LocationGroupName")

    }
    
    func getFullName(defaultName:String = "") -> String {
        var name = defaultName
        if LocationGroupName.characters.count > 0 {
            name = "\(LocationGroupName)"
        }
        if Name.characters.count > 0 {
            name += "-\(Name)"
        }
        return name
    }

    func setLock(locked: Bool) {
        notMapped_Locked = locked
    }
    
    func getLock() -> Bool {
        return notMapped_Locked
    }
    
}
