//
//  ReceivingListRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiReceivingListRequest : FbiRequest {
    var ReceivingListRq : receiveListCore
    
    init(count: UInt) {
        ReceivingListRq = receiveListCore(count: count)
    }
    init(count: UInt, status: UInt) {
        ReceivingListRq = receiveListCore(count: count, status: status)
    }
    
}


class receiveListCore {
    var OrderType: UInt = 0
    var LocationGroupID: UInt = 0
    var ReceiptStatus: UInt = 2
    var StartRecord: UInt = 0
    var RecordCount: UInt = 99
   
    init(count: UInt) {
        RecordCount = count
    }
    init(count: UInt, status: UInt) {
        RecordCount = count
        ReceiptStatus = status
    }
}
