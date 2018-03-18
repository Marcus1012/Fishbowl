//
//  Protocols.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/31/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation

protocol FBResponseDelegate {
    func receivedServerStatus(status:NSStreamStatus)
    func receivedServerError(error:NSError)
}


protocol FBScannerDelegate {
    func receivedScanCode(code: String)
}

protocol FBLocationDelegate {
    func didSelectLocation(location: FbLocation)
}

// Input is a string that represents the location
// or a location TAG... returns nil if not found
// or returns the FbLocation object if found.
protocol FBLocationLookupDelegate {
    func lookupLocation(location: String) -> FbLocation?
}

protocol AddSerialNumberDelegate {
    func addSerialNumber(serialNumber: String) -> (num:Int, total:Int)
}

// id is caller-supplied
protocol SetLocationDelegate {
    func setLocation(context: Int, fbLocation: FbLocation?)
}

protocol PartCellDelegate {
    func setPart(partNumber: String)
    func togglePartLock(isLocked: Bool)
}

protocol SetQuantityDelegate {
    func setQuantity(quantity: Int)
}
