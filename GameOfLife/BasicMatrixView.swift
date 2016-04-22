//
//  BasicMatrixView.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 2015-07-27.
//  Copyright © 2015 nearedge. All rights reserved.
//

import UIKit

class MyFadeLayer: CATiledLayer {
    override class func fadeDuration() -> CFTimeInterval {
        return 0.1
    }
}

class ZoomableMatrixView<MatrixType: GameOfLifeMatrix>: UIView {
    
    var matrix: MatrixType? { didSet { setNeedsDisplay() } }
    var matrixUpdated: ((MatrixType) -> ())?
    
    override class func layerClass() -> AnyClass {
        return MyFadeLayer.self
    }
    
    override init(frame : CGRect) {
        super.init(frame : frame)
        
        let tempTiledLayer = layer as! MyFadeLayer
        tempTiledLayer.levelsOfDetail = 1
        tempTiledLayer.levelsOfDetailBias = 1
        opaque = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ZoomableMatrixView.handleTapGesture(_:))))
    }
    
    convenience init() {
        self.init(frame:CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func drawRect(rect: CGRect) {
        
    }
    
    override func drawLayer(layer: CALayer, inContext context: CGContext) {
        let rect = bounds

        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextFillRect(context, rect)
        
        guard let matrix = matrix else { return }
        
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextSetTextMatrix(context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0))
        
        for y in 0..<matrix.height {
            for x in 0..<matrix.width {
                if matrix[x, y] == true {
                    let cellRect = matrix.frameForPosition(CGPoint(x: x, y: y), rect: rect)
                    
                    CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
                    CGContextFillRect(context, cellRect)
                    
                    let attr:CFDictionaryRef = [NSFontAttributeName : UIFont.systemFontOfSize(10, weight: UIFontWeightUltraLight),
                                                NSForegroundColorAttributeName : UIColor(white: 0, alpha: 0.2)]
                    let line = CTLineCreateWithAttributedString(CFAttributedStringCreate(nil, "\(matrix.numberOfNeighbours(x, row: y))", attr))
                    CGContextSetTextDrawingMode(context, .Fill)
                    CGContextSetTextPosition(context, cellRect.origin.x + 4.5, cellRect.origin.y + 11)
                    CTLineDraw(line, context)
                }
            }
        }
        
        let cellSize = matrix.frameForPosition(CGPointZero, rect: rect).size.width
        CGContextSetLineWidth(context, 1.0)
        CGContextSetStrokeColorWithColor(context, UIColor.lightGrayColor().CGColor)
        
        for y in 0..<matrix.height + 1 {
            CGContextMoveToPoint(context, 0, CGFloat(y) * cellSize)
            CGContextAddLineToPoint(context, CGFloat(matrix.width) * cellSize, CGFloat(y) * cellSize)
            CGContextStrokePath(context)
        }
        
        for x in 0..<matrix.width + 1 {
            CGContextMoveToPoint(context, CGFloat(x) * cellSize, 0)
            CGContextAddLineToPoint(context, CGFloat(x) * cellSize, CGFloat(matrix.height) * cellSize)
            CGContextStrokePath(context)
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
