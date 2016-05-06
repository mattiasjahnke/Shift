//
//  SKMatrixView.swift
//  Shift
//
//  Created by Mattias Jähnke on 06/05/16.
//  Copyright © 2016 nearedge. All rights reserved.
//

import SpriteKit

class SKMatrixView<MatrixType: GameOfLifeMatrix>: SKScene {
    var matrix: MatrixType?
    var matrixUpdated: ((MatrixType) -> ())?
    
    var showGrid = false
    var gridColor = UIColor.lightGrayColor()
    var cellColor = UIColor.whiteColor()
    
    private var grid: Grid!
    private var nodePool = [SKNode]()
    
    private var cellSize: CGSize!
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    override func didMoveToView(view: SKView) {
        scaleMode = .ResizeFill

        let f = matrix!.frameForPoint(Point(x: 0, y: 0), rect: view.bounds).size.width
        cellSize = CGSize(width: f, height: f)
        grid = Grid(blockSize: f, rows: Int(view.frame.size.width / f), cols: Int(view.frame.size.height / f))
        grid.position = CGPointMake (CGRectGetMidX(view.frame),CGRectGetMidY(view.frame))
        grid.texture!.filteringMode = .Nearest
        addChild(grid)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SKMatrixView.handleTapGesture(_:))))
    }
    
    func handleTapGesture(gesture: UITapGestureRecognizer) {
        guard matrix != nil else { return }
        
        let touchPoint = gesture.locationInView(gesture.view)
        
        let cellSize = matrix!.frameForPoint(Point(), rect: frame).size
        let point = Point(x: Int((touchPoint.x - touchPoint.x % cellSize.width) / cellSize.width), y: Int((touchPoint.y - touchPoint.y % cellSize.height) / cellSize.height))
        
        if matrix!.contains(point) {
            matrix![point] = !matrix![point]
            if let matrixUpdated = matrixUpdated {
                matrixUpdated(matrix!)
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
        
        let points = matrix!.activeCells.map { grid.gridPosition($0.y, col: $0.x) }
        while nodePool.count < points.count {
            let cell = SKShapeNode(rectOfSize: cellSize)
            cell.antialiased = false
            cell.strokeColor = UIColor.clearColor()
            cell.fillColor = SKColor.whiteColor()
            nodePool.append(cell)
            grid.addChild(cell)
        }
        for (index, node) in nodePool.enumerate() {
            guard index < points.count else { node.hidden = true; continue }
            node.hidden = false
            node.position = points[index]
        }
    }
}

class Grid:SKSpriteNode {
    var rows:Int!
    var cols:Int!
    var blockSize:CGFloat!
    
    convenience init(blockSize:CGFloat,rows:Int,cols:Int) {
        let texture = Grid.gridTexture(blockSize,rows: rows, cols:cols)
        self.init(texture: texture, color:SKColor.clearColor(), size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
    }
    
    override init(texture: SKTexture!, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func gridTexture(blockSize:CGFloat,rows:Int,cols:Int) -> SKTexture {
        // Add 1 to the height and width to ensure the borders are within the sprite
        let size = CGSize(width: CGFloat(cols)*blockSize+1.0, height: CGFloat(rows)*blockSize+1.0)
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        // Draw vertical lines
        for i in 0...cols {
            let x = CGFloat(i)*blockSize + offset
            bezierPath.moveToPoint(CGPoint(x: x, y: 0))
            bezierPath.addLineToPoint(CGPoint(x: x, y: size.height))
        }
        // Draw horizontal lines
        for i in 0...rows {
            let y = CGFloat(i)*blockSize + offset
            bezierPath.moveToPoint(CGPoint(x: 0, y: y))
            bezierPath.addLineToPoint(CGPoint(x: size.width, y: y))
        }
        SKColor.blackColor().setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
        CGContextAddPath(context, bezierPath.CGPath)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image)
    }
    
    func gridPosition(row:Int, col:Int) -> CGPoint {
        let offset = blockSize / 2.0
        let x = CGFloat(col) * blockSize - (blockSize * CGFloat(cols)) / 2.0 + offset
        let y = CGFloat(rows - row - 1) * blockSize - (blockSize * CGFloat(rows)) / 2.0 + offset
        return CGPoint(x:x, y:y)
    }
}

private extension GameOfLifeMatrix {
    // TODO: This should respect different width/height of cells
    func frameForPoint(point: Point, rect: CGRect) -> CGRect {
        let minSize = max(rect.size.width, rect.size.height)
        let s = round(minSize / CGFloat(min(width, height)))
        return CGRect(x: CGFloat(point.x) * s, y: CGFloat(point.y) * s, width: s, height: s)
    }
}