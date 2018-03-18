//
//  SaveUpcRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiSaveUpcRequest : FbiRequest {
    var SaveUPCRq : saveUpcRequestCore
    
    init(part: String, upc: String, updateProducts:Bool=true) {
        SaveUPCRq = saveUpcRequestCore(part: part, upc: upc, updateProducts: updateProducts)
    }
    
}

class saveUpcRequestCore {
    var PartNum: String = ""
    var UPC: String = ""
    var UpdateProducts: Bool = true
    
    init(part: String, upc: String, updateProducts: Bool) {
        PartNum = part
        UPC = upc
        UpdateProducts = updateProducts
    }
}
