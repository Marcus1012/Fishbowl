//
//  BigGoButton.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 1/26/17.
//  Copyright © 2017 RPM Consulting. All rights reserved.
//

import UIKit

//@IBDesignable
class BigGoButton: UIButton {

    // MARK: Public interface
    
    // Corner radius of the background rectangle
    @IBInspectable var roundRectCornerRadius: CGFloat = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // Color of the background rectangle
    @IBInspectable var roundRectColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.backgroundColor = UIColor.clearColor()
            self.setNeedsLayout()
        }
    }
    
    
    // MARK: - Overrides
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutRoundRectLayer()
        layoutImageAndText()
        
        //let width = frame.width
        /*
        if titleLabel?.text == "Delivery" {
            print("Button Frame for \(titleLabel?.text): \(frame)")
            print("superview frame: \(self.superview?.frame)")
        }
        */
    }
    
    
    // MARK: - Private
    private var roundRectLayer: CAShapeLayer?
    
    private func layoutRoundRectLayer() {
        if let existingLayer = roundRectLayer {
            existingLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: roundRectCornerRadius).CGPath
        shapeLayer.fillColor = roundRectColor.CGColor
        self.layer.insertSublayer(shapeLayer, atIndex: 0)
        self.roundRectLayer = shapeLayer
    }
    
    private func layoutImageAndText() {
        let spacing: CGFloat = 6.0
        let imageSize: CGSize = imageView!.image!.size
        titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(imageSize.height + spacing), 0.0)
        let labelString = NSString(string: titleLabel!.text!)
        let titleSize = labelString.sizeWithAttributes([NSFontAttributeName: titleLabel!.font])
        imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0, 0.0, -titleSize.width)
        let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0;
        contentEdgeInsets = UIEdgeInsetsMake(edgeOffset, 0.0, edgeOffset, 0.0)
    }
}
