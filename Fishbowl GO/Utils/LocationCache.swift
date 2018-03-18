//
//  LocationCache.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/18/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class LocationCache: FBLocationLookupDelegate {
    
    
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
    
    
    private var locationsCache: Array<FbLocation> = Array<FbLocation>()
    private var locationsByTagNumber = [Int: FbLocation]()
    private var locationsById = [Int: FbLocation]()
    private var locationsByName = [String: FbLocation]()
    private var locationGroupList = [UInt: String]()
    private var groupList: [LocationGroup] = []

    func getCount() -> Int {
        return locationsCache.count
    }
    
    func getGroupCount() -> Int {
        return groupList.count
    }
    
    func getGroupLocationCount(index: Int) -> Int {
        if index < self.getGroupCount() {
            return groupList[index].locationList.count

        }
        return 0
    }
    
    func getGroupName(index: Int) -> String {
        if index < self.getGroupCount() {
            return groupList[index].name
        }
        return ""
    }
    
    func getLocationFromGroup(groupIndex:Int, locationIndex:Int) -> FbLocation? {
        if groupIndex < self.getGroupCount() {
            if locationIndex < self.getGroupLocationCount(groupIndex) {
                return groupList[groupIndex].locationList[locationIndex]
            }
        }
        return nil
    }
    
    func getLocationNameFromGroup(groupIndex:Int, locationIndex:Int) -> String {
        if groupIndex < self.getGroupCount() {
            if locationIndex < self.getGroupLocationCount(locationIndex) {
                return groupList[groupIndex].locationList[locationIndex].Name
            }
        }
        return ""
    }
    
    func getGroupLocation(groupIndex:Int, locationIndex:Int) -> FbLocation? {
        if groupIndex < self.getGroupCount() {
            if locationIndex < self.getGroupLocationCount(groupIndex) {
                return groupList[groupIndex].locationList[locationIndex]
            }
        }
        return nil
    }
    
    func setLocations(locations: [FbLocation]) {
        reset()
        locationsCache.appendContentsOf(locations)
        locationsCache.sortInPlace {
            $0.getFullName().compare($1.getFullName()) == .OrderedAscending
        }
        
        // Save locations by ID's and by Name for lookup later.
        for location in locations {
            locationsByTagNumber[location.TagNumber] = location
            locationsByName[location.getFullName()] = location
            locationsById[location.LocationID] = location
            
            // de-dupe the location groups
            locationGroupList[location.LocationGroupID] = location.LocationGroupName

        }
        
        for locationGrp in locationGroupList {
            let group = LocationGroup(groupId: locationGrp.0, groupName: locationGrp.1)
            groupList.append(group)
        }

        // Now add the locations to the groups to which they belong
        for fbLocation in locationsCache {
            for group in groupList {
                if group.addLocation(fbLocation) {
                    break
                }
            }
        }
        
        // sort Groups first...
        groupList.sortInPlace { $0.name.compare($1.name) == .OrderedAscending }
        
        // Sort Locations
        for group in groupList {
            group.locationList.sortInPlace { $0.Name.compare($1.Name) == .OrderedAscending }
        }
    }
    
    func validLocation(location: String) -> (Bool, FbLocation?) {
        // First.. check to see if location specified was the TAG Number
        if let number = Int(location) {
            if let location = locationsByTagNumber[number] {
                return (true, location)
            }
        }
        
        // Now try to look up the location by the full location name...
        if let location = locationsByName[location] {
            return (true, location)
        }
        
        return (false, nil);
    }
    
    func getLocationById(locationId: Int) -> FbLocation? {
        if let location = locationsById[locationId] {
            return location
        }
        return nil
    }
    
    func lookupLocation(locationName: String) -> FbLocation? {
        let (_, location) = validLocation(locationName)
        return location
    }
    
    func reset() {
        locationsCache.removeAll()
        locationsByTagNumber.removeAll()
        locationsByName.removeAll()
        locationsById.removeAll()
        locationGroupList.removeAll()
        groupList.removeAll()
    }
}
