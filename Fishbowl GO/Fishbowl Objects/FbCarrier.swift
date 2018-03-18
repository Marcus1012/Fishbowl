//
//  FbCarrier.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper

class FbCarriers: Mappable {
    var names = [String]()
    
    required init(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        names <- map["Carriers.Name"]
        //        dictionary  <- map["dict"]
        //        bestFriend  <- map["best_friend"]
        //        friends     <- map["friends"]
        //        birthday    <- (map["birthday"], DateTransform())
    }
    
}
/*
 
 var delegateList = [String: ResponseDelegate]()
 var cache = [String: AnyObject]()
 
 // Each entry in the cache
 // cacheList (list of caches)
 // each cache is a list of String:AnyObjects
 // when adding a cache item... send "key" for that item, and the class
 // cache will decide which cache based on the class name, then store the key/object value
 // cache.storeItem(type, key, object)
 // cache.storeItem("Carrier", "Key", ObjectB)
 // Getting items from cache...
 // cache.getItem(type, key)
 // cache.getList(type)
 
 delegateList[responseName] = newDelegate
 }
 
 /*
 Unregister a response delegate/callback function for the given response name.
 */
 func removeResponseDelegate(responseName: String)
 {
 delegateList[responseName] = nil */
