//
//  ViewController.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 2015-07-26.
//  Copyright © 2015 nearedge. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var gridScreen: UIScreen! {
        didSet {
            if gridView != nil {
                gridView.removeFromSuperview()
            }
            
            gridView = MatrixPlayerView()
            gridView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.stopAnimation)))
            gridView.translatesAutoresizingMaskIntoConstraints = false
            
            if gridScreen != .mainScreen() {
                gridWindow = UIWindow(frame: gridScreen.bounds)
                gridWindow.layer.contentsGravity = kCAGravityResizeAspect
                gridWindow.screen = gridScreen
                gridWindow.hidden = false
                
                gridWindow.addSubview(gridView)
                gridWindow.addConstraint(NSLayoutConstraint(item: gridView, attribute: .Width, relatedBy: .Equal, toItem: gridView, attribute: .Height, multiplier: 1, constant: 0))
                gridWindow.addConstraint(NSLayoutConstraint(item: gridView, attribute: .CenterX, relatedBy: .Equal, toItem: gridWindow, attribute: .CenterX, multiplier: 1, constant: 0))
                gridWindow.addConstraint(NSLayoutConstraint(item: gridView, attribute: .CenterY, relatedBy: .Equal, toItem: gridWindow, attribute: .CenterY, multiplier: 1, constant: 0))
                
                if gridWindow.frame.height < gridWindow.frame.width {
                    gridWindow.addConstraint(NSLayoutConstraint(item: gridView, attribute: .Height, relatedBy: .Equal, toItem: gridWindow, attribute: .Height, multiplier: 1, constant: 0))
                } else {
                    gridWindow.addConstraint(NSLayoutConstraint(item: gridView, attribute: .Width, relatedBy: .Equal, toItem: gridWindow, attribute: .Width, multiplier: 1, constant: 0))
                }
            } else {
                gridWindow = nil
                gridView.hidden = true
                
                let hostView = scrollView.subviews.first!
                
                hostView.addSubview(gridView)
                hostView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[gridView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["gridView" : gridView]))
                hostView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[gridView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["gridView" : gridView]))
            }
        }
    }
    var gridWindow: UIWindow!
    
    var seedMatrix = TupleMatrix(width: 50, height: 50)
    var currentMatrix: TupleMatrix!
    let editingGridView = MatrixEditorView<TupleMatrix>()
    var gridView: MatrixPlayerView<TupleMatrix>!
    
    var timer: NSTimer?
    var idleTimer: NSTimer?
    
    var scrollView: UIScrollView!
    var minimap: MiniMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blackColor()
        
        // ** Scroll view **
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.delegate = self
        view.addSubview(scrollView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[scroll]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scroll" : scrollView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scroll]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scroll" : scrollView]))
        scrollView.contentSize = CGSizeMake(CGFloat(seedMatrix.width) * 15, CGFloat(seedMatrix.height) * 15)
        
        let contectFrame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height)
        
        // ** View to zoom **
        let zoomView = UIView()
        zoomView.frame = contectFrame
        scrollView.addSubview(zoomView)
        
        // ** Editor **
        editingGridView.matrix = seedMatrix
        editingGridView.matrixUpdated = { matrix in
            self.seedMatrix = matrix
            self.stopAnimation()
            if self.gridScreen != UIScreen.mainScreen() {
                self.startAnimation()
            }
        }
        editingGridView.frame = contectFrame
        zoomView.addSubview(editingGridView)
        
        // ** Minimap **
        minimap = MiniMapView()
        minimap.alpha = 0.6
        minimap.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(minimap)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-10-[map(==60)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["map" : minimap]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[map(==60)]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["map" : minimap]))
        
        // ** Setup screen **
        gridScreen = UIScreen.mainScreen()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupOutputScreen()
    }
    
    func startAnimation() {
        idleTimer?.invalidate()
        idleTimer = nil
        timer?.invalidate()
        timer = nil
        currentMatrix = seedMatrix
        gridView.matrix = currentMatrix
        if gridScreen == UIScreen.mainScreen() {
            gridView.hidden = false
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(ViewController.nextGeneration), userInfo: nil, repeats: true)
    }
    
    func stopAnimation() {
        timer?.invalidate()
        timer = nil
        idleTimer?.invalidate()
        idleTimer = nil
        idleTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewController.startAnimation), userInfo: nil, repeats: true)
        if gridScreen == UIScreen.mainScreen() {
            gridView.hidden = true
        }
    }
    
    func nextGeneration() {
        currentMatrix = currentMatrix.incrementedGeneration()
        
        if currentMatrix == gridView.matrix {
            timer?.invalidate()
            timer = nil
        }
        
        gridView.matrix = currentMatrix
    }
    
    func setupOutputScreen() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.screenDidConnect(_:)), name: UIScreenDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.screenDidDisconnect(_:)), name: UIScreenDidDisconnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.screenModeDidChange(_:)), name: UIScreenModeDidChangeNotification, object: nil)
        // Setup screen mirroring for an existing screen
        let connectedScreens = UIScreen.screens()
        if connectedScreens.count > 1 {
            if let screen = connectedScreens.filter({ x in x != UIScreen.mainScreen() }).first {
                setupMirroringForScreen(screen)
            }
        }
    }
    
    func setupMirroringForScreen(screen: UIScreen) {
        // Find max resolution
        var max: (CGFloat, CGFloat) = (0.0, 0.0)
        var maxScreenMode: UIScreenMode?
        
        for current in screen.availableModes {
            if maxScreenMode == nil || current.size.height > max.1 || current.size.width > max.0 {
                max = (current.size.width, current.size.height)
                maxScreenMode = current
            }
        }
        
        screen.currentMode = maxScreenMode
        
        self.gridScreen = screen
    }
    
    func disableMirroringOnCurrentScreen() {
        self.gridScreen = UIScreen.mainScreen()
    }
    
    func screenDidConnect(notification: NSNotification) {
        print("A screen connected: \(notification.object)")
        if let screen = notification.object as? UIScreen {
            setupMirroringForScreen(screen)
        }
    }
    
    func screenDidDisconnect(notification: NSNotification) {
        print("A screen was disconnected: \(notification.object)")
        disableMirroringOnCurrentScreen()
    }
    
    func screenModeDidChange(notification: NSNotification) {
        print("A screen mode changed: \(notification.object)")
        disableMirroringOnCurrentScreen()
        if let screen = notification.object as? UIScreen {
            setupMirroringForScreen(screen)
        }
    }
    
    private func updateMiniMap() {
        var viewport = scrollView.bounds
        viewport.origin.x = scrollView.contentOffset.x
        viewport.origin.y = scrollView.contentOffset.y
        minimap.renderMiniMap(viewport, worldSize: scrollView.contentSize)
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first!
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateMiniMap()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateMiniMap()
    }
}

class MiniMapView: UIView {
    
    override var backgroundColor: UIColor? {
        didSet { super.backgroundColor = backgroundColor; setNeedsDisplay() }
    }
    
    var viewportColor = UIColor.redColor() {
        didSet { setNeedsDisplay() }
    }
    
    private var viewport = CGRect.zero
    private var worldSize = CGSize.zero
    
    func renderMiniMap(viewport: CGRect, worldSize: CGSize) {
        self.viewport = viewport
        self.worldSize = worldSize
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, backgroundColor?.CGColor ?? UIColor.blackColor().CGColor)
        CGContextFillRect(context, rect)
        
        // Scale
        let scaleX = rect.width / worldSize.width
        let scaleY = rect.height / worldSize.height
        
        let scaledRect = CGRect(x: max(min(viewport.origin.x * scaleX, rect.width), 0),
                                y: max(min(viewport.origin.y * scaleY, rect.height), 0),
                                width: viewport.width * scaleX,
                                height: viewport.height * scaleY)
        
        CGContextSetLineWidth(context, 1)
        CGContextSetStrokeColorWithColor(context, viewportColor.CGColor)
        CGContextAddRect(context, scaledRect)
        CGContextStrokePath(context)
    }
    
    // Pass through any touches
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return false
    }
}
