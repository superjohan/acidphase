//
//  ViewController.swift
//  demo
//
//  Created by Johan Halin on 12/03/2018.
//  Copyright © 2018 Dekadence. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController {
    let audioPlayer: AVAudioPlayer
    let startButton: UIButton
    let contentView: UIView = UIView.init(frame: .zero)
    let qtFoolingBgView: UIView = UIView.init(frame: CGRect.zero)

    private let sequenceCount = 260
    private let rotatedViewCount = 7
    
    private var rotatedViews = [ShufflingView]()
    private var sequences = [[Board]]()
    private var sequenceCounter = 0
    
    // MARK: - UIViewController
    
    init() {
        if let trackUrl = Bundle.main.url(forResource: "audio", withExtension: "m4a") {
            guard let audioPlayer = try? AVAudioPlayer(contentsOf: trackUrl) else {
                abort()
            }
            
            self.audioPlayer = audioPlayer
        } else {
            abort()
        }
        
        let startButtonText =
            "\"literal acid phase\"\n" +
                "by dekadence\n" +
                "\n" +
                "programming and music by ricky martin\n" +
                "\n" +
                "presented at vortex 2018\n" +
                "\n" +
        "tap anywhere to start"
        self.startButton = UIButton.init(type: UIButton.ButtonType.custom)
        self.startButton.setTitle(startButtonText, for: UIControl.State.normal)
        self.startButton.titleLabel?.numberOfLines = 0
        self.startButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.startButton.backgroundColor = UIColor.black
        
        super.init(nibName: nil, bundle: nil)
        
        createBoards()
        
        self.startButton.addTarget(self, action: #selector(startButtonTouched), for: UIControl.Event.touchUpInside)
        
        self.view.backgroundColor = .black
        
        self.qtFoolingBgView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        // barely visible tiny view for fooling Quicktime player. completely black images are ignored by QT
        self.view.addSubview(self.qtFoolingBgView)
        
        self.contentView.backgroundColor = .white
        self.contentView.isHidden = true
        self.view.addSubview(self.contentView)
        
        for _ in 0..<self.rotatedViewCount {
            let rotatedView = ShufflingView(frame: .zero)
            self.rotatedViews.append(rotatedView)
            self.contentView.addSubview(rotatedView)
        }

        self.view.addSubview(self.startButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.audioPlayer.prepareToPlay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.qtFoolingBgView.frame = CGRect(
            x: (self.view.bounds.size.width / 2) - 1,
            y: (self.view.bounds.size.height / 2) - 1,
            width: 2,
            height: 2
        )

        self.startButton.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        
        self.contentView.frame = self.view.bounds
        
        for rotatedView in self.rotatedViews {
            let length = self.contentView.bounds.size.height * 0.6
            rotatedView.frame = CGRect(
                x: (self.contentView.bounds.size.width / 2.0) - (length / 2.0),
                y: (self.contentView.bounds.size.height / 2.0) - (length / 2.0),
                width: length,
                height: length
            )
            
            rotatedView.adjustViews(toBoard: Board.initialBoard(), animated: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.audioPlayer.stop()
    }
    
    // MARK: - Private
    
    private func createBoards() {
        var baseBoards = [Board]()
        baseBoards.append(Board.boardByMovingOnePosition(fromBoard: Board.initialBoard()))
        
        for i in 1..<self.sequenceCount {
            let previousBoard = baseBoards[i - 1]
            baseBoards.append(Board.boardByMovingOnePosition(fromBoard: previousBoard))
        }
        
        self.sequences.append(baseBoards)
        
        for _ in 1..<8 {
            self.sequences.append(baseBoards)
        }
    }
    
    @objc
    fileprivate func startButtonTouched(button: UIButton) {
        self.startButton.isUserInteractionEnabled = false
        
        // long fadeout to ensure that the home indicator is gone
        UIView.animate(withDuration: 4, animations: {
            self.startButton.alpha = 0
        }, completion: { _ in
            self.start()
        })
    }
    
    fileprivate func start() {
        self.audioPlayer.play()
        
        self.contentView.isHidden = false
        
        let totalDuration = 240.0
        let durationDelta = 7.0
        
        for (index, rotatedView) in self.rotatedViews.enumerated() {
            let duration = TimeInterval(totalDuration - (Double(index) * durationDelta))
            rotate(view: rotatedView, from: 0, to: CGFloat.pi * 2.0, duration: duration)
        }
        
        scheduleEvents()
    }
    
    private func scheduleEvents() {
        let interval = 120.0 / 130.0
        var position = -0.1
        var counter = 1
        
        while counter < self.sequenceCount {
            position = Double(counter) * interval
            perform(#selector(refreshBoards), with: nil, afterDelay: position)
            
            counter += 1
        }
        
        position = Double(counter) * interval
        perform(#selector(resetBoards), with: nil, afterDelay: position)
    }
    
    @objc
    private func refreshBoards() {
        for (index, rotatedView) in self.rotatedViews.enumerated() {
            let sequence = self.sequences[index]
            let board = sequence[self.sequenceCounter]
            
            rotatedView.adjustViews(toBoard: board, animated: true)
        }

        self.sequenceCounter += 1
    }
    
    @objc
    private func resetBoards() {
        for rotatedView in self.rotatedViews {
            rotatedView.adjustViews(toBoard: Board.initialBoard(), animated: true)
        }
    }
    
    private func rotate(view: UIView, from: CGFloat, to: CGFloat, duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = NSNumber(floatLiteral: Double(from))
        animation.toValue = NSNumber(floatLiteral: Double(to))
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        view.layer.add(animation, forKey: "rotation")
    }
}
