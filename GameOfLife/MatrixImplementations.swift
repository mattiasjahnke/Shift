//
//  MatrixImplementations.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 23/04/16.
//  Copyright © 2016 nearedge. All rights reserved.
//

import Foundation

// MARK: Tuple Set implemention of a Matrix
struct TupleMatrix: GameOfLifeMatrix {
    private(set) var height: Int
    private(set) var width: Int
    private var set = Set<Point>()
    
    var activeCells: Set<Point> { return set }
    var isEmpty: Bool { return set.isEmpty }
    
    init(width: Int, height: Int) {
        self.height = height
        self.width = width
    }
    
    subscript(point: Point) -> Bool {
        get { return set.contains(point) }
        set {
            if newValue && !self[point] {
                set.insert(point)
            } else if !newValue && self[point] {
                set.remove(point)
            }
        }
    }
}

extension TupleMatrix: Equatable {}
func ==(lhs: TupleMatrix, rhs: TupleMatrix) -> Bool {
    return lhs.set == rhs.set
}
