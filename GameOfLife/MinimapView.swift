//
//  MinimapView.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 23/04/16.
//  Copyright © 2016 nearedge. All rights reserved.
//

import UIKit

class MinimapView: UIView {
    
    override var backgroundColor: UIColor? {
        didSet { super.backgroundColor = backgroundColor; setNeedsDisplay() }
    }
    
    var viewportColor = UIColor.redColor() {
        didSet { setNeedsDisplay() }
    }
    
    private var viewport = CGRect.zero
    private var worldSize = CGSize.zero
    
    func renderMinimap(viewport: CGRect, worldSize: CGSize) {
        self.viewport = viewport
        self.worldSize = worldSize
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, backgroundColor?.CGColor ?? UIColor.blackColor().CGColor)
        CGContextFillRect(context, rect)
        
        // Scale
        let scaleX = rect.width / worldSize.width
        let scaleY = rect.height / worldSize.height
        
        let scaledRect = CGRect(x: max(min(viewport.origin.x * scaleX, rect.width), 0),
                                y: max(min(viewport.origin.y * scaleY, rect.height), 0),
                                width: viewport.width * scaleX,
                                height: viewport.height * scaleY)
        
        CGContextSetLineWidth(context, 1)
        CGContextSetStrokeColorWithColor(context, viewportColor.CGColor)
        CGContextAddRect(context, scaledRect)
        CGContextStrokePath(context)
    }
    
    // Pass through any touches
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return false
    }
}