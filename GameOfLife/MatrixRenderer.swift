//
//  MatrixRenderer.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 2015-07-27.
//  Copyright © 2015 nearedge. All rights reserved.
//

import UIKit

enum MatrixPresentationMode {
    case Edit
    case Display
}

protocol MatrixRenderer {
    var mode: MatrixPresentationMode { get set }
    var matrix: Matrix? { get set }
}

extension MatrixRenderer {
    func frameForPosition(position: CGPoint, rect: CGRect) -> CGRect {
        if let matrix = matrix {
            let minSize = max(rect.size.width, rect.size.height)
            let s = round(minSize / CGFloat(min(matrix.columns, matrix.rows)))
            return CGRect(x: position.x * s, y: position.y * s, width: s, height: s)
        }
        return CGRect.zero
    }
    
    func cellPointAtPoint(point: CGPoint, rect: CGRect) -> CGPoint? {
        if let matrix = matrix {
            let cellSize = frameForPosition(CGPointZero, rect: rect).size.width
            let res = CGPointMake((point.x - point.x % cellSize) / cellSize, (point.y - point.y % cellSize) / cellSize)
            if Int(res.x) >= 0 && Int(res.x) < matrix.columns && Int(res.y) >= 0 && Int(res.y) < matrix.rows {
                return res
            }
        }
        return nil
    }
}