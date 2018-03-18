//
//  LoginRequest.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/6/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiLoginRequest : FbiRequest {
    
    var LoginRq: loginCore
    
    init(username: String, password: String) {
        LoginRq = loginCore(username: username,password: password)
    }
}

class loginCore {
    var IAID : Int = 1234
    var IAName : String = "Fishbowl GO iOS"
    var IADescription : String = "Fishbowl GO for iOS Devices"
    var UserName : String = ""
    var UserPassword : String = "" // encrypted
    
    // password is sent to initializer as plain text
    init(username: String, password: String) {
        UserName = username
        UserPassword = encodePassword(password)
    }
    
    func encodePassword(password:String) -> String {
        let data = password.dataUsingEncoding(NSUTF8StringEncoding)
        let hash = data!.md5()
        let encodedString:String = hash.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        return encodedString
    }
}
