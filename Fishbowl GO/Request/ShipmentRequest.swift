//
//  ShipmentRequest.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/6/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation

class FbiShipmentRequest : FbiRequest {
    var GetShipmentRq : shipmentRequestCore
    
    init(shipmentNum: String) {
        GetShipmentRq = shipmentRequestCore(shipmentNum: shipmentNum)
    }
    
}


class shipmentRequestCore {
    var ShipmentID: Int = 0
    var ShipmentNum: String = ""

    init(shipmentNum: String) {
        ShipmentNum = shipmentNum
    }
}
