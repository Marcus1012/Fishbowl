//
//  SavePickRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiSavePickRequest : FbiRequest {
    var SavePickRq : savePickRequestCore
    
    init(pick: FbPick) {
        SavePickRq = savePickRequestCore(pick: pick)
    }
    
}


class savePickRequestCore {
    var Pick: FbPick
    
    init(pick: FbPick) {
        Pick = pick
    }
}

/*
class PickCore {
    var Status: String = ""
    var TypeID: UInt = 0
    var DateStarted: String = ""
    var UserName: String = ""
    var PickID: UInt = 0
    var Priority: String = ""
    var DateCreated: String = ""
    var LocationGroupID: UInt = 0
    var DateScheduled: String = ""
    var DateLastModified: String = ""
    var Type: String = "Pick"
    var Number: String = ""
    var StatusID: UInt = 0
    var PriorityID: UInt = 0
    var PickItems: [PickItem] = [PickItem]()
    var PickOrders: [PickOrder] = [PickOrder]()
    
    init(pickNum: String) {
        Number = pickNum
    }
}

class PickItem {
    
}

class PickOrder {
    
}
*/
