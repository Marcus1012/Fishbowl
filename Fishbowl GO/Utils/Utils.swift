//
//  Utils.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 9/1/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import UIKit


func invokeAlertMessage(msgTitle: String, msgBody: String, delegate: AnyObject?, handler: ((UIAlertAction) -> Void)? = nil)  {
    let alertController = UIAlertController(title: msgTitle, message: msgBody, preferredStyle: g_alertSytle)
    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: handler))
    
    if delegate is UIViewController {
        let vc = delegate as! UIViewController
        alertController.popoverPresentationController?.sourceView = vc.view
    }
    delegate!.presentViewController(alertController, animated: true, completion: nil)
}


func invokeConfirm(title:String, message: String, okText: String, cancelText: String, okHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?, delegate: AnyObject?) {
    let confirmAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    confirmAlert.addAction(UIAlertAction(title: okText,     style: .Default, handler: okHandler))
    if cancelText.characters.count > 0 {
        confirmAlert.addAction(UIAlertAction(title: cancelText, style: .Default, handler: cancelHandler))
    }
    
    if delegate is UIViewController {
        let vc = delegate as! UIViewController
        confirmAlert.popoverPresentationController?.sourceView = vc.view
    }
    delegate!.presentViewController(confirmAlert, animated: true, completion: nil)
}
