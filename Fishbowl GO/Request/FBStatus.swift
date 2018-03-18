//
//  FBStatus.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/21/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation

/* 
// Example
enum Device {
    case iPad, iPhone
    var year: Int {
        switch self {
        case iPhone: return 2007
        case iPad: return 2010
        }
    }
}
*/

func getFBStatusMessage(status:Int) -> String {
    switch(status) {
        case 1000:  return "Success!"
        
        case 1001: return "Unknown message received."
        case 1002: return "Connection to Fishbowl server was lost."
        case 1003: return "Some requests had errors."
        case 1004: return "There was an error with the database."
        case 1009: return "Fishbowl server has been shut down."
        case 1010: return "You have been logged off the server by an administrator."
        case 1011: return "Not found."
        case 1012: return "General error."
        case 1013: return "Dependencies need to be deleted"
        case 1014: return "Unable to establish network connection."
        case 1015: return "Your subscription date is greater than your server date."
        case 1016: return "Incompatible database version."
        case 1100: return "Unknown login error occurred."
        case 1109: return "This integrated application registration key is already in use."
        case 1110: return "A new integrated application has been added to Fishbowl. Please contact the Fishbowl administrator to approve this integrated application."
        case 1111: return "This integrated application registration key does not match."
        case 1112: return "This integrated application has not been approved by the Fishbowl administrator."
        case 1120: return "Invalid username or password."
        case 1130: return "Invalid ticket passed to Fishbowl server."
        case 1131: return "Invalid ticket key passed to Fishbowl server."
        case 1140: return "Initialization token is not correct type."
        case 1150: return "Request was invalid."
        case 1161: return "Response was invalid."
        case 1162: return "The login limit has been reached for the server's key."
        case 1163: return "Your API session has timed out."
        case 1164: return "Your API session has been logged out."
        case 1200: return "Custom field is invalid."
        case 1300: return "Was not able to find the memo _________."
        case 1301: return "The memo was invalid."
        case 1400: return "Was not able to find the order history."
        case 1401: return "The order history was invalid."
        case 1500: return "The import was not properly formed."
        case 1501: return "That import type is not supported."
        case 1502: return "File not found."
        case 1503: return "That export type is not supported."
        case 1504: return "Unable to write to file."
        case 1505: return "The import data was of the wrong type."
        case 1506: return "Import requires a header."
        case 1600: return "Unable to load the user."
        case 1601: return "Unable to find the user."
        case 2000: return "Was not able to find the part _________."
        case 2001: return "The part was invalid."
        case 2002: return "Was not able to find a unique part."
        case 2003: return "BOM had an error on the part."
        case 2100: return "Was not able to find the product _________."
        case 2101: return "The product was invalid."
        case 2102: return "The product is not unique."
        case 2120: return "The kit item was invalid."
        case 2121: return "The associated product was invalid."
        case 2200: return "Yield failed."
        case 2201: return "Commit failed."
        case 2202: return "Add initial inventory failed."
        case 2203: return "Cannot adjust committed inventory."
        case 2204: return "Invalid quantity."
        case 2205: return "Quantity must be greater than zero."
        case 2206: return "Serial number _________ already committed."
        case 2207: return "Part _________ is not an inventory part."
        case 2208: return "Not enough available quantity in _________."
        case 2209: return "Move failed."
        case 2210: return "Cycle count failed."
        case 2300: return "Was not able to find the tag number _______."
        case 2301: return "The tag was invalid."
        case 2302: return "The tag move failed."
        case 2303: return "Was not able to save tag number _________."
        case 2304: return "Not enough available inventory in tag number _________."
        case 2305: return "Tag number _________ is a location."
        case 2400: return "Invalid UOM."
        case 2401: return "UOM _________ not found."
        case 2402: return "Integer UOM _________ cannot have non-integer quantity."
        case 2403: return "The UOM is not compatible with the part's base UOM."
        case 2404: return "Cannot convert to the requested UOM."
        case 2405: return "Cannot convert to the requested UOM."
        case 2406: return "The quantity must be a whole number."
        case 2407: return "The UOM conversion for the quantity must be a whole number."
        case 2500: return "The tracking is not valid."
        case 2501: return "Part tracking not found."
        case 2502: return "The part tracking name is required."
        case 2503: return "The part tracking name _________ is already in use."
        case 2504: return "The part tracking abbreviation is required."
        case 2505: return "The part tracking abbreviation _________ is already in use."
        case 2506: return "The part tracking _________ is in use or was used and cannot be deleted."
        case 2510: return "Serial number is missing."
        case 2511: return "Serial number is null."
        case 2512: return "Duplicate serial number."
        case 2513: return "The serial number is not valid."
        case 2514: return "Tracking is not equal."
        case 2515: return "The tracking _________ was not found in location _________ or is committed to another order."
        case 2600: return "Location _________ not found."
        case 2601: return "Invalid location."
        case 2602: return "Location group _________ not found."
        case 2603: return "Default customer not specified for location _________."
        case 2604: return "Default vendor not specified for location _________."
        case 2605: return "Default location for part _________ not found."
        case 2606: return "_________ is not pickable location."
        case 2607: return "_________ is not receivable location."
        case 2700: return "Location group not found."
        case 2701: return "Invalid location group."
        case 2702: return "User does not have access to location group _________."
        case 3000: return "Customer _________ not found."
        case 3001: return "Customer is invalid."
        case 3002: return "Customer _________ must have a default main office address."
        case 3100: return "Vendor _________ not found."
        case 3101: return "Vendor is invalid."
        case 3300: return "Address not found."
        case 3301: return "Invalid address."
        case 4000: return "There was an error loading PO _________."
        case 4001: return "Unknown status _________."
        case 4002: return "Unknown carrier _________."
        case 4003: return "Unknown QuickBooks class _________."
        case 4004: return "PO does not have a PO number. Please turn on the auto-assign PO number option in the purchase order module options."
        case 4005: return "Duplicate order number _________."
        case 4006: return "Cannot create PO with configureable parts: _________"
        case 4007: return "The following parts were not added to the purchase order. They have no default vendor:"
        case 4008: return "Unknown type _________."
        case 4100: return "There was an error loading SO _________."
        case 4101: return "Unknown salesman _________."
        case 4102: return "Unknown tax rate _________."
        case 4103: return "Cannot create SO with configurable parts: _________."
        case 4104: return "The sales order item is invalid: _________."
        case 4105: return "SO does not have a SO number. Please turn on the auto-assign SO numbers option in the sales order module options."
        case 4106: return "Cannot create SO with kit products."
        case 4107: return "A kit item must follow a kit header."
        case 4108: return "Sales order cannot be found."
        case 4200: return "There was an error loading BOM _________."
        case 4201: return "Bill of materials cannot be found."
        case 4202: return "Duplicate BOM number _________."
        case 4203: return "The bill of materials is not up to date and must be reloaded."
        case 4204: return "Bill of materials was not saved."
        case 4205: return "Bill of materials is in use and cannot be deleted."
        case 4206: return "Requires a raw good and a finished good, or a repair."
        case 4207: return "This change would make this a recursive bill of materials."
        case 4210: return "There was an error loading MO _________."
        case 4211: return "Manufacture order cannot be found."
        case 4212: return "No manufacture order was created. Duplicate order number _________."
        case 4213: return "The manufacture order is not up to date and must be reloaded."
        case 4214: return "Manufacture order was not saved."
        case 4215: return "Manufacture order is closed and cannot be modified."
        case 4220: return "There was an error loading WO _________."
        case 4221: return "Work order cannot be found."
        case 4222: return "Duplicate work order number _________."
        case 4223: return "The work order is not up to date and must be reloaded."
        case 4224: return "Work order was not saved."
        case 4300: return "There was an error loading TO _________."
        case 4301: return "Unknown status _________."
        case 4302: return "Unknown carrier _________."
        case 4303: return "Transfer order cannot be found."
        case 4304: return "TO does not have a TO number. Please turn on the auto-assign TO number option in the Transfer Order module options."
        case 4305: return "Duplicate order number _________."
        case 4306: return "Unknown type _________."
        case 4307: return "Transfer order was not saved."
        case 4308: return "The transfer order is not up to date and must be reloaded."
        case 5000: return "There was a receiving error."
        case 5001: return "Receive ticket invalid."
        case 5002: return "Could not find a line item for part number _________."
        case 5003: return "Could not find a line item for product number _________."
        case 5004: return "Not a valid receive type."
        case 5005: return "The receipt is not up to date and must be reloaded."
        case 5006: return "A location is required to receive this part. Part num: _________"
        case 5007: return "Cannot receive or reconcile more than the quantity ordered on a TO."
        case 5008: return "Receipt not found _________."
        case 5100: return "Pick invalid."
        case 5101: return "Pick not found _________."
        case 5102: return "Pick was not saved."
        case 5103: return "An order on pick _________ has a problem."
        case 5104: return "Pick item not found _________."
        case 5105: return "Could not finalize pick. Quantity is not correct."
        case 5106: return "The pick is not up to date and must be reloaded."
        case 5107: return "The part in tag _________ does not match part _________."
        case 5108: return "Incorrect slot for this item. Item must be placed with others for this order."
        case 5109: return "Wrong number of serial numbers sent for pick."
        case 5110: return "Pick items must be started to assign tag."
        case 5111: return "Order must be picked from location group _________."
        case 5112: return "The item must be picked from _________."
        case 5200: return "Shipment invalid."
        case 5201: return "Shipment not found _________."
        case 5202: return "Shipment status error."
        case 5203: return "Unable to process shipment."
        case 5204: return "Carrier not found _________."
        case 5205: return "The shipment _________ has already been shipped."
        case 5206: return "Cannot ship order _________. The customer has a ship hold."
        case 5207: return "Cannot ship order _________. The vendor has a ship hold."
        case 5300: return "Could not load RMA."
        case 5400: return "Could not take payment."
        case 5500: return "Could not load the calendar."
        case 5501: return "Could not find the calendar."
        case 5502: return "Could not save the calendar."
        case 5503: return "Could not delete the calendar."
        case 5504: return "Could not find the calendar activity."
        case 5505: return "Could not save the calendar activity."
        case 5506: return "Could not delete the calendar activity."
        case 5507: return "The start date must be before the stop date."
        case 6000: return "Account invalid."
        case 6001: return "Discount invalid."
        case 6002: return "Tax rate invalid."
        case 6003: return "Accounting connection failed."
        case 6004: return "Accounting not here."
        case 6005: return "Accounting system not defined."
        case 6006: return "Accounting brought back a null result."
        case 6007: return "Accounting synchronization error."
        case 6008: return "The export failed."
        case 6009: return "Fishbowl and Quickbooks multiple currency features don't match"
        case 6010: return "The data validation for the export has failed."
        case 6100: return "Class already exists."
        case 7000: return "Pricing Rule error."
        case 7001: return "Pricing Rule not found."
        case 7002: return "The pricing rules name is not unique."
        case 8000: return "Unknown FOB _________."
        
        default:    return "unknown"
    }
}
