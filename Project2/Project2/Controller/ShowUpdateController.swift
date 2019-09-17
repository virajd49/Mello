//
//  ShowUpdateController.swift
//  Project2
//
//  Created by virdeshp on 7/27/18.
//  Copyright © 2018 Viraj. All rights reserved.
//


import UIKit
import QuartzCore
import MediaPlayer

class ShowUpdateController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, YTPlayerViewDelegate {
    
    
    //this should have the spotify apple and youtube players
    var song_name: String!
    var player: String?
    var albumArt_string: String?
    var duration: Float!
    var timer : Timer!
    var Spotifyplayer =  SPTAudioStreamingController.sharedInstance()
    let apple_music_player = MPMusicPlayerController.applicationMusicPlayer
    var youtubeplayer: YTPlayerView?
    var test_view: UIView?
    
    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var playBar: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //youtubeplayer = YTPlayerView(frame: CGRect(origin: CGPoint(x: 37, y: 94), size: CGSize(width: 300, height: 300))
        self.Spotifyplayer?.playbackDelegate = self as SPTAudioStreamingPlaybackDelegate
        self.Spotifyplayer?.delegate = self as SPTAudioStreamingDelegate
        
        let tapGesture = UISwipeGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        tapGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(tapGesture)
        
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        containerView.clipsToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 10
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 10).cgPath
        
        containerView.isHidden = true
        albumArt.layer.cornerRadius = 10
        
        
      
        self.view.bringSubview(toFront: youtubeplayer!)
        albumArt.image = UIImage(named: albumArt_string!)
        /*
        self.test_view = UIView(frame: CGRect(origin: CGPoint(x:37, y:94), size: CGSize(width: 300, height: 300)))
        
        self.view.addSubview(test_view!)
        self.test_view?.backgroundColor = UIColor.white
        self.view.bringSubview(toFront: test_view!)
        */
        //self.playerView.layer.cornerRadius = 10
        
        
        //playBar = UIProgressView(frame: CGRect(origin: CGPoint(x:67, y:42), size: CGSize(width: 203, height: 2)))
        //self.playBar.progressTintColor = UIColor.darkGray
        //self.playBar.trackTintColor = UIColor.lightGray
        self.playBar.progress = 0.0
        //self.addSubview(playBar)
        duration = 60
        
        play_update()
        
    }
    
    @objc func tapEdit(recognizer: UITapGestureRecognizer){
        stop_with_dismiss()
    }
    
    @IBAction func Dismiss(_ sender: Any) {
        stop_with_dismiss()
    }
    
    
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = self
        //vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindowLevelAlert + 1
        win.makeKeyAndVisible()
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
        //vc.present(self, animated: true, completion: nil)
    }
    
     @objc func updateProgress() {
        
        self.playBar.progress += 0.00005/(self.duration)
        
        if self.playBar.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.playBar.progress = 0.0
            self.Spotifyplayer?.setIsPlaying(false, callback: { (error) in
                if (error == nil) {
                    print("paused")
                    //self.timer?.invalidate()
                    //self.offsetvalue = (self.Spotifyplayer!.playbackState.position)
                }
                else {
                    print ("error in pausing!")
                }
            })
            
            
        }
        
    }
    
    func youtube_player_setup() {
        self.youtubeplayer = YTPlayerView.init(frame: CGRect(origin: CGPoint(x:37, y:94), size: CGSize(width: 300, height: 300)))
        self.youtubeplayer?.delegate = self
        self.youtubeplayer?.contentMode = UIViewContentMode.scaleAspectFill
        self.view.addSubview(youtubeplayer!)
        self.youtubeplayer?.backgroundColor = UIColor.white
        self.youtubeplayer?.clipsToBounds = true
        self.youtubeplayer?.layer.cornerRadius = 10
        
    }
    
    
    
    func play_update() {
        
        switch (player) {
        
        case "Spotify": self.Spotifyplayer?.playSpotifyURI(self.song_name, startingWith: 0, startingWithPosition: 10.0, callback: { (error) in
            if (error == nil) {
                print("playing!")
                print(self.Spotifyplayer?.metadata.currentTrack?.name)
                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
                self.updateProgress()
            }
            
        })
            break
            
        case "Apple":
            self.apple_music_player.setQueue(with: [self.song_name])
            self.apple_music_player.play()
            break
        case "Youtube":
            self.youtubeplayer?.playVideo()
            break
        default:
            print("Invalid player type")
            break
            
            
        }
        
    }
    
    func stop_with_dismiss(){
        
        switch (player) {
            
        case "Spotify":
        
        self.timer?.invalidate()
        self.playBar.progress = 0.0
        self.Spotifyplayer?.setIsPlaying(false, callback: { (error) in
            if (error == nil) {
                print("paused")
                //self.timer?.invalidate()
                //self.offsetvalue = (self.Spotifyplayer!.playbackState.position)
            }
            else {
                print ("error in pausing!")
            }
        })
            break
            
        case "Apple":
            self.apple_music_player.stop()
            break
        case "Youtube":
            self.youtubeplayer?.stopVideo()
            break
        default:
            print("Invalid player type")
            break
            
            
        }
        dismiss(animated: true, completion: nil)
        
    }
    
}
