//
//  ViewController.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 2015-07-26.
//  Copyright © 2015 nearedge. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var minimap: MinimapView!
    @IBOutlet weak var playPauseButton: RoundedButton!
    @IBOutlet weak var tempoButton: UIButton!
    @IBOutlet weak var rightStackView: UIStackView!
    @IBOutlet weak var saveLoadStackView: UIStackView!
    @IBOutlet weak var airPlayLabel: UILabel!
    
    fileprivate let tempoOptions: [(String, TimeInterval)] = [("1x", 1),
                                                            ("2x", 0.5),
                                                            ("4x", 0.25)]
    fileprivate var currentTempoIndex = 0
    
    fileprivate var gridScreen: UIScreen! {
        didSet {
            if gridScreen != .main {
                gridWindow = UIWindow(frame: gridScreen.bounds)
                gridWindow.layer.contentsGravity = kCAGravityResizeAspect
                gridWindow.screen = gridScreen
                gridWindow.isHidden = false
                
                airPlayLabel.isHidden = false
                
                gridView.showGrid = false
                
                //gridWindow.addSubview(gridView)
                gridWindow.addConstraint(NSLayoutConstraint(item: gridView, attribute: .width, relatedBy: .equal, toItem: gridView, attribute: .height, multiplier: 1, constant: 0))
                gridWindow.addConstraint(NSLayoutConstraint(item: gridView, attribute: .centerX, relatedBy: .equal, toItem: gridWindow, attribute: .centerX, multiplier: 1, constant: 0))
                gridWindow.addConstraint(NSLayoutConstraint(item: gridView, attribute: .centerY, relatedBy: .equal, toItem: gridWindow, attribute: .centerY, multiplier: 1, constant: 0))
                
                if gridWindow.frame.height < gridWindow.frame.width {
                    gridWindow.addConstraint(NSLayoutConstraint(item: gridView, attribute: .height, relatedBy: .equal, toItem: gridWindow, attribute: .height, multiplier: 1, constant: 0))
                } else {
                    gridWindow.addConstraint(NSLayoutConstraint(item: gridView, attribute: .width, relatedBy: .equal, toItem: gridWindow, attribute: .width, multiplier: 1, constant: 0))
                }
            } else {
                airPlayLabel.isHidden = true
                gridWindow = nil
                gridView.showGrid = true
                
                containerView.presentScene(editingGridView)
            }
        }
    }
    fileprivate var gridWindow: UIWindow!
    
    fileprivate var seedMatrix = TupleMatrix(width: 100, height: 100)
    fileprivate var currentMatrix: TupleMatrix!
    fileprivate var editingGridView: SKMatrixView<TupleMatrix>!
    fileprivate var gridView: SKMatrixView<TupleMatrix>!
    
    fileprivate var timer: Timer?
    
    fileprivate var isPlaying: Bool {
        return timer != nil
    }
    
    fileprivate var containerView = SKView()
    
    fileprivate var displayedModal: UIViewController?
    fileprivate var modalShadowView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveLoadStackView.isHidden = true
        
        // ** Scroll view **
        scrollView.contentSize = CGSize(width: CGFloat(seedMatrix.width) * 16, height: CGFloat(seedMatrix.height) * 16)
        
        // ** View to zoom **
        containerView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        containerView.ignoresSiblingOrder = false
        scrollView.addSubview(containerView)
        
        // ** Editor **
        editingGridView = SKMatrixView(size: containerView.frame.size)
        editingGridView.matrix = seedMatrix
        editingGridView.showGrid = true
        editingGridView.matrixUpdated = { matrix in
            self.seedMatrix = matrix
            self.playPauseButton.isEnabled = !matrix.isEmpty
        }
        
        // ** "Player" view
        gridView = SKMatrixView(size: containerView.frame.size)
        gridView.matrix = seedMatrix
        gridView.showGrid = true
        gridView.isUserInteractionEnabled = false
        
        // ** Minimap **
        minimap.layer.borderColor = UIColor.white.cgColor
        minimap.layer.borderWidth = 1
        minimap.layer.cornerRadius = 2
        minimap.viewportColor = UIColor(white: 1, alpha: 0.5)
        
        // ** Setup screen **
        gridScreen = UIScreen.main
        
        // ** Setup menu **
        playPauseButton.isEnabled = false
        setUpMenuIsPlaying(isPlaying)
        
        // ** Modal **
        modalShadowView.backgroundColor = .black
        modalShadowView.isHidden = true
        modalShadowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissCurrentModal)))
        view.wrapSubview(modalShadowView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupOutputScreen()
        updateMiniMap()
    }
    
    func dismissCurrentModal() {
        displayedModal?.willMove(toParentViewController: nil)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            if let displayedModal = self.displayedModal {
                var rect = displayedModal.view.frame
                rect.origin.y += self.view.frame.height + 10
                displayedModal.view.frame = rect
            }
            self.modalShadowView.alpha = 0
        }) { _ in
            self.displayedModal?.removeFromParentViewController()
            self.displayedModal?.didMove(toParentViewController: nil)
            self.displayedModal?.view.removeFromSuperview()
            self.displayedModal = nil
            self.modalShadowView.isHidden = true
        }
    }
    
    func nextGeneration() {
        currentMatrix = currentMatrix.incrementedGeneration()
        
        guard currentMatrix != gridView.matrix else {
            playButtonTapped(playPauseButton)
            return
        }
        
        gridView.matrix = currentMatrix
    }
    
    // MARK: User interaction
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if isPlaying {
            timer?.invalidate()
            timer = nil
            gridView.matrix = seedMatrix
            containerView.presentScene(editingGridView)
        } else {
            currentMatrix = seedMatrix
            gridView.matrix = currentMatrix
            containerView.presentScene(gridView)
            restartTimer()
        }
        
        setUpMenuIsPlaying(isPlaying)
    }
    
    @IBAction func tempoButtonTapped(_ sender: UIButton) {
        currentTempoIndex += 1
        if currentTempoIndex >= tempoOptions.count {
            currentTempoIndex = 0
        }
        if isPlaying { restartTimer() }
        tempoButton.setTitle(tempoOptions[currentTempoIndex].0, for: UIControlState())
    }
    
    @IBAction func aboutButtonTapped(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "about") else { return }
        presentModal(viewController: vc)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func loadButtonTapped(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "load") else { return }
        presentModal(viewController: vc)
    }

    
    // MARK: Privates
    fileprivate func presentModal(viewController vc: UIViewController, size: CGSize? = CGSize(width: 320, height: 500)) {
        assert(displayedModal == nil)
        guard let size = size else { return }
        
        displayedModal = vc
        
        vc.willMove(toParentViewController: self)
        addChildViewController(vc)
        
        vc.view.layer.cornerRadius = 5
        vc.view.layer.borderColor = UIColor.white.cgColor
        vc.view.layer.borderWidth = 1
        
        vc.view.frame = CGRect(x: view.frame.width / 2 - size.width / 2, y: view.frame.height + 10, width: size.width, height: size.height)
        
        view.addSubview(vc.view)
        modalShadowView.alpha = 0
        modalShadowView.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            var rect = vc.view.frame
            rect.origin.y = self.view.frame.height / 2 - rect.height / 2
            vc.view.frame = rect
            self.modalShadowView.alpha = 0.6
        }) { _ in
            vc.didMove(toParentViewController: self)
        }
    }
    
    fileprivate func restartTimer() {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: tempoOptions[currentTempoIndex].1,
                                                       target: self,
                                                       selector: #selector(ViewController.nextGeneration),
                                                       userInfo: nil,
                                                       repeats: true)
        
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    fileprivate func setUpMenuIsPlaying(_ isPlaying: Bool) {
        playPauseButton.setTitle(isPlaying ? "Stop" : "Play", for: UIControlState())
        rightStackView.isHidden = isPlaying
    }
    
    fileprivate func setupOutputScreen() {
        let nc = NotificationCenter.default
        nc.addObserver(forName: NSNotification.Name.UIScreenDidConnect, object: nil, queue: nil) { notification in
            if let screen = notification.object as? UIScreen {
                self.setupMirroringForScreen(screen)
            }
        }
        
        nc.addObserver(forName: NSNotification.Name.UIScreenDidDisconnect, object: nil, queue: nil) { notification in
            self.disableMirroringOnCurrentScreen() // Check if correct screen?
        }
        
        nc.addObserver(forName: NSNotification.Name.UIScreenModeDidChange, object: nil, queue: nil) { notification in
            self.disableMirroringOnCurrentScreen() // Check if correct screen?
            if let screen = notification.object as? UIScreen {
                self.setupMirroringForScreen(screen)
            }
        }

        // Setup screen mirroring for an existing screen
        let connectedScreens = UIScreen.screens
        if connectedScreens.count > 1 {
            if let screen = connectedScreens.filter({ x in x != UIScreen.main }).first {
                setupMirroringForScreen(screen)
            }
        }
    }
    
    fileprivate func setupMirroringForScreen(_ screen: UIScreen) {
        // Find max resolution
        var max: (CGFloat, CGFloat) = (0.0, 0.0)
        var maxScreenMode: UIScreenMode?
        
        if !screen.availableModes.isEmpty {
            for current in screen.availableModes {
                if maxScreenMode == nil || current.size.height > max.1 || current.size.width > max.0 {
                    max = (current.size.width, current.size.height)
                    maxScreenMode = current
                }
            }
            
            screen.currentMode = maxScreenMode
        }
            
        self.gridScreen = screen
    }
    
    fileprivate func disableMirroringOnCurrentScreen() {
        self.gridScreen = UIScreen.main
    }
    
    fileprivate func updateMiniMap() {
        var viewport = scrollView.bounds
        viewport.origin.x = scrollView.contentOffset.x
        viewport.origin.y = scrollView.contentOffset.y
        minimap.renderMinimap(viewport, worldSize: scrollView.contentSize)
    }
}

extension GameOfLifeMatrix {
    func save(storedName name: String) throws {
        var saved = UserDefaults.standard.dictionary(forKey: "saved-layouts") ?? [:]
        guard saved[name] == nil else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        saved[name] = ["w" : width, "h" : height, "a" : activeCells.map { [$0.x, $0.y] }]
    }
    
    init?(storedName name: String) {
        guard let dic = UserDefaults.standard.dictionary(forKey: "saved-layouts")?[name] as? [String : AnyObject] else {
            return nil
        }
        guard let w = dic["w"] as? Int, let h = dic["h"] as? Int, let a = dic["a"] as? [[Int]] else {
            return nil
        }
        self.init(width: w, height: h, active: Set(a.map { Point(x: $0[0] , y: $0[1] ) }))
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first!
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateMiniMap()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateMiniMap()
    }
}
