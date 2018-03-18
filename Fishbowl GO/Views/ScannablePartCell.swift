//
//  ScannablePartCell.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 1/9/17.
//  Copyright © 2017 RPM Consulting. All rights reserved.
//

import UIKit

class ScannablePartCell: UITableViewCell, UITextFieldDelegate, FBScannerDelegate {

    @IBOutlet var btnLock: LockButton!
    @IBOutlet var btnScan: UIButton!
    @IBOutlet var part: ScannableTextField!
    
    private var delegate: PartCellDelegate?
    
    @IBAction func toggleLock(sender: LockButton) {
        part.setEnable(sender.isLocked)
        btnScan.enabled = sender.isLocked
        if let del = delegate {
            del.togglePartLock(!sender.isLocked)
        }
    }
   
    
    @IBAction func btnScan(sender: AnyObject) {
        if let win = window {
            if let topController = win.visibleViewController() {
                let storyboard = UIStoryboard(name: "Scanner", bundle: nil)
                let navController = storyboard.instantiateInitialViewController() as! UINavigationController
                let destViewController = navController.childViewControllers[0] as! ScannerViewController
                destViewController.delegate = self
                topController.presentViewController(navController, animated: true, completion: nil)
            }
        }
    }
    
    override func didMoveToSuperview() {
        part.delegate = self
    }
    
    func setDelegate(delegate: PartCellDelegate?) {
        self.delegate = delegate
    }
    
    func isLocked() -> Bool {
        return btnLock.isLocked
    }

    func setValue(value: String) {
        part.text = value
    }
    
    override func reset() {
        super.reset()
        if !btnLock.isLocked { // only reset if not locked
            part.reset()
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        part.endEditing(true) // close keyboard
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder() // close keyboard on return
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let del = delegate {
            del.setPart(textField.stringValue)
        }
    }
    
    func setAsFirstResponder() {
        becomeFirstResponder()
        part.becomeFirstResponder()
    }

    func setLock(locked: Bool) {
        part.setEnable(!locked)
        btnScan.enabled = !locked
        if locked {
            btnLock.lock()
        } else {
            btnLock.unlock()
        }
    }
    
    // MARK: - Delegate Methods
    func receivedScanCode(code: String) {  // called from scanner
        self.part.receivedScanCode(code)
        textFieldDidEndEditing(part)
    }
}
