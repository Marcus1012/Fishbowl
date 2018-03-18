//
//  ShipOrderRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiShipOrderRequest : FbiRequest {
    var ShipRq : shipCore
    
    init(number: String) {
        ShipRq = shipCore(number: number)
    }
    init(number: String, image: String, contact: String) {
        ShipRq = shipCore(number: number, image: image, contact: contact)
    }
}

class shipCore {
    var ShipNum: String = ""
    var statusCode: UInt = 0
    var Image: String = ""
    var Contact: String = ""
    
    
    init(number: String) {
        ShipNum = number
    }
    init(number: String, image: String, contact: String) {
        ShipNum = number
        Image = image
        Contact = contact
    }
}
