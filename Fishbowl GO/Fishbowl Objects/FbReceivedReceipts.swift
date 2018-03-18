//
//  FbReceivedReceipts.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import ObjectMapper


class FbReceivedReceipts: Mappable {
    var ReceivedReceipt = [FbReceivedReceipt]()

    init() {}
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FbReceivedReceipts()
        
        for item in ReceivedReceipt {
            let newItem = (item.copyWithZone(zone) as! FbReceivedReceipt)
            copy.ReceivedReceipt.append(newItem)
        }
        
        return copy
    }
    
    // Mappable
    func mapping(map: Map) {
        ReceivedReceipt <- map["ReceivedReceipt"]
        if ReceivedReceipt.count <= 0 {
            var receivedReceipt: FbReceivedReceipt?
            receivedReceipt <- map["ReceivedReceipt"]
            ReceivedReceipt.append(receivedReceipt!)
        }
    }
    
    func getCount() -> Int {
        return ReceivedReceipt.count
    }
    
    func getTrackingAtIndex(index: Int) -> FbTracking? {
        if index >= 0 && index < ReceivedReceipt.count {
            return ReceivedReceipt[index].getTracking()
        }
        return nil
    }
    
    func removeAll() {
        ReceivedReceipt.removeAll()
    }
    
    func add(receipt: FbReceivedReceipt) {
        ReceivedReceipt.append(receipt)
    }
}
