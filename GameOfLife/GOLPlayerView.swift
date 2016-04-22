//
//  GameOfLife
//
//  Created by Mattias Jähnke on 22/04/16.
//  Copyright © 2016 nearedge. All rights reserved.
//

import UIKit

private class GOLPlayerLayer: CATiledLayer {
    override class func fadeDuration() -> CFTimeInterval {
        return 0.1
    }
}

class GOLPlayerView<MatrixType: GameOfLifeMatrix>: UIView {
    var matrix: MatrixType? { didSet { setNeedsDisplay() } }
    
    override class func layerClass() -> AnyClass {
        return GOLPlayerLayer.self
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        let tempTiledLayer = layer as! GOLPlayerLayer
        tempTiledLayer.levelsOfDetail = 1
        tempTiledLayer.levelsOfDetailBias = 1
        opaque = true
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func drawRect(rect: CGRect) {
        
    }
    
    override func drawLayer(layer: CALayer, inContext context: CGContext) {
        let rect = bounds
        CGContextSetTextMatrix(context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0))
        
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextFillRect(context, rect)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        
        guard let matrix = matrix else { return }
        
        for y in 0..<matrix.height {
            for x in 0..<matrix.width {
                if matrix[x, y] == true {
                    let cellRect = matrix.frameForPosition(CGPoint(x: x, y: y), rect: rect)
                    CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
                    CGContextFillRect(context, cellRect)
                }
            }
        }
    }
}

extension GameOfLifeMatrix {
    func frameForPosition(position: CGPoint, rect: CGRect) -> CGRect {
        let minSize = max(rect.size.width, rect.size.height)
        let s = round(minSize / CGFloat(min(width, height)))
        return CGRect(x: position.x * s, y: position.y * s, width: s, height: s)
    }
}
