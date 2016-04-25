//
//  MatrixImplementations.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 23/04/16.
//  Copyright © 2016 nearedge. All rights reserved.
//

import Foundation

// MARK: Tuple Set implemention of a Matrix
private struct Point: Hashable, Equatable {
    let x: Int, y: Int
    private let hash: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
        hash = "\(x.hashValue)\(y.hashValue)".hashValue
    }
    
    var hashValue: Int {
        return hash
    }
}
private func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct TupleMatrix: GameOfLifeMatrix {
    private(set) var height: Int
    private(set) var width: Int
    private var set = Set<Point>()
    
    var activeCells: [(Int, Int)] {
        return set.map { ($0.x, $0.y) }
    }
    
    var isEmpty: Bool {
        return set.isEmpty
    }
    
    init(width: Int, height: Int) {
        self.height = height
        self.width = width
    }
    
    subscript(x: Int, y: Int) -> Bool {
        get { return set.contains(Point(x: x, y: y)) }
        set {
            if newValue && !self[x, y] {
                set.insert(Point(x: x, y: y))
            } else if !newValue && self[x, y] {
                set.remove(Point(x: x, y: y))
            }
        }
    }
}

extension TupleMatrix: Equatable {}
func ==(lhs: TupleMatrix, rhs: TupleMatrix) -> Bool {
    return lhs.set == rhs.set
}

// MARK: Basic array implementation of a Matrix
struct ArrayMatrix: GameOfLifeMatrix {
    private(set) var height: Int
    private(set) var width: Int
    private var grid: [Bool]
    
    var activeCells: [(Int, Int)] {
        var cells = [(Int, Int)]()
        for y in 0..<height {
            for x in 0..<width {
                if self[x, y] == true {
                    cells.append((x, y))
                }
            }
        }
        return cells
    }
    
    var isEmpty: Bool {
        return grid.filter{ $0 }.isEmpty
    }
    
    init(width: Int, height: Int) {
        self.height = height
        self.width = width
        grid = Array(count: width * height, repeatedValue: false)
    }
    
    subscript(x: Int, y: Int) -> Bool {
        get { return grid[(y * width) + x] }
        set { grid[(y * width) + x] = newValue }
    }
}

extension ArrayMatrix: Equatable {}

// MARK: Equatable

func ==(lhs: ArrayMatrix, rhs: ArrayMatrix) -> Bool {
    return lhs.grid == rhs.grid
}