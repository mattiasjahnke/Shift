//
//  WebMatrixView.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 2015-07-27.
//  Copyright © 2015 nearedge. All rights reserved.
//

import UIKit

class WebMatrixView: UIView, MatrixRenderer {
    var mode: MatrixPresentationMode = .Edit { didSet { setNeedsDisplay() } }
    var matrix: Matrix? { didSet { setNeedsDisplay() } }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetTextMatrix(context, CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0))
        
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextFillRect(context, rect)
        //CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        if let matrix = matrix {
            for row in 0..<matrix.rows {
                for column in 0..<matrix.columns {
                    if matrix[row, column] == true {
                        let cellRect = frameForPosition(CGPoint(x: column, y: row), rect: rect)
                        
                        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
                        let neighbours = matrix.neighbours(row, column: column)
                        for neighbour in neighbours.map({ n in self.frameForPosition(CGPoint(x: n.column, y: n.row), rect: rect) }) {
                            CGContextMoveToPoint(context, cellRect.origin.x + cellRect.size.width / 2, cellRect.origin.y + cellRect.size.height / 2)
                            CGContextAddLineToPoint(context, neighbour.origin.x + neighbour.size.width / 2, neighbour.origin.y + neighbour.size.height / 2)
                            CGContextStrokePath(context)
                        }
                        
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
                CGContextSetLineWidth(context, 2.0)
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

// MARK: Extension of Matrix in order to find the neigbours points
private extension Matrix {
    func neighbours(row: Int, column: Int) -> [(row: Int, column: Int)] {
        var neighbours = [(row: Int, column: Int)]()
        
        if column > 0 &&            self[row, column - 1] { neighbours.append((row, column - 1)) }
        if column < columns - 1 &&  self[row, column + 1] { neighbours.append((row, column + 1)) }
        if row > 0 &&               self[row - 1, column] { neighbours.append((row - 1, column)) }
        if row < rows - 1 &&        self[row + 1, column] { neighbours.append((row + 1, column)) }
        
        if column > 0 && row > 0 &&                   self[row - 1, column - 1] { neighbours.append((row - 1, column - 1)) }
        if column < columns - 1 && row > 0 &&         self[row - 1, column + 1] { neighbours.append((row - 1, column + 1)) }
        if column < columns - 1 && row < rows - 1 &&  self[row + 1, column + 1] { neighbours.append((row + 1, column + 1)) }
        if column > 0 && row < rows - 1 &&            self[row + 1, column - 1] { neighbours.append((row + 1, column - 1)) }
        
        
        return neighbours
    }
}
