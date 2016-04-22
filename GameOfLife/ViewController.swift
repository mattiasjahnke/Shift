//
//  ViewController.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 2015-07-26.
//  Copyright © 2015 nearedge. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var gridScreen = UIScreen.mainScreen() {
        didSet {
            gridView.removeFromSuperview()
            
            gridView = BasicMatrixView()
            
            if gridScreen != UIScreen.mainScreen() {
                gridWindow = UIWindow(frame: gridScreen.bounds)
                gridWindow!.layer.contentsGravity = kCAGravityResizeAspect
                gridWindow!.screen = gridScreen
                gridWindow!.hidden = false
            } else {
                gridWindow = nil
                gridView.hidden = true
            }
            
            gridView.mode = .Display
            
            let gridHostView = gridWindow ?? self.view
            
            gridView.translatesAutoresizingMaskIntoConstraints = false
            gridHostView!.addSubview(gridView)
            gridHostView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[gridView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["gridView" : gridView]))
            gridHostView!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[gridView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["gridView" : gridView]))
            
            gridView.matrix = seedMatrix
        }
    }
    var gridWindow: UIWindow?
    
    var seedMatrix = Matrix(rows: 30, columns: 30)
    
    var gridView = BasicMatrixView() {
        didSet {
            gridView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.stopAnimation)))
        }
    }
    var editingGridView = BasicMatrixView()
    
    var timer: NSTimer?
    var idleTimer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        editingGridView.translatesAutoresizingMaskIntoConstraints = false
        editingGridView.mode = .Edit
        view.addSubview(editingGridView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[editingGridView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["editingGridView" : editingGridView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[editingGridView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["editingGridView" : editingGridView]))
        editingGridView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.tap(_:))))
        
        seedMatrix = Matrix(rows: Int(self.view.frame.width / 10), columns: Int(self.view.frame.height / 10))
        editingGridView.matrix = seedMatrix
        
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
        gridView.matrix = seedMatrix
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
        //let lastGen = gridView.matrix
        gridView.matrix = gridView.matrix!.getNextGeneration()
        // TODO: Add a comparator in order to know if the simulation is halted (lastgen == gen)
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        if let position = editingGridView.cellPointAtPoint(gesture.locationInView(gesture.view!), rect: self.view.frame) {
            stopAnimation()
            seedMatrix[Int(position.y), Int(position.x)] = !seedMatrix[Int(position.y), Int(position.x)]
            editingGridView.matrix = seedMatrix
            if gridScreen != UIScreen.mainScreen() {
                startAnimation()
            }
        }
    }
}

extension ViewController {
    
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
}

