//
//  PickOrderTableView.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 11/18/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit

class PickOrderTableView: UITableView {

    private var itemsToPick = FbPickItems() // Model for table view displaying items to pick

    func setItemsToPick(pickItems: FbPickItems) {
        itemsToPick = pickItems
    }
    
    func getPickItem(index: Int) -> FbPickItem? {
        return itemsToPick.getPickItem(index)
    }
    
    /*
        Actually pick the item
        Returns the number of items that were actually picked.
    */
    func doPickItem(itemToPick: FbPickItem, quantity: Int) -> Int {
        var decrimentQuantity: Int = 0
        let partNumber = itemToPick.Part.Num
        
        let (index, pickItem) = itemsToPick.lookupPickItem(partNumber, location: itemToPick.getLocation())
        if let item = pickItem {
            decrimentQuantity = item.subtractQuantity(quantity)
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if item.Quantity <= 0 {
                itemsToPick.removeAtIndex(index)
                deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            } else {
                reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
        return decrimentQuantity
    }
    
    func allItemsPicked() -> Bool {
        return itemsToPick.allItemsPicked()
    }
    
    func reset() {
        itemsToPick.removeAll()
    }
    
    override func numberOfRowsInSection(section: Int) -> Int {
        return itemsToPick.PickItem.count
    }
    
    override func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
        let cell = self.dequeueReusableCellWithIdentifier("CustomPickCell", forIndexPath: indexPath) as! PickItemCell
        
        cell.status.text = Constants.Status[0] // Unknown
        let pickItem = itemsToPick.PickItem[indexPath.row]
        if let status = Constants.Status[pickItem.Status] {
            cell.status.text = status
        }
        cell.part.text = pickItem.Part.Num+"-"+(pickItem.Part.Description)
        cell.partName = (pickItem.Part.Num)
        cell.location.text = pickItem.Location.getFullName("N/A")
        cell.quantity.text = "\(pickItem.Quantity) \(pickItem.UOM.Code)"
        return cell
    }
    
}
