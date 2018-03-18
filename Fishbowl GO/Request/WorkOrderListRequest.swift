//
//  WorkOrderListRequest.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/6/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiWorkOrderListRequest : FbiRequest {
    var WorkOrderListRq : workOrderListCore
    
    init(count: UInt) {
        WorkOrderListRq = workOrderListCore(count: count)
    }
    init(count: UInt, status: UInt) {
        WorkOrderListRq = workOrderListCore(count: count, status: status)
    }
}


class workOrderListCore {
    var Count: UInt
    var WOStatus: UInt = 5
    
    init(count: UInt) {
        Count = count
    }
    init(count: UInt, status: UInt) {
        Count = count
        WOStatus = status
    }
}
