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
    
    var viewportColor = UIColor.red {
        didSet { setNeedsDisplay() }
    }
    
    fileprivate var viewport = CGRect.zero
    fileprivate var worldSize = CGSize.zero
    
    func renderMinimap(_ viewport: CGRect, worldSize: CGSize) {
        self.viewport = viewport
        self.worldSize = worldSize
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor?.cgColor ?? UIColor.black.cgColor)
        context?.fill(rect)
        
        // Scale
        let scaleX = rect.width / worldSize.width
        let scaleY = rect.height / worldSize.height
        
        let scaledRect = CGRect(x: max(min(viewport.origin.x * scaleX, rect.width), 0),
                                y: max(min(viewport.origin.y * scaleY, rect.height), 0),
                                width: viewport.width * scaleX,
                                height: viewport.height * scaleY)
        
        context?.setLineWidth(1)
        context?.setStrokeColor(viewportColor.cgColor)
        context?.addRect(scaledRect)
        context?.strokePath()
    }
    
    // Pass through any touches
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
