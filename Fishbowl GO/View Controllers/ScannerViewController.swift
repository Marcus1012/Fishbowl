//
//  ScannerViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/31/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
//

import UIKit
import AVFoundation


class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate
{
    var delegate:FBScannerDelegate? = nil
    var theBarcode: String = ""
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var audioPath: String = ""
    var player: AVAudioPlayer = AVAudioPlayer()
    var deviceCount = 0
    
    private var errorTitle = "Scan Error"
    private var captureCount: Int = 0
    private var maxCaptures: Int = 0
    
    @IBOutlet weak var captureCountButtonItem: UIBarButtonItem!
    
    
    
    // MARK: - Button Actions
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let devices = AVCaptureDevice.devices()
        deviceCount = devices.count
        guard deviceCount > 0 else { return }
        
        view.backgroundColor = UIColor.blackColor()
        captureSession = AVCaptureSession()
        
        audioPath = NSBundle.mainBundle().pathForResource("DigitalBeep", ofType: "mp3")!

        let videoCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeAztecCode]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        previewLayer.frame = view.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(previewLayer);
        
        captureSession.startRunning();
        
    }

    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        guard deviceCount > 0 else {
            invokeAlertMessage(errorTitle, msgBody: "No scanning device found", delegate: self, handler: { (UIAlertAction) in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            return
        }
        captureCount = 0
        if (captureSession?.running == false) {
            captureSession.startRunning();
        }
        updateCaptureCountButton()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        maxCaptures = 1 // Reset to one code
        if (captureSession?.running == true) {
            captureSession.stopRunning();
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    // MARK: - Main Methods
    func setMaxCaptures(count: Int) {
        maxCaptures = (count > 0) ? count: 1
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        ac.popoverPresentationController?.sourceView = self.view
        presentViewController(ac, animated: true, completion: nil)
        captureSession = nil
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            do {
                try player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioPath))
                player.play()
            } catch {
                assert(false, "couldn't find the audio file")
            }
            dispatchCode(readableObject.stringValue)
            captureCount += 1
            updateCaptureCountButton()
        }

        if captureCount >= maxCaptures {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    // Send barcode back to the delegate
    private func dispatchCode(code: String)
    {
        if delegate != nil {
            delegate?.receivedScanCode(code)
        }
    }
    
    private func updateCaptureCountButton() {
        captureCountButtonItem.title = "\(captureCount + 1) of \(maxCaptures)"
    }

}
