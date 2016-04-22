//
//  GameOfLife.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 2015-07-27.
//  Copyright © 2015 nearedge. All rights reserved.
//

import Foundation

// MARK: Basic implementation of a Matrix, a two-dimensional array
struct Matrix {
    let rows: Int, columns: Int
    var grid: [Bool]
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(count: rows * columns, repeatedValue: false)
    }
    
    func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Bool {
        get {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}

// MARK: Extension to Matrix that adds "Game Of Life"-logic
extension Matrix {
    func getNextGeneration() -> Matrix {
        var next = Matrix(rows: self.rows, columns: self.columns)
        
        for row in 0..<rows {
            for column in 0..<columns {
                let numOfNeighbours = numberOfNeighbours(row, column: column)
                if self[row, column] == false {
                    if numOfNeighbours == 3 {
                        next[row, column] = true // Dead cell comes alive
                    }
                } else {
                    if numOfNeighbours < 2 {
                        next[row, column] = false // Under-population, dies
                    } else if numOfNeighbours < 4 {
                        next[row, column] = true // Lives on
                    } else {
                        next[row, column] = false // Over-population, dies
                    }
                }
            }
        }
        
        return next
    }
    
    func numberOfNeighbours(row: Int, column: Int) -> Int {
        var neighbours = 0
        
        if column > 0 &&            self[row, column - 1] { neighbours += 1 }
        if column < columns - 1 &&  self[row, column + 1] { neighbours += 1 }
        if row > 0 &&               self[row - 1, column] { neighbours += 1 }
        if row < rows - 1 &&        self[row + 1, column] { neighbours += 1 }
        
        if column > 0 && row > 0 &&                   self[row - 1, column - 1] { neighbours += 1 }
        if column < columns - 1 && row > 0 &&         self[row - 1, column + 1] { neighbours += 1 }
        if column < columns - 1 && row < rows - 1 &&  self[row + 1, column + 1] { neighbours += 1 }
        if column > 0 && row < rows - 1 &&            self[row + 1, column - 1] { neighbours += 1 }
        
        
        return neighbours
    }
}