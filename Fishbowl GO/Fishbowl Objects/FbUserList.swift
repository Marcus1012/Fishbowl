//
//  FbUserList.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
/*
 Fishbowl API Documentation:
 
 <User>
     <User>
        <ID>int</ID>
        <UserName>string</UserName>
        <FirstName>string</FirstName>
        <LastName>string</LastName>
        <Initials>string</Initials>
        <Active>boolean</Active>
     </User>
 </User>
*/

import Foundation
import ObjectMapper


class FbUserList: Mappable {

    var User = [FbUser]()

    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbUserList()

        for user in User {
            let newUser = user.copyWithZone(zone) as! FbUser
            copy.User.append(newUser)
        }
        
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        User <- map["User"]
        if User.count <= 0 {
            var newUser: FbUser?
            newUser <- map["User"]
            User.append(newUser!)
        }
    }
}
