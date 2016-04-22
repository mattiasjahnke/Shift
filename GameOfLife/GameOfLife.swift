//
//  GameOfLife.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 2015-07-27.
//  Copyright © 2015 nearedge. All rights reserved.
//

import Foundation

protocol GameOfLifeMatrix: Equatable {
    var width: Int { get }
    var height: Int { get }
    
    init(width: Int, height: Int)
    
    subscript(x: Int, y: Int) -> Bool { get set }
}

extension GameOfLifeMatrix {
    var generations: Int {
        var gen = 0
        var curr = self
        while true {
            let next = curr.incrementedGeneration()
            if next == curr { break }
            curr = next
            gen += 1
        }
        return gen
    }
    
    func incrementedGeneration() -> Self {
        var next = Self.init(width: width, height: height)
        
        for y in 0..<height {
            for x in 0..<width {
                let numOfNeighbours = numberOfNeighbours(x, row: y)
                if self[x, y] == false {
                    if numOfNeighbours == 3 {
                        next[x, y] = true // Dead cell comes alive
                    }
                } else {
                    if numOfNeighbours < 2 {
                        next[x, y] = false // Under-population, dies
                    } else if numOfNeighbours < 4 {
                        next[x, y] = true // Lives on
                    } else {
                        next[x, y] = false // Over-population, dies
                    }
                }
            }
        }
        
        return next
    }
    
    func numberOfNeighbours(column: Int, row: Int) -> Int {
        var neighbours = 0
        
        if column > 0 &&            self[column - 1, row] { neighbours += 1 }
        if column < width - 1 &&  self[column + 1, row] { neighbours += 1 }
        if row > 0 &&               self[column, row - 1] { neighbours += 1 }
        if row < height - 1 &&        self[column, row + 1] { neighbours += 1 }
        
        if column > 0 && row > 0 &&                   self[column - 1, row - 1] { neighbours += 1 }
        if column < width - 1 && row > 0 &&         self[column + 1, row - 1] { neighbours += 1 }
        if column < width - 1 && row < height - 1 &&  self[column + 1, row + 1] { neighbours += 1 }
        if column > 0 && row < height - 1 &&            self[column - 1, row + 1] { neighbours += 1 }
        
        return neighbours
    }
}


// MARK: Basic implementation of a Matrix, a two-dimensional array
struct Matrix: GameOfLifeMatrix {
    private(set) var height: Int
    private(set) var width: Int
    var grid: [Bool]
    
    init(width: Int, height: Int) {
        self.height = height
        self.width = width
        grid = Array(count: width * height, repeatedValue: false)
    }
    
    subscript(x: Int, y: Int) -> Bool {
        get {
            assert(indexIsValidForRow(y, column: x), "Index out of range")
            return grid[(y * width) + x]
        }
        set {
            assert(indexIsValidForRow(y, column: x), "Index out of range")
            grid[(y * width) + x] = newValue
        }
    }
    
    private func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < height && column >= 0 && column < width
    }
}

extension Matrix: Equatable {}

// MARK: Equatable

func ==(lhs: Matrix, rhs: Matrix) -> Bool {
    return lhs.grid == rhs.grid
}
