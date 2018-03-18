//
//  ShipListRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiShipListRequest : FbiRequest {
    var GetShipListRq : shipListCore
    
    init(count: UInt) {
        GetShipListRq = shipListCore(count: count, status: 5)
    }
    init(count: UInt, status: UInt) {
        GetShipListRq = shipListCore(count: count, status: status)
    }
    
}


class shipListCore {
    var StartRecord: UInt = 0
    var RecordCount: UInt = 99 // Default is to get 100 orders
    //var OrderNumber: String = ""
    //var OrderTypeID: UInt = Constants.OrderType.SO // Default type is Sales Order
    //var Carrier: String = ""
    var LocationGroup: String = ""
    var StatusID: UInt = 0  // Saw this in the request from Android GO in the server console log but its not in the FishHook request.

    init(status: UInt) {
        StatusID = status
    }
    init(count: UInt, status: UInt) {
        RecordCount = count
        StatusID = status
    }
}
