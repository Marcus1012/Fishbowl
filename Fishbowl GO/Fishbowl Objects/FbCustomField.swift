//
//  FbCustomField.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
/*
 Fishbowl API Documentation:
 
 <CustomField>
	<ID>int</ID>
	<Type>string</Type>
	<Name>string</Name>
	<Description>string</Description>
	<SortOrder>int</SortOrder>
	<Info>string</Info>
	<RequiredFlag>boolean</RequiredFlag>
	<ActiveFlag>boolean</ActiveFlag>
	<CustomList>Custom List objects</CustomList>
 </CustomField>
*/

import Foundation
import ObjectMapper


class FbCustomField: Mappable {

    var ID: Int = 0
    var Type: String = ""
    var Name: String = ""
    var Description: String = ""
    var SortOrder: Int = 0
    var Info: String = ""
    var RequiredFlag: Bool = false
    var ActiveFlag: Bool = false
    var CustomList = FbCustomList()

    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        ID <- map["ID"]
        Type = forceMapString(map, key: "Type")
        Name = forceMapString(map, key: "Name")
        Description = forceMapString(map, key: "Description")
        SortOrder <- map["SortOrder"]
        Info = forceMapString(map, key: "Info")
        RequiredFlag <- map["RequiredFlag"]
        ActiveFlag <- map["ActiveFlag"]
        CustomList <- map["CustomList"]
    }
}
