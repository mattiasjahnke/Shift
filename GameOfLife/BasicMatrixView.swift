//
//  BasicMatrixView.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 2015-07-27.
//  Copyright © 2015 nearedge. All rights reserved.
//

import UIKit

class BasicMatrixView: UIView, MatrixRenderer {
    
    var mode: MatrixPresentationMode = .Edit { didSet { setNeedsDisplay() } }
    var matrix: Matrix? { didSet { setNeedsDisplay() } }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetTextMatrix(context, CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0))
        
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextFillRect(context, rect)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        if let matrix = matrix {
            for row in 0..<matrix.rows {
                for column in 0..<matrix.columns {
                    if matrix[row, column] == true {
                        let cellRect = frameForPosition(CGPoint(x: column, y: row), rect: rect)
                        
                        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
                        CGContextFillRect(context, cellRect)
                        
                        if mode == .Edit {
                            let aFont = UIFont(name: "Helvetica", size: 12)
                            let attr:CFDictionaryRef = [NSFontAttributeName:aFont!, NSForegroundColorAttributeName:UIColor.blueColor()]
                            let text = CFAttributedStringCreate(nil, "\(matrix.numberOfNeighbours(row, column: column))", attr)
                            let line = CTLineCreateWithAttributedString(text)
                            CGContextSetLineWidth(context, 1.5)
                            CGContextSetTextDrawingMode(context, CGTextDrawingMode.Stroke)
                            CGContextSetTextPosition(context, cellRect.origin.x + 5, cellRect.origin.y + 10)
                            CTLineDraw(line, context!)
                        }
                    }
                }
            }
            
            if mode == .Edit {
                let cellSize = frameForPosition(CGPointZero, rect: rect).size.width
                CGContextSetLineWidth(context, 1.0)
                CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor)
                
                for row in 0..<matrix.rows {
                    CGContextMoveToPoint(context, 0, CGFloat(row) * cellSize)
                    CGContextAddLineToPoint(context, CGFloat(matrix.columns) * cellSize, CGFloat(row) * cellSize)
                    CGContextStrokePath(context)
                }
                
                for column in 0..<matrix.columns {
                    CGContextMoveToPoint(context, CGFloat(column) * cellSize, 0)
                    CGContextAddLineToPoint(context, CGFloat(column) * cellSize, CGFloat(matrix.rows) * cellSize)
                    CGContextStrokePath(context)
                }
                
            }
        }
    }
    
    
}

class MyFadeLayer: CATiledLayer {
    override class func fadeDuration() -> CFTimeInterval {
        return 0.1
    }
}

class ZoomableMatrixView: UIView, MatrixRenderer {
    
    var mode: MatrixPresentationMode = .Edit { didSet { setNeedsDisplay() } }
    var matrix: Matrix? { didSet { setNeedsDisplay() } }
    
    override class func layerClass() -> AnyClass {
        return MyFadeLayer.self
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        let tempTiledLayer = layer as! MyFadeLayer
        tempTiledLayer.levelsOfDetail = 1
        tempTiledLayer.levelsOfDetailBias = 1
        opaque = true
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func drawRect(rect: CGRect) {
        
    }
    
    override func drawLayer(layer: CALayer, inContext context: CGContext) {
        let rect = bounds
        CGContextSetTextMatrix(context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0))
        
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextFillRect(context, rect)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        if let matrix = matrix {
            for row in 0..<matrix.rows {
                for column in 0..<matrix.columns {
                    if matrix[row, column] == true {
                        let cellRect = frameForPosition(CGPoint(x: column, y: row), rect: rect)
                        
                        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
                        CGContextFillRect(context, cellRect)
                        
                        if mode == .Edit {
                            let attr:CFDictionaryRef = [NSFontAttributeName : UIFont.systemFontOfSize(10, weight: UIFontWeightUltraLight),
                                                        NSForegroundColorAttributeName : UIColor(white: 0, alpha: 0.2)]
                            let line = CTLineCreateWithAttributedString(CFAttributedStringCreate(nil, "\(matrix.numberOfNeighbours(row, column: column))", attr))
                            CGContextSetTextDrawingMode(context, .Fill)
                            CGContextSetTextPosition(context, cellRect.origin.x + 4.5, cellRect.origin.y + 11)
                            CTLineDraw(line, context)
                        }
                    }
                }
            }
            
            if mode == .Edit {
                let cellSize = frameForPosition(CGPointZero, rect: rect).size.width
                CGContextSetLineWidth(context, 1.0)
                CGContextSetStrokeColorWithColor(context, UIColor.lightGrayColor().CGColor)
                
                for row in 0..<matrix.rows + 1 {
                    CGContextMoveToPoint(context, 0, CGFloat(row) * cellSize)
                    CGContextAddLineToPoint(context, CGFloat(matrix.columns) * cellSize, CGFloat(row) * cellSize)
                    CGContextStrokePath(context)
                }
                
                for column in 0..<matrix.columns + 1 {
                    CGContextMoveToPoint(context, CGFloat(column) * cellSize, 0)
                    CGContextAddLineToPoint(context, CGFloat(column) * cellSize, CGFloat(matrix.rows) * cellSize)
                    CGContextStrokePath(context)
                }
                
            }
        }
    }
}

extension CGContext {
    func saveAndRestore(operations: () -> ()) {
        CGContextSaveGState(self)
        operations()
        CGContextRestoreGState(self)
    }
}