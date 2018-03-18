//
//  FbUser.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
/*
 Fishbowl API Documentation:
 
 <User>
	<ID>int</ID>
	<UserName>string</UserName>
	<FirstName>string</FirstName>
	<LastName>string</LastName>
	<Initials>string</Initials>
	<Active>boolean</Active>
 </User>
*/

import Foundation
import ObjectMapper


class FbUser: Mappable {

    var ID: Int = 0
    var UserName: String = ""
    var FirstName: String = ""
    var LastName: String = ""
    var Initials: String = ""
    var Active: Bool = false
    
    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbUser()

        copy.ID = ID
        copy.UserName = UserName
        copy.FirstName = FirstName
        copy.LastName = LastName
        copy.Initials = Initials
        copy.Active = Active
        
        return copy
    }
    // Mappable
    func mapping(map: Map) {
        ID <- map["ID"]
        UserName = forceMapString(map, key: "UserName")
        FirstName = forceMapString(map, key: "FirstName")
        LastName = forceMapString(map, key: "LastName")
        Initials = forceMapString(map, key: "Initials")
        Active <- map["Active"]
    }
}
