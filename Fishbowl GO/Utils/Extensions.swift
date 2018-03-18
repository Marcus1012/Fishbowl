//
//  Extensions.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import ObjectMapper


extension NSDate
{
    convenience init(dateString: String, format: String="yyyy-MM-dd") {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = format
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)
        self.init(timeInterval:0, sinceDate:d!)
    }
    
    func getFormattedDate(format: String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        let dateString = formatter.stringFromDate(self)
        return dateString
    }
}


extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

extension UILabel {
    func reset() {
        if enabled {
            text = ""
        }
    }
}

extension UITableViewCell {
    func reset() {
        textLabel?.reset()
    }
}

extension UITextField {
    var stringValue : String { return text!.trim()        ?? "" }
    var integerValue: Int    { return Int(stringValue)    ?? 0  }
    var doubleValue : Double { return Double(stringValue) ?? 0  }
    var floatValue  : Float  { return Float(stringValue)  ?? 0  }
    func reset() {
        if enabled {
            text = ""
        }
    }
    
    func addDismissButton(title: String = "Done") {
        let dismissToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        dismissToolbar.barStyle = UIBarStyle.Default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Done, target: self, action: #selector(dismissButtonAction))
        
        dismissToolbar.items = [flexSpace, done]
        dismissToolbar.sizeToFit()
        self.inputAccessoryView = dismissToolbar
    }
    
    @objc private func dismissButtonAction() {
        self.resignFirstResponder()
    }

}

extension UILabel {
    var stringValue : String { return text!.trim()        ?? "" }
}

extension UIImage {
    func base64Endcode() -> String {
        var strBase64 = ""
        if let imageData:NSData = UIImageJPEGRepresentation(self, 60) {
            strBase64 = imageData.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
        }
        return strBase64
            
    }
    
    func scaleToMaxDimension(maxDimension: CGFloat) -> UIImage {
        var returnImage = UIImage()
        
        let longDimension = max(self.size.width, self.size.height)
        if longDimension > maxDimension {
            let ratio: CGFloat = maxDimension / longDimension
            let size = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(ratio, ratio))
            let hasAlpha = false
            let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
            self.drawInRect(CGRect(origin: CGPointZero, size: size))
            returnImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        return returnImage
    }
}

extension UIView {
    func lookForSuperviewOfType<T: UIView>(type: T.Type) -> T? {
        guard let view = self.superview as? T else {
            return self.superview?.lookForSuperviewOfType(type)
        }
        return view
    }
}


extension UIColor {
    // Usage: var color = UIColor(red: 0xFF, green: 0xFF, blue: 0xFF)
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    // Usage: var color2 = UIColor(netHex:0xFFFFFF)
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    ///Scale a color to a different color using a scaling coefficient.
    ///Coefficient (lightr) 0 -> 1.0 (Darkere)
    func scaledColor(coeff:CGFloat) -> UIColor {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue : CGFloat = 0.0
        var alpha : CGFloat = 0.0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return UIColor(red: red*coeff, green: green*coeff, blue: blue*coeff, alpha: alpha*coeff)
        //return scaledColor
    }
}

extension UITableView {
    func selectRowAtSectionRow(forRow:Int, inSection: Int, animated: Bool, scrollPosition: UITableViewScrollPosition) -> Bool {
        if forRow < 0 || inSection < 0 { return false }
        let indexPath = NSIndexPath(forRow: forRow, inSection: inSection)
        selectRowAtIndexPath(indexPath, animated: animated, scrollPosition: scrollPosition)
        return true
    }
    
}

extension UIBarButtonItem {
    func hide() {
        enabled = false
        tintColor = UIColor.clearColor()
    }
}

extension UIViewController {
    func setNavigationBackItem(title: String) {
        let backItem = UIBarButtonItem()
        backItem.title = title
        navigationItem.backBarButtonItem = backItem
    }
}

extension Float {
    var cleanValue: String {
        return self % 1 == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Array {
    func ref (i:Index) -> Element? {
        return i < count ? self[i] : nil
    }
}


extension UIWindow {
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController  = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(rootViewController)
        }
        return nil
    }
    
    class func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        
        if vc.isKindOfClass(UINavigationController.self) {
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom( navigationController.visibleViewController!)
            
        } else if vc.isKindOfClass(UITabBarController.self) {
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(tabBarController.selectedViewController!)
            
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(presentedViewController)
            } else {
                return vc;
            }
        }
    }
}

extension Mappable {
    func forceMapString(map: Map, key: String) -> String {
        var value = ""
        if let valueString = map[key].currentValue as? String {
            value = valueString
        } else if let valueNum = map[key].currentValue as? UInt {
            value = "\(valueNum)"
        } else {
            value <- map[key]
        }
        return value
    }
}
