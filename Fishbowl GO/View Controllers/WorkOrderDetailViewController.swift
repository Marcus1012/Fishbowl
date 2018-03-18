//
//  WorkOrderDetailViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 11/21/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import ObjectMapper


protocol FBWorkOrderDelegate {
    func getWorkOrder() -> FbWorkOrder?
    func workOrderSaved(orderNumber: String)
}

/*
protocol PickOrderDelegate {
    func savePickItem(pickItem: FbPickItem)
}
*/

class WorkOrderDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FbWorkOrderSavedDelegate {

    private let errorTitle = "Work Order Error"
    private var WorkOrder: FbWorkOrder?
    private var ConsumeItems = FbConsumeItems()
    private var wasSaved = false

    var delegate: FBWorkOrderDelegate?
    
    
    @IBOutlet var tableView: UITableView!
    
    
    // MARK: - Actions
    @IBAction func btnFinish(sender: AnyObject) {
        
        guard let WorkOrder = self.WorkOrder else { return }
        setNavigationBackItem(WorkOrder.Num)
        let segueIdentifier = getSegueIdentifier(WorkOrder)
        switch segueIdentifier {
            
        case "workOrderTracking":
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(segueIdentifier) as! WorkOrderFinishTrackingTableViewController
            vc.delegate = self
            vc.setWorkOrder(WorkOrder)
            self.navigationController?.pushViewController(vc, animated: true)
            break
            
        case "workOrderSerial":
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(segueIdentifier) as! WorkOrderFinishSerialTableViewController
            vc.setWorkOrder(WorkOrder)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            break
            
        default: // "workOrderStandard"
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(segueIdentifier) as! WorkOrderFinishTableViewController
            vc.setWorkOrder(WorkOrder)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            break
            
        }
    }
    
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        getWorkOrderRequest()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if wasSaved {
            if let del = delegate {
                if let wo = WorkOrder {
                    del.workOrderSaved(wo.Num)
                }
            }
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    // MARK: - Table View Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConsumeItems.getCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkOrderDetailCell", forIndexPath: indexPath) as! WorkOrderDetailCell
        
        guard let consumeItem = ConsumeItems.getItemAtIndex(indexPath.row) else { return cell }
        cell.part.text = consumeItem.Part.Num
        cell.desc.text = consumeItem.Part.Description
        let qty = consumeItem.Quantity.cleanValue
        cell.quantity.text = "\(qty) \(consumeItem.UOM.Code)"
        return cell
    }
    
    // MARK: - Delegate Requests
    func workOrderSaved(workOrder: FbWorkOrder?) {
        if workOrder != nil {
            wasSaved = true
        }
    }
    
    private func getWorkOrderRequest() {
        if let del = delegate {
            WorkOrder = del.getWorkOrder()
            extractConsumeItems(WorkOrder, consumeItems: ConsumeItems)
        }
    }

    // Mark: - Helper Functions
    private func extractConsumeItems(workOrder: FbWorkOrder?, consumeItems: FbConsumeItems) {
        guard let wo = workOrder else { return }
        wo.extractConsumeItems(consumeItems)
    }
    
    private func getSegueIdentifier(WorkOrder: FbWorkOrder) -> String {
        var vcIdentifier = "workOrderStandard"
        guard let item = WorkOrder.getFinishedGoodItem() else { return vcIdentifier }
        let part = item.Part
        //validPart = part
        
        if part.hasSerialTracking() {
            vcIdentifier = "workOrderSerial"
        } else  if part.hasTracking() {
            vcIdentifier = "workOrderTracking"
        }
        return vcIdentifier
    }
}


























