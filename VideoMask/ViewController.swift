//
//  ViewController.swift
//  VideoMask
//
//  Created by SHUVO on 9/6/16.
//  Copyright © 2016 SHUVO. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


class ViewController: UIViewController {
    
    var player = AVPlayer()
    var playerViewController = AVPlayerViewController()
    var playerLayer = AVPlayerLayer()
    @IBOutlet weak var playPauseBtn: UIButton!
    var timeObserver: Any!
    @IBOutlet weak var timeRemainingLbl: UILabel!
    @IBOutlet weak var slider: UISlider!
    var playerRateBeforeSeek: Float = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.orientationChanged(notification:)),
            name: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil)
        
        
        let path = Bundle.main.path(forResource: "SampleVideo", ofType: "mp4")
        let url = NSURL(fileURLWithPath: path!)
        player = AVPlayer(url: url as URL)
        playerLayer.player = player
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        let diameter = min(self.view.frame.size.width, self.view.frame.size.height) * 0.8;
        playerLayer.frame = CGRect(x :(self.view.frame.size.width - diameter) / 2,
                                   y :(self.view.frame.size.height - diameter) / 2,
                                   width :diameter, height :diameter);
        playerLayer.cornerRadius = diameter / 2;
        playerLayer.masksToBounds = true;
        self.view.layer.addSublayer(playerLayer)
        
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1,1)
        timeObserver = player.addPeriodicTimeObserver(forInterval: timeInterval,
                                                                   queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in
                                                                    self.observeTime(elapsedTime: elapsedTime)
        }
        
        slider.value = 0.0
        slider.addTarget(self, action: #selector(sliderBeganTracking),
                         for: .touchDown)
        slider.addTarget(self, action: #selector(sliderEndedTracking),
                         for: [.touchUpInside, .touchUpOutside])
        slider.addTarget(self, action: #selector(sliderValueChanged),
                         for: .valueChanged)
        
        playPauseBtn.addTarget(self, action: #selector(playPauseBtnTapped),
                               for: .touchUpInside)
    }
    
    
    deinit {
        player.removeTimeObserver(timeObserver)
    }

    
    func playPauseBtnTapped(sender: UIButton) {
        
        let playerIsPlaying = player.rate > 0
        if playerIsPlaying {
            player.pause()
            playPauseBtn.setTitle("Play", for: UIControlState.normal)
        } else {
            player.play()
            playPauseBtn.setTitle("Pause", for: UIControlState.normal)
        }
    }
    
    
    private func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = CMTimeGetSeconds(player.currentItem!.duration) - elapsedTime
        timeRemainingLbl.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
    }
    
    
    private func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(player.currentItem!.duration)
        if duration.isFinite {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabel(elapsedTime: elapsedTime,duration: duration)
            slider.value = Float(elapsedTime/duration)
            
            if slider.value == 1.0 {
                player.rate = 0.0
                print("setting rate :\(player.rate)")
                player.seek(to: kCMTimeZero)
                player.play()
            }
        }
    }
    
    func sliderBeganTracking(slider: UISlider) {
        playerRateBeforeSeek = player.rate
        player.pause()
    }
    
    func sliderEndedTracking(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(player.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(slider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        player.seek(to: CMTimeMakeWithSeconds(elapsedTime, 100)) { (completed: Bool) -> Void in
            if self.playerRateBeforeSeek > 0 {
                self.player.play()
            }
        }
    }
    
    func sliderValueChanged(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(player.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(slider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
    }
    
    func orientationChanged(notification : NSNotification) {

        if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            let diameter = min(self.view.frame.size.width, self.view.frame.size.height) * 0.6;
            playerLayer.frame = CGRect(x :(self.view.frame.size.width - diameter) / 2,
                                       y :(self.view.frame.size.height - diameter) / 3,
                                       width :diameter, height :diameter);
            playerLayer.cornerRadius = diameter / 2;
            playerLayer.masksToBounds = true;
        }
        
        else {
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            let diameter = min(self.view.frame.size.width, self.view.frame.size.height) * 0.8;
            playerLayer.frame = CGRect(x :(self.view.frame.size.width - diameter) / 2,
                                       y :(self.view.frame.size.height - diameter) / 2,
                                       width :diameter, height :diameter);
            playerLayer.cornerRadius = diameter / 2;
            playerLayer.masksToBounds = true;
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

