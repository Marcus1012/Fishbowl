//
//  SettingsViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/30/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    struct SETTINGS {
        static let ORDERS = "Orders"
        static let AUTO_SELECT = "AutoSelect"
        static let TOUCH_ID = "TouchId"
    }
    
    @IBOutlet var fieldPickCount: UITextField!
    @IBOutlet var fieldPackCount: UITextField!
    @IBOutlet var fieldShipCount: UITextField!
    @IBOutlet var fieldReceiveCount: UITextField!
    @IBOutlet var fieldWorkOrderCount: UITextField!
    @IBOutlet var fieldDeliveryCount: UITextField!
    @IBOutlet var switchAutoSelect: UISwitch!
    @IBOutlet var switchTouchId: UISwitch!
    
    
    // MARK: - Actions
    @IBAction func btnSave(sender: AnyObject) {
        saveSettings()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
        
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
    }
    
    // MARK: - Core Methods
    private func saveSettings() {
        moduleSettings.saveSetting(Constants.Module.Pick, setting: SETTINGS.ORDERS, value: UInt(fieldPickCount.text!)!)
        moduleSettings.saveSetting(Constants.Module.Pack, setting: SETTINGS.ORDERS, value: UInt(fieldPackCount.text!)!)
        moduleSettings.saveSetting(Constants.Module.Ship, setting: SETTINGS.ORDERS, value: UInt(fieldShipCount.text!)!)
        moduleSettings.saveSetting(Constants.Module.Receive, setting: SETTINGS.ORDERS, value: UInt(fieldReceiveCount.text!)!)
        moduleSettings.saveSetting(Constants.Module.WorkOrder, setting: SETTINGS.ORDERS, value: UInt(fieldWorkOrderCount.text!)!)
        moduleSettings.saveSetting(Constants.Module.Delivery, setting: SETTINGS.ORDERS, value: UInt(fieldDeliveryCount.text!)!)
        moduleSettings.saveSetting(Constants.Module.General, setting: SETTINGS.AUTO_SELECT, value: switchAutoSelect.on)
        moduleSettings.saveSetting(Constants.Module.General, setting: SETTINGS.TOUCH_ID, value: switchTouchId.on)
    }
    
    private func loadSettings() {
        var setting:AnyObject
        
        setting = moduleSettings.loadSetting(Constants.Module.Pick, setting: SETTINGS.ORDERS, defaultValue: 99)
        fieldPickCount.text = "\(setting)"
        setting = moduleSettings.loadSetting(Constants.Module.Pack, setting: SETTINGS.ORDERS, defaultValue: 99)
        fieldPackCount.text = "\(setting)"
        setting = moduleSettings.loadSetting(Constants.Module.Ship, setting: SETTINGS.ORDERS, defaultValue: 99)
        fieldShipCount.text = "\(setting)"
        setting = moduleSettings.loadSetting(Constants.Module.Receive, setting: SETTINGS.ORDERS, defaultValue: 99)
        fieldReceiveCount.text = "\(setting)"
        setting = moduleSettings.loadSetting(Constants.Module.WorkOrder, setting: SETTINGS.ORDERS, defaultValue: 99)
        fieldWorkOrderCount.text = "\(setting)"
        setting = moduleSettings.loadSetting(Constants.Module.Delivery, setting: SETTINGS.ORDERS, defaultValue: 99)
        fieldDeliveryCount.text = "\(setting)"
        setting = moduleSettings.loadSetting(Constants.Module.General, setting: SETTINGS.AUTO_SELECT, defaultValue: true)
        switchAutoSelect.on = setting as! Bool
        setting = moduleSettings.loadSetting(Constants.Module.General, setting: SETTINGS.TOUCH_ID, defaultValue: true)
        switchTouchId.on = setting as! Bool
    }
    
}
