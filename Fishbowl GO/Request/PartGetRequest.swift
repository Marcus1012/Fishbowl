//
//  PartGetRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiPartGetRequest : FbiRequest {
    var PartGetRq : partGetCore
    
    init(number: String, getImage: Bool) {
        PartGetRq = partGetCore(number: number, getImage: getImage)
    }
    
}

class partGetCore {
    var Number: String = ""
    var GetImage: Bool = false
    
    init(number: String, getImage: Bool) {
        Number = number
        GetImage = getImage
    }
}
