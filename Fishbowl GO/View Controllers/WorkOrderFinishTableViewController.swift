//
//  WorkOrderFinishTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 12/5/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit


protocol FbWorkOrderSavedDelegate {
    func workOrderSaved(workOrder: FbWorkOrder?)
}


class WorkOrderFinishTableViewController: UITableViewController {

    
    private var WorkOrder: FbWorkOrder?
    private var validLocation = FbLocation()
    private var validQuantity: Int = 0
    
    var delegate: FbWorkOrderSavedDelegate?

    
    @IBOutlet weak var finishedGoodLabel: UILabel!
    @IBOutlet weak var quantityLabel: UITextField!
    @IBOutlet weak var locationLabel: LocationTextField!
    
    // MARK: - Actions
    @IBAction func btnFinish(sender: AnyObject) {
        if validFormInputs() {
            doFinishWorkOrderRequest()
        }
    }
    
    @IBAction func btnSave(sender: AnyObject) {
    }
    
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        locationLabel.lookupDelegate = locationCache
        guard let workOrder = WorkOrder else { return }
        if let item = workOrder.getFinishedGoodItem() {
            quantityLabel.text = item.getQuantityToFulfill()
            locationLabel.text = item.DestLocation.Location.getFullName()
            finishedGoodLabel.text = item.Part.getFullName()
        }
        quantityLabel.addDismissButton()
    }
    
    /*
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navController = segue.destinationViewController as! UINavigationController
        guard let segueId = segue.identifier else { return }
        
        if segueId == "choose_location_segue" {
            let destViewController = navController.childViewControllers[0] as! LocationTableViewController
            destViewController.delegate = self.locationLabel
        } else if segueId == "scan_location_segue" {
            let destViewController = navController.childViewControllers[0] as! ScannerViewController
            destViewController.delegate = self.locationLabel
        }
    }
    
    
    // MARK: - Helper Functions
    func setWorkOrder(workOrder: FbWorkOrder?) {
        WorkOrder = workOrder
    }
    
    private func validFormInputs() -> Bool {
        // Validate From-Location
        let (valid, fbLocation) = locationCache.validLocation(locationLabel.stringValue);
        if !valid {
            invokeAlertMessage("Location Error", msgBody: "Location is invalid", delegate: self)
            return false
        }
        locationLabel.text = fbLocation?.getFullName()
        validLocation = fbLocation!
        
        // Validate quantity
        if quantityLabel.integerValue <= 0 {
            invokeAlertMessage("Quantity Error", msgBody: "Quantity is invalid", delegate: self)
            return false
        }
        validQuantity = quantityLabel.integerValue
        
        return true
    }
    
    private func doFinishWorkOrderRequest() {
        guard let workOrder = self.WorkOrder else { return }

        let workOrderToSave = workOrder.copyWithZone(nil) as! FbWorkOrder
        workOrderToSave.StatusID = Constants.WorkOrderStatus.Fulfilled
        if let item = workOrderToSave.getFinishedGoodItem() {
            item.setDestinationLocation(validLocation)
        }
        sendSaveWorkOrderRequest(workOrderToSave) { (success) in
            if success {
                if let del = self.delegate {
                    del.workOrderSaved(workOrderToSave)
                }
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    // MARK: - Server Requests
    private func sendSaveWorkOrderRequest(workOrder: FbWorkOrder, handler: (Bool) -> Void ) {
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiSaveWorkOrderRequest(workOrder: workOrder)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest) { (ticket, response) in
            handler(self.saveWorkOrderResponse(ticket, response: response))
        }
    }
    
    private func saveWorkOrderResponse(ticket: FbTicket, response: FbResponse) -> Bool
    {
        if response.isValid(Constants.Response.saveWorkOrder) {
            /*
            // Decode the full save work order response
            let pickJson = response.getJson()["Pick"]
            pick = Mapper<FbPick>().map(String(pickJson))
            if pick != nil {
                itemsToPick = pick!.getPickItemsCopy()
                itemsToPick.removeItemsWithStatus([
                    Constants.PickStatus.Hold,
                    Constants.PickStatus.Short,
                    Constants.PickStatus.Finished
                    ])
                pickedItems = pick!.getPickItemsCopy()
                pickedItems.resetQuantity(0) // set all items to zero quantity
                tableView.setItemsToPick(itemsToPick)
            }
            tableView.reloadData()
            */
            return true
        } else {
            invokeAlertMessage("Work Order Error", msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        }
        return false
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

}
