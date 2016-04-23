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
    var activeCells: [(Int, Int)] { get }
    var isEmpty: Bool { get }
    
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
        if column < width - 1 &&    self[column + 1, row] { neighbours += 1 }
        if row > 0 &&               self[column, row - 1] { neighbours += 1 }
        if row < height - 1 &&      self[column, row + 1] { neighbours += 1 }
        
        if column > 0 && row > 0 &&                     self[column - 1, row - 1] { neighbours += 1 }
        if column < width - 1 && row > 0 &&             self[column + 1, row - 1] { neighbours += 1 }
        if column < width - 1 && row < height - 1 &&    self[column + 1, row + 1] { neighbours += 1 }
        if column > 0 && row < height - 1 &&            self[column - 1, row + 1] { neighbours += 1 }
        
        return neighbours
    }
}
