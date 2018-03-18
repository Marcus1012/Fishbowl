//
//  FbReceipt.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbReceipt: Mappable {
    var TypeID:         UInt = 0
    var UserID:         UInt = 0
    var OrderTypeID:    UInt = 0
    var StatusID:       UInt = 0
    var LocationGroupID:UInt = 0
    var ID:             UInt = 0
    var POID:           UInt = 0
    var SOID:           UInt = 0
    var XOID:           UInt = 0
    var ReceiptItems = FbReceiptItems()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        TypeID <- map["TypeID"]
        UserID <- map["UserID"]
        OrderTypeID <- map["OrderTypeID"]
        StatusID <- map["StatusID"]
        LocationGroupID <- map["LocationGroupID"]
        ID <- map["ID"]
        POID <- map["POID"]
        SOID <- map["SOID"]
        XOID <- map["XOID"]
        ReceiptItems <- map["ReceiptItems"]
    }
    
    func addItemReceipt(id: UInt, receipt: FbReceivedReceipt?) {
        ReceiptItems.addReceivedReceipt(id, receipt: receipt!)
    }

    func getPart(partNumber: String) -> FbPart? {
        return ReceiptItems.getPart(partNumber)
    }
}
