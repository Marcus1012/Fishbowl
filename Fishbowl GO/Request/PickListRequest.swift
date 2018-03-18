//
//  PickListRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiPickListRequest : FbiRequest {
    var PickQueryRq : pickListCore
    
    init(count: UInt) {
        PickQueryRq = pickListCore(count: count)
    }
    init(count: UInt, status: String) {
        PickQueryRq = pickListCore(count: count, status: status)
    }
    
}


class pickListCore {
    var StartIndex: UInt = 0
    var RecordCount: UInt
    var PickNum: String = ""
    var OrderNum: String = ""
    var PickType: String = ""
    var Status: String = ""
    var Priority: String = ""
    var StartDate: NSDate = NSDate(dateString:"1970-01-01")
    var EndDate: NSDate = NSDate()
    var Fulfillable: Bool = true
    var LocationGroup: String = ""
    
    init(count: UInt) {
        RecordCount = count
    }
    init(count: UInt, status: String) {
        RecordCount = count
        Status = status
    }
}
