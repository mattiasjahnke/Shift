//
//  MatrixRenderView.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 23/04/16.
//  Copyright © 2016 nearedge. All rights reserved.
//

import UIKit

private class MatrixViewLayer: CATiledLayer {
    override class func fadeDuration() -> CFTimeInterval {
        return 0.1
    }
}

class MatrixView<MatrixType: GameOfLifeMatrix>: UIView {
    
    var matrix: MatrixType? { didSet { setNeedsDisplay() } }
    var matrixUpdated: ((MatrixType) -> ())?
    
    var showGrid = false { didSet { setNeedsDisplay() } }
    var displayNrOfNeighbours = false { didSet { setNeedsDisplay() } }
    var gridColor = UIColor.lightGrayColor() { didSet { setNeedsDisplay() } }
    var cellColor = UIColor.whiteColor() { didSet { setNeedsDisplay() } }
    override var backgroundColor: UIColor? {
        didSet { super.backgroundColor = backgroundColor; setNeedsDisplay() }
    }
    
    override class func layerClass() -> AnyClass { return MatrixViewLayer.self }
    
    override init(frame : CGRect) {
        super.init(frame : frame)
        
        let tempTiledLayer = layer as! MatrixViewLayer
        tempTiledLayer.levelsOfDetail = 1
        tempTiledLayer.levelsOfDetailBias = 1
        opaque = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MatrixView.handleTapGesture(_:))))
    }
    
    convenience init() { self.init(frame:CGRect.zero) }
    required init(coder aDecoder: NSCoder) { fatalError("This class does not support NSCoding") }
    override func drawRect(rect: CGRect) { }
    
    override func drawLayer(layer: CALayer, inContext context: CGContext) {
        let rect = bounds
        
        // Draw background
        CGContextSetFillColorWithColor(context, (backgroundColor ?? UIColor.blackColor()).CGColor)
        CGContextFillRect(context, rect)
        
        guard let matrix = matrix else { return }
        
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextSetTextMatrix(context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0))
        CGContextSetTextDrawingMode(context, .Fill)
        
        // Draw active cells
        for pos in matrix.activeCells {
            let cellRect = matrix.frameForPosition(CGPoint(x: pos.0, y: pos.1), rect: rect)
            CGContextFillRect(context, cellRect)
            
            // This needs a cache if we're gonna have it!
            if displayNrOfNeighbours {
                let attr:CFDictionaryRef = [NSFontAttributeName : UIFont.systemFontOfSize(10, weight: UIFontWeightUltraLight),
                                            NSForegroundColorAttributeName : UIColor(white: 0, alpha: 0.2)]
                let line = CTLineCreateWithAttributedString(CFAttributedStringCreate(nil, "\(matrix.numberOfNeighbours(pos.0, row: pos.1))", attr))
                
                CGContextSetTextPosition(context, cellRect.origin.x + 4.5, cellRect.origin.y + 11)
                CTLineDraw(line, context)
            }
        }
        
        // Draw grid
        if showGrid {
            let cellSize = matrix.frameForPosition(CGPointZero, rect: rect).size.width
            CGContextSetLineWidth(context, 1.0)
            CGContextSetStrokeColorWithColor(context, gridColor.CGColor)
            
            CGContextStrokeGrid(context, rect: rect, cellSize: cellSize)
        }
    }
    
    func handleTapGesture(gesture: UITapGestureRecognizer) {
        guard let position = cellPointAtPoint(gesture.locationInView(self), rect: frame) else { return }
        guard matrix != nil else { return }
        matrix![Int(position.x), Int(position.y)] = !matrix![Int(position.x), Int(position.y)]
        setNeedsDisplay()
        if let matrixUpdated = matrixUpdated {
            matrixUpdated(matrix!)
        }
    }
    
    private func cellPointAtPoint(point: CGPoint, rect: CGRect) -> CGPoint? {
        guard let matrix = matrix else { return nil }
        let cellSize = matrix.frameForPosition(CGPointZero, rect: rect).size.width
        let res = CGPointMake((point.x - point.x % cellSize) / cellSize, (point.y - point.y % cellSize) / cellSize)
        if Int(res.x) >= 0 && Int(res.x) < matrix.width && Int(res.y) >= 0 && Int(res.y) < matrix.height {
            return res
        } else {
            return nil
        }
    }
}

private extension GameOfLifeMatrix {
    func frameForPosition(position: CGPoint, rect: CGRect) -> CGRect {
        let minSize = max(rect.size.width, rect.size.height)
        let s = round(minSize / CGFloat(min(width, height)))
        return CGRect(x: position.x * s, y: position.y * s, width: s, height: s)
    }
}
