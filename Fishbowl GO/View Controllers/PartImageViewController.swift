//
//  PartImageViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/29/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD


class PartImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    private var errorTitle = "Image Error"
    
    var partNumber: String = ""
    var image: UIImage?
    var delegate: PartDelegate?

    @IBOutlet var partImageView: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    
    // MARK: - Actions
    @IBAction func takePicture(sender: AnyObject) {
        let camera = UIImagePickerController()
        camera.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            camera.sourceType = .Camera
        } else {
            camera.sourceType = .PhotoLibrary
        }
        presentViewController(camera, animated: true) {
            //print("camera view controller completed")
        }
        
    }

    @IBAction func saveImage(sender: AnyObject) {
        if let image = partImageView.image {
            saveButton.enabled = false
            SVProgressHUD.showWithStatus("Processing image...")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                // Do heavy work here
                self.saveImageFromView(image, completion: { (didSaveImage) in
                    dispatch_async(dispatch_get_main_queue()) {
                        if let del = self.delegate {
                            if didSaveImage {
                                del.partImageSaved(image)
                            }
                        }
                        self.saveButton.enabled = true
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        // set the image vew back to the original
        partImageView.image = image
        saveButton.enabled = false
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - Support Functions
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        partImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: {})
        saveButton.enabled = true
    }
    
    private func saveImageFromView(img: UIImage, completion: (Bool) -> Void) {
        
        let sizedImage = img.scaleToMaxDimension(g_maxImageDimension)
        let strBase64 = sizedImage.base64Endcode()
        if strBase64.characters.count > 0 {
            let updateAssociations = g_pluginSettings.getSetting(Constants.Options.partUpdateProductImage)
            let fbMessageRequest = FbMessageRequest(
                key: g_apiKey,
                id: g_userId,
                requestObj: FbiSaveImageRequest(type: "Part", number: partNumber,  image: strBase64, updateAssociations: updateAssociations)
            )
            connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "Image Saved", status: "Saving image...") { (ticket, response) in
                completion(self.ValidateSaveImageResponse(ticket, response: response))
            }
        } else {
            invokeAlertMessage(errorTitle, msgBody: "Unknow or invalid image format", delegate: self)
        }
    }
    
    private func ValidateSaveImageResponse(ticket: FbTicket, response: FbResponse) -> Bool
    {
        var status = 1000
        var statusMessage = ""
        
        if response.isValid(Constants.Response.saveImage) {
            status = response.getJson()["statusCode"].intValue
            if status != 1000 {
                statusMessage = response.getJson()["statusMessage"].stringValue
            }
        } else {
            status = response.getStatus()
        }
        
        if status != 1000 {
            if statusMessage.characters.count == 0 {
                statusMessage = getFBStatusMessage(status)
            }
            dispatch_async(dispatch_get_main_queue()) {
                invokeAlertMessage(self.errorTitle, msgBody: getFBStatusMessage(status), delegate: self)
                self.navigationController?.popViewControllerAnimated(true)
            }
            return false
        }
        return true
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.enabled = false
        partImageView.image = image
        cameraButton.enabled = g_moduleAccess.hasAccess(g_username, group: Constants.defaultRightsGroup, feature: Constants.Rights.AllowSavePicture)
    }
}























