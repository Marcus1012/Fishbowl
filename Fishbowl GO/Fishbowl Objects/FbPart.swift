//
//  FbPart.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbPart: Mappable {
    var TypeID: UInt         = 0
    var Description: String  = ""
    var Num: String          = ""            // part number
    var UPC: String          = ""
    var ABCCode: String      = ""
    var ActiveFlag: Bool     = false
    var HasBOM: Bool         = false
    var Details: String      = ""
    var SerializedFlag: Bool = false
    var TrackingFlag: Bool   = false
    var StandardCost: Float  = 0
    var PartID: UInt         = 0
    var UOM                  = FbUom()
    var Image: String        = ""
    var PartTrackingList     = FbPartTrackingList()
    var Width: Float         = 0
    var Height: Float        = 0
    
    private var notMapped_Locked: Bool = false // is the part locked? (via lock icon in UI)

//    var UOMConversions = [FbUomConversion]()
//    UOMConversions <- map["UOMConversions.UOMConversion"]
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbPart()

        copy.TypeID = TypeID
        copy.Description = Description
        copy.Num = Num
        copy.UPC = UPC
        copy.ABCCode = ABCCode
        copy.ActiveFlag = ActiveFlag
        copy.HasBOM = HasBOM
        copy.Details = Details
        copy.SerializedFlag = SerializedFlag
        copy.TrackingFlag = TrackingFlag
        copy.StandardCost = StandardCost
        copy.PartID = PartID
        copy.Image = Image
        copy.UOM = UOM.copyWithZone(zone) as! FbUom
        copy.PartTrackingList = PartTrackingList.copyWithZone(zone) as! FbPartTrackingList
        copy.Width = Width
        copy.Height = Height

        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        SerializedFlag      <- map["SerializedFlag"]
        PartID              <- map["PartID"]
        TrackingFlag        <- map["TrackingFlag"]
        ActiveFlag          <- map["ActiveFlag"]
        HasBOM              <- map["HasBOM"]
        StandardCost        <- map["StandardCost"]
        TypeID              <- map["TypeID"]
        UOM                 <- map["UOM"]
        PartTrackingList    <- map["PartTrackingList"]
        Width               <- map["Width"]
        Height              <- map["Height"]
        
        Description   = forceMapString(map, key: "Description")
        Num           = forceMapString(map, key: "Num")
        UPC           = forceMapString(map, key: "UPC")
        ABCCode       = forceMapString(map, key: "ABCCode")
        Details       = forceMapString(map, key: "Details")
        Image         = forceMapString(map, key: "Image")
    }
    
    func getFullName() -> String {
        var name = "\(Num)"
        if Description.characters.count > 0 {
            name += "-\(Description)"
        }
        return name
    }
    
    func hasTracking() -> Bool {
        return TrackingFlag
    }
    
    func hasSerialTracking() -> Bool {
        return SerializedFlag
    }
    
    func matchesPartNumber(partNumber: String, checkForUpcMatch: Bool = false) -> Bool {
        if Num.caseInsensitiveCompare(partNumber) == NSComparisonResult.OrderedSame {
            return true
        } else if checkForUpcMatch && UPC.caseInsensitiveCompare(partNumber) == NSComparisonResult.OrderedSame {
            return true
        }
        return false
    }
    
    func getType() -> UInt {
        return TypeID
    }
    
    func getTrackingCount() -> Int {
        return PartTrackingList.getTrackingCount()
    }
    
    func getNonSerialTrackingCount() -> Int {
        return PartTrackingList.getNonSerialTrackingCount()
    }
    
    func setLocked(locked: Bool) {
        notMapped_Locked = locked
    }
    
    func getLocked() -> Bool {
        return notMapped_Locked
    }
}

