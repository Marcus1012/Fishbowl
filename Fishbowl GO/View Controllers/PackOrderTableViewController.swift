//
//  PackOrderTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 10/18/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import ObjectMapper


protocol PackOrderDelegate {
    func savePackItem(shippingItem: FbShippingItem)
}

class PackOrderTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, PackOrderDelegate, FBScannerDelegate {

    // MARK: Data source for product items table
    class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
        var items = FbShippingItems()
        var parent: PackOrderTableViewController! = nil
        
        func setData(shippingItems: FbShippingItems) {
            items = shippingItems
        }
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.ShippingItem.count
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let item = items.ShippingItem[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
            cell.textLabel?.text = item.ProductNumber+"-"+item.ProductDescription
            let qty = item.QtyShipped
            cell.detailTextLabel?.text = "\(qty)"
            cell.detailTextLabel?.text = "\(qty) \(item.UOM.Code)"
            return cell
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            parent.unpackedItemSelected(items.ShippingItem[indexPath.row])
        }
        
        func removeItem(tableView: UITableView, itemNumber: String) {
            for (idx, item) in items.ShippingItem.enumerate() {
                if item.ProductNumber == itemNumber {
                    items.ShippingItem.removeAtIndex(idx)
                    // delete cell from tableview...
                    let indexPath = NSIndexPath(forItem: idx, inSection: 0)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    break
                }
            }
        }
    }
    // -----------------------------------------------------------------------------
    
    class PickerCellInfo {
        var indexPath: NSIndexPath
        var indexPathParent: NSIndexPath // the indexpath of the "parent" cell (that controls the open/close of this cell)
        var pickerView: UIPickerView
        var isVisible: Bool = false
        var parentLabel: UILabel?
        let textNormalColor = UIColor.blackColor()
        let textHighlightColor = UIColor.redColor()
        
        init(indexPath: NSIndexPath, parent: NSIndexPath, view: UIPickerView, visible: Bool, label:UILabel) {
            self.indexPath = indexPath
            self.indexPathParent = parent
            self.pickerView = view
            self.pickerView.hidden = true
            self.pickerView.translatesAutoresizingMaskIntoConstraints = false
            self.isVisible = visible
            self.parentLabel = label
        }
    }
    
    class BasicCarton {
        var name: String = ""       // Display name of the carton
        var number: Int = -1        // Carton number (not the ID)
        init(name:String, number: Int) {
            self.name = name
            self.number = number
        }
    }
    
    @IBOutlet var pickerCarton: UIPickerView!
    @IBOutlet var pickerCarrier: UIPickerView!
    @IBOutlet var labelCarton: UILabel!
    @IBOutlet var labelCarrier: UILabel!
    @IBOutlet var tableViewItems: UITableView!
    
    private var initialzied = false
    private var packedItems = FbShippingItems()
    private var itemsToPack = FbShippingItems()     // Model for table view displaying items to pack
    private let errorTitle = "Pack Error"

    var dataSource = DataSource()
    var orderNum: String = ""
    var pickerCellCarton: PickerCellInfo?
    var pickerCellCarrier: PickerCellInfo?
    var cartonList = [BasicCarton]()
    private var selectedCartonIndex: Int = 0
    private var selectedCarrierIndex: Int = 0
    var shipping = FbShipping()             // GetShipmentRs object from server
    var selectedShippingItem: FbShippingItem?
    var delegate: PackDelegate?

    
    
    // MARK: - Actions
    @IBAction func addCarton(sender: AnyObject) {
        let number = cartonList.count + 1
        let cartonName = "Carton #\(number)"
        shipping.addCarton(number)
        cartonList.append(BasicCarton(name: cartonName, number: number))
        labelCarton.text = cartonName
        selectedCartonIndex = cartonList.count - 1
        pickerCarton.reloadAllComponents()
    }
    
    func packItem(sender: AnyObject) {
        if shouldShowEdit() {
            if selectedShippingItem != nil {
                prepAndPerformSegue(selectedShippingItem!)
            }
        } else { // If not showing edit scene, pack the selected item
            if let item  = selectedShippingItem {
                let newItem = item.copyWithZone(nil) as! FbShippingItem
                newItem.CartonName = cartonList[selectedCartonIndex].number
                savePackItem(newItem)
                shipping.setItemQuantity(newItem.ProductNumber, quantity: newItem.QtyShipped)
                dataSource.removeItem(tableViewItems, itemNumber: newItem.ProductNumber)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func getSegueIdentifier(shipItem: FbShippingItem?) -> String {
        var vcIdentifier = "packPartStandard"
        guard let item = shipItem else { return vcIdentifier }
        if item.Tracking.TrackingItem.count > 0 {
            vcIdentifier = "packPartTracking"
        }
        return vcIdentifier
    }
    
    private func shouldShowEdit() -> Bool {
        let showEdit = g_pluginSettings.getSetting(Constants.Options.packShowEditAlways);
        if showEdit {
            return true
        }
        // If the item is tracked, we always want to show the "edit" scene
        guard let item = selectedShippingItem else { return false }
        return item.hasTracking()
    }

    func prepAndPerformSegue(shippingItem: FbShippingItem) {
        let storyboardId = getSegueIdentifier(shippingItem)
        setNavigationBackItem(labelCarton.stringValue)
        switch storyboardId {
        case "packPartTracking":
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(storyboardId) as! PackPartTrackingTableViewController
            vc.shippingItem = shippingItem
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            break
            
        default: // "packPartStandard"
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(storyboardId) as! PackPartStandardTableViewController
            vc.shippingItem = shippingItem
            vc.delegate = self
            vc.setCartonNumber(cartonList[selectedCartonIndex].number)
            self.navigationController?.pushViewController(vc, animated: true)
            break
            
        }
    }

    
    // MARK: - Delegate Methods
    func savePackItem(shippingItem: FbShippingItem) {
        if packedItems.shipItemExists(shippingItem.ShipItemID) {
            shippingItem.ShipItemID = -1
        }
        packedItems.addShippingItem(shippingItem)
        itemsToPack.decrementItemQuantity(shippingItem.ProductNumber, quantity: shippingItem.QtyShipped)
        tableViewItems.reloadData()
    }
    
    func receivedScanCode(code: String) {
        if let item = itemsToPack.getItemByNumber(code, checkForUpcMatch: true) {
            unpackedItemSelected(item)
        }
    }

    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.parent = self
        pickerCarrier.delegate = self
        pickerCarrier.dataSource = self
        pickerCarton.delegate = self
        pickerCarton.dataSource = self
        
        cartonList.append(BasicCarton(name: "Carton #1", number: 1))
        
        pickerCellCarton = PickerCellInfo(indexPath: NSIndexPath(forItem: 1, inSection: 0), parent: NSIndexPath(forItem: 0, inSection: 0), view: self.pickerCarton, visible: false, label: labelCarton)
        pickerCellCarrier = PickerCellInfo(indexPath: NSIndexPath(forItem: 3, inSection: 0), parent: NSIndexPath(forItem: 2, inSection: 0), view: self.pickerCarrier, visible: false, label: labelCarrier)
        
        labelCarton.text = cartonList[0].name
        if g_carrierList.count > 0 {
            labelCarrier.text = g_carrierList[0]
        }
        tableViewItems.dataSource = dataSource
        tableViewItems.delegate = dataSource
        sendGetShipmentRequest()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
        checkSavePackOrder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }
        if segueId   == "segueScanPack" {
            let navController = segue.destinationViewController as! UINavigationController
            let destViewController = navController.childViewControllers[0] as! ScannerViewController
            destViewController.delegate = self
        }
    }

    // MARK: - Server Requests
    func sendPrintPackingListRequest(handler: (Bool, String) -> Void)
    {
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiPrintReportRequest(moduleName: "Shipping", shipId: shipping.ID)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest) { (ticket, response) in
            let (success, error) = self.printPackingListResponse(ticket, response: response)
            handler(success, error)
        }
    }
    
    
    func sendSaveShipmentRequest(handler: (Bool) -> Void )
    {
        guard packedItems.ShippingItem.count > 0 else {
            handler(false)
            return
        }
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiSaveShipmentRequest(shipment: shipping)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest) { (ticket, response) in
            handler(self.saveShipmentResponse(ticket, response: response))
        }
    }
    
    func sendGetShipmentRequest()
    {
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiShipmentRequest(shipmentNum: orderNum)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "") { (ticket, response) in
            self.shipmentResponse(ticket, response: response)
            self.initialzied = true
        }
    }
    
    // MARK: - Server Responses
    func printPackingListResponse(ticket: FbTicket, response: FbResponse) -> (Bool, String)
    {
        var errorMessage: String = ""
        var wasSuccessful = false

        if response.isValid(Constants.Response.printReport) {
            let status = response.getJson()["statusCode"].intValue
            if status == 1000 {
                wasSuccessful = true
            } else {
                errorMessage = response.getJson()["statusMessage"].stringValue
            }
        } else {
            errorMessage = getFBStatusMessage(response.getStatus())
        }
        return (wasSuccessful, errorMessage)
    }
    
    func saveShipmentResponse(ticket: FbTicket, response: FbResponse) -> Bool
    {
        var errorMessage: String = ""
        var wasSuccessful = false
        if response.isValid(Constants.Response.saveShipment) {
            let packStatus = response.getJson()["statusCode"].intValue
            if packStatus == 1000 {
                wasSuccessful = true
            } else {
                errorMessage = response.getJson()["statusMessage"].stringValue
            }
        } else {
            errorMessage = getFBStatusMessage(response.getStatus())
        }
        
        if !wasSuccessful {
            invokeAlertMessage(errorTitle, msgBody: errorMessage, delegate: self)
        }
        return wasSuccessful
    }
    
    func shipmentResponse(ticket: FbTicket, response: FbResponse)
    {
        if response.isValid(Constants.Response.shipment) {
            let responseStatus = response.getJson()["statusCode"].intValue
            if responseStatus != 1000 {
                let statusMessage = response.getJson()["statusMessage"].stringValue
                invokeAlertMessage(errorTitle, msgBody: statusMessage, delegate: self)
            } else {
                let shipList = response.getJson()["Shipping"]
                let data = String(shipList) + ""
                if let fbShipping = Mapper<FbShipping>().map(data) {
                    shipping = fbShipping
                    shipping.Cartons.resetAllShipIds()
                    itemsToPack = shipping.getShippingItemsCopy()
                    dataSource.setData(itemsToPack)
                    setCarrierSelection(shipping.Carrier)
                    tableViewItems.reloadData()
                } else {
                    invokeAlertMessage(errorTitle, msgBody: "Unable to decode the order information", delegate: self)
                }
            }
        } else {
            invokeAlertMessage(errorTitle, msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        }
    }
    
    // MARK: - Table View Methods
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat = tableView.rowHeight
        
        if tableView.tag == tableViewItems.tag { // return if this is the nested table
            return height
        }
        
        if let cellInfo = pickerCellCarton {
            if cellInfo.indexPath.isEqual(indexPath) {
                height = (cellInfo.isVisible) ? 150.0 : 0.0
            }
        }
        if let cellInfo = pickerCellCarrier {
            if cellInfo.indexPath.isEqual(indexPath) {
                height = (cellInfo.isVisible) ? 150.0 : 0.0
            }
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            height = 250
        }
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cellInfo = matchParentCellInfo(indexPath) {
            if cellInfo.isVisible {
                hidePickerCell(cellInfo)
            } else {
                showPickerCell(cellInfo)
            }
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Picker View Methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 1 { // Carton Picker
            return cartonList.count
        } else if pickerView.tag == 2 { // Carrier Picker
            return g_carrierList.count
        }
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return cartonList[row].name
        } else if pickerView.tag == 2 {
            return g_carrierList[row]
        }
        return nil
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 { // Carton
            selectedCartonIndex = row
            labelCarton.text = cartonList[row].name
        } else if pickerView.tag == 2 { // Carrier
            selectedCarrierIndex = row
            labelCarrier.text = g_carrierList[row]
        }
    }
    
    // MARK: - Helper Functions
    private func setCarrierSelection(selectItem: String) {
        // Set initial carrier selection in picker
        for (index, carrier) in g_carrierList.enumerate() {
            if carrier == selectItem {
                selectedCarrierIndex = index
                pickerCarrier.selectRow(selectedCarrierIndex, inComponent: 0, animated: true)
                labelCarrier.text = carrier
            }
        }
    }

    private func checkSavePackOrder() {
        if initialzied && allItemsPacked() {
            savePackOrder()
        }
    }

    private func allItemsPacked() -> Bool {
        if itemsToPack.itemsRemaining() > 0 {
            return false
        }
        return true
    }
    
    private func savePackOrder() {
        shipping.mergeShippingItems(packedItems)
        shipping.setStatus(Constants.ShipStatus.Packed)
        
        sendSaveShipmentRequest { (valid) in
            if valid {
                if let del = self.delegate {
                    del.packOrderSaved(nil)
                }
                self.promptPrintPackingList()
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                invokeAlertMessage(self.errorTitle, msgBody: "An error occured while attempting to save packed order", delegate: self)
            }
        }
    }
    
    private func promptPrintPackingList() {
        invokeConfirm("Fishbowl GO Pack", message: "Print packing list?", okText: "Yes", cancelText: "No",
            okHandler: { (UIAlertAction) in
                self.sendPrintPackingListRequest({ (success, message) in
                    if success {
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        invokeAlertMessage(self.errorTitle, msgBody: message, delegate: self, handler: { (UIAlertAction) in
                            self.navigationController?.popViewControllerAnimated(true)
                        })
                    }
                })
            },
            cancelHandler: { (UIAlertAction) in
                self.navigationController?.popViewControllerAnimated(true)
            },
            delegate: self)
    }

    func unpackedItemSelected(item: FbShippingItem) {
        selectedShippingItem = item
        selectedShippingItem?.CartonName
        if moduleSettings.loadSetting(Constants.Module.General, setting: "AutoSelect", defaultValue: true) as! Bool {
            packItem(self)
            checkSavePackOrder()
        }
    }
    
    private func matchParentCellInfo(indexPath: NSIndexPath) -> PickerCellInfo? {
        if let cellInfo = pickerCellCarton {
            if cellInfo.indexPathParent.isEqual(indexPath) {
                return cellInfo
            }
        }
        if let cellInfo = pickerCellCarrier {
            if cellInfo.indexPathParent.isEqual(indexPath) {
                return cellInfo
            }
        }
        return nil
    }
    
    private func showPickerCell(cellInfo: PickerCellInfo) {
        cellInfo.isVisible = true
        tableView.beginUpdates()
        tableView.endUpdates()
        cellInfo.pickerView.hidden = false
        cellInfo.pickerView.alpha = 0.0
        UIView.animateWithDuration(0.25) { 
            cellInfo.pickerView.alpha = 1.0
        }
        cellInfo.parentLabel?.textColor = cellInfo.textHighlightColor
    }
    
    private func hidePickerCell(cellInfo: PickerCellInfo) {
        cellInfo.isVisible = false
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.animateWithDuration(0.25, animations: {
            cellInfo.pickerView.alpha = 0.0
            }) { (finishd ) in
                cellInfo.pickerView.hidden = true
                cellInfo.parentLabel?.textColor = cellInfo.textNormalColor
        }
    }



}
