//
//  SaveShipmentRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiSaveShipmentRequest : FbiRequest {
    var SaveShipmentRq : saveShipmentRequestCore
    
    init(shipment: FbShipping) {
        SaveShipmentRq = saveShipmentRequestCore(shipment: shipment)
    }
}


class saveShipmentRequestCore {
    var Shipping: FbShipping
    
    init(shipment: FbShipping) {
        Shipping = shipment
    }
}
