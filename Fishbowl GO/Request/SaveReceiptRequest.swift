//
//  SaveReceiptRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiSaveReceiptRequest : FbiRequest {
    var SaveReceiptRq : saveReceiptRequestCore
    
    init(receipt: FbReceipt) {
        SaveReceiptRq = saveReceiptRequestCore(receipt: receipt)
    }
    
}

class saveReceiptRequestCore {
    var Receipt : FbReceipt
    
    init(receipt: FbReceipt) {
        Receipt = receipt
    }
}
