//
//  ModuleSettings.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/30/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class ModuleSettings {
    let settingList: [String] = [
        "\(Constants.Module.Pick)-Orders",
        "\(Constants.Module.Pack)-Orders",
        "\(Constants.Module.Ship)-Orders",
        "\(Constants.Module.Receive)-Orders",
        "\(Constants.Module.WorkOrder)-Orders",
        "\(Constants.Module.Delivery)-Orders",
    ]
    
    let UserDefaults = NSUserDefaults.standardUserDefaults()
    
    private let keyPrefix: String = "_mod_"
    
    private func buildKey(module: String, setting: String) -> String {
        let key = "\(keyPrefix)\(module)-\(setting)"
        return key
    }

    func saveSetting(module: String, setting: String, value: AnyObject) {
        let key = buildKey(module, setting: setting)
        UserDefaults.setValue(value, forKey: key)
    }
    
    func loadSetting(module: String, setting: String, defaultValue: AnyObject) -> AnyObject {
        let key = buildKey(module, setting: setting)
        if let value = UserDefaults.valueForKey(key) {
            return value
        }
        return defaultValue
    }

    func settingExists(module: String, setting: String) -> Bool {
        let key = buildKey(module, setting: setting)
        if UserDefaults.valueForKey(key) != nil {
            return true
        }
        return false
    }
    
    func deleteSetting(module: String, setting: String) {
        let key = buildKey(module, setting: setting)
        UserDefaults.removeObjectForKey(key)
    }

    func autoSelecteEnabled() -> Bool {
        let setting = loadSetting(Constants.Module.General, setting: "AutoSelect", defaultValue: true) as! Bool
        return setting
    }

}
