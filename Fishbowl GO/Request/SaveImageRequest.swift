//
//  SaveImageRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation


class FbiSaveImageRequest : FbiRequest {
    var SaveImageRq : saveImageRequestCore
    
    init(type: String, number: String, image: String, updateAssociations: Bool=true) {
        SaveImageRq = saveImageRequestCore(type: type, number: number, image: image, updateAssociations: updateAssociations)
    }
    
}

class saveImageRequestCore {
    var Type: String = "Part"
    var Number: String = ""
    var UpdateAssociations: Bool = true
    var Image: String = ""
    
    init(type: String, number: String, image: String, updateAssociations: Bool) {
        Type = type
        Number = number
        Image = image
        UpdateAssociations = updateAssociations
    }
}
