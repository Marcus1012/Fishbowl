//
//  WorkOrderRequest.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/6/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation

// <GetWorkOrderRq><WorkOrderNumber>174:001</WorkOrderNumber></GetWorkOrderRq>
class FbiWorkOrderRequest : FbiRequest {
    var GetWorkOrderRq : workOrderCore
    
    init(orderNum: String) {
        GetWorkOrderRq = workOrderCore(orderNum: orderNum)
    }
}


class workOrderCore {
    var WorkOrderNumber: String
    
    init(orderNum: String) {
        WorkOrderNumber = orderNum
    }
}
