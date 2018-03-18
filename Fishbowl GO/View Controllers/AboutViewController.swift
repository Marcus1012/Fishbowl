//
//  AboutViewController.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import Foundation


class AboutViewController: UIViewController {

    @IBOutlet var labelVersion: UILabel!
    @IBOutlet weak var labelUUID: UILabel!

    @IBAction func btnOk(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func viewOnlineDemo(sender: AnyObject) {
        if let url = NSURL(string: "https://www.fishbowlinventory.com/wiki/Fishbowl_GO_iOS") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let versionString = version()
        if versionString.characters.count > 0 {
            labelVersion.text = versionString
        } else {
            labelVersion.text = "beta v0.99"
        }
        
        labelUUID.text = g_install_id
        labelUUID.hidden = false
    }

    func version() -> String {
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        var versionInfo = "v \(version) (build \(build))"
        if g_serverVersion.characters.count > 0 {
            versionInfo += " -- Server: \(g_serverVersion)"
        }
        return versionInfo
    }
}
