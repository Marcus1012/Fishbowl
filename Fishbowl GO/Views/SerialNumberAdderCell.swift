//
//  SerialNumberAdderCell.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 1/10/17.
//  Copyright © 2017 RPM Consulting. All rights reserved.
//

import UIKit

class SerialNumberAdderCell: UITableViewCell, FBScannerDelegate {
    private var defaultStatus = "No serial numbers required"
    var delegate: AddSerialNumberDelegate?
    
    @IBOutlet var serialNumber: ScannableTextField!
    @IBOutlet var infoLabel: UILabel!
    
    @IBAction func btnAdd(sender: AnyObject) {
        guard serialNumber.stringValue.characters.count > 0 else { return }
        if let del = delegate {
            let (num, total) = del.addSerialNumber(serialNumber.stringValue)
            updateStatusLabel(num, total: total)
            serialNumber.becomeFirstResponder()
            serialNumber.selectedTextRange = serialNumber.textRangeFromPosition(serialNumber.beginningOfDocument, toPosition: serialNumber.endOfDocument)
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
        updateStatusLabel(0, total: 0)
    }
    
    func receivedScanCode(code: String) {
        serialNumber.receivedScanCode(code)
        btnAdd(self)
    }
    
    func setDelegate(addSerialDelegate: AddSerialNumberDelegate) {
        delegate = addSerialDelegate
    }
    
    func setSerailDelegate(delegate: UITextFieldDelegate) {
        serialNumber.delegate = delegate
    }
    
    // MARK: - Helper Functions
    func updateStatusLabel(num: Int, total: Int) {
        if num == 0 && total == 0 {
            infoLabel.text = defaultStatus
        } else {
            self.infoLabel.text = "Added \(num) of \(total) serial number, \(total-num) remaining"
            self.setNeedsDisplay()
        }
    }
}
