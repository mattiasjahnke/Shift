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
        
        // Draw active cells
        for pos in matrix.activeCells {
            let cellRect = matrix.frameForPoint(pos, rect: rect)
            CGContextFillRect(context, cellRect)
        }
        
        // Draw grid
        if showGrid {
            let cellSize = matrix.frameForPoint(Point(), rect: rect).size.width
            CGContextSetLineWidth(context, 1.0)
            CGContextSetStrokeColorWithColor(context, gridColor.CGColor)
            
            CGContextStrokeGrid(context, rect: rect, cellSize: cellSize)
        }
    }
    
    func handleTapGesture(gesture: UITapGestureRecognizer) {
        guard matrix != nil else { return }
        
        let touchPoint = gesture.locationInView(self)
        
        let cellSize = matrix!.frameForPoint(Point(), rect: frame).size
        let point = Point(x: Int((touchPoint.x - touchPoint.x % cellSize.width) / cellSize.width), y: Int((touchPoint.y - touchPoint.y % cellSize.height) / cellSize.height))
        
        if matrix!.contains(point) {
            matrix![point] = !matrix![point]
            setNeedsDisplay()
            if let matrixUpdated = matrixUpdated {
                matrixUpdated(matrix!)
            }
        }
    }
}

private extension GameOfLifeMatrix {
    // TODO: This should respect different width/height of cells
    func frameForPoint(point: Point, rect: CGRect) -> CGRect {
        let minSize = max(rect.size.width, rect.size.height)
        let s = round(minSize / CGFloat(min(width, height)))
        return CGRect(x: CGFloat(point.x) * s, y: CGFloat(point.y) * s, width: s, height: s)
    }
}
