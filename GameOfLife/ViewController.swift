//
//  ViewController.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 2015-07-26.
//  Copyright © 2015 nearedge. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var minimap: MinimapView!
    @IBOutlet weak var playPauseButton: RoundedButton!
    @IBOutlet weak var tempoButton: UIButton!
    @IBOutlet weak var rightStackView: UIStackView!
    
    private let tempoOptions: [(String, NSTimeInterval)] = [("1x", 1),
                                                            ("2x", 0.5),
                                                            ("4x", 0.25)]
    private var currentTempoIndex = 0
    
    private var gridScreen: UIScreen! {
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
    private var gridWindow: UIWindow!
    
    private var seedMatrix = TupleMatrix(width: 50, height: 50)
    private var currentMatrix: TupleMatrix!
    private let editingGridView = MatrixView<TupleMatrix>()
    private var gridView = MatrixView<TupleMatrix>()
    
    private var timer: NSTimer?
    private var idleTimer: NSTimer?
    
    private var isPlaying: Bool {
        return timer != nil
    }
    
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
            //self.stopAnimation()
            /*if self.gridScreen != UIScreen.mainScreen() {
                self.startAnimation()
            }*/
            self.playPauseButton.enabled = !matrix.isEmpty
        }
        editingGridView.frame = zoomView.bounds
        zoomView.addSubview(editingGridView)
        
        // ** "Player" view
        //gridView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.stopAnimation)))
        gridView.translatesAutoresizingMaskIntoConstraints = false
        gridView.showGrid = true
        
        // ** Minimap **
        minimap.layer.borderColor = UIColor.whiteColor().CGColor
        minimap.layer.borderWidth = 1
        minimap.layer.cornerRadius = 2
        minimap.viewportColor = UIColor(white: 1, alpha: 0.5)
        
        // ** Setup screen **
        gridScreen = UIScreen.mainScreen()
        
        // Setup menu
        playPauseButton.enabled = false
        setUpMenuIsPlaying(isPlaying)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupOutputScreen()
        updateMiniMap()
    }
    /*
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
    }*/
    
    func nextGeneration() {
        currentMatrix = currentMatrix.incrementedGeneration()
        
        guard currentMatrix != gridView.matrix else {
            playButtonTapped(playPauseButton)
            return
        }
        
        gridView.matrix = currentMatrix
    }
    
    // MARK: User interaction
    @IBAction func playButtonTapped(sender: UIButton) {
        if isPlaying {
            timer?.invalidate()
            timer = nil
            gridView.matrix = seedMatrix
            if gridScreen == UIScreen.mainScreen() {
                gridView.hidden = true
            }
        } else {
            currentMatrix = seedMatrix
            gridView.matrix = currentMatrix
            if gridScreen == UIScreen.mainScreen() {
                gridView.hidden = false
            }
            restartTimer()
        }
        
        setUpMenuIsPlaying(isPlaying)
    }
    
    @IBAction func tempoButtonTapped(sender: UIButton) {
        currentTempoIndex += 1
        if currentTempoIndex >= tempoOptions.count {
            currentTempoIndex = 0
        }
        if isPlaying { restartTimer() }
        tempoButton.setTitle(tempoOptions[currentTempoIndex].0, forState: .Normal)
    }
    
    @IBAction func aboutButtonTapped(sender: UIButton) {
        
    }
    
    @IBAction func saveButtonTapped(sender: UIButton) {
        
    }
    
    @IBAction func loadButtonTapped(sender: UIButton) {
        
    }
    
    
    // MARK: Privates
    private func restartTimer() {
        timer?.invalidate()
        timer = nil
        timer = NSTimer.scheduledTimerWithTimeInterval(tempoOptions[currentTempoIndex].1,
                                                       target: self,
                                                       selector: #selector(ViewController.nextGeneration),
                                                       userInfo: nil,
                                                       repeats: true)
    }
    
    private func setUpMenuIsPlaying(isPlaying: Bool) {
        playPauseButton.setTitle(isPlaying ? "Stop" : "Play", forState: .Normal)
        rightStackView.hidden = isPlaying
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
