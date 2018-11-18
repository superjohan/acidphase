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
    let qtFoolingBgView: UIView = UIView.init(frame: CGRect.zero)

    private let rotatedView = UIView(frame: .zero)

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
        
        self.startButton.addTarget(self, action: #selector(startButtonTouched), for: UIControl.Event.touchUpInside)
        
        self.view.backgroundColor = .black
        
        self.qtFoolingBgView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        // barely visible tiny view for fooling Quicktime player. completely black images are ignored by QT
        self.view.addSubview(self.qtFoolingBgView)
        
        self.view.addSubview(self.rotatedView)

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
        
        self.rotatedView.backgroundColor = .black
        let length = self.view.bounds.size.height * 0.6
        self.rotatedView.frame = CGRect(
            x: (self.view.bounds.size.width / 2.0) - (length / 2.0),
            y: (self.view.bounds.size.height / 2.0) - (length / 2.0),
            width: length,
            height: length
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.audioPlayer.stop()
    }
    
    // MARK: - Private
    
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
        self.view.backgroundColor = .white

        self.audioPlayer.play()
        
        rotate(view: self.rotatedView, from: 0, to: CGFloat.pi * 2.0, duration: 240)
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
