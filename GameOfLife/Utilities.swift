//
//  Utilities.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 23/04/16.
//  Copyright © 2016 nearedge. All rights reserved.
//

import UIKit

func CGContextStrokeGrid(_ context: CGContext, rect: CGRect, cellSize: CGFloat) {
    var xOffset: CGFloat = rect.origin.x
    var yOffset: CGFloat = rect.origin.y
    while xOffset <= rect.maxX {
        context.move(to: CGPoint(x: xOffset, y: 0))
        context.addLine(to: CGPoint(x: xOffset, y: rect.maxY))
        context.strokePath()
        xOffset += cellSize
    }
    while yOffset <= rect.maxY {
        context.move(to: CGPoint(x: 0, y: yOffset))
        context.addLine(to: CGPoint(x: rect.maxX, y: yOffset))
        context.strokePath()
        yOffset += cellSize
    }
}

extension UIView {
    func wrapSubview(_ view: UIView) {
        if view.superview != self {
            addSubview(view)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view" : view]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view" : view]))
    }
}

extension UIImage {
    convenience init(gridWithBlockSize blockSize: CGFloat, columns: Int, rows: Int, gridColor: UIColor = .gray) {
        // Add 1 to the height and width to ensure the borders are within the sprite
        let size = CGSize(width: CGFloat(columns) * blockSize + 1.0,
                          height: CGFloat(rows) * blockSize + 1.0)
        
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        
        // Draw vertical lines
        for i in 0...columns {
            let x = CGFloat(i) * blockSize + offset
            bezierPath.move(to: CGPoint(x: x, y: 0))
            bezierPath.addLine(to: CGPoint(x: x, y: size.height))
        }
        // Draw horizontal lines
        for i in 0...rows {
            let y = CGFloat(i) * blockSize + offset
            bezierPath.move(to: CGPoint(x: 0, y: y))
            bezierPath.addLine(to: CGPoint(x: size.width, y: y))
        }
        
        gridColor.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
        
        context?.setAllowsAntialiasing(false)
        context?.setShouldAntialias(false)
        
        context?.addPath(bezierPath.cgPath)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.init(cgImage: (image?.cgImage!)!)
    }
}

class LinkButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        titleLabel!.numberOfLines = 0
        titleLabel!.textAlignment = .center
    }
    
    func handleTap() {
        UIApplication.shared.openURL(URL(string: currentTitle!)!)
    }
}
