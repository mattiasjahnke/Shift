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
    let editingGridView = MatrixView<TupleMatrix>()
    var gridView = MatrixView<TupleMatrix>()
    
    var timer: NSTimer?
    var idleTimer: NSTimer?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var minimap: MinimapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ** Scroll view **
        scrollView.contentSize = CGSizeMake(CGFloat(seedMatrix.width) * 15, CGFloat(seedMatrix.height) * 15)
        
        // ** View to zoom **
        let zoomView = UIView(frame: CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height))
        scrollView.addSubview(zoomView)
        
        // ** Editor **
        editingGridView.matrix = seedMatrix
        editingGridView.showGrid = true
        editingGridView.matrixUpdated = { matrix in
            self.seedMatrix = matrix
            self.stopAnimation()
            if self.gridScreen != UIScreen.mainScreen() {
                self.startAnimation()
            }
        }
        editingGridView.frame = zoomView.bounds
        zoomView.addSubview(editingGridView)
        
        // ** "Player" view
        gridView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.stopAnimation)))
        gridView.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        guard currentMatrix != gridView.matrix else {
            timer?.invalidate()
            timer = nil
            return
        }
        
        gridView.matrix = currentMatrix
    }
    
    private func setupOutputScreen() {
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserverForName(UIScreenDidConnectNotification, object: nil, queue: nil) { notification in
            if let screen = notification.object as? UIScreen {
                self.setupMirroringForScreen(screen)
            }
        }
        
        nc.addObserverForName(UIScreenDidDisconnectNotification, object: nil, queue: nil) { notification in
            self.disableMirroringOnCurrentScreen() // Check if correct screen?
        }
        
        nc.addObserverForName(UIScreenModeDidChangeNotification, object: nil, queue: nil) { notification in
            self.disableMirroringOnCurrentScreen() // Check if correct screen?
            if let screen = notification.object as? UIScreen {
                self.setupMirroringForScreen(screen)
            }
        }

        // Setup screen mirroring for an existing screen
        let connectedScreens = UIScreen.screens()
        if connectedScreens.count > 1 {
            if let screen = connectedScreens.filter({ x in x != UIScreen.mainScreen() }).first {
                setupMirroringForScreen(screen)
            }
        }
    }
    
    private func setupMirroringForScreen(screen: UIScreen) {
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
    
    private func disableMirroringOnCurrentScreen() {
        self.gridScreen = UIScreen.mainScreen()
    }
    
    private func updateMiniMap() {
        var viewport = scrollView.bounds
        viewport.origin.x = scrollView.contentOffset.x
        viewport.origin.y = scrollView.contentOffset.y
        minimap.renderMinimap(viewport, worldSize: scrollView.contentSize)
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
