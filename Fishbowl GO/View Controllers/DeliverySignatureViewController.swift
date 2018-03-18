//
//  DeliverySignatureViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/23/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftSignatureView


class DeliverySignatureViewController: UIViewController, SwiftSignatureViewDelegate {

    private let errorTitle = "Signature Error"
    
    var orderNumber: String = ""
    var delegate: SignatureDelegate?

    
    @IBOutlet var customer: UITextField!
    @IBOutlet var signatureView: SwiftSignatureView!
    @IBOutlet var signHereLabel: UILabel!
    
    
    // MARK: - Actions
    @IBAction func clearSignature(sender: AnyObject) {
        signatureView.clear()
        signHereLabel.hidden = false
    }
    
    @IBAction func saveSignature(sender: AnyObject) {
        if let image:UIImage = signatureView.signature {
            let imageData:NSData = UIImageJPEGRepresentation(image, 90)!
            let strBase64 = imageData.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
            sendDeliveryRequest(strBase64, contact: customer.stringValue)
        } else {
            invokeAlertMessage(errorTitle, msgBody: "Unable to acquire signature image", delegate: self)
        }
    }

    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        signatureView.delegate = self
        
        // We got the order number from parent view controller...
        // Now go get the Customer from that order number and put it in the text field
        sendShipmentRequest()
    }
    
    // MARK: - Server Requests
    private func sendDeliveryRequest(imageData:String, contact:String) {
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            id: g_userId,
            requestObj: FbiShipOrderRequest(number: orderNumber, image: imageData, contact: contact)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "Saved") { (ticket, response) in
            self.DeliveryResponse(ticket, response: response)
        }
    }
    
    private func DeliveryResponse(ticket: FbTicket, response: FbResponse)
    {
        if response.isValid(Constants.Response.shipOrder) {
            notifyDelegateOfAcceptance()
            navigationController?.popViewControllerAnimated(true)
        } else {
            invokeAlertMessage(errorTitle, msgBody: "Error processing delivery", delegate: self)
        }
    }
    
    private func sendShipmentRequest()
    {
        let fbMessageRequest = FbMessageRequest(
            key: g_apiKey,
            id: g_userId,
            requestObj: FbiShipmentRequest(shipmentNum: orderNumber)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "") { (ticket, response) in
            self.ShipmentResponse(ticket, response: response)
        }
    }
    
    private func ShipmentResponse(ticket: FbTicket, response: FbResponse)
    {
        if response.isValid(Constants.Response.shipment) {
            
            let data = String(response.getJson()["Shipping"])
            if let shipment = Mapper<FbShipment>().map(data) {
                customer.text = shipment.Contact
            }
        } else {
            invokeAlertMessage(errorTitle, msgBody: "Error requesting shipment", delegate: self)
        }
    }
    
    // MARK: - Helper Functions
    private func notifyDelegateOfAcceptance() {
        if let del = delegate {
            del.signatureAccepted(orderNumber)
        }
    }

    //MARK: - Signature Delegates
    
    func swiftSignatureViewDidTapInside(view: SwiftSignatureView) {
        signHereLabel.hidden = true
    }
    
    func swiftSignatureViewDidPanInside(view: SwiftSignatureView) {
        signHereLabel.hidden = true
    }
    
}
