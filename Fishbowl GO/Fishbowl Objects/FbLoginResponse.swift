//
//  FbLoginResponse.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbModuleAccess: Mappable {
    var notMapped_accessList = [String: [String]]() // Group/Feature

    
    var Module = [String]()

    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        Module <- map["Module"]
        if Module.count <= 0 {
            var newModule: String?
            newModule <- map["Module"]
            Module.append(newModule!)
        }
        
        parseMappings()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbModuleAccess()
        
        for module in Module {
            let newItem: String = module
            copy.Module.append(newItem)
        }
        copy.parseMappings()
        return copy
    }

    private func parseMappings() {
        for module in Module {
            var info = module.characters.split{$0 == "-"}.map(String.init)
            if info.count > 0 {
                let group = info[0]
                info.removeAtIndex(0)
                let feature = info.joinWithSeparator("-")
                if notMapped_accessList[group] != nil {
                    notMapped_accessList[group]?.append(feature)
                } else {
                    notMapped_accessList[group] = [String]()
                    notMapped_accessList[group]?.append(feature)
                }
            }
        }
    }
    
    func hasAccess(user: String, group: String, feature: String) -> Bool {
        /*
         "Fishbowl GO-Part - Allow saving UPC",
         "Fishbowl GO-Part - Allow saving picture",
         "Fishbowl GO-Receive - Allow over receiving",
         "Fishbowl GO-Settings - Device",
         "Fishbowl GO-View",
         "Fishbowl GO-Work Order - Allow over pick",
         */
        
        // Is this the admin user?
        if user.caseInsensitiveCompare("admin") == .OrderedSame {
            return true
        }
        
        if let group = notMapped_accessList[group] {
            return group.contains(feature)
        }
        return false
    }
    
}

class FbLoginResponse: Mappable {

    var ModuleAccess = FbModuleAccess()
    var ServerVersion: String = ""
    var UserFullName: String = ""
    var statusCode: Int = 0
    

    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        ModuleAccess <- map["ModuleAccess"]
        ServerVersion <- map["ServerVersion"]
        UserFullName <- map["UserFullName"]
        statusCode <- map["statusCode"]
    }
    
    func getServerVerionInfo() -> [String] {
        let info = ServerVersion.characters.split{$0 == "."}.map(String.init)
        return info
    }
}
