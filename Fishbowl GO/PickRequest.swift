//
//  PickListRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiPickRequest : FbiRequest {
    var GetPickRq : pickRequestCore
    
    init(pickNum: String) {
        GetPickRq = pickRequestCore(pickNum: pickNum)
    }
    
}


class pickRequestCore {
    var PickNum: String = ""
    
    init(pickNum: String) {
        PickNum = pickNum
    }
}
