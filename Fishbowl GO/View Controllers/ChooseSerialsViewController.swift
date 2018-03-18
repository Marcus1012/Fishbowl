//
//  ChooseSerialsViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 10/10/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit


protocol SerialNumberDelegate {
    func saveSerials(list: [String])
}

class ChooseSerialsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FBScannerDelegate {

    var maxSerials: Int = 0
    var serials = [String]()
    var selectedSerial:String = ""
    var delegate: SerialNumberDelegate?
    
    @IBOutlet var serialNumber: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var infoLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func save(sender: AnyObject) {
        // Save serial numbers to parent
        if let del = delegate {
            del.saveSerials(serials)
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    func addSerialNumberFromTextField(textField: UITextField) {
        let serial = textField.stringValue
        if serial.characters.count > 0 {
            if serials.indexOf(serial) != nil {
                invokeAlertMessage("Serial Number Error", msgBody: "Duplicate serial number found.", delegate: self)
            } else {
                if serials.count < maxSerials {
                    serials.append(serial)
                    textField.becomeFirstResponder()
                    textField.selectedTextRange = textField.textRangeFromPosition(textField.beginningOfDocument, toPosition: textField.endOfDocument)
                    updateInfoLabel()
                    tableView.reloadData()
                } else {
                    invokeAlertMessage("Serial Number Error", msgBody: "Maximum number of serial numbers reached.", delegate: self)
                }
            }
        } else {
            invokeAlertMessage("Serial Number Error", msgBody: "Invalid serial number specified", delegate: self)
        }
    }
    
    @IBAction func addSerialNumber(sender: AnyObject) {
        addSerialNumberFromTextField(serialNumber)

    }
    
    func deleteSerialNumber(indexPath: NSIndexPath) {
        var index = indexPath.row
        serials.removeAtIndex(index)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        
        selectedSerial = ""
        serialNumber.text = ""
        // adjust index for new selection if this was the last item in the list
        if serials.count > 0 {
            if index >= serials.count {
                index = serials.count - 1
            }
            tableView.selectRowAtSectionRow(index, inSection: 0, animated: true
                , scrollPosition: UITableViewScrollPosition.None)
            selectedSerial = serials[index]
            deleteButton.enabled = true
        } else {
            // serail list is empty -- put focus in text field
            serialNumber.becomeFirstResponder()
            deleteButton.enabled = false
        }
        updateInfoLabel()
    }
    
    
    @IBAction func btnDelete(sender: AnyObject) {
        if selectedSerial.characters.count > 0 {
            let index = serials.indexOf(selectedSerial)
            let indexPath = NSIndexPath(forItem: index!, inSection: 0)
            deleteSerialNumber(indexPath)
        }
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        serialNumber.delegate = self
        updateInfoLabel()
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "segueScan" {
            // only fire-up scanner if we need to scan more serial numbers
            return (maxSerials - serials.count > 0)
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else { return }

        if segueId == "segueScan" {
            let navController = segue.destinationViewController as! UINavigationController
            let destViewController = navController.childViewControllers[0] as! ScannerViewController
            destViewController.delegate = self
            destViewController.setMaxCaptures(maxSerials - serials.count)
        }
        
    }

    
    // MARK: - Text Field Delegate Methods
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder() // close the keyboard on <return>
        if textField == serialNumber {
            addSerialNumberFromTextField(textField)
        }
        return true
    }
    
    // MARK: - Scanner Delegate Methods
    func receivedScanCode(code: String) {
        serialNumber.text = code
    }
    
    // MARK: - Table View Delegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serials.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("serialNumberCell", forIndexPath: indexPath)

        cell.textLabel?.text = serials[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        deleteButton.enabled = true
        if let currentCell = tableView.cellForRowAtIndexPath(indexPath) {
            selectedSerial = (currentCell.textLabel?.text)!
            serialNumber.text = selectedSerial
        }
        serialNumber.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Normal, title: "Remove") { (action, indexPath) in
            self.selectedSerial = self.serials[indexPath.row]
            if self.selectedSerial.characters.count > 0 {
                self.deleteSerialNumber(indexPath)
            }
        }
        return [delete]
        
    }

    // MARK: - Support Functions
    func updateInfoLabel() {
        // Do any additional setup after loading the view.
        let remaining = maxSerials - serials.count
        infoLabel.text = "Added \(serials.count) of \(maxSerials) serial numbers, \(remaining) remaining"
    }
    
    
}
