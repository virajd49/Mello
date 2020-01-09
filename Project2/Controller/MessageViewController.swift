//
//  MessageViewController.swift
//  Project2
//
//  Created by virdeshp on 5/7/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import PostgresClientKit


/*
    This is still at stage zero. Been using this guy as a testing ground for a lot of things all around the app. So everything below is useless.
 
 
 
 
 
 */

class MessageViewController: UIViewController, YTPlayerViewDelegate {
    
    @IBOutlet weak var test_album_art_image: UIImageView!
    let musicPlayerController = MPMusicPlayerController.applicationMusicPlayer
    let bottomView = BottomView()
    var youtube: YTPlayerView!
    var mini_youtube: YTPlayerView!
    let alertController = UIAlertController(title: nil, message: "Takes the appearance of the bottom bar if specified; otherwise, same as UIActionSheetStyleDefault.", preferredStyle: .actionSheet)
    var pngimageView: UIImageView!
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        // ...
    }
    
    let OKAction = UIAlertAction(title: "OK", style: .default) { action in
        // ...
    }
    
    let destroyAction = UIAlertAction(title: "Destroy", style: .destructive) { action in
        print (action)
    }
    
    @IBAction func switch_players(_ sender: Any) {
        
        let time: Float = youtube.currentTime() + 2.00
        print (time)
        //mini_youtube.cueVideo(byId: "_N2xvUhqPEA", startSeconds: time, endSeconds: 120, suggestedQuality: YTPlaybackQuality.default)
        //mini_youtube.load(withVideoId: "_N2xvUhqPEA" , playerVars: ["playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 0, "controls": 1, "start": time, "end": 120, "rel": 0])
        //mini_youtube.playVideo()
        
    }
    
    @IBAction func begin_playback(_ sender: Any) {
        
        self.beginPlayback(itemID: "1224353520")
    }
    
    @IBAction func play_pause(_ sender: Any) {
        
        self.togglePlayPause()
        
    }
    
    
    
    
    @IBAction func alertbutton(_ sender: Any) {
        
        /*self.present(alertController, animated: true) {
            // ...
        }
        */
        //bottomView.bringupview(id: "")
        let time2: Float = mini_youtube.currentTime() + 2.00
        print (time2)
        //youtube.cueVideo(byId: "_N2xvUhqPEA", startSeconds: time2, endSeconds: 120, suggestedQuality: YTPlaybackQuality.default)
        youtube.load(withVideoId: "_N2xvUhqPEA" , playerVars: ["playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 0, "controls": 1, "start": time, "end": 120, "rel": 0])
        youtube.playVideo()
        
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        tapGesture.delegate = self as? UIGestureRecognizerDelegate
        test_album_art_image.addGestureRecognizer(tapGesture)
        
        //musicPlayerController.beginGeneratingPlaybackNotifications()
        youtube = YTPlayerView.init(frame: CGRect(x: 67, y: 431, width: 240, height: 128))
        //mini_youtube = YTPlayerView.init(frame: CGRect(x: 67, y: 260, width: 240, height: 128))
        
        pngimageView = UIImageView.init(frame: CGRect(x: 67, y: 260, width: 240, height: 128))
        pngimageView.image = UIImage(named: "Beatles")
        self.view.addSubview(pngimageView)
        self.view.addSubview(youtube!)
        //self.view.addSubview(mini_youtube!)
        //mini_youtube.backgroundColor = UIColor.black
        youtube.backgroundColor = UIColor.black
        youtube.delegate = self
        //mini_youtube.delegate = self
        
        //youtube.load(withVideoId: "_N2xvUhqPEA" , playerVars: ["playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 0, "controls": 1, "start": 20, "end": 120, "rel": 0])
        //mini_youtube.load(withVideoId: "_N2xvUhqPEA" , playerVars: ["playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 0, "controls": 1, "start": 20, "end": 120, "rel": 0])
        
        //youtube.currentTime()
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        alertController.addAction(destroyAction)
        
        //postgres_testing()
        print("stopping apple player")
        // musicPlayerController.stop()
        //self.animated_png()
       
    }
    
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState)
    {
        print("state changed youtube")
        switch(state){
        case YTPlayerState.unstarted:
            print("unstarted youtube")
            
            break;
        case YTPlayerState.queued:
            print("queued youtube")
            break;
        case YTPlayerState.buffering:
            print("buffering youtube")
           // musicPlayerController.stop()
            
            break;
        case YTPlayerState.ended:
            print("ended youtube")
            break;
        case YTPlayerState.playing:
            print("playing youtube")
            //self.animate_color()
            break;
        case YTPlayerState.paused:
            print("paused youtube")
        default:
            break;
            
            
        }
    }
    
    func postgres_testing () {
        
        select_postgres()
       
    }
    
    func select_postgres () {
        do {
            var configuration = PostgresClientKit.ConnectionConfiguration()
            configuration.host = "ec2-18-222-104-142.us-east-2.compute.amazonaws.com"
            //configuration.database = "example"
            configuration.user = "postgres"
            configuration.credential = .md5Password(password: "123TestDB!")
            configuration.ssl = false               // SSL/TLS is disabled    ??
            configuration.credential = .trust       //connects without authenticating   ??
            
            let connection = try PostgresClientKit.Connection(configuration: configuration)
            defer { connection.close() }
            
            let text = "SELECT cust_id, cust_name, cust_age FROM customer WHERE cust_name = $1;"
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [ "Viraj" ])
            defer { cursor.close() }
            
            for row in cursor {
                let columns = try row.get().columns
                let cust_id = try columns[0].int()
                let cust_name = try columns[1].string()
                let cust_age = try columns[2].int()
                
                
                print("""
                    cust_id: \(cust_id) cust_name: \(cust_name) cust_age: \(cust_age)
                    """)
            }
        } catch {
            print(error) // better error handling goes here
        }
    }
    
    func insert_postgres () {
        do {
            var configuration = PostgresClientKit.ConnectionConfiguration()
            configuration.host = "ec2-18-222-104-142.us-east-2.compute.amazonaws.com"
            //configuration.database = "example"
            configuration.user = "postgres"
            configuration.credential = .md5Password(password: "123TestDB!")
            configuration.ssl = false               // SSL/TLS is disabled    ??
            configuration.credential = .trust       //connecrs without authenticating   ??
            
            let connection = try PostgresClientKit.Connection(configuration: configuration)
            defer { connection.close() }
            
            let text = "INSERT INTO customer (cust_id, cust_name, cust_age) VALUES (9, 'Viraj', 25);"
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            defer { cursor.close() }
            
        } catch {
            print(error) // better error handling goes here
        }
    }
    
    
    func beginPlayback(itemID: String) {
       musicPlayerController.setQueue(with: ["1224353520"])
        
        musicPlayerController.play()
        //togglePlayPause()
    }
    
    // MARK: Playback Control Methods
    
    func togglePlayPause() {
        if musicPlayerController.playbackState == .playing {
           musicPlayerController.pause()
            //togglePlayPause()
        } else {
            musicPlayerController.play()
            musicPlayerController.currentPlaybackTime = 30.0
        }
    }
    
    
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        
        self.animated_png()
        //self.togglePlayPause()
    }
    
    func animated_png () {
        print ("animated_png")
        let start = CFAbsoluteTimeGetCurrent()
        let url = Bundle.main.resourceURL!
        print (Bundle.main.resourceURL)
        print (Bundle.main.bundlePath)
        pngimageView.animationImages = (0 ..< 15).map {
            UIImage(contentsOfFile: Bundle.main.path(forResource: "Fire_\($0)", ofType: "png")!)!
        }
        pngimageView.animationDuration = 2.0
        pngimageView.animationRepeatCount = 1
        pngimageView.startAnimating()

        print(CFAbsoluteTimeGetCurrent() - start)
        print ("animated_png done")
    }
    
    
    
    
    
}
