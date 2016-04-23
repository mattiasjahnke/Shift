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