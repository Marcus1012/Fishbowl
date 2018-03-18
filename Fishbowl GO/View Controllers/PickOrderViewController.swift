//
//  PickOrderViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/1/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import ObjectMapper
//import DZNEmptyDataSet

protocol PickOrderDelegate {
    func savePickItem(pickItem: FbPickItem)
}


class PickOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FBScannerDelegate, PickOrderDelegate
{
    let moduleTitle = "Pick"
    var orderNumber : String = ""
    var itemList: JSON?
    var pick: FbPick?
    var delegate: PickDelegate?
    var selectedPickItem: FbPickItem?

    private var errorTitle = "Pick Error"
    private var validPart: FbPart?
    private var activityIndicator : ActivityIndicatorWithText?
    private var itemsToPick = FbPickItems() // Model for table view displaying items to pick
    private var pickedItems = FbPickItems()
    
    @IBOutlet var tableView: PickOrderTableView!
    @IBOutlet var partNumber: UITextField!
    @IBOutlet var btnPickItem: UIButton!
    
    // MARK: - Actions
    @IBAction func btnPickItem(sender: AnyObject) {
        if partNumber.text!.isEmpty {
            invokeAlertMessage(moduleTitle, msgBody: "Part number is required", delegate: self)
        }

        if !findAndSelectItem(partNumber.stringValue) {
            invokeAlertMessage(moduleTitle, msgBody: "Part number not found on order", delegate: self)
            return
        }
        handlePick()
    }
    
    @IBAction func save(sender: AnyObject) {
        savePickOrder()
    }
    
    @IBAction func btnReload(sender: AnyObject) {
        resetPick()
        sendPickOrderRequest()
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        self.partNumber.delegate = self
        sendPickOrderRequest()
    }
    
    override func viewDidAppear(animated: Bool) {
        checkSavePickOrder()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "seguePickItem" {
            if !validatePartNumber(partNumber.text!) {
                return false
            }
            // Check settings... if "show edit" is not enable for pick module
            // then cancel the segue and "auto-pick" the item.
            let showEdit = g_pluginSettings.getSetting(Constants.Options.pickShowEditAlways)
            if showEdit {
                return true
            }
            // Auto pick the selected item...
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }
        guard let pick = self.pick else { return }

        if segueId == "seguePickItem" {
            let partNum = partNumber.stringValue
            setNavigationBackItem(partNum)
            let destViewController = segue.destinationViewController as! PickPartTableViewController
            destViewController.partNumber = partNum
            
            // Find the pick item in pick items list, look for UPC match too
            for pickItem in pick.PickItems.PickItem {
                if pickItem.Part.Num == partNum {
                    destViewController.pickItem = pickItem
                    break
                }
                
                if pickItem.Part.UPC == partNum {
                    destViewController.pickItem = pickItem
                    break
                }
            }
            
            // Now, get the part... don't segue if error
            
        } else if segueId == "segueScan" {
            let navController = segue.destinationViewController as! UINavigationController
            let destViewController = navController.childViewControllers[0] as! ScannerViewController
            destViewController.delegate = self
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
            case partNumber:
                btnPickItem(self)
                break
            default:
                textField.resignFirstResponder() // close the keyboard on <return>
        }
        return true
    }
    
    // MARK: - Delegate Methods
    func receivedScanCode(code: String) {
        partNumber.text = code
        findAndSelectItem(code)
        handlePick()
    }
    
    // Delegate method for part-picking scenes to call
    /*
     Notes:
     PickOrders
        PickOrder
            orderToId (this element is in the XML request from Android version)--what is it?
    */
    func savePickItem(pickItem: FbPickItem) {
        let actualPickedCount = tableView.doPickItem(pickItem, quantity: pickItem.Quantity) // remove from items to pick
        pickItem.Quantity = actualPickedCount
        pickItem.setStatus(Constants.PickStatus.Finished)
        pickItem.setDestinationTagNum(-1)
        pickedItems.add(pickItem)
        partNumber.text = "" // Clear part number field when item is picked.
    }
    
    // MARK: - Table View Delegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.numberOfRowsInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.cellForRowAtIndexPath(indexPath)!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        btnPickItem.enabled = true
        //textFieldShouldReturn(partNumber)
        selectedPickItem = self.tableView.getPickItem(indexPath.row)
        if selectedPickItem != nil {
            partNumber.text = selectedPickItem?.Part.Num
        }
        if moduleSettings.loadSetting(Constants.Module.General, setting: "AutoSelect", defaultValue: true) as! Bool {
            handlePick()
            checkSavePickOrder()
        }
    }

    // MARK: - Handle Selected Pick Item
    func handlePick() {
        if shouldShowEdit() {
            if let pickItem = selectedPickItem {
                getPartPrepForSegue(pickItem)
            }
        } else { // If not showing edit scene, pick the selected item
            if let pickItem = selectedPickItem {
                savePickItem(pickItem)
            }
        }
    }
    
    // MARK: - Server Requests
    func sendPickOrderRequest()
    {
        if orderNumber.characters.count > 0 {
            let fbMessageRequest = FbMessageRequest(
                key: g_apiKey,
                requestObj: FbiPickRequest(pickNum: orderNumber)
            )
            connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "Order loaded", handler: { (ticket, response) in
                self.pickOrderResponse(ticket, response:response)
            })
        }
    }    

    private func sendSavePickOrderRequest(pickToSave: FbPick, handler: (Bool) -> Void )
    {
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiSavePickRequest(pick: pickToSave)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest) { (ticket, response) in
            handler(self.savePickResponse(ticket, response: response))
        }
    }
    
    // MARK: - Response Handlers
    func savePickResponse(ticket: FbTicket, response: FbResponse) -> Bool
    {
        var errorMessage: String = ""
        var wasSuccessful = false
        if response.isValid(Constants.Response.savePick) {
            
            let partStatus = response.getJson()["statusCode"].intValue
            if partStatus == 1000 {
                wasSuccessful = true
            } else {
                errorMessage = response.getJson()["statusMessage"].stringValue
            }
        } else {
            errorMessage = getFBStatusMessage(response.getStatus())
        }
        
        if !wasSuccessful {
            invokeAlertMessage(errorTitle, msgBody: errorMessage, delegate: self, handler: { (UIAlertAction) in
                self.resetPick()
                self.sendPickOrderRequest()
            })
        }
        return wasSuccessful
    }

    
    private func pickOrderResponse(ticket: FbTicket, response: FbResponse)
    {
        if response.isValid(Constants.Response.getPick) {
            // Decode the full pick response
            let pickJson = response.getJson()["Pick"]
            pick = Mapper<FbPick>().map(String(pickJson))
            if pick != nil {
                let nonPickStatus: [UInt] = [
                    Constants.PickStatus.Hold,
                    Constants.PickStatus.Short,
                    Constants.PickStatus.Finished
                ]
                itemsToPick = pick!.getPickItemsCopy()
                itemsToPick.removeItemsWithStatus(nonPickStatus)
                tableView.setItemsToPick(itemsToPick)
            }
            tableView.reloadData()
        } else {
            invokeAlertMessage(errorTitle, msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        }
    }

    // MARK: - Support Methods
    private func checkSavePickOrder() {
        if tableView.allItemsPicked() {
            savePickOrder()
        }
    }

    private func findAndSelectItem(partNum: String) -> Bool {
        var found = false
        
        let (index, item) = itemsToPick.lookupPickItem(partNum)
        if index >= 0, let pickItem = item {
            selectedPickItem = pickItem
            partNumber.text = pickItem.Part.Num
            tableView.selectRowAtSectionRow(index, inSection: 0, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            found = true
        }
        
        return found
    }
    
    private func shouldShowEdit() -> Bool {
        let showEdit = g_pluginSettings.getSetting(Constants.Options.pickShowEditAlways)
        if showEdit {
            return true
        }
        // If the item is tracked, we always want to show the "edit" scene
        guard let pick = self.pick else { return false }
        if let pickItem = pick.getPickItem(partNumber.stringValue) {
            return pickItem.hasTracking()
        }
        return false
    }
    
    private func validatePartNumber(partNumber: String) -> Bool {
        var valid = false
        
        // Check to see if part number text field is empty... if it is, show alert and return false
        if !partNumber.isEmpty {
            valid = itemInList(partNumber)
        }
        
        if !valid {
            invokeAlertMessage(errorTitle, msgBody: "Invalid part number", delegate: self)

        }
        return valid
    }
    
    private func itemInList(partNum: String) -> Bool {
        // Find the pick item in pick item list
        guard let pick = self.pick else { return false }
        for pickItem in pick.PickItems.PickItem {
            if pickItem.Part.Num == partNum {
                return true
            }
            if pickItem.Part.UPC == partNum {
                return true
            }
        }
        return false
    }
    
    func getPartPrepForSegue(pickItem: FbPickItem) {
        
        validPart = pickItem.Part
        
        // setup the "back" button in nav bar...
        let partNum = partNumber.stringValue
        setNavigationBackItem(partNum)
        
        let segueIdentifier = getSegueIdentifier(validPart)
        switch segueIdentifier {
            
        case "pickPartTracking":
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(segueIdentifier) as! PickPartTrackTableViewController
            vc.partNumber = partNum
            vc.part = validPart
            vc.delegate = self
            vc.pickItem = pickItem
            vc.setPick(pick!)
            self.navigationController?.pushViewController(vc, animated: true)
            break
            
        case "pickPartSerial":
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(segueIdentifier) as! PickPartTrackSerialTableViewController
            vc.partNumber = partNum
            vc.part = validPart
            vc.pickItem = pickItem
            vc.setPick(pick!)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            break
            
        default: // "pickPartStandard"
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(segueIdentifier) as! PickPartTableViewController
            vc.part = validPart
            vc.partNumber = partNum
            vc.delegate = self
            vc.pickItem = pickItem
            self.navigationController?.pushViewController(vc, animated: true)
            break
            
        }
    }
    
    private func getSegueIdentifier(fbPart: FbPart?) -> String {
        var vcIdentifier = "pickPartStandard"
        guard let part = fbPart else { return vcIdentifier }
        
        if part.hasSerialTracking() {
            vcIdentifier = "pickPartSerial"
        } else  if part.hasTracking() {
            vcIdentifier = "pickPartTracking"
        }
        return vcIdentifier
    }

    private func savePickOrder() {
        guard let pick = self.pick else { return }

        let pickToSave = pick.copyWithZone(nil) as! FbPick
        pickToSave.replacePickedItems(pickedItems)
        sendSavePickOrderRequest(pickToSave) { (success) in
            if success {
                if let del = self.delegate {
                    del.pickOrderSaved(pick)
                }
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    private func resetPick() {
        pick = nil
        itemsToPick.removeAll()
        pickedItems.removeAll()
        tableView.reset()
    }

}
