//
//  LocationTableViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/13/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit

class LocationGroup {
    var id : UInt = 0
    var name : String = ""
    private var locationList: [FbLocation] = []
    
    
    init(groupId: UInt, groupName: String) {
        id = groupId
        name = groupName
    }
    
    // Only add locations that belong to this group
    func addLocation(location: FbLocation) -> Bool {
        if location.LocationGroupID == id {
            locationList.append(location)
            return true
        }
        return false
    }
}

class LocationTableViewController: UITableViewController
{
    var delegate:FBLocationDelegate? = nil
    //var locationGroupList = [UInt: String]()
    //var groupList: [LocationGroup] = []
    var selectedLocation: FbLocation?
    var selectedIndexPath: NSIndexPath = NSIndexPath(forRow: -1, inSection: -1)
    
    private var selectedLocationId: Int = 0
    private var sectionCount:Int = 0
    
    // MARK: - Actions
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnDone(sender: AnyObject) {
        if let loc = selectedLocation {
            do {
                try dispatchLocation(loc)
            } catch _ {
                print("ERROR WITH DELEGATE")
            }
        }
        selectedLocationId = 0
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Interfaces
    func setInitialSelection(locationId: Int) {
        selectedLocationId = locationId
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if selectedIndexPath.row != -1 && selectedIndexPath.section != -1 {
            tableView.selectRowAtIndexPath(selectedIndexPath, animated: animated, scrollPosition: UITableViewScrollPosition.None)
            tableView.scrollToRowAtIndexPath(selectedIndexPath, atScrollPosition: .None, animated: animated)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        sectionCount = locationCache.getGroupCount()
        return sectionCount
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return locationCache.getGroupName(section)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationCache.getGroupLocationCount(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("location_cell") as! LocationCell
        if let loc = locationCache.getLocationFromGroup(indexPath.section, locationIndex: indexPath.row) {
            cell.location.text = loc.Name
            cell.tagNumber.text = "(\(loc.TagNumber))"
            if loc.LocationID == selectedLocationId {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                selectedIndexPath = indexPath
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedLocation = locationCache.getGroupLocation(indexPath.section, locationIndex: indexPath.row)
        selectedLocationId = selectedLocation!.LocationID
        
        if indexPath.row != selectedIndexPath.row || indexPath.section != selectedIndexPath.section {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            
            if selectedIndexPath.row >= 0 && selectedIndexPath.section >= 0 {
                let previousCell = tableView.cellForRowAtIndexPath(selectedIndexPath)
                previousCell?.accessoryType = UITableViewCellAccessoryType.None
            }
            selectedIndexPath = indexPath
            
            if moduleSettings.loadSetting(Constants.Module.General, setting: "AutoSelect", defaultValue: true) as! Bool {
                btnDone(self)
            }
            
        }
        
    }
    
    enum MyError: ErrorType {
        case NoDelegateError
    }
    
    // Send location back to the delegate
    private func dispatchLocation(location: FbLocation) throws
    {
        guard self.delegate != nil else { throw MyError.NoDelegateError }
        self.delegate?.didSelectLocation(location)
    }
}
