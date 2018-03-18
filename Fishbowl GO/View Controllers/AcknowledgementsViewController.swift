//
//  AcknowledgementsViewController.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 1/5/17.
//  Copyright © 2017 RPM Consulting. All rights reserved.
//

import UIKit
import MMMarkdown


class AcknowledgementsViewController: UIViewController {

    
    @IBOutlet var webView: UIWebView!
    
    
    @IBAction func btnDone(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let htmlPath = NSBundle.mainBundle().pathForResource("Pods-Fishbowl GO-acknowledgements", ofType: "markdown"),
            let html = try? String(contentsOfFile: htmlPath, encoding: NSUTF8StringEncoding)
        else {
            fatalError("Acknowledgements file not found.")
        }
        
        do {
            let str: String = try MMMarkdown.HTMLStringWithMarkdown(html)
            webView.loadHTMLString(str, baseURL: nil)
        } catch {
            webView.loadHTMLString("<b>Unable to load Acknowledgements file.</b>", baseURL: nil)
        }
        
    }

}
