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