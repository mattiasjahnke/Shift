//
//  GameOfLife.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 2015-07-27.
//  Copyright © 2015 nearedge. All rights reserved.
//

import Foundation

struct Point: Hashable, Equatable {
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

// Move
extension Point {
    var adjecentPoints: Set<Point> {
        return [left, leftUp, up, rightUp, right, rightDown, down, leftDown]
    }
    
    var left: Point {       return Point(x: x - 1, y: y) }
    var leftUp: Point {     return Point(x: x - 1, y: y - 1) }
    var up: Point {         return Point(x: x, y: y - 1) }
    var rightUp: Point {    return Point(x: x + 1, y: y - 1) }
    var right: Point {      return Point(x: x + 1, y: y) }
    var rightDown: Point {  return Point(x: x + 1, y: y + 1) }
    var down: Point {       return Point(x: x, y: y + 1) }
    var leftDown: Point {   return Point(x: x - 1, y: y + 1) }
}

func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

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
        
        var cellsToProcess = [Point : Int]() // Point : Neighbours
        for cell in activeCells.map({ Point(x: $0.0, y: $0.1) }) {
            // Retrieve the "inactive" neighbours
            for inactiveNeighbour in getAdjecents(cell).filter({ !$0.1 }).map({ $0.0 }) {
                cellsToProcess[inactiveNeighbour] = numberOfNeighbours(inactiveNeighbour.x, row: inactiveNeighbour.y)
            }
            // Add current cell
            cellsToProcess[cell] = numberOfNeighbours(cell.x, row: cell.y)
        }
        
        for (cell, neighbours) in cellsToProcess {
            if self[cell.x, cell.y] == false {
                if neighbours == 3 {
                    next[cell.x, cell.y] = true // Dead cell comes alive
                }
            } else {
                next[cell.x, cell.y] = neighbours > 1 && neighbours < 4
            }
        }
        
        return next
    }
    
    func numberOfNeighbours(column: Int, row: Int) -> Int {
        return getAdjecents(Point(x: column, y: row)).filter({ $0.1 }).count
    }
    
    private func getAdjecents(point: Point) -> [Point : Bool] {
        let adjecent = point.adjecentPoints.filter { self.containtsPoint($0) }
        
        var dic = [Point : Bool]()
        for cell in adjecent {
            dic[cell] = self[cell.x, cell.y]
        }
        return dic
    }
    
    private func containtsPoint(point: Point) -> Bool {
        return point.x >= 0 && point.y >= 0 && point.x < width - 1 && point.y < height - 1
    }
}
