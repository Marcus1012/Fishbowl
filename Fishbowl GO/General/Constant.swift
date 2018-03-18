//
//  Constant.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 7/8/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let defaultServerPort = 28192
    static let defaultServerHost = ""
    static let defaultPluginName = "Fishbowl GO"
    static let defaultMajorVersion = 17
    static let defaultRightsGroup = "Fishbowl GO"
    static let defaultRowHeight: CGFloat = 44.0
    
    struct Request {
//        static let login = ""
//        static let compatible = ""
    }
    
    struct Orientation {
        static let Portrait = 1
        static let Landscape = 2
    }
    
    // Rights Management Features for Fishbowl GO
    struct Rights {
        static let Cycle              = "Cycle"
        static let Delivery           = "Delivery"
        static let Move               = "Move"
        static let Pack               = "Pack"
        static let Part               = "Part"
        static let Pick               = "Pick"
        static let Receive            = "Receive"
        static let Ship               = "Ship"
        static let View               = "View"
        static let Scrap              = "Scrap"
        static let AddInventory       = "Add Inventory"
        
        static let AllowSaveUpc       = "Part - Allow saving UPC"
        static let AllowSavePicture   = "Part - Allow saving picture"
        static let AllowOverReceiving = "Receive - Allow over receiving"
        static let SettingsDevice     = "Settings - Device"
        static let WorkOrder          = "Work Order"
        static let AllowOverPick      = "Work Order - Allow over pick"
    }
    
    // Response Names
    struct Response {
        static let addInventory = "AddInventoryRs"
        static let carrierList = "CarrierListRs"
        static let compatible = "CompatibleRs"
        static let cycleCount = "CycleCountRs"
        static let getPick = "GetPickRs"
        static let getPluginData = "GetPluginDataRs"
        static let inventoryQuantity = "InvQtyRs"
        static let locationList = "LocationListRs"
        static let login = "LoginRs"
        static let logout = "LogoutRs"
        static let move = "MoveRs"
        static let partGet = "PartGetRs"
        static let pickQuery = "PickQueryRs"
        static let printReport = "PrintReportRs"
        static let receivingList = "ReceivingListRs"
        static let receipt = "GetReceiptRs"
        static let shipList = "GetShipListRs"
        static let shipment = "GetShipmentRs"
        static let saveImage = "SaveImageRs"
        static let savePick = "SavePickRs"
        static let saveReceipt = "SaveReceiptRs"
        static let saveShipment = "SaveShipmentRs"
        static let saveUpc = "SaveUPCRs"
        static let saveWorkOrder = "SaveWorkOrderRs"
        static let shipOrder = "ShipRs"
        static let uomList = "UOMRs"
        static let workOrderList = "WorkOrderListRs"
        static let workOrder = "GetWorkOrderRs"
    }
    
    struct Property {
        static let license = "License"
        static let compatible = "Compatible"
        static let statusCode = "statusCode"
        //static let statusStarted = "Started"
        static let statusStarted = "5"
    }
    
    // MARK: - Constants for Plugin Options
    struct Options {
        static let pluginActivated = "pluginActivated"
        static let rebuildFullCache = "rebuildFullCache"
        static let pickShowOnlyAssigned = "pickShowOnlyAssignedPicks"
        static let pickShowEditAlways = "pickShowEditAlways"
        static let pickShowOnlyInProgress = "pickShowOnlyInProgress"
        static let packShowEditAlways = "packShowEditAlways"
        static let partUpdateProductUpc = "partUpdateProductUpc"
        static let partUpdateProductImage = "partUpdateProductImage"
        static let shipIncludeEntered = "shipIncludeEntered"
        static let receiveShowEditAlways = "receiveShowEditAlways"
        static let workorderShowAllOpen = "woShowAllOpen"
    }
    
    // MARK: - Order Types
    struct OrderType {
        static let ALL:UInt = 5     // All
        static let PO: UInt = 10    // Purchase Order
        static let SO: UInt = 20    // Sales Order
        static let WO: UInt = 30    // Work Order
        static let TO: UInt = 40    // Transfer Order
        static let None:UInt = 1    // None
        
    }
    
    struct TrackingType {
        static let Text: UInt           = 10
        static let Date: UInt           = 20
        static let ExpirationDate: UInt = 30
        static let SerialNumber: UInt   = 40
        static let Money: UInt          = 50
        static let Quantity: UInt       = 60
        static let Count: UInt          = 70
        static let CheckBox: UInt       = 80
    }
    
    // MARK: - Module Constants
    struct Module {
        static let Pick = "PICK"
        static let Pack = "PACK"
        static let Ship = "SHIP"
        static let Receive = "RECEIVE"
        static let Move = "MOVE"
        static let Cycle = "CYCLE"
        static let Part = "PART"
        static let WorkOrder = "WORKORDER"
        static let Delivery = "DELIVERY"
        static let General = "GENERAL"
        static let DefaultOrderCount: UInt = 99
    }
    
    struct Settings {
        static let Orders     = "Orders"
        static let AutoSelect = "AutoSelect"
        static let ToutchId   = "TouchId"
        static let InstallId  = "install_id"
    }
    
    struct PickStatus {
        static let Short: UInt     = 5
        static let Hold: UInt      = 6
        static let Entered: UInt   = 10
        static let EnteredNew:UInt = 11
        static let Started: UInt   = 20
        static let Committed: UInt = 30
        static let Finished: UInt  = 40
    }

    static let Status: [UInt: String] = [
        0:                     "Unknown",
        PickStatus.Short:      "Short",
        PickStatus.Hold:       "Hold",
        PickStatus.Entered:    "Entered",
        PickStatus.EnteredNew: "Entered New",
        PickStatus.Started:    "Started",
        PickStatus.Committed:  "Committed",
        PickStatus.Finished:   "Finished"
    ]
    
    struct ShipStatus {
        static let Entered: UInt    = 10
        static let Packed: UInt     = 20
        static let Shipped: UInt    = 30
    }
    
    struct ReceiptItemStatus {
        static let Entered: UInt    = 10
        static let Reconciled: UInt = 20
        static let Received: UInt   = 30
        static let Fulfilled: UInt  = 40
    }
    
    struct BomItemType {
        static let FinishedGood: UInt       = 10
        static let RawGood: UInt            = 20
        static let Repair: UInt             = 30
        static let RepairFinishedGood: UInt = 31
        static let Note: UInt               = 40
        static let BillOfMaterials: UInt    = 50
    }
    
    struct WorkOrderStatus {
        static let All: UInt        = 5
        static let Entered: UInt    = 10
        static let Issued: UInt     = 20
        static let Started: UInt    = 30
        static let Fulfilled: UInt  = 40
    }
    
    struct PartType {
        static let Inventory: UInt      = 10
        static let Service: UInt        = 20
        static let Labor: UInt          = 21
        static let Overhead: UInt       = 22
        static let NonInventory: UInt   = 30
        static let InternalUse: UInt    = 40
        static let CapitalEquip: UInt   = 50
        static let Shipping: UInt       = 60
        static let Tax: UInt            = 70
        static let Misc: UInt           = 80
    }
    
    struct Field {
        static let Location: Int        = 0
        static let FromLocation: Int    = 1
        static let ToLocation: Int      = 2
        static let Quantity: Int        = 3
        static let Part: Int            = 4
    }
}
