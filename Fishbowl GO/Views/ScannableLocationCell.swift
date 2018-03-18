//
//  ScannableLocationCell.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 1/9/17.
//  Copyright © 2017 RPM Consulting. All rights reserved.
//

import UIKit

class ScannableLocationCell: UITableViewCell, UITextFieldDelegate, FBLocationDelegate, FBScannerDelegate {

    @IBOutlet var btnLock: LockButton!
    @IBOutlet var btnScan: UIButton!
    @IBOutlet weak var btnLocationChooser: UIButton!
    @IBOutlet var location: LocationTextField!

    private var context: Int = 0 // a configurable cell-context
    private var delegate: SetLocationDelegate?
    
    
    @IBAction func toggleLock(sender: LockButton) {
        location.setEnable(sender.isLocked)
        btnScan.enabled = sender.isLocked
        btnLocationChooser.enabled = sender.isLocked
        
        if let fbLoc = location.getCurrentLocation() {
            fbLoc.setLock(!sender.isLocked)
        }

    }
    
    @IBAction func btnScan(sender: UIButton) {
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
    
    @IBAction func btnLocationChooser(sender: AnyObject) {
        if let win = window {
            if let topController = win.visibleViewController() {
                let storyboard = UIStoryboard(name: "LocationChooser", bundle: nil)
                let navController = storyboard.instantiateInitialViewController() as! UINavigationController
                let destViewController = navController.childViewControllers[0] as! LocationTableViewController
                destViewController.delegate = self
                topController.presentViewController(navController, animated: true, completion: nil)
            }
        }
    }
    
    override func didMoveToSuperview() {
        location.delegate = self
    }

    
    func getLocation() -> String {
        return location.stringValue
    }
    
    func setValue(value: String) {
        location.text = value
    }
    
    func isLocked() -> Bool {
        return btnLock.isLocked
    }

    override func reset() {
        if !btnLock.isLocked { // only reset if not locked
            location.reset()
        }
    }
    
    func setDelegate(context: Int, delegate: SetLocationDelegate?) {
        self.context = context
        self.delegate = delegate
    }
    
    func setLocationCache(cache: LocationCache) {
        location.lookupDelegate = cache
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if let del = delegate {
            var fbLoc: FbLocation? = nil
            if textField is LocationTextField {
                let field = textField as! LocationTextField
                fbLoc = field.getCurrentLocation()
            }
            del.setLocation(context, fbLocation: fbLoc)
        }
    }
    
    func setLock(locked: Bool) {
        location.setEnable(!locked)
        btnScan.enabled = !locked
        btnLocationChooser.enabled = !locked
        if locked {
            btnLock.lock()
        } else {
            btnLock.unlock()
        }
    }
    
    // MARK: - Delegate Methods
    func didSelectLocation(location: FbLocation) { // called from location chooser
        self.location.didSelectLocation(location)
        textFieldDidEndEditing(self.location)
    }

    func receivedScanCode(code: String) {  // called from scanner
        self.location.receivedScanCode(code)
        textFieldDidEndEditing(self.location)
    }
    
}
