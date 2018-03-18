//
//  FbCustomFields.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbCustomFields: Mappable {
    var CustomField = [FbCustomField]()

    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        CustomField <- map["CustomField"]
        if CustomField.count <= 0 {
            var customField: FbCustomField?
            customField <- map["CustomField"]
            CustomField.append(customField!)
        }
    }
    
}
