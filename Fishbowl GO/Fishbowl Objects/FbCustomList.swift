//
//  FbCustomList.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
/*
 Fishbowl API Documentation:
 
 <CustomList>
	<ID>int</ID>
	<Name>string</Name>
	<Description>string</Description>
	<CustomListItems>Custom List Item objects</CustomListItems>
 </CustomList>
*/

import Foundation
import ObjectMapper


class FbCustomList: Mappable {

    var ID: Int = 0
    var Name: String = ""
    var Description: String = ""
    var CustomListItems = [FbCustomListItem]()
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        ID <- map["ID"]
        Name = forceMapString(map, key: "Name")
        Description = forceMapString(map, key: "Description")

        CustomListItems <- map["CustomListItems"]
        if CustomListItems.count <= 0 {
            var customListItem: FbCustomListItem?
            customListItem <- map["CustomListItem"]
            CustomListItems.append(customListItem!)
        }

    }
}
