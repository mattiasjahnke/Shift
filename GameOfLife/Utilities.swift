//
//  Utilities.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 23/04/16.
//  Copyright © 2016 nearedge. All rights reserved.
//

import UIKit

func CGContextStrokeGrid(context: CGContext, rect: CGRect, cellSize: CGFloat) {
    var xOffset: CGFloat = rect.origin.x
    var yOffset: CGFloat = rect.origin.y
    while xOffset <= rect.maxX {
        CGContextMoveToPoint(context, xOffset, 0)
        CGContextAddLineToPoint(context, xOffset, rect.maxY)
        CGContextStrokePath(context)
        xOffset += cellSize
    }
    while yOffset <= rect.maxY {
        CGContextMoveToPoint(context, 0, yOffset)
        CGContextAddLineToPoint(context, rect.maxX, yOffset)
        CGContextStrokePath(context)
        yOffset += cellSize
    }
}

extension UIView {
    func wrapSubview(view: UIView) {
        if view.superview != self {
            addSubview(view)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view" : view]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view" : view]))
    }
}

extension UIImage {
    convenience init(gridWithBlockSize blockSize: CGFloat, columns: Int, rows: Int, gridColor: UIColor = .grayColor()) {
        // Add 1 to the height and width to ensure the borders are within the sprite
        let size = CGSize(width: CGFloat(columns) * blockSize + 1.0,
                          height: CGFloat(rows) * blockSize + 1.0)
        
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        
        // Draw vertical lines
        for i in 0...columns {
            let x = CGFloat(i) * blockSize + offset
            bezierPath.moveToPoint(CGPoint(x: x, y: 0))
            bezierPath.addLineToPoint(CGPoint(x: x, y: size.height))
        }
        // Draw horizontal lines
        for i in 0...rows {
            let y = CGFloat(i) * blockSize + offset
            bezierPath.moveToPoint(CGPoint(x: 0, y: y))
            bezierPath.addLineToPoint(CGPoint(x: size.width, y: y))
        }
        
        gridColor.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
        
        CGContextSetAllowsAntialiasing(context, false)
        CGContextSetShouldAntialias(context, false)
        
        CGContextAddPath(context, bezierPath.CGPath)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.init(CGImage: image.CGImage!)
    }
}

class LinkButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self, action: #selector(handleTap), forControlEvents: .TouchUpInside)
        titleLabel!.numberOfLines = 0
        titleLabel!.textAlignment = .Center
    }
    
    func handleTap() {
        UIApplication.sharedApplication().openURL(NSURL(string: currentTitle!)!)
    }
}