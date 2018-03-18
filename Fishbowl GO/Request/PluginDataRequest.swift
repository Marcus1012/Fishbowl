//
//  PluginDataRequest.swift
//  Fishbowl Go
//
//  Created by Marcus Korpi on 6/25/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiPluginDataRequest : FbiRequest {
    var GetPluginDataRq : pluginDataRequestCore
    
    init(pluginName: String) {
        GetPluginDataRq = pluginDataRequestCore(pluginName: pluginName)
    }
    
}


class pluginDataRequestCore {
    var Plugin: String = ""
    
    init(pluginName: String) {
        Plugin = pluginName
    }
}
