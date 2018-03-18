//
//  PickReceiptRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation

/*
<GetReceiptRq>
 <OrderType>10</OrderType>
 <OrderNumber>10075</OrderNumber>
 <LocationGroup>1</LocationGroup>
</GetReceiptRq>
*/

class FbiReceiptRequest : FbiRequest {
    var GetReceiptRq : receiptRequestCore
    
    init(orderNumber: String, orderType: UInt, locationGroup: UInt) {
        GetReceiptRq = receiptRequestCore(orderNum: orderNumber, orderType: orderType, locationGroup: locationGroup)
    }
    
}


class receiptRequestCore {
    var OrderNumber: String = ""
    var OrderType: UInt = 0
    var LocationGroup: UInt = 0
    
    init(orderNum: String, orderType: UInt, locationGroup: UInt) {
        OrderNumber = orderNum
        OrderType = orderType
        LocationGroup = locationGroup
    }
}
