//
//  SaveWorkOrderRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiSaveWorkOrderRequest : FbiRequest {
    var SaveWorkOrderRq : saveWorkOrderRequestCore
    
    init(workOrder: FbWorkOrder) {
        SaveWorkOrderRq = saveWorkOrderRequestCore(wo: workOrder)
    }
}


class saveWorkOrderRequestCore {
    var WO: FbWorkOrder
    
    init(wo: FbWorkOrder) {
        WO = wo
    }
}
