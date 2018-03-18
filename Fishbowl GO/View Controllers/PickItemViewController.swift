//
//  PickItemViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/20/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import ObjectMapper
//import DZNEmptyDataSet

class PickItemViewController: UIViewController, UITextFieldDelegate {

    var locked: Bool = false
    var partNumber: String!
    var pickItem: FbPickItem!
    
    @IBOutlet var partName: UILabel!
    @IBOutlet var fromLocation: UITextField!
    @IBOutlet var toLocation: UITextField!
    @IBOutlet var quantity: UITextField!
    
    // MARK: - Actions
   
    private func setLocked(field: UITextField, tag: Int, locked: Bool) {
        var found = false
        let imageName = locked ? "locked-20.png" : "unlocked-20.png"
        for subView in field.subviews {
            if subView.tag == tag {
                let imageView = subView as! UIImageView
                imageView.image = UIImage(named: imageName)
                found = true
                break
            }
        }
        if !found {
            let imageView = UIImageView()
            let image = UIImage(named: imageName)
            imageView.image = image
            imageView.frame = CGRect(x: 5, y: 5, width: 20, height: 20)
            imageView.tag = tag
            field.addSubview(imageView)
            
            let leftView = UIView.init(frame: CGRectMake(5, 0, 25, 20))
            field.leftView = leftView
            field.leftViewMode = UITextFieldViewMode.Always
        }

    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        
        setLocked(fromLocation, tag: 123, locked: locked)
        setLocked(toLocation, tag: 123, locked: locked)

        self.fromLocation.delegate = self
        self.toLocation.delegate = self
        self.quantity.delegate = self
        quantity.addDismissButton()
        sendGetPartRequest()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder() // close the keyboard on <return>
        return true
    }
    
    // MARK: - Server Requests
    func sendGetPartRequest()
    {
        // Grab what we can from self.pickItem
        fromLocation.text = pickItem.Location.getFullName()
        let destLocation = pickItem.DestinationTag.Tag.Location
        toLocation.text = destLocation.getFullName()
        quantity.text = "\(pickItem.Quantity)"
        
        
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            requestObj: FbiPartGetRequest(number: self.partNumber, getImage: false)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest) { (ticket, response) in
            self.GetPartResponse(ticket, response: response)
        }
    }
    
    // MARK: - Response Handlers
    func GetPartResponse(ticket: FbTicket, response: FbResponse)
    {
        if response.isValid(Constants.Response.partGet) {
            let data = String(response.getJson()["Part"])
            if let part = Mapper<FbPart>().map(data) {
                partName.text = part.getFullName()
            }
        } else {
            invokeAlertMessage("Pick Error", msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        }
    }
    
}
