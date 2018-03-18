//
//  ImageFromText.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/21/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
// taken from http://stackoverflow.com/questions/25635125/uibarbuttonitem-title-offset
//

import Foundation
import UIKit

func sizeOfAttributeString(str: NSAttributedString, maxWidth: CGFloat) -> CGSize {
    let size = str.boundingRectWithSize(CGSizeMake(maxWidth, 1000), options:(NSStringDrawingOptions.UsesLineFragmentOrigin), context:nil).size
    return size
}

func imageFromText(text:NSString, font:UIFont, maxWidth:CGFloat, color:UIColor) -> UIImage
{
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
    paragraph.alignment = .Center // potentially this can be an input param too, but i guess in most use cases we want center align
    
    let attributedString = NSAttributedString(string: text as String, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName:paragraph])
    
    let size = sizeOfAttributeString(attributedString, maxWidth: maxWidth)
    UIGraphicsBeginImageContextWithOptions(size, false , 0.0)
    attributedString.drawInRect(CGRectMake(0, 0, size.width, size.height))
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
}
