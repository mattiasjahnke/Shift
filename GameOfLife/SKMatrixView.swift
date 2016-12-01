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
    var gridColor = UIColor.lightGray
    var cellColor = UIColor.white
    
    fileprivate var grid: SKSpriteNode!
    fileprivate var nodePool = [SKNode]()
    
    fileprivate var cellSize: CGFloat!
    
    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        if grid == nil {
            scaleMode = .resizeFill
            
            let minSize = max(view.bounds.width, view.bounds.height)
            cellSize = round(minSize / CGFloat(min(matrix!.width, matrix!.height)))
            
            let gridImage = UIImage(
                gridWithBlockSize: cellSize,
                columns: Int(view.bounds.size.height / cellSize),
                rows: Int(view.bounds.size.width / cellSize), gridColor: .lightGray)
            let gridTexture = SKTexture(image: gridImage)
            
            grid = SKSpriteNode(texture: gridTexture, color: .black, size: gridTexture.size())
            grid.blendMode = .replace
            
            grid.position = CGPoint(x: view.bounds.midX,y: view.bounds.midY)
            grid.texture!.filteringMode = .nearest
            addChild(grid)
            
            if let _ = matrixUpdated {
                view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SKMatrixView.handleTapGesture(_:))))
            }
        }
    }
    
    func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard matrix != nil else { return }
        
        let touchPoint = gesture.location(in: gesture.view)
        let point = Point(x: Int((touchPoint.x - touchPoint.x.truncatingRemainder(dividingBy: cellSize)) / cellSize),
                          y: Int((touchPoint.y - touchPoint.y.truncatingRemainder(dividingBy: cellSize)) / cellSize))
        
        if matrix!.contains(point) {
            matrix![point] = !matrix![point]
            if let matrixUpdated = matrixUpdated {
                matrixUpdated(matrix!)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        let points = matrix!.activeCells.map { point -> CGPoint in
            let offset = cellSize / 2.0
            return CGPoint(
                x: CGFloat(point.x) * cellSize + offset,
                y: CGFloat(matrix!.height - point.y - 1) * cellSize + offset - 0.25
            )
        }
        
        while nodePool.count < points.count {
            let cell = SKShapeNode(rectOf: CGSize(width: cellSize - 1, height: cellSize - 1))
            cell.isAntialiased = false
            cell.strokeColor = UIColor.clear
            cell.fillColor = SKColor.white
            cell.blendMode = .replace
            cell.zPosition = 1
            nodePool.append(cell)
            self.addChild(cell)
        }
        
        for (index, node) in nodePool.enumerated() {
            guard index < points.count else { node.isHidden = true; continue }
            node.isHidden = false
            node.position = points[index]
        }
    }
}
