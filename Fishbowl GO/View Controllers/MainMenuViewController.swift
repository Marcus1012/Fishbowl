//
//  MainMenuViewController.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/01/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import Foundation


class MainMenuViewController: UIViewController {
    
    private var buttonGrid = ButtonGrid()
    var segueFeatureMap = [String: String]()

    @IBOutlet var btnPick: BigGoButton!
    @IBOutlet var btnPack: BigGoButton!
    @IBOutlet var btnShip: BigGoButton!
    @IBOutlet var btnReceive: BigGoButton!
    @IBOutlet var btnMove: BigGoButton!
    @IBOutlet var btnCycle: BigGoButton!
    @IBOutlet var btnPart: BigGoButton!
    @IBOutlet var btnWorkOrder: BigGoButton!
    @IBOutlet var btnDelivery: BigGoButton!
    @IBOutlet var btnAddInventory: BigGoButton!
    @IBOutlet var btnScrap: BigGoButton!
    
    // Height
    @IBOutlet weak var btnHeightPick: NSLayoutConstraint!
    @IBOutlet weak var btnHeightPack: NSLayoutConstraint!
    @IBOutlet weak var btnHeightShip: NSLayoutConstraint!
    @IBOutlet weak var btnHeightReceive: NSLayoutConstraint!
    @IBOutlet weak var btnHeightMove: NSLayoutConstraint!
    @IBOutlet weak var btnHeightCycle: NSLayoutConstraint!
    @IBOutlet weak var btnHeightPart: NSLayoutConstraint!
    @IBOutlet weak var btnHeightWorkorder: NSLayoutConstraint!
    @IBOutlet weak var btnHeightDelivery: NSLayoutConstraint!
    @IBOutlet weak var btnHeightAddInventory: NSLayoutConstraint!
    @IBOutlet weak var btnHeightScrap: NSLayoutConstraint!
    
    // Width
    @IBOutlet weak var btnWidthPick: NSLayoutConstraint!
    @IBOutlet weak var btnWidthPack: NSLayoutConstraint!
    @IBOutlet weak var btnWidthShip: NSLayoutConstraint!
    @IBOutlet weak var btnWidthReceive: NSLayoutConstraint!
    @IBOutlet weak var btnWidthMove: NSLayoutConstraint!
    @IBOutlet weak var btnWidthCycle: NSLayoutConstraint!
    @IBOutlet weak var btnWidthPart: NSLayoutConstraint!
    @IBOutlet weak var btnWidthWorkorder: NSLayoutConstraint!
    @IBOutlet weak var btnWidthDelivery: NSLayoutConstraint!
    @IBOutlet weak var btnWidthAddInventory: NSLayoutConstraint!
    @IBOutlet weak var btnWidthScrap: NSLayoutConstraint!
    
    // Left
    @IBOutlet weak var btnLeftPick: NSLayoutConstraint!
    @IBOutlet weak var btnLeftPack: NSLayoutConstraint!
    @IBOutlet weak var btnLeftShip: NSLayoutConstraint!
    @IBOutlet weak var btnLeftReceive: NSLayoutConstraint!
    @IBOutlet weak var btnLeftMove: NSLayoutConstraint!
    @IBOutlet weak var btnLeftCycle: NSLayoutConstraint!
    @IBOutlet weak var btnLeftPart: NSLayoutConstraint!
    @IBOutlet weak var btnLeftWorkorder: NSLayoutConstraint!
    @IBOutlet weak var btnLeftDelivery: NSLayoutConstraint!
    @IBOutlet weak var btnLeftAddInventory: NSLayoutConstraint!
    @IBOutlet weak var btnLeftScrap: NSLayoutConstraint!
    
    // Top
    @IBOutlet weak var btnTopPick: NSLayoutConstraint!
    @IBOutlet weak var btnTopPack: NSLayoutConstraint!
    @IBOutlet weak var btnTopShip: NSLayoutConstraint!
    @IBOutlet weak var btnTopReceive: NSLayoutConstraint!
    @IBOutlet weak var btnTopMove: NSLayoutConstraint!
    @IBOutlet weak var btnTopCycle: NSLayoutConstraint!
    @IBOutlet weak var btnTopPart: NSLayoutConstraint!
    @IBOutlet weak var btnTopWorkorder: NSLayoutConstraint!
    @IBOutlet weak var btnTopDelivery: NSLayoutConstraint!
    @IBOutlet weak var btnTopAddInventory: NSLayoutConstraint!
    @IBOutlet weak var btnTopScrap: NSLayoutConstraint!
    
    
    
    @IBAction func about(sender: AnyObject) {
    }
    
    @IBAction func btnLogout(sender: AnyObject) {
        invokeConfirm("Logout", message: "What would you like to do?", okText: "Log out now", cancelText: "Cancel", okHandler: logoutHandler, cancelHandler: nil, delegate: self)
    }
    

    func logoutHandler(action:UIAlertAction) {
        sendLogoutRequest()
        g_serverVersion = ""
    }
    
    func showConfirm(title:String, message: String, okHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) {
        let confirmAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        confirmAlert.addAction(UIAlertAction(title: "Ok",     style: .Default, handler: okHandler))
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: cancelHandler))
        confirmAlert.popoverPresentationController?.sourceView = self.view
        presentViewController(confirmAlert, animated: true, completion: nil)
    }

    // MARK: - Server Requests
    private func sendLogoutRequest()
    {
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            id: g_userId,
            requestObj: FbiLogoutRequest()
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "") { (ticket, response) in
            self.LogoutResponse(ticket, response: response)
        }
    }
    
    private func LogoutResponse(ticket: FbTicket, response:FbResponse)
    {
        if response.isValid(Constants.Response.logout) {
        } else {
            // invokeAlertMessage("Logout Error", msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        }
        ViewController.resetGlobalItems()
        performSegueWithIdentifier("login_screen_segue", sender: self)
    }
    
    // MARK: Overrides
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if identifier == "segue_settings" {
            return true
        }
        
        // Fisrt, check to see if user has module access rights...
        var hasRights = false
        if let feature = segueFeatureMap[identifier] {
            hasRights = g_moduleAccess.hasAccess(g_username, group: Constants.defaultRightsGroup, feature: feature)
        }
        if !hasRights {
            invokeAlertMessage("Feature Unavailable", msgBody: "The current user does not have sufficient privileges to access this feature", delegate: self)
            return false
        }
        
        // Second, see if user has compatibility access...
        switch identifier {
            case "segue_picking",
                 "segue_packing",
                 "segue_shipping",
                 "segue_receiving",
                 "segue_move",
                 "segue_cycle",
                 "segue_workorder",
                 "segue_delivery",
                 "segue_add_inventory",
                 "segue_scrap":
                    if !g_compatibility.isFullVersion() {
                        invokeAlertMessage("Feature Unavailable", msgBody: "Please contact your Fishbowl administrator to enable this feature", delegate: self)
                        return false
                    }
                    break
            default:
                return true
        }
        return true
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition(nil, completion: {
            _ in
            
            self.relayoutButtons()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        relayoutButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFeatureMap()
        layoutHeader()
        populateButtonList()
        assert(buttonGrid.buttons.count == 11, "Button list length is incorrect")
        buttonGrid.frameTopOffset = 60
        buttonGrid.frame = self.view.frame

    }

    private func relayoutButtons() {
        var frame = self.view.frame
        let minDim = min(frame.width, frame.height)
        let maxDim = max(frame.width, frame.height)
        let isPortrait = UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation)
        if isPortrait.boolValue {
            frame = CGRect(x: 0, y: 0, width: minDim, height: maxDim)
            buttonGrid.frameTopOffset = 60
        } else {
            frame = CGRect(x: 0, y: 0, width: maxDim, height: minDim)
            buttonGrid.frameTopOffset = 30
        }
        buttonGrid.frame = frame
    }
    
    private func populateButtonList() {
        buttonGrid.addButton(btnPick, left: btnLeftPick, top: btnTopPick, width: btnWidthPick, height: btnHeightPick)
        buttonGrid.addButton(btnPack, left: btnLeftPack, top: btnTopPack, width: btnWidthPack, height: btnHeightPack)
        buttonGrid.addButton(btnShip, left: btnLeftShip, top: btnTopShip, width: btnWidthShip, height: btnHeightShip)
        buttonGrid.addButton(btnReceive, left: btnLeftReceive, top: btnTopReceive, width: btnWidthReceive, height: btnHeightReceive)
        buttonGrid.addButton(btnMove, left: btnLeftMove, top: btnTopMove, width: btnWidthMove, height: btnHeightMove)
        buttonGrid.addButton(btnAddInventory, left: btnLeftAddInventory, top: btnTopAddInventory, width: btnWidthAddInventory, height: btnHeightAddInventory)
        buttonGrid.addButton(btnScrap, left: btnLeftScrap, top: btnTopScrap, width: btnWidthScrap, height: btnHeightScrap)
        buttonGrid.addButton(btnCycle, left: btnLeftCycle, top: btnTopCycle, width: btnWidthCycle, height: btnHeightCycle)
        buttonGrid.addButton(btnPart, left: btnLeftPart, top: btnTopPart, width: btnWidthPart, height: btnHeightPart)
        buttonGrid.addButton(btnWorkOrder, left: btnLeftWorkorder, top: btnTopWorkorder, width: btnWidthWorkorder, height: btnHeightWorkorder)
        buttonGrid.addButton(btnDelivery, left: btnLeftDelivery, top: btnTopDelivery, width: btnWidthDelivery, height: btnHeightDelivery)
    }
    
    private func layoutHeader() {
        // Set the header title to a clickable image...
        let image = UIImage(named: "header_logo_black.png")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 36))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = image
        imageView.userInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(MainMenuViewController.clickOnButton))
        imageView.addGestureRecognizer(recognizer)
        navigationItem.titleView = imageView
    }
    
    @objc private func clickOnButton() {
        performSegueWithIdentifier("segue_about", sender: self)
    }
    
    private func initFeatureMap() {
        segueFeatureMap["segue_picking"] = Constants.Rights.Pick
        segueFeatureMap["segue_packing"] = Constants.Rights.Pack
        segueFeatureMap["segue_shipping"] = Constants.Rights.Ship
        segueFeatureMap["segue_receiving"] = Constants.Rights.Receive
        segueFeatureMap["segue_move"] = Constants.Rights.Move
        segueFeatureMap["segue_cycle"] = Constants.Rights.Cycle
        segueFeatureMap["segue_workorder"] = Constants.Rights.WorkOrder
        segueFeatureMap["segue_delivery"] = Constants.Rights.Delivery
        segueFeatureMap["segue_part"] = Constants.Rights.Part
        segueFeatureMap["segue_scrap"] = Constants.Rights.Scrap
        segueFeatureMap["segue_add_inventory"] = Constants.Rights.AddInventory
    }
    
}
