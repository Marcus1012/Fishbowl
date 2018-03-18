//
//  FBRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/15/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
//  Base Fishbowl request class
//

import Foundation
import SwiftyJSON
import CryptoSwift


class FbTicket {
    private var Key: String = ""
    private var UserID: Int = 0
    
    init (json: JSON) {
        self.Key = json["Key"].stringValue
        self.UserID = json["UserID"].intValue
    }
    init(key: String, userId: Int) {
        self.Key = key
        self.UserID = userId
    }
    
    func setJson(json: JSON) {
        self.Key = json["Key"].stringValue
        self.UserID = json["UserID"].intValue
    }
    
    func setKey(key:String) {
        self.Key = key
    }
    func getKey() -> String {
        return Key
    }
    func setUserId(id: Int) {
        self.UserID = id
    }
    func getUserId() -> Int {
        return self.UserID
    }
}

class FbResponse {
    private var json: JSON = nil
    private var jsonResponse: JSON = nil
    private var name: String = ""
    private var status: Int = 0
    
    init () {}
    init (json: JSON) {
        initializeWithJson(json)
    }
    
    func initializeWithJson(json: JSON) {
        self.json = json
        if json != nil {
            if (json.object.objectForKey("statusCode") != nil) {
                self.status = json["statusCode"].intValue
                self.json.dictionaryObject?.removeValueForKey("statusCode")
            }
            if status == 1000 {
                (self.name, self.jsonResponse) = self.json.first!
            } else if status == 1164 {
                // logout
            }else {
                //let statusMessage = getFBStatusMessage(status)
                //assert(false,statusMessage)
            }
        } else {
            assert(json != nil, "JSON OBJECT IS NULL")
        }
    }
    
    func getName() -> String {
        return name
    }
    
    func getJson() -> JSON {
        return jsonResponse
    }
    
    func getStatus() -> Int {
        return status
    }
    
    func setStatus(status: Int) {
        self.status = status
    }
    
    func isValid(nameExpected: String) -> Bool {
        if getStatus() == 1000 && getName() == nameExpected {
            return true
        }
        return false
    }
}

/**
 *  Main Request Class
 */
class FbMessageRequest {
    var FbiJson: FbiJsonRequest
    
    required init(key: String, requestObj: AnyObject) {
        FbiJson = FbiJsonRequest(key: key, reqestObj: requestObj)
    }
    required init(key: String, id: Int, requestObj: AnyObject) {
        FbiJson = FbiJsonRequest(key: key, id: id, reqestObj: requestObj)
    }
}

class FbiJsonRequest {
    var Ticket: FbTicket = FbTicket(key: "", userId: 0)
    var FbiMsgsRq: FbiRequest
    
    required init(key:String, reqestObj: AnyObject) {
        Ticket.setKey(key)
        self.FbiMsgsRq = reqestObj as! FbiRequest
    }
    required init(key:String, id:Int, reqestObj: AnyObject) {
        Ticket.setKey(key)
        Ticket.setUserId(id)
        self.FbiMsgsRq = reqestObj as! FbiRequest
    }
}

protocol FbiRequest {
    
}


class FbiOrdersToPackRequest : FbiRequest {
    
}

class FbiCustomerListRequest : FbiRequest {
    var CustomerListRq :String = ""
}

