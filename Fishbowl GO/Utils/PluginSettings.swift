//
//  PluginSettings.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/4/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class PluginSettings {
    var settings = [String: Bool]()   // Stores the plugin settings in key/value pairs

    func addSetting(name: String, value: Bool) {
        settings[name] = value
    }
    
    func getSetting(name: String) -> Bool {
        if let value = settings[name] {
            return value
        }
        return false
    }
    
    func reset() {
        settings.removeAll()
    }
}
