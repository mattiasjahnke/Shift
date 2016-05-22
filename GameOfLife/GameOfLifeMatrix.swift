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
    var activeCells: Set<Point> { get }
    var isEmpty: Bool { get }
    
    init(width: Int, height: Int)
    
    subscript(point: Point) -> Bool { get set }
}

struct Point: Hashable, Equatable {
    let x: Int, y: Int
    private let hash: Int
    
    init(x: Int = 0, y: Int = 0) {
        self.x = x
        self.y = y
        hash = "\(x.hashValue)\(y.hashValue)".hashValue
    }
    
    var hashValue: Int { return hash }
}

func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

extension GameOfLifeMatrix {
    func contains(point: Point) -> Bool {
        return point.x >= 0 && point.y >= 0 && point.x <= width - 1 && point.y <= height - 1
    }
    
    subscript(x: Int, y: Int) -> Bool {
        get { return self[Point(x: x, y: y)] }
        set { self[Point(x: x, y: y)] = newValue }
    }
}

extension GameOfLifeMatrix {
    func incrementedGeneration() -> Self {
        var next = Self.init(width: width, height: height)
        var processed = Set<Point>()
        for cell in activeCells {
            next[cell] = fate(cell)
            // Determine the fate for the the "inactive" neighbours
            for inactive in cell.adjecentPoints.filter({ self.contains($0) && !self[$0] }) {
                guard !processed.contains(inactive) else { continue }
                next[inactive] = fate(inactive)
                processed.insert(inactive)
            }
        }
        
        return next
    }
    
    private func fate(point: Point) -> Bool {
        let activeNeighbours = point.adjecentPoints.filter { self.contains($0) && self[$0] }.count
        switch activeNeighbours {
        case 3 where self[point] == false:      // Dead cell comes alive
            return true
        case 2..<4 where self[point] == true:   // Lives on
            return true
        default:                                // Under- or over-population, dies
            return false
        }
    }
}

// Move
private extension Point {
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

