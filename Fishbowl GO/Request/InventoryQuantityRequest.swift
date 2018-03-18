//
//  InventoryQuantityRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiInventoryQuantityRequest : FbiRequest {
    var InvQtyRq : inventoryQuantityRequestCore
    
    init(part: String) {
        InvQtyRq = inventoryQuantityRequestCore(part: part)
    }
    
}

class inventoryQuantityRequestCore {
    var PartNum: String = ""
    
    init(part: String) {
        PartNum = part
    }
}
