//
//  NewsFeedTableViewController.swift
//  Project2
//
//  Created by virdeshp on 3/12/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import Firebase
import Foundation


enum MyError: Error {
    case runtimeError(String)
}

class NewsFeedTableViewController: UITableViewController, YTPlayerViewDelegate, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate  {
    
    
  
    var super_temp_flag = true
    var poller = now_playing_poller.shared
    var dismiss_chevron: UIButton?
    var navBarImage: UIImageView?
    var navBarImageView: UIView?
    var navBarImageView_leadConstraint : NSLayoutConstraint?
    var navBarImageView_trailConstraint : NSLayoutConstraint?
    var navBarImageView_topConstraint : NSLayoutConstraint?
    var navBarImageView_botConstraint : NSLayoutConstraint?
    var tabBarImageView: UIImageView?
    var tabBarImageView_leadConstraint : NSLayoutConstraint?
    var tabBarImageView_trailConstraint : NSLayoutConstraint?
    var tabBarImageView_topConstraint : NSLayoutConstraint?
    var tabBarImageView_botConstraint : NSLayoutConstraint?
    var name_label: UILabel?
    var artist_label: UILabel?
    var duration_label: UILabel?
    var prog_bar: UIProgressView?
    var containerView: UIView?
    var containerView_leadConstraint : NSLayoutConstraint?
    var containerView_trailConstraint : NSLayoutConstraint?
    var containerView_topConstraint : NSLayoutConstraint?
    var containerView_botConstraint : NSLayoutConstraint?
    var backimage_leadConstraint : NSLayoutConstraint?
    var backimage_trailConstraint : NSLayoutConstraint?
    var backimage_botConstraint : NSLayoutConstraint?
    var backimage_topConstraint : NSLayoutConstraint?
    var backingImageView: UIImageView?
    var dimmmerLayer: UIView?
    var heightConstraint : NSLayoutConstraint?
    var widthConstraint : NSLayoutConstraint?
    var leadingConstraint : NSLayoutConstraint?
    var trailingConstraint : NSLayoutConstraint?
    var bottomConstraint : NSLayoutConstraint?
    var topConstraint : NSLayoutConstraint?
    var enlarged: Bool?
    var mainWindow = UIApplication.shared.keyWindow
    var temp_view: UIView?
    var temp_view2: UIView?
    var the_temp: Float?
    var the_new_temp: Float?
    var it_has_been_a_second: Int?
    var current_song_player: String?     //Used by Update Progress to grab the current time from the right player. Updated everywhere a player is played.
    var miniplayer: Bool?
    var miniplayer_just_started: Bool?
    var helper = Post_helper()
    var worker = ISRC_worker()
    var struct1 : apple_data_struct?
    var struct2 : spotify_data_struct?
    var isrc_num : String?
    typealias isrc_data_set = [String : [String: [String: Any]]]
    var av_player : AVAudioPlayer!
    let appleMusicControl = AppleMusicControl()
    let appleMusicManager = AppleMusicManager()
    let userDefaults = UserDefaults.standard
    var posts: [Post]?
    //var index_for_progress_bar : IndexPath? //for checking runaway porgress bars for other cells
    var currently_playing_song_cell: IndexPath! //last tapped/currently playing cell, so that we can stop it if a youtube video starts playing
    var currently_playing_youtube_cell: IndexPath! //last tapped/currently playing youtube cell, so that we can stop it if a youtube video starts playing
    var currently_playing_song_id: String!
    var paused_cell: IndexPath?
    var last_viewed_youtube_cell: IndexPath?
    var songnameLabel: UILabel?
    var playingImage: UIImageView?
    var spotifyplayer: SPTAudioStreamingController?
    var appleplayer = MPMusicPlayerController.applicationMusicPlayer
    var youtubeplayer: YTPlayerView?
    var youtubeplayer2: YTPlayerView!
    var no_other_video_is_active = true     //flag makes sure that the table view controller acts as the delegate of only one youtube player
    var playingView: UIView?
    var timer : Timer!
    var duration: Float!
    var temp_duration: Float!
    var playBar : UIProgressView!
    var executed_once: Bool!
    var playerView_offsetvalue: TimeInterval! //offset value for separate play/pause routine held by player_view
    var playerView_source_value: String!
    let playlist_access = UserAccess(myPlaylistQuery: MPMediaQuery.playlists(), myLibrarySongsQuery: MPMediaQuery.songs())
    let window = UIApplication.shared.keyWindow
    var currentPost: Post!
    struct Storyboard {
        
        static let postCell = "PostCell"
        static let postCellDefaultHeight : CGFloat = 550.0
        
    }
   let getView = BottomView()
    var spotify_mediaItems: [SpotifyMediaObject.item]!
    var apple_mediaItems: [[MediaItem]]!

    @objc func showBottomView(sender: UIButton){
        
        Post.dict_posts()
        print(self.currently_playing_song_id!)
        getView.bringupview(id: self.currently_playing_song_id! as String)
        
    }

    //global cell settings checker for @objc @objc the cell reuse problem
    //                                           playing | paused | progress Bar
    var allCells : [IndexPath: [Bool]] = [[0,0] : [false, false, false],
                                         [1,0] : [false, false, false],
                                         [2,0] : [false, false, false],
                                         [3,0] : [false, false, false],
                                         [4,0] : [false, false, false],
                                         [5,0] : [false, false, false],
                                         [6,0] : [false, false, false],
                                         [7,0] : [false, false, false],
                                         [8,0] : [false, false, false],
                                         [9,0] : [false, false, false]]
    var dark = false
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if (dark) {
            return .lightContent
        } else {
            return .default
        }
    }
  

    override func viewDidLoad() {
        super.viewDidLoad()
        //appleMusicControl.requestStorefrontCountryCode()
        enlarged = false
        self.appleplayer.beginGeneratingPlaybackNotifications()
        self.spotifyplayer = SPTAudioStreamingController.sharedInstance()
        NotificationCenter.default.addObserver(self,
                                       selector: #selector(handleMusicPlayerControllerPlaybackStateDidChange),
                                       name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                       object: self.appleplayer)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: secret_key), object: nil, queue: nil, using: handleMusicPlayerControllerPlaybackStateDidChange_fromSongPlayController)
        //NotificationCenter.default.addObserver(self, selector: #selector(self.firebase_addition), name: Notification.Name(rawValue: "FireBaseloginSuccessfull"), object: nil )
         NotificationCenter.default.addObserver(self, selector: #selector(stopAudioplayerforYoutube(notification:)), name: Notification.Name(rawValue: "Stop Audio Player!"), object: nil )
//        Adding the currently playing bar on top of the table view
        //playingView = UIView(frame: CGRect(origin: CGPoint(x:0, y:568), size: CGSize(width: 375, height: 50)))
        NotificationCenter.default.addObserver(self, selector: #selector(stop_newsfeed_player(notification:)), name: Notification.Name(rawValue: "Stop NewsFeed Player!"), object: nil)
        playingView = UIView(frame: CGRect(origin: CGPoint(x:0, y: (window?.frame.height)!), size: CGSize(width: 375, height: 50)))
        playingView?.backgroundColor = UIColor.white
        self.navigationController?.view.addSubview(playingView!)
        

        temp_view2 = UIView(frame: CGRect(origin: CGPoint(x:12, y: 573), size: CGSize(width: 40, height: 40)))
        mainWindow!.addSubview(self.temp_view2!)
        self.temp_view2!.translatesAutoresizingMaskIntoConstraints = false
        leadingConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 12)
        trailingConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: -323)
        topConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 573)
        bottomConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -54)
        //heightConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
        //widthConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
        mainWindow?.addConstraints([topConstraint!, bottomConstraint!, leadingConstraint!, trailingConstraint!])

        temp_view2?.backgroundColor = UIColor.blue
        temp_view = UIView(frame: (UIApplication.shared.keyWindow?.frame)!)
        temp_view?.backgroundColor = UIColor.black
        
        let aspectRatio1 = self.mainWindow!.frame.height / self.mainWindow!.frame.width
        mainWindow!.addSubview(self.temp_view!)
        backingImageView = UIImageView(frame: CGRect(origin: CGPoint(x:0, y: 0), size: CGSize(width: 375.0, height: 667.0)))
        backingImageView?.clipsToBounds = true
        mainWindow!.addSubview(self.backingImageView!)
        self.backingImageView!.translatesAutoresizingMaskIntoConstraints = false
        backimage_leadConstraint = NSLayoutConstraint(item: backingImageView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        backimage_trailConstraint = NSLayoutConstraint(item: backingImageView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        backimage_botConstraint = NSLayoutConstraint(item: backingImageView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        backimage_topConstraint = NSLayoutConstraint(item: backingImageView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        mainWindow?.addConstraints([backimage_topConstraint!, backimage_botConstraint!, backimage_leadConstraint!, backimage_trailConstraint!])
        backingImageView?.isHidden = true
        
        
        dimmmerLayer = UIView(frame: (UIApplication.shared.keyWindow?.frame)!)
        dimmmerLayer?.backgroundColor = UIColor.black
        dimmmerLayer?.alpha = 0
        mainWindow!.addSubview(self.dimmmerLayer!)
        dimmmerLayer?.isHidden = true
        
        
        containerView = UIView(frame: CGRect(origin: CGPoint(x:0, y: 568), size: CGSize(width: 375.0, height: 647.0)))
        containerView?.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        containerView?.layer.cornerRadius = 0
        dismiss_chevron = UIButton(frame: CGRect(origin: CGPoint(x:169.5, y: 44), size: CGSize(width: 36, height: 22)))
        dismiss_chevron?.setImage(UIImage(named: "chevron"), for: .normal)
        dismiss_chevron?.isUserInteractionEnabled = true
        name_label = UILabel(frame: CGRect(origin: CGPoint(x:16, y: 467), size: CGSize(width: 343.0, height: 20.5)))
        name_label?.text = "Song name"
        name_label?.textAlignment = NSTextAlignment.center
        name_label!.font = UIFont.systemFont(ofSize: 17.0)
        artist_label = UILabel(frame: CGRect(origin: CGPoint(x:16, y: 495.5), size: CGSize(width: 343.0, height: 20.5)))
        artist_label?.text = "Artist name"
        artist_label?.textAlignment = NSTextAlignment.center
        artist_label!.font = UIFont.systemFont(ofSize: 17.0)
        duration_label = UILabel(frame: CGRect(origin: CGPoint(x:16, y: 524), size: CGSize(width: 343.0, height: 16)))
        duration_label?.text = "duration: 00:00"
        duration_label?.textAlignment = NSTextAlignment.center
        duration_label!.font = UIFont.systemFont(ofSize: 13.0)
        prog_bar = UIProgressView(frame: CGRect(origin: CGPoint(x:22.5, y: 560), size: CGSize(width: 330.0, height: 2)))
        prog_bar!.progressTintColor = UIColor.darkGray
        prog_bar!.trackTintColor = UIColor.lightGray
        prog_bar!.progress = 0.0
        containerView!.addSubview(self.dismiss_chevron!)
        containerView!.addSubview(self.name_label!)
        containerView!.addSubview(self.artist_label!)
        containerView!.addSubview(self.duration_label!)
        containerView!.addSubview(self.prog_bar!)
        
        self.containerView?.addConstraintWithFormat(format: "H:|-169.5-[v0]-169.5-|", views: self.dismiss_chevron!)
        self.containerView?.addConstraintWithFormat(format: "H:|-16-[v0]-16-|", views: self.name_label!)
        self.containerView?.addConstraintWithFormat(format: "H:|-16-[v0]-16-|", views: self.artist_label!)
        self.containerView?.addConstraintWithFormat(format: "H:|-16-[v0]-16-|", views: self.duration_label!)
        self.containerView?.addConstraintWithFormat(format: "H:|-22.5-[v0]-22.5-|", views: self.prog_bar!)
        self.containerView?.addConstraintWithFormat(format: "V:|-4-[v0]-355-[v1]-8-[v2]-8-[v3]-20-[v4]-150-|", views: self.dismiss_chevron!, self.name_label!, self.artist_label!, self.duration_label!, self.prog_bar!)

        mainWindow!.addSubview(self.containerView!)
        self.containerView!.translatesAutoresizingMaskIntoConstraints = false
        containerView_leadConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        containerView_trailConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        containerView_topConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 568)
        containerView_botConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 531)
        mainWindow?.addConstraints([containerView_topConstraint!, containerView_botConstraint!, containerView_leadConstraint!, containerView_trailConstraint!])
        containerView?.isHidden = true
        
        
        tabBarImageView = UIImageView(frame: CGRect(origin: CGPoint(x:0, y: 618), size: CGSize(width: 375.0, height: 49))) // 375 x 49
        mainWindow?.addSubview(tabBarImageView!)
        self.tabBarImageView!.translatesAutoresizingMaskIntoConstraints = false
        tabBarImageView_leadConstraint = NSLayoutConstraint(item: tabBarImageView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        tabBarImageView_trailConstraint = NSLayoutConstraint(item: tabBarImageView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        tabBarImageView_topConstraint = NSLayoutConstraint(item: tabBarImageView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 618)
        tabBarImageView_botConstraint = NSLayoutConstraint(item: tabBarImageView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        mainWindow?.addConstraints([tabBarImageView_topConstraint!, tabBarImageView_botConstraint!, tabBarImageView_leadConstraint!, tabBarImageView_trailConstraint!])
        tabBarImageView?.isHidden = true
        
        
        navBarImageView = UIView(frame: CGRect(origin: CGPoint(x:0, y: 0), size: CGSize(width: 375.0, height: 64.0))) // 375 x 64
        navBarImage = UIImageView(frame: CGRect(origin: CGPoint(x:0, y: 20), size: CGSize(width: 375.0, height: 44.0))) // 375 x 44
        navBarImageView?.addSubview(navBarImage!)
        self.navBarImageView?.addConstraintWithFormat(format: "H:|[v0]|", views: self.navBarImage!)
        self.navBarImageView?.addConstraintWithFormat(format: "V:|-20-[v0]|", views: self.navBarImage!)
        mainWindow?.addSubview(navBarImageView!)
        self.navBarImageView!.translatesAutoresizingMaskIntoConstraints = false
        navBarImageView_leadConstraint = NSLayoutConstraint(item: navBarImageView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        navBarImageView_trailConstraint = NSLayoutConstraint(item: navBarImageView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        navBarImageView_topConstraint = NSLayoutConstraint(item: navBarImageView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        navBarImageView_botConstraint = NSLayoutConstraint(item: navBarImageView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -603)
        mainWindow?.addConstraints([navBarImageView_topConstraint!, navBarImageView_botConstraint!, navBarImageView_leadConstraint!, navBarImageView_trailConstraint!])
        navBarImageView?.backgroundColor = UIColor.white
        navBarImageView?.isOpaque = false
        navBarImageView?.isHidden = true
        
        
        mainWindow!.addSubview(self.temp_view2!)
        temp_view?.isHidden = true
        
        print (backingImageView?.layer.frame.height)
        print (backingImageView?.layer.frame.width)
        print (backingImageView?.frame.height)
        print (backingImageView?.frame.width)
        
        playingImage = UIImageView(image: #imageLiteral(resourceName: "clapton"))
        playingImage?.contentMode = UIViewContentMode.scaleAspectFill
        playingImage?.frame = CGRect(x: 12, y: 5, width: 40, height: 40)
        playingView?.addSubview(playingImage!)
        //playingImage?.isHidden = true
        
        youtubeplayer2 = YTPlayerView.init(frame: CGRect(x: 12, y: 573, width: 40, height: 40))
        //playingView?.addSubview(youtubeplayer2!)
        youtubeplayer2.contentMode = UIViewContentMode.scaleAspectFit
        //mainWindow!.addSubview(self.youtubeplayer2!)
        mainWindow!.bringSubview(toFront: self.temp_view2!)
        self.temp_view2?.addSubview(self.youtubeplayer2!)
        self.temp_view2?.addConstraintWithFormat(format: "H:|-0-[v0]-0-|", views: self.youtubeplayer2)
        self.temp_view2?.addConstraintWithFormat(format: "V:|-0-[v0]-0-|", views: self.youtubeplayer2)
        self.temp_view2!.translatesAutoresizingMaskIntoConstraints = false
        self.temp_view2?.bringSubview(toFront: youtubeplayer2)
        youtubeplayer2.backgroundColor = UIColor.black
        youtubeplayer2?.delegate = self
        //playingView?.bringSubview(toFront: youtubeplayer2!)
        youtubeplayer2.isHidden = true
        temp_view2?.isHidden = true
        songnameLabel = UILabel(frame: CGRect(origin: CGPoint(x:67, y:5), size: CGSize(width: 203, height:37)))
        songnameLabel?.text = "Song Name"
        songnameLabel?.textAlignment = NSTextAlignment.center
        songnameLabel?.font = songnameLabel?.font.withSize(13)
        playingView?.addSubview(songnameLabel!)
        it_has_been_a_second = 0
        current_song_player = "apple"
        the_temp = 0.0
        the_new_temp = 0.0
        var getbutton = UIButton(frame: CGRect(origin: CGPoint(x: 283, y: 9), size: CGSize(width: 32, height: 32)))
        getbutton.setImage(#imageLiteral(resourceName: "icons8-below-96"), for: .normal)
        getbutton.addTarget(self, action: #selector(showBottomView(sender:)), for: .touchUpInside)
        playingView?.addSubview(getbutton)
        
        var playbutton = UIButton(frame: CGRect(origin: CGPoint(x: 331, y: 9), size: CGSize(width: 32, height: 32)))
        playbutton.setImage(#imageLiteral(resourceName: "icons8-play-100"), for: .normal)
        playbutton.addTarget(self, action: #selector(tapEdit3(recognizer:)), for: .touchUpInside)
        playingView?.addSubview(playbutton)
        
        playBar = UIProgressView(frame: CGRect(origin: CGPoint(x:67, y:42), size: CGSize(width: 203, height: 2)))
        playBar.progressTintColor = UIColor.darkGray
        playBar.trackTintColor = UIColor.lightGray
        playBar.progress = 0.0
        playingView?.addSubview(playBar)
        playingView?.isHidden = true
        
        playerView_source_value = "default"
        duration = 60
        miniplayer = false
        miniplayer_just_started = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(tapEdit2(recognizer:)))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(tapEdit3(recognizer:)))
        let tapGesture4 = UISwipeGestureRecognizer(target: self, action: #selector(tapEdit4(recognizer:)))
        tapGesture4.direction = UISwipeGestureRecognizerDirection.down
        //temp_view?.addGestureRecognizer(tapGesture4)
        containerView?.addGestureRecognizer(tapGesture4)
        tableView.addGestureRecognizer(tapGesture)
        playingView?.addGestureRecognizer(tapGesture2)
        
        
        //playingImage?.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self as? UIGestureRecognizerDelegate
        tapGesture2.delegate = playingView as? UIGestureRecognizerDelegate
        
        //index_for_progress_bar = nil //when you hit pause, spotify stops the song, but the progress bar keeps running. This variable is part of the functionality that pauses and restarts the progress bar
        currently_playing_youtube_cell = nil
        last_viewed_youtube_cell = nil
        currently_playing_song_cell = nil
        currently_playing_song_id = ""
        self.fetchPosts()
        self.spotifyplayer?.playbackDelegate = self as SPTAudioStreamingPlaybackDelegate
        self.spotifyplayer?.delegate = self as SPTAudioStreamingDelegate
        self.youtubeplayer?.delegate = self
        
        print(allCells)
        
        let play = false
        print (play)
        print("oi")

        tableView.estimatedRowHeight = Storyboard.postCellDefaultHeight //estimate the minimum height to  be this value
        tableView.rowHeight = UITableViewAutomaticDimension //Actual height resized as per autolayout
        tableView.separatorColor = UIColor.clear //we don't want the default separator between the cells to be seen
    }
    
    
    @objc func stop_newsfeed_player(notification: NSNotification) {
        print("Something is started playing in FriendUpdateController - stop News Feed player")
        self.timer?.invalidate()
        if currently_playing_song_cell != nil {
            allCells[currently_playing_song_cell]?[0] =  false
            allCells[currently_playing_song_cell]?[1] = false
            currently_playing_song_cell = nil
        }
        
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------------------------------------//
    //-> this does not work -> don't have a perfect workaround yet -> all the surrounding comments are the remnants of attempted workarounds - still see Domain=MPCPlayerRequestErrorDomain Code=1 "No commands provided." intermittently - need to open bug with Apple
    @objc func setcurrentplaybacktime() {
        
        print ("cureent playback time is \(self.appleplayer.currentPlaybackTime)")
        if ((self.appleplayer.playbackState == .playing) && (self.appleplayer.currentPlaybackTime > 0.01)) {
            self.timer.invalidate()
            print(Float((self.appleplayer.currentPlaybackTime)))
            self.appleplayer.currentPlaybackTime = 30.0
            print(Float((self.appleplayer.currentPlaybackTime)))
            print("current test")
            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
        }
        
    }
    
    func set_curr_playback() {
        DispatchQueue.global(qos: .userInteractive).async {
            let group  = DispatchGroup()
            group.enter()
            while (self.super_temp_flag) {
                print ("while true")
                if ((self.appleplayer.currentPlaybackTime > 0.01) && (self.appleplayer.currentPlaybackTime < 30.0) ) {
                    self.super_temp_flag = false
                    print(Float((self.appleplayer.currentPlaybackTime)))
                    self.appleplayer.currentPlaybackTime = 30.0
                    print(Float((self.appleplayer.currentPlaybackTime)))
                    print("current test")
                }
            }
            group.leave()
            group.notify(queue: .main) {
                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
            }
        }
    }
    
    
    func set_current_playback_time () {
        while (self.super_temp_flag) {
            print ("while true")
            if ((self.appleplayer.currentPlaybackTime > 0.01)) {
                self.super_temp_flag = false
                print(Float((self.appleplayer.currentPlaybackTime)))
                self.appleplayer.currentPlaybackTime = 30.0
                print(Float((self.appleplayer.currentPlaybackTime)))
                print("current test")
                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
            }
        }
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------//

    
    
    @objc func updateProgress_apple() {
        self.it_has_been_a_second = self.it_has_been_a_second! + 1
        if (self.it_has_been_a_second! >= 10000) {
            print("update_apple \(Float(self.appleplayer.currentPlaybackTime))")
            
            //print("duration is \(self.duration)")
            //print ("current post startoffset \(currentPost.startoffset)")
            //print(Float((self.appleplayer.currentPlaybackTime)))
            the_temp = Float(self.appleplayer.currentPlaybackTime) - 0.0 //<- Apple does not allow starting from a different point. No workaround so far. -> this does not work -> don't have a perfect workaround yet -> all the surrounding comments are the remnants of attempted workarounds - still see Domain=MPCPlayerRequestErrorDomain Code=1 "No commands provided." intermittently - need to open bug with Apple
            the_new_temp = Float(the_temp!)/Float(self.duration)
            if ((the_new_temp!) > self.playBar.progress) {
                self.playBar.progress = the_new_temp!
                self.prog_bar!.progress = the_new_temp!
                it_has_been_a_second = 0
                print (self.it_has_been_a_second)
            } else {
                //do regular increment
                //print("regular increment")
                self.playBar.progress += (0.000189/self.duration)
                self.prog_bar!.progress += (0.000189/self.duration)
            }
        } else {
            //print("regular increment")
            self.playBar.progress += (0.000189/self.duration)
            self.prog_bar!.progress += (0.000189/self.duration)
            
        }
        if self.playBar.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.playBar.progress = 0.0
            self.prog_bar!.progress = 0.0
            it_has_been_a_second = 0
            if currently_playing_song_cell != nil {
                self.appleplayer.stop()
                if let tappedCell = self.tableView.cellForRow(at: currently_playing_song_cell!) as? PostCell {
                    tappedCell.playingflag = false
                    tappedCell.pausedflag = false
                    print (tappedCell.pausedflag)
                    print("updated cell immediately")
                }
                allCells[currently_playing_song_cell!]?[0] = false
                allCells[currently_playing_song_cell!]?[1] = false
                print ("updated global flags")
                currently_playing_song_cell = nil
                currently_playing_song_id = ""
            }
        }
    }
    
    @objc func updateProgress_spotify() {
        self.it_has_been_a_second = self.it_has_been_a_second! + 1
        if (self.it_has_been_a_second! >= 10000){
            print("update_spotify")
            the_temp = Float(((self.spotifyplayer?.playbackState.position)!) - currentPost.startoffset)
            the_new_temp = Float(the_temp!) / Float(self.duration)
            if ((the_new_temp!) > self.playBar.progress) {
                self.playBar.progress = the_new_temp!
                self.prog_bar!.progress = the_new_temp!
                it_has_been_a_second = 0
                print (self.it_has_been_a_second)
            } else {
                //do regular increment
                //print("regular increment")
                self.playBar.progress += (0.000089/self.duration)
                self.prog_bar!.progress += (0.000089/self.duration)
                
                
            }
        } else {
            //print("regular increment")
            self.playBar.progress += (0.000089/self.duration)
            self.prog_bar!.progress += (0.000089/self.duration)
        }
        if self.playBar.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.playBar.progress = 0.0
            self.prog_bar!.progress = 0.0
            it_has_been_a_second = 0
            if currently_playing_song_cell != nil {
                self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
                    if (error == nil) {
                        print("paused number 1")
                        
                    }
                    else {
                        print ("error in pausing!")
                    }
                })
                if let tappedCell = self.tableView.cellForRow(at: currently_playing_song_cell!) as? PostCell {
                    tappedCell.playingflag = false
                    tappedCell.pausedflag = false
                    print (tappedCell.pausedflag)
                    print("updated cell immediately")
                }
                allCells[currently_playing_song_cell!]?[0] = false
                allCells[currently_playing_song_cell!]?[1] = false
                print ("updated global flags")
                currently_playing_song_cell = nil
                currently_playing_song_id = ""
            }
        }
    }
    
    @objc func updateProgress_yt() {
        self.it_has_been_a_second = self.it_has_been_a_second! + 1
        if (self.it_has_been_a_second! >= 10000){
            //print("update_yt")
            the_temp = Float(((youtubeplayer?.currentTime())!) - currentPost.starttime)
            the_new_temp = Float(the_temp!) / Float(self.duration)
            if ((the_new_temp!) > self.playBar.progress) {
                self.playBar.progress = the_new_temp!
                self.prog_bar!.progress = the_new_temp!
                it_has_been_a_second = 0
                print (self.it_has_been_a_second)
            } else {
                //do regular increment
                //print("regular increment")
                self.playBar.progress += (0.000089/self.duration)
                self.prog_bar!.progress += (0.000089/self.duration)
            }
        } else {
            //print("regular increment")
            self.playBar.progress += (0.000089/self.duration)
            self.prog_bar!.progress += (0.000089/self.duration)
        }
        if self.playBar.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.playBar.progress = 0.0
            self.prog_bar?.progress = 0.0
            it_has_been_a_second = 0
            
            if currently_playing_youtube_cell != nil {
                if let tappedCell = self.tableView.cellForRow(at: currently_playing_youtube_cell!) as? PostCell {
                    tappedCell.playingflag = false
                    tappedCell.pausedflag = false
                    print (tappedCell.pausedflag)
                    print("updated cell immediately")
                }
                allCells[currently_playing_youtube_cell!]?[0] = false
                allCells[currently_playing_youtube_cell!]?[1] = false
                print ("updated global flags")
                currently_playing_youtube_cell = nil
                miniplayer = false
                no_other_video_is_active = true
            }
        }
    }
    
    @objc func updateProgress_ytmini() {
        self.it_has_been_a_second = self.it_has_been_a_second! + 1
        if (self.it_has_been_a_second! >= 10000){
            print("update_ytmini")
            the_temp = Float(((youtubeplayer2?.currentTime())!) - currentPost.starttime)
            the_new_temp = Float(the_temp!) / Float(self.duration)
            if ((the_new_temp!) > self.playBar.progress) {
                self.playBar.progress = the_new_temp!
                self.prog_bar?.progress = the_new_temp!
                it_has_been_a_second = 0
                print (self.it_has_been_a_second)
            } else {
                //do regular increment
                //print("regular increment")
                self.playBar.progress += (0.000089/self.duration)
                self.prog_bar?.progress += (0.000089/self.duration)
            }
        } else {
            //print("regular increment")
            self.playBar.progress += (0.000089/self.duration)
            self.prog_bar?.progress += (0.000089/self.duration)
        }
        if self.playBar.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.playBar.progress = 0.0
            self.prog_bar?.progress = 0.0
            it_has_been_a_second = 0
            if currently_playing_youtube_cell != nil {
                if let tappedCell = self.tableView.cellForRow(at: currently_playing_youtube_cell!) as? PostCell {
                    tappedCell.playingflag = false
                    tappedCell.pausedflag = false
                    print (tappedCell.pausedflag)
                    print("updated cell immediately")
                }
                allCells[currently_playing_youtube_cell!]?[0] = false
                allCells[currently_playing_youtube_cell!]?[1] = false
                print ("updated global flags")
                currently_playing_youtube_cell = nil
                miniplayer = false
                no_other_video_is_active = true
            }
        }
    }
    
    @objc func updateProgress_av() {
        self.it_has_been_a_second = self.it_has_been_a_second! + 1
        if (self.it_has_been_a_second! >= 10000){
            print("update_av")
            the_temp = Float(((self.av_player?.deviceCurrentTime)!) - 0.0)
            the_new_temp = Float(the_temp!) / 30.0
            if ((the_new_temp!) > self.playBar.progress) {
                self.playBar.progress = the_new_temp!
                self.prog_bar!.progress = the_new_temp!
                it_has_been_a_second = 0
                print (self.it_has_been_a_second)
            } else {
                //do regular increment
                //print("regular increment")
                self.playBar.progress += (0.000089/self.duration)
                self.prog_bar!.progress += (0.000089/self.duration)
            }
        } else {
            //print("regular increment")
            self.playBar.progress += (0.000089/self.duration)
            self.prog_bar!.progress += (0.000089/self.duration)
        }
        if self.playBar.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.playBar.progress = 0.0
            self.prog_bar!.progress = 0.0
            it_has_been_a_second = 0
            if currently_playing_song_cell != nil {
                self.av_player.stop()
                if let tappedCell = self.tableView.cellForRow(at: currently_playing_song_cell!) as? PostCell {
                    tappedCell.playingflag = false
                    tappedCell.pausedflag = false
                    print (tappedCell.pausedflag)
                    print("updated cell immediately")
                }
                allCells[currently_playing_song_cell!]?[0] = false
                allCells[currently_playing_song_cell!]?[1] = false
                print ("updated global flags")
                currently_playing_song_cell = nil
                currently_playing_song_id = ""
            }
        }
    }
  
    @objc func updateProgress() {
        // increase progress value
//        print("updating")
//        print (self.it_has_been_a_second)
        self.it_has_been_a_second = self.it_has_been_a_second! + 1
//        if self.it_has_been_a_second == 10000 {
//            print (self.it_has_been_a_second)
//        }
//        if currentPost.flag == "video" &&  self.it_has_been_a_second == 5000 {
//            print (currentPost.flag)
//        }
        if (currentPost.flag == "video" && self.it_has_been_a_second! >= 10000){
                print("Every second")
                //print (youtubeplayer?.currentTime())
                //print (currentPost.starttime)
                if (youtubeplayer2.playerState() == YTPlayerState.playing && self.miniplayer!) {
                    the_temp = Float((youtubeplayer2?.currentTime())! - currentPost.starttime)
                } else {
                    the_temp = Float((youtubeplayer?.currentTime())! - currentPost.starttime)
                }
                the_new_temp = Float(the_temp!) / Float(self.duration)
                print(the_temp)
                print (the_new_temp)
                //print (self.duration)
                //print(( youtubeplayer?.currentTime() ?? currentPost.starttime - currentPost.starttime) / self.duration)
                //print ( self.playBar.progress)
                if ((the_new_temp!) > self.playBar.progress) {
                    self.playBar.progress = the_new_temp!
                    it_has_been_a_second = 0
                    print (self.it_has_been_a_second)
                } else {
                    //do regular increment
                    //print("regular increment")
                    self.playBar.progress += (0.000089/self.duration)
                }
        } else {
            //print("regular increment")
            self.playBar.progress += (0.000089/self.duration)
//
//            if current_song_player == "apple"{
//                if ((( self.appleplayer.currentPlaybackTime ?? currentPost.startoffset - currentPost.startoffset) / self.duration) > self.playBar.progress) {
//                    self.playBar.progress = ((self.appleplayer.currentPlaybackTime ?? currentPost.startoffset - currentPost.startoffset) / self.duration)
//                } else {
//                    //do regular increment
//                    self.playBar.progress += (0.000089/self.duration)
//                }
//            }else if current_song_player == "spotify" {
//                if ((( self.spotifyplayer ?? currentPost.starttime - currentPost.starttime) / self.duration) > self.playBar.progress) {
//                    self.playBar.progress = ((youtubeplayer?.currentTime() ?? currentPost.starttime - currentPost.starttime) / self.duration)
//                } else {
//                    //do regular increment
//                    self.playBar.progress += (0.000089/self.duration)
//                }
//            }else if current_song_player == "av_player" {
//                if ((( youtubeplayer?.currentTime() ?? currentPost.starttime - currentPost.starttime) / self.duration) > self.playBar.progress) {
//                    self.playBar.progress = ((youtubeplayer?.currentTime() ?? currentPost.starttime - currentPost.starttime) / self.duration)
//                } else {
//                    //do regular increment
//                    self.playBar.progress += (0.000089/self.duration)
//                }
//            }
            
        }
        //self.playBar.progress += (0.000089/self.duration)
        //self.progressBar.setProgress(0.01, animated: true)
        //self.progressBar.animate(duration: 10)
        
        // invalidate timer if progress reach to 1
        if self.playBar.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.playBar.progress = 0.0
            it_has_been_a_second = 0
            if currently_playing_song_cell != nil{
            self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
                if (error == nil) {
                    print("paused number 1")
                    
                }
                else {
                    print ("error in pausing!")
                }
            })
                self.appleplayer.stop()
                if let tappedCell = self.tableView.cellForRow(at: currently_playing_song_cell!) as? PostCell {
                tappedCell.playingflag = false
                tappedCell.pausedflag = false
                print (tappedCell.pausedflag)
                print("updated cell immediately")
                }
                allCells[currently_playing_song_cell!]?[0] = false
                allCells[currently_playing_song_cell!]?[1] = false
                print ("updated global flags")
                //index_for_progress_bar = nil                          
                currently_playing_song_cell = nil
                currently_playing_song_id = ""
            }
        }
    }
    
    
    @objc func handleMusicPlayerControllerPlaybackStateDidChange () {
        if self.appleplayer.playbackState == .playing {
            print ("apple player ksjnkwrnlwinw just started playing - newsfeed - handleMusicPlayerControllerPlaybackStateDidChange")
            self.youtubeplayer?.stopVideo()
            self.youtubeplayer2?.stopVideo()
            self.miniplayer = false
            self.miniplayer_just_started = false
            youtubeplayer2.isHidden = true
            temp_view2?.isHidden = true
        } else if self.appleplayer.playbackState == .interrupted {
            print ("apple player was interrupted - newsfeed - handleMusicPlayerControllerPlaybackStateDidChange")
            if currently_playing_song_cell != nil {
                allCells[currently_playing_song_cell!]?[0] = false
                allCells[currently_playing_song_cell!]?[1] = false
            }
        } else if self.appleplayer.playbackState == .paused {
            print ("apple player was paused - newsfeed - handleMusicPlayerControllerPlaybackStateDidChange")
        } else if self.appleplayer.playbackState == .stopped {
            print ("apple player was stopped - newsfeed - handleMusicPlayerControllerPlaybackStateDidChange")
            if currently_playing_song_cell != nil {
                allCells[currently_playing_song_cell!]?[0] = false
                allCells[currently_playing_song_cell!]?[1] = false
            }
        }
    }
    
    @objc func handleMusicPlayerControllerPlaybackStateDidChange_fromSongPlayController (notification: Notification) -> Void {
        guard var player_state = notification.userInfo!["State"] as? String else { return }
        if player_state == "playing" {
            self.youtubeplayer?.stopVideo()
            self.youtubeplayer2?.stopVideo()
            self.miniplayer = false
            self.miniplayer_just_started = false
            youtubeplayer2.isHidden = true
            temp_view2?.isHidden = true
        } else if player_state == "interrupted" {
            print ("interrupted")
            allCells[currently_playing_song_cell!]?[0] = false
            allCells[currently_playing_song_cell!]?[1] = false
        } else if player_state == "paused" {
            print ("paused number 7")
        } else if player_state == "stopped" {
            print ("stopped")
            allCells[currently_playing_song_cell!]?[0] = false
            allCells[currently_playing_song_cell!]?[1] = false
        }
    }
    
//this function stops the spotify post when it recieves the stop notification
    @objc func stopAudioplayerforYoutube(notification: NSNotification) {
        print ("in notification")
        /*
        if let stop_this_cell = self.tableView.cellForRow(at: currently_playing_cell!) as? PostCell {
            stop_this_cell.pauseButton(stop_this_cell)
            currently_playing_cell = nil
        print("cell should shut up")
        }*/
        if ((self.spotifyplayer?.playbackState != nil) && (self.spotifyplayer?.playbackState.isPlaying)!){
        self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
            if (error == nil) {
                print("paused number 8")
                self.allCells[self.currently_playing_song_cell!]?[0] = false
                self.allCells[self.currently_playing_song_cell!]?[1] = false
                let previous_cell = self.tableView.cellForRow(at: self.currently_playing_song_cell!) as? PostCell
                previous_cell?.playingflag = false
                previous_cell?.pausedflag = false
                self.currently_playing_song_cell = nil
            }
            else {
                print ("error in pausing!")
            }
        })
        }else if (self.appleplayer.playbackState == .playing){
            self.appleplayer.stop()
            self.allCells[self.currently_playing_song_cell!]?[0] = false
            self.allCells[self.currently_playing_song_cell!]?[1] = false
            let previous_cell = self.tableView.cellForRow(at: self.currently_playing_song_cell!) as? PostCell
            previous_cell?.playingflag = false
            previous_cell?.pausedflag = false
            currently_playing_song_cell = nil
        }else {
            print ("something went very wrong: Youtube cell was tapped: In Stop Audio Notification Observer")
        }
        
        
    }
    
    
//this function identify's that a youtube post has been played and sends the stop spotify player notification
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
            print (currently_playing_song_cell)
            if currently_playing_song_cell != nil{
                print("there is a audio cell playing but i wont shut it")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "Stop Audio Player!"), object: nil)
            }else{
                print ("there is no audio cell playing")
            }
            break;
        case YTPlayerState.ended:
            print("Ended - Yes we come here")
            currently_playing_youtube_cell = nil
            miniplayer = false
            no_other_video_is_active = true
            self.timer?.invalidate()
            self.playBar.progress = 0
            print("no_other_video_is_active")
            
            break;
        case YTPlayerState.playing:
            print ("we know state changed")
            self.current_song_player = "youtube"
            print("miniplayer is \(self.miniplayer)")
            executed_once = true
            if !(self.miniplayer!) { //We'll be here again when the miniplayer starts and post player is paused. Don't need any of this setup.
                if executed_once == true{ //WHY DID I PUT THIS IN HERE ?
                //dismiss_player_view()
                youtubeplayer2.isHidden = true
                temp_view2?.isHidden = true
                if currently_playing_youtube_cell == nil{
                print ("this works")
                playBar.progress = 0
                self.timer?.invalidate()
                }
                self.duration = self.temp_duration
                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_yt), userInfo: nil, repeats: true)
                RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
                print("-----------------------------------------Timer started------------------------------------------")
                currently_playing_youtube_cell = last_viewed_youtube_cell
                no_other_video_is_active = false
                print(currently_playing_youtube_cell)
                if let cell  = self.tableView.cellForRow(at: currently_playing_youtube_cell!) as? PostCell {
                    print("video should load man")
                    youtubeplayer = cell.playerView
                    currentPost = cell.post
                    youtubeplayer2?.load (withVideoId: cell.videoID , playerVars: [ "playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 0, "start": cell.videostart, "end": cell.videoend, "rel": 0, "iv_load_policy": 3])
                } else {
                        self.youtubeplayer?.stopVideo() //Comment this out if we load the post cell ytplayer every time the cell is dequeued
                    //otherwise, leave this in, since we don't load the cell ytplayer everytime it just remains paused at the position where the miniplayer started and we don't want to see that when we scroll back.
                }
                
                }else{
                    executed_once = true
                }
            } else {
                self.miniplayer_just_started = false
                print("did we even come here ?? what is going on?")
                self.timer.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_ytmini), userInfo: nil, repeats: true)
                RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
            }
            break;
        case YTPlayerState.paused:
            print("Nah we come here") //when the miniplayer cuts off the post player, it goes to paused state not ended state.
            print("state changed to paused")
            if !(self.miniplayer_just_started!) && (currently_playing_youtube_cell != nil) {
                print (self.miniplayer_just_started)
                self.timer?.invalidate()        //if the miniplayer has just started and we come here, let the timer run, we handle it in .isPlaying for miniplayer, handing it over from the post player to the miniplayer. Skip the rest of the settings as well
                allCells[currently_playing_youtube_cell!]?[0] = false
                allCells[currently_playing_youtube_cell!]?[1] = true
                paused_cell = currently_playing_youtube_cell
                currently_playing_youtube_cell = nil
                print ("we didnt let it run")
            }
            break;
        default:
            print("none of these")
            break;
        }
    }
    
    /* - this does not work for some reason: had to use the stopVideo function with the playing - paused flag functionality in func tapEdit.
     
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        print("we know a spotify post playback status has changed")
        if isPlaying {
            print("we know the status has changed to playing")
            self.youtubeplayer?.stopVideo()
        }
    }
 */

    
    @objc func tapEdit4(recognizer: UITapGestureRecognizer) {
        
        if (enlarged!) {
            self.youtubeplayer2.isHidden = true
            self.temp_view2?.isHidden = true
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                           options: [.curveEaseIn], animations: {
                            self.temp_view?.frame = CGRect(origin: CGPoint(x: 0, y: (self.window?.frame.height)!), size: CGSize(width: (self.window?.frame.width)!, height: (self.window?.frame.height)!))
            }, completion: nil)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                                                        options: [.curveEaseIn], animations:  {
                self.tabBarImageView_topConstraint?.constant = 618
                self.tabBarImageView_botConstraint?.constant = 0
             }, completion: { (value: Bool) in
                //self.tabBarImageView?.isHidden = true
            })
            
//            UIView.animate(withDuration: 0.5/4) {
//                self.containerView?.backgroundColor = UIColor.white.withAlphaComponent(0.3)
//            }
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                           options: [.curveEaseIn], animations: {
                            

                            self.configureBackingImageInPosition(presenting: false)
                            self.leadingConstraint?.constant = 12
                            self.trailingConstraint?.constant = -323
                            self.topConstraint?.constant = 573
                            self.bottomConstraint?.constant = (-54)
                            self.containerView_topConstraint?.constant = 568
                            self.containerView_botConstraint?.constant = 531
                            self.containerView?.layer.cornerRadius = 0
                            self.dismiss_chevron?.alpha = 0
                            self.youtubeplayer2?.frame = CGRect(origin: CGPoint(x: 12, y: 573), size: CGSize(width: (self.temp_view2?.frame.width)!, height: (self.temp_view2?.frame.height)!))
                            self.youtubeplayer2?.layoutIfNeeded()
                            self.temp_view2?.layoutIfNeeded()
                            self.mainWindow!.layoutIfNeeded()
            }, completion: { (value: Bool) in
                self.containerView?.isHidden = true
                //self.youtubeplayer2.isHidden = false
                //self.temp_view2?.isHidden = false
                self.backingImageView?.isHidden = true
                self.dimmmerLayer?.isHidden = true
                self.temp_view?.isHidden = true
                self.temp_view?.frame = (UIApplication.shared.keyWindow?.frame)!
                self.dark = false
                self.setNeedsStatusBarAppearanceUpdate()
                self.enlarged = false
                self.tabBarImageView?.isHidden = true
                self.containerView?.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            })
            self.youtubeplayer2.isHidden = false
            self.temp_view2?.isHidden = false
        } else {
            self.window?.bringSubview(toFront: self.temp_view!)
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
                
                self.temp_view?.frame = CGRect(origin: CGPoint(x: 25, y: 5), size: CGSize(width: 325, height: 325))
                
            }, completion: nil)
            enlarged = true
        }
    }
    
    
     @objc func tapEdit3(recognizer: UITapGestureRecognizer)  {
        guard let post = currentPost else {
            return
        }
        
        if (miniplayer!) {
            self.youtubeplayer2.isHidden = true
            temp_view2?.isHidden = true
            self.backingImageView?.image = tableView.makeSnapshot()
            temp_view?.isHidden = false
            name_label?.text = currentPost.songname
            self.dimmmerLayer?.isHidden = false
            self.backingImageView?.isHidden = false
            self.containerView?.isHidden = false
            if let tabBar = tabBarController?.tabBar {
                self.tabBarImageView?.image = tabBar.makeSnapshot()
            }
            
            self.tabBarImageView?.isHidden = false
            
            UIView.animate(withDuration: 0.5/2) {
                self.tabBarImageView_topConstraint?.constant = 667
                self.tabBarImageView_botConstraint?.constant = 49
            }
            
            UIView.animate(withDuration: 0.5/4) {
                self.containerView?.backgroundColor = UIColor.white
            }
        
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                           options: [.curveEaseOut], animations: {
                
                self.configureBackingImageInPosition(presenting: true)
                self.leadingConstraint?.constant = 30
                self.trailingConstraint?.constant = -29
                self.topConstraint?.constant = 78 //(40 + 38)
                self.bottomConstraint?.constant = -273
                self.containerView_topConstraint?.constant = 40
                self.containerView_botConstraint?.constant = 10
                self.containerView?.layer.cornerRadius = 10
                self.dismiss_chevron?.alpha = 1
                self.youtubeplayer2?.webView!.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: (self.temp_view2?.frame.width)!, height: (self.temp_view2?.frame.height)!))
                self.youtubeplayer2?.frame = CGRect(origin: CGPoint(x: 25, y: 5), size: CGSize(width: (self.temp_view2?.frame.width)!, height: (self.temp_view2?.frame.height)!))
                self.youtubeplayer2?.layoutIfNeeded()
                self.temp_view2?.layoutIfNeeded()
                self.mainWindow!.layoutIfNeeded()
                            
            }, completion: { (value: Bool) in
                //self.youtubeplayer2.isHidden = false
                //self.temp_view2?.isHidden = false
                self.temp_view?.isHidden = false
                self.dark = true
                self.setNeedsStatusBarAppearanceUpdate()
                self.enlarged = true
            })
            self.youtubeplayer2.isHidden = false
            self.temp_view2?.isHidden = false
        } else {
            self.expandSong(post: post)
        }
        
    }
    
    private func configureBackingImageInPosition(presenting: Bool) {
        print("we be configuring")
        let edgeInset: CGFloat = presenting ? 15 : 0
        let dimmerAlpha: CGFloat = presenting ? 0.3 : 0
        let cornerRadius: CGFloat = presenting ? 10 : 0
        
        backimage_leadConstraint!.constant = edgeInset
        backimage_trailConstraint!.constant = -edgeInset
        print (self.backingImageView!.frame.height)
        print (self.backingImageView!.frame.width)
        let aspectRatio = mainWindow!.frame.height / mainWindow!.frame.width
        print (aspectRatio)
        print (edgeInset)
        backimage_topConstraint!.constant = edgeInset * aspectRatio
        backimage_botConstraint!.constant = -(edgeInset * aspectRatio)
        //2.
        dimmmerLayer!.alpha = dimmerAlpha
        //3.
        backingImageView!.layer.cornerRadius = cornerRadius
    }
    
     @objc func tapEdit2(recognizer: UITapGestureRecognizer)  {
        
        print("In tap edit2")
        if (currently_playing_song_cell != nil){  //something is playing right now
            print("something is playing")
            if (self.appleplayer.playbackState == .playing){
                print("true")
            }
           
            print(self.spotifyplayer!.playbackState)
            let previousCell = self.tableView.cellForRow(at: currently_playing_song_cell!) as? PostCell
            if (previousCell?.source == "apple" && self.appleplayer.playbackState == .playing){
                print("true")}
            
            if (self.playerView_source_value == "spotify" &&  userDefaults.string(forKey: "UserAccount") == "Apple") {
                    print("something is playing : apple")
                if self.appleplayer.playbackState == .playing {
                    self.appleplayer.pause()
                    self.playerView_offsetvalue = self.appleplayer.currentPlaybackTime
                    print (self.playerView_offsetvalue)
                }
            } else if (self.playerView_source_value == "apple" && userDefaults.string(forKey: "UserAccount") == "Spotify") {
                print("something is playing : spotify")
                if self.spotifyplayer!.playbackState.isPlaying {
                self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
                    if (error == nil) {
                        print("paused number 2")
                    }
                    else {
                        print ("error in pausing!")
                    }
                })
                self.playerView_offsetvalue = (self.spotifyplayer!.playbackState.position)
                print(self.spotifyplayer!.playbackState.position)
                }
            } else if ( self.playerView_source_value == "apple" && self.appleplayer.playbackState == .playing){

                    print("something is playing : apple")
                    self.appleplayer.pause()
                    self.playerView_offsetvalue = self.appleplayer.currentPlaybackTime
                    print (self.playerView_offsetvalue)
                
            } else if ( self.playerView_source_value == "spotify" && self.spotifyplayer!.playbackState.isPlaying){

                    print("something is playing : spotify")
                    self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
                        if (error == nil) {
                        print("paused number 2")
                        }
                        else {
                            print ("error in pausing!")
                        }
                    })
                self.playerView_offsetvalue = (self.spotifyplayer!.playbackState.position)
                print(self.spotifyplayer!.playbackState.position)
    
            }
            self.timer?.invalidate()
            
            //Update global here
            allCells[currently_playing_song_cell!]?[0] = false
            allCells[currently_playing_song_cell!]?[1] = true
            previousCell?.pausedflag = true
            previousCell?.playingflag = false
            paused_cell = currently_playing_song_cell
            currently_playing_song_cell = nil
        }else if currently_playing_youtube_cell != nil {
            
            if (self.miniplayer!) {
                self.youtubeplayer2.pauseVideo()
                //ALL THE STUFF BELOW IS HANDLED IN YTSTATE.isPAUSED - BECAUSE for the POST players WHEN THE YT VIDEO IS PAUSED THERE IS NOT TAPEDIT TO CAPTURE THAT - SO NONE OF THE FLAG SETTING WILL HAPPEN IN THAT CASE IF WE DONT DO IT IN YTSTATE.isPAUSED.
//                self.timer?.invalidate()
//                allCells[currently_playing_youtube_cell!]?[0] = false
//                allCells[currently_playing_youtube_cell!]?[1] = true
//                paused_cell = currently_playing_youtube_cell
//                currently_playing_youtube_cell = nil
            } else {
               print ("miniplayer should be true if we are pausing it from the miniplayer!!!!!!")
            }
            

        } else if (paused_cell != nil){ //something was paused and nothing new was played
        
            print("something was paused")
            let previousCell = self.tableView.cellForRow(at: paused_cell!) as? PostCell
            if playerView_source_value == "spotify" {
                if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                    print("something was paused: spotify")
                    print(previousCell?.trackidstring)
                    self.spotifyplayer?.playSpotifyURI(previousCell!.trackidstring, startingWith: 0, startingWithPosition: self.playerView_offsetvalue, callback: { (error) in
                            if (error == nil) {
                                print("playing number 3")
                                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_spotify), userInfo: nil, repeats: true)
                                RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                                self.current_song_player = "spotify"
                            }else {
                                print ("error in playing 3!")
                            }
                        })
                    }else if userDefaults.string(forKey: "UserAccount") == "Apple" {
                        print (self.playerView_offsetvalue)
                        //self.appleplayer.setQueue(with: [self.currently_playing_song_id])
                        //self.appleplayer.currentPlaybackTime = self.playerView_offsetvalue
                        self.appleplayer.play()
                        self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
                        self.current_song_player = "apple"
                        //self.appleplayer.currentPlaybackTime = self.playerView_offsetvalue
                        print (self.playerView_offsetvalue)
                    }
                    currently_playing_song_cell = paused_cell
                    //paused_cell = nil
            }else if (playerView_source_value == "apple") {
                if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                    print("something was paused: spotify")
                    print(previousCell?.helper_id)
                    self.spotifyplayer?.playSpotifyURI(previousCell!.helper_id, startingWith: 0, startingWithPosition: self.playerView_offsetvalue, callback: { (error) in
                        if (error == nil) {
                            print("playing number 3")
                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_spotify), userInfo: nil, repeats: true)
                            RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                            self.current_song_player = "spotify"
                        }
                        else {
                            print ("error in playing 3!")
                        }
                    })
                }else if userDefaults.string(forKey: "UserAccount") == "Apple" {
                    print("something was paused: apple")
                    print (self.playerView_offsetvalue)
                    //self.appleplayer.setQueue(with: [self.currently_playing_song_id])
                    //self.appleplayer.currentPlaybackTime = self.playerView_offsetvalue
                    self.appleplayer.play()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                    RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
                    self.current_song_player = "apple"
                    //self.appleplayer.currentPlaybackTime = self.playerView_offsetvalue
                    print (self.playerView_offsetvalue)
                }
                currently_playing_song_cell = paused_cell
                //paused_cell = nil
            } else if (playerView_source_value == "youtube"){
                if (self.miniplayer!) {
                    self.youtubeplayer2.playVideo()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_ytmini), userInfo: nil, repeats: true)
                    RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
                    currently_playing_youtube_cell = paused_cell
                } else {
                }
                
            }
            allCells[paused_cell!]?[0] = true
            allCells[paused_cell!]?[1] = false
            paused_cell = nil
            previousCell?.pausedflag = false
            previousCell?.playingflag = true
        }
        
        
    }
    

    
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        print ("tapedit here 1")
        if recognizer.state == UIGestureRecognizerState.ended {
            print ("tap edit here 2")
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                print ("tap edit here 3")
                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? PostCell {  //find the cell we tapped on
                   
                    //debug
                   print("detects video cell too")
                   print (tapIndexPath)
                   //print (index_for_progress_bar as Any)
                   print (tappedCell.playingflag)
                   print (tappedCell.pausedflag)
                    //debug
                    
                    if tappedCell.typeFlag != "video"{     //If the tapped cell is not a Video cell
                        print("this is not a video cell")
                    if tappedCell.playingflag == false {     //If this is a new untapped cell OR paused cell
                        if currently_playing_song_cell == nil {      //if no other cell is currently playing
                                if paused_cell == tapIndexPath {     //If this is a previously paused cell
                                    print ("paused_cell == tapIndexPath")
                                    
                                            currently_playing_song_cell = tapIndexPath  //record current cell
                                            currently_playing_song_id = tappedCell.trackidstring
                                            currentPost = tappedCell.post
                                            if (self.playerView_offsetvalue != nil) {
                                                tappedCell.offsetvalue = self.playerView_offsetvalue
                                            }
                                            self.playButton(cell: tappedCell)
                                            update_global(cell_control: true, tapped_cell: tappedCell, tapped_index: currently_playing_song_cell!)
                                } else {
                                            //Here - since paused_cell != tapIndexPath, meaning - the currently tapped cell, we also need to check if there is any previously paused cell - anf reset it's playing/paused flags to false/false.
                                            print ("paused_cell != tapIndexPath")   //If this is a new untapped cell
                                            playerView_source_value = tappedCell.source
                                            currently_playing_song_cell = tapIndexPath
                                            currently_playing_song_id = tappedCell.trackidstring
                                            currentPost = tappedCell.post
                                            self.youtubeplayer?.stopVideo()      //stops the last playing youtube cell
                                            self.youtubeplayer2?.stopVideo()
                                            self.miniplayer = false
                                            self.miniplayer_just_started = false
                                            youtubeplayer2.isHidden = true
                                            temp_view2?.isHidden = true
                                            currently_playing_youtube_cell = nil
                                            no_other_video_is_active = true //songnameLabel?.text = tappedCell.player?.metadata.currentTrack?.name
                                            setup_player_view(tapped_cell: tappedCell) //we call this before playbutton because timer reset happens here and initialization happens further down in playbutton
                                            self.playButton(cell: tappedCell)
                                            print ()
                                            //debug
                                            print (tappedCell.playingflag)
                                            print (tappedCell.pausedflag)
                                            //debug
                                            update_global(cell_control: true, tapped_cell: tappedCell, tapped_index: currently_playing_song_cell!) //sync to global settings
                            }
                        }else{ //if some other cell is playing right now
                            let previousCell = self.tableView.cellForRow(at: currently_playing_song_cell!) as? PostCell //record what the other cell that was playing was
                            //debug
                            
                            if tappedCell.pausedflag == true {
                                //This means - this cell was played - then paused - then scrolled away from - and a new cell was played - and we never reset this cells play/pause flags to false/false. Since we want to treat this cell as a brand new one now - reset all flags to false/false.
                                tappedCell.pausedflag = false
                                tappedCell.playingflag = false
                                update_global(cell_control: true, tapped_cell: tappedCell, tapped_index: tapIndexPath) 
                            }
                            
                            print(currently_playing_song_cell)
                            print("these are nil?")
                            print(previousCell?.playingflag as Any)
                            print(previousCell?.pausedflag as Any)
                            
                            previousCell?.playingflag = false
                            
                            allCells[currently_playing_song_cell!]![0] =  false
                            allCells[currently_playing_song_cell!]![1] = false
                            
                            //debug
                            //update_global(cell_control: false, tapped_cell: previousCell!, tapped_index: currently_playing_song_cell!) //sync to global settings for previous cell
                            print(previousCell?.source)
                            //This is how we stop the previously playing cell
                            if (tappedCell.source == "spotify" && self.userDefaults.string(forKey: "UserAccount") != "Spotify" ){
                                if self.appleplayer.playbackState == .playing {
                                self.appleplayer.stop()
                                print ("switching from apple to spotify")
                                }
                            }else if (tappedCell.source == "apple" && self.userDefaults.string(forKey: "UserAccount") != "Apple"){
                                if (self.spotifyplayer?.playbackState.isPlaying)! {
                                print("switching from spotify to apple")
                                print(self.spotifyplayer?.playbackState.isPlaying)
                                self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
                                    if (error == nil) {
                                        print("paused number 4")
                                    }
                                    else {
                                        print ("error in pausing!")
                                    }
                                })
                                }
                            } else {
                                    print ("switching within same player")
                            }
                            playerView_source_value = tappedCell.source
                            currently_playing_song_cell = tapIndexPath
                            currently_playing_song_id = tappedCell.trackidstring
                            currentPost = tappedCell.post
                            setup_player_view(tapped_cell: tappedCell) //we call this before playbutton because timer reset happens here and initialization happens further down in playbutton
                            self.playButton(cell: tappedCell)
                            self.youtubeplayer?.stopVideo()         //stops the last playing youtube cell
                            self.youtubeplayer2?.stopVideo()
                            self.miniplayer = false
                            self.miniplayer_just_started = false
                            youtubeplayer2.isHidden = true
                            temp_view2?.isHidden = true
                            currently_playing_youtube_cell = nil
                            no_other_video_is_active = true
                            update_global(cell_control: true, tapped_cell: tappedCell, tapped_index: currently_playing_song_cell!) //sync to global settings for current cell
                        }
                        
                    }else{ //if this cell is currently playing
                        if currently_playing_song_cell == tapIndexPath{
                            //we are pausing the cell so turn all currently playing flags to nil
                            currently_playing_song_id = ""
                            paused_cell = tapIndexPath
                            self.pauseButton(cell: tappedCell)
                            self.timer?.invalidate()
                            update_global(cell_control: true, tapped_cell: tappedCell, tapped_index: currently_playing_song_cell!)  //sync to global settings for current cell
                            currently_playing_song_cell = nil
                        }
                    }
                    }else{ //if the tapped cell is a video cell
                        if currently_playing_youtube_cell != nil{ //check if the tableview player is playing a previously tapped video cell
                            self.youtubeplayer?.stopVideo()  //stop it
                            self.youtubeplayer2?.stopVideo()
                            self.miniplayer = false
                            self.miniplayer_just_started = false
                            //youtubeplayer2.isHidden = true
                            currently_playing_youtube_cell = nil
                            self.timer.invalidate()
                            self.playBar.progress = 0
                        }
                        tappedCell.playerView.isUserInteractionEnabled = true
                        tappedCell.playerView.delegate = self                     //if a cell is a video cell, declare the tableview as its delegate,
                        youtubeplayer = tappedCell.playerView                     //so that we can have playback control on the 'last played' youtube
                        //tappedCell.playerView.bringSubview(toFront: tappedCell.playerView)
                        //WE MOVED THE LOADING OF THE VIDEO HERE FROM PostCell.swift - TO PREVENT SCROLL LAG - TRADEOFF - LOOKS SHITTY AND TAKES FOREVER TO LOAD BEFORE IT PLAYS - NEED TO FIND A WAY TO SHIFT THIS LOADING TO A BACKGROUND THREAD - RAN INTO A WEIRD ERROR WHEN I TRIED BEFORE
                        tappedCell.playerView.load(withVideoId: tappedCell.post.videoid , playerVars: ["autoplay": 1,"playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 1, "start": tappedCell.post.starttime, "end": tappedCell.post.endtime, "rel": 0, "iv_load_policy": 3])
                        //self.youtubeplayer?.playVideo()
                        tappedCell.playerView.isHidden = false                      //internal control because otherwise you would need two taps: 1 to
                        playerView_source_value = tappedCell.source
                        temp_duration = tappedCell.duration                         //enable user interaction and one to play the video
                        dismiss_player_view()
                        setup_player_view(tapped_cell: tappedCell)     //timer reset happens here, timer initialization happens in YTPlayerState check
                    }
                }
            }
        }
    }
    
    func fetchPosts()
    {
        Post.fetchPosts().done { posts in
            self.posts = posts
            self.tableView.reloadData()
        }
        self.tableView.reloadData()
        
    }
    
    func update_global(cell_control: Bool, tapped_cell: PostCell, tapped_index: IndexPath) {
        if (cell_control) {                     //"cell_control" : If true, we are setting the global variables as per the flags set by cell.play and cell.pause buttons
            allCells[tapped_index]?[0] = tapped_cell.playingflag
            allCells[tapped_index]?[1] = tapped_cell.pausedflag
            
        }else{                                  //else we are setting them by ourselves: usually to false, because we are force stopping something
            allCells[tapped_index]?[0] =  false
            allCells[tapped_index]?[1] = false
        }
        
    }
    
    func bring_up_player_view () {
        
        if (playingView?.isHidden == true){
            playingView?.isHidden = false
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.playingView?.frame = CGRect(x: 0, y: 568, width: 375, height: 50)
        }, completion: nil)
    }
    
    
    func setup_player_view(tapped_cell: PostCell){
        
        
        playingImage?.isHidden = true
        if tapped_cell.typeFlag != "video" {        //for a video cell we want the mini player to be hidden till we scroll away from the cell,
            //Bring up and setup the player view        //the mini player is brought up in the dequeue cell method. But we want set up everything else,
            if (playingView?.isHidden == true){         // because we might not be able to access the same cell again to call this method from dequeue method.
                playingView?.isHidden = false
            }
             playingImage?.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
               
                self.playingView?.frame = CGRect(x: 0, y: 568, width: 375, height: 50)
            }, completion: nil)
            
        }
        
        //if tapped_cell.typeFlag != "video" {
            playBar.progress = 0
            self.timer?.invalidate()
            duration = tapped_cell.duration
        
        //}
        
        songnameLabel?.text = tapped_cell.trackname
        playingImage?.image = tapped_cell.albumArtImage.image
        //youtubeplayer2 = tapped_cell.playerView
        //Bring up and setup the player view
//        helper.apple_search (song_name: "Don't Stop Me Now", song_id: "401145510").done { p1_struct in
//            print("!!!!!!!!!!!!!!!!!!---------------!!!!!!!!!!!!!!!!!!!!!")
//            print (p1_struct)
//                let p2_struct : song_db_struct = p1_struct
//            print (p2_struct)
//            print ("---------------------------------")
//            self.worker.get_this_song(target_catalog: "spotify", song_data: p2_struct).done {p1_found_id in
//                print ("Heya wtf bruh")
//                print (p1_found_id)
//                print ("Heya wtf bruh")
//            }
//        }
        
    }
    
    func dismiss_player_view(){
        print("dismiss_player_view")
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.playingView?.frame = CGRect(origin: CGPoint(x:0, y: (self.window?.frame.height)!), size: CGSize(width: 375, height: 50))
        }, completion: nil)
        
    }
    
    //THIS IS STUPID
    //THIS HAS TO BE SIMPLIFIED - GIVE MORE INFO TO THE POST SO THAT IT KNOWS WHAT HAS TO BE PLAYED INSTEAD OF SO MANY INFO CHECKS EVERY TIME PLAY/PAUSE IS HIT.
    
    func playButton(cell: PostCell) {
        if cell.playingflag == false {
            if cell.pausedflag == true {
                cell.playingflag = true
                cell.pausedflag = false
                print (cell.source)
                if cell.source == "spotify" {
                    print ("source is spotify")
                    print(cell.trackidstring)
                    if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                    self.spotifyplayer = SPTAudioStreamingController.sharedInstance()
                    self.spotifyplayer?.playSpotifyURI(cell.trackidstring, startingWith: 0, startingWithPosition: cell.offsetvalue, callback: { (error) in
                        if (error == nil) {
                            print("Spotify is playing! 1")
                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_spotify), userInfo: nil, repeats: true)
                            RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                            self.current_song_player = "spotify"
                            print(self.spotifyplayer?.metadata.currentTrack?.name)
                        }
                        else {
                            print ("error this one!")
                        }
                    })
                    } else if userDefaults.string(forKey: "UserAccount") == "Apple" {
                        if cell.helper_id != "default" {
                            self.appleplayer.play()
                            self.appleplayer.currentPlaybackTime = playerView_offsetvalue
                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
                            print ("Apple is playing")
                            self.current_song_player = "apple"
                        } else if cell.preview_url != "nil"{
                            self.play_av()
                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_av), userInfo: nil, repeats: true)
                            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
                            self.current_song_player = "av_player"
                        } else {
                            print ("Last resort gracious failure - song cannot be played")
                        }
                    } else {
                        print ("Error no UserAccount specified")
                    }
                } else if cell.source == "apple" {
                    print ("source is apple 1")
                    print (cell.trackidstring)
                    if userDefaults.string(forKey: "UserAccount") == "Apple" {
                        print (self.appleplayer.currentPlaybackTime)
                        self.appleplayer.play()
                        self.appleplayer.currentPlaybackTime = playerView_offsetvalue
                        self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
                        self.current_song_player = "apple"
                        print("Apple is playing")
                    } else if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                        if cell.helper_id != "default" {
                            self.spotifyplayer = SPTAudioStreamingController.sharedInstance()
                            self.spotifyplayer?.playSpotifyURI(cell.helper_id, startingWith: 0, startingWithPosition: cell.offsetvalue, callback: { (error) in
                            if (error == nil) {
                               print("Spotify is playing! 1")
                                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_spotify), userInfo: nil, repeats: true)
                                RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                                self.current_song_player = "spotify"
                               //print(self.spotifyplayer?.metadata.currentTrack?.name)
                            }
                            else {
                              print ("error this one!")
                                }
                            })
                        } else if cell.preview_url != "nil"{
                            self.play_av()
                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_av), userInfo: nil, repeats: true)
                            RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                            self.current_song_player = "av_player"
                        } else {
                            print ("Last resort gracious faliure - song cannot be played")
                        }
                    } else {
                        print ("Error no UserAccount specified")
                    }
                } else {
                    print ("something went wrong")
                }
            } else{
                cell.playingflag = true
                if cell.source == "spotify" {
                    print ("source is spotify 2")
                    print(cell.trackidstring)
                    print(cell.startoffset)
                    if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                        self.spotifyplayer = SPTAudioStreamingController.sharedInstance()
                        self.spotifyplayer?.playSpotifyURI(cell.trackidstring, startingWith: 0, startingWithPosition: currentPost.startoffset, callback: { (error) in
                            if (error == nil) {
                                print("Spotify is playing! 2")
                                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_spotify), userInfo: nil, repeats: true)
                                RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                                self.current_song_player = "spotify"
                                //print(self.Spotifyplayer?.metadata.currentTrack?.name)
                                //print(self.Spotifyplayer?.metadata.currentTrack?.albumName)
                                //print(self.Spotifyplayer?.metadata.nextTrack?.name)
                            } else {
                            print ("error this one!")
                            }
                        })
                    } else if userDefaults.string(forKey: "UserAccount") == "Apple" {
                        if cell.helper_id != "default" {
                            self.appleplayer.setQueue(with: [cell.helper_id])
                            //self.appleplayer.stop()
                            print ("current playback time after the stop \(self.appleplayer.currentPlaybackTime)")
                            print("should be calling setcurrentplaybacktime")
//                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.setcurrentplaybacktime), userInfo: nil, repeats: true)
//                            RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                            self.appleplayer.play()
                            //self.appleplayer.currentPlaybackTime = cell.startoffset //-> this does not work -> don't have a perfect workaround yet -> all the surrounding comments are the remnants of attempted workarounds - still se Domain=MPCPlayerRequestErrorDomain Code=1 "No commands provided." intermittently - need to open bug with Apple
                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                            RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                            //self.super_temp_flag = true
                            //self.set_current_playback_time()
                            //self.set_curr_playback()
                            print("Apple is playing")
                            self.current_song_player = "apple"
                        } else if cell.preview_url != "nil" {
                            self.download_preview(url: URL(string: cell.preview_url)!)
                        } else {
                            print ("Last resort gracious faliure - song cannot be played")
                        }
                    } else {
                        print ("Error no UserAccount specified")
                    }
                } else if cell.source == "apple"{
                    print ("source is apple")
                    print (cell.trackidstring)
                    print (currentPost.startoffset)
                    if userDefaults.string(forKey: "UserAccount") == "Apple" {
                        self.appleplayer.setQueue(with: [cell.trackidstring])
                        //self.appleplayer.stop()
                        print ("current playback time after the stop \(self.appleplayer.currentPlaybackTime)")
                        print("should be calling setcurrentplaybacktime")
//                        self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.setcurrentplaybacktime), userInfo: nil, repeats: true)
//                        RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                        self.appleplayer.play()
                        //self.appleplayer.currentPlaybackTime = cell.startoffset //-> this does not work -> don't have a perfect workaround yet -> all the surrounding comments are the remnants of attempted workarounds - still se Domain=MPCPlayerRequestErrorDomain Code=1 "No commands provided." intermittently - need to open bug with Apple
                        self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                        RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                        self.super_temp_flag = true
                        //self.set_current_playback_time()
                        //self.set_curr_playback()
                        self.current_song_player = "apple"
                        print("Apple is playing")
                    } else if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                        if cell.helper_id != "default" {
                            print (cell.helper_id)
                            self.spotifyplayer = SPTAudioStreamingController.sharedInstance()
                            self.spotifyplayer?.playSpotifyURI(cell.helper_id, startingWith: 0, startingWithPosition: currentPost.startoffset, callback: { (error) in
                                if (error == nil) {
                                    print("Spotify is playing! 2")
                                    self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_spotify), userInfo: nil, repeats: true)
                                    RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                                    self.current_song_player = "spotify"
                                    //print(self.Spotifyplayer?.metadata.currentTrack?.name)
                                    //print(self.Spotifyplayer?.metadata.currentTrack?.albumName)
                                    //print(self.Spotifyplayer?.metadata.nextTrack?.name)
                                } else {
                                    print ("error this one!")
                                }
                            })
                        } else if cell.preview_url != nil {
                            self.download_preview(url: URL(string: cell.preview_url)!)
                        } else {
                            print ("Last resort gracious faliure - song cannot be played")
                        }
                    } else {
                        print ("Error no UserAccount specified")
                    }
 
                } else {
                    print ("something went very wrong")
                }
            }
        } else{
            print ("song is playing")
        }
    }

    
    func pauseButton(cell: PostCell) {
        if cell.playingflag == true {
            print (cell.source)
            if cell.source == "spotify" {
                print ("source is spotify 3")
                if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
                    if (error == nil) {
                        print("paused number 5")
                        cell.offsetvalue = (self.spotifyplayer!.playbackState.position)
                    }
                    else {
                        print ("error in pausing!")
                    }
                })
                } else if userDefaults.string(forKey: "UserAccount") == "Apple" {
                    if cell.helper_id != "default" {
                        cell.offsetvalue = self.appleplayer.currentPlaybackTime
                        playerView_offsetvalue = self.appleplayer.currentPlaybackTime
                        self.appleplayer.pause()
                    } else if cell.preview_url != "nil"{
                        self.pause_av()
                    } else {
                        print ("Last resort gracious faliure - Trying ot pause after error")
                    }
                } else {
                    print ("Error no UserAccount specified")
                }

            }else if cell.source == "apple" {
                print ("source is apple")
                print (self.appleplayer.currentPlaybackTime)
                if userDefaults.string(forKey: "UserAccount") == "Apple" {
                    cell.offsetvalue = self.appleplayer.currentPlaybackTime
                    playerView_offsetvalue = self.appleplayer.currentPlaybackTime
                    self.appleplayer.pause()
                    //self.offsetvalue = self.musicPlayerController.currentPlaybackTime
                } else if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                    if cell.helper_id != "default" {
                        self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
                            if (error == nil) {
                                print("paused number 5")
                                cell.offsetvalue = (self.spotifyplayer!.playbackState.position)
                            }
                            else {
                                print ("error in pausing!")
                            }
                        })
                    } else if cell.preview_url != "nil"{
                        self.pause_av()
                    } else {
                        print ("Last resort gracious faliure - Trying ot pause after error")
                    }
                } else {
                    print ("Error no UserAccount specified")
                }
            }else {
                print ("something went wrong")
            }
            
            cell.pausedflag = true
            cell.playingflag = false
            //self.offsetvalue = (self.Spotifyplayer!.playbackState.position)
            
        }else {
            print ("nothing is playing")
        }
    }
    
    
    
    func download_preview (url : URL) {
        
        var download_task = URLSessionDownloadTask()
        
        download_task = URLSession.shared.downloadTask(with: url, completionHandler: {(downloadedURL, response, error) in
            
            self.initiate_av(url: downloadedURL!)
        })
        
        download_task.resume()
    }
    
    func initiate_av (url : URL) {
        
        
        do {
            av_player = try AVAudioPlayer(contentsOf: url)
            av_player.prepareToPlay()
            av_player.play()
            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_av), userInfo: nil, repeats: true)
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
            self.current_song_player = "av_player"
        } catch {
            print (error)
        }
    }
    
    func play_av () {
        
        av_player.play()
    }
    
    func pause_av () {
        
        av_player.pause()
    }
    

}




//datasource for the table view: populating the view
extension NewsFeedTableViewController{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let posts = posts {  //because it is optional
            return posts.count   //number of sections = number of posts
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = posts {
        return 1    //there is only one row in every section
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
//     let cell = tableView.cellForRow(at: indexPath) as! PostCell
//
//        if cell.post.flag == "video" {
//
//
//            DispatchQueue.global(qos: .userInitiated).async {
//            cell.playerView.load(withVideoId: cell.post.videoid , playerVars: ["playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 1, "start": cell.post.starttime, "end": cell.post.endtime, "rel": 0])
//            }
//
//        }
//
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.postCell, for: indexPath) as! PostCell
        
        
        cell.post = self.posts?.reversed()[indexPath.section]
        
        //cell.imageView?.loadImageUsingCacheWithUrlString(imageurlstring: cell.post.albumArtUrl)
        
        if (cell.post.flag == "video"){
            
//            DispatchQueue.global(qos: .utility).async {
//                        print ("async is happenning now cell is \(indexPath)")
//                        cell.playerView.load(withVideoId: cell.post.videoid , playerVars: ["playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 1, "start": cell.post.starttime, "end": cell.post.endtime, "rel": 0])
//                        }
            
            executed_once = false
            switch(cell.playerView.playerState()){
            case YTPlayerState.buffering:
                print("bufferring")
            case YTPlayerState.ended:
                print("ended")
            case YTPlayerState.unstarted:
                print("unstarted")
            case YTPlayerState.queued:
                print("queued")
            case YTPlayerState.playing:
                print("playing")
            case YTPlayerState.paused:
                print("paused number 6")
            default:
                print("none of these")
            }
            
            if cell.playerView.playerState() != YTPlayerState.playing {
            print("unstarted cell")
            cell.playerView.isUserInteractionEnabled = false
            }
            
            /* moved to tapEdit
            cell.playerView.delegate = self                     //if a cell is a video cell, declare the tableview as its delegate,
            youtubeplayer = cell.playerView                     //so that we can have playback control on the 'last played' youtube
            temp_duration = cell.duration
            */
            last_viewed_youtube_cell = indexPath                //video cell from the newsfeedcontroller
            
        }
        print (mainWindow!.frame.height)
        print (UIScreen.main.bounds.height)
        print ("right before the block ")
        print("currently_playing_youtube_cell is \(currently_playing_youtube_cell)")
        print (self.miniplayer)
        if currently_playing_youtube_cell != nil && self.miniplayer == false {
            print("currently_playing_youtube_cell is \(currently_playing_youtube_cell)")
            print("indexpath is \(indexPath[0])")
            let var1: Int = currently_playing_youtube_cell?[0] ?? 0    //the position of the youtube cell
            let var2: Int = indexPath[0]                               //the position of the dequed cell
            print(var1)
            print(var2)
            var diff : Int = var1 - var2                               //difference in position
            print (diff)
            if abs(diff) == 2 {                                        //if they have a full cell between them, we want to bring up the miniplayer.
                print ("1")
                if ((self.youtubeplayer?.currentTime()) != nil) {
                    print ("2")
                    self.miniplayer = true                   //this variable indicates that the miniplayer is currently playing
                    self.miniplayer_just_started = true      //used to avoid invalidating timer when post youtube player is paused.
                    youtubeplayer2.isHidden = false
                    temp_view2?.isHidden = false
                    bring_up_player_view()
                    print(self.youtubeplayer?.currentTime())
                    let time : Float = (self.youtubeplayer?.currentTime())! + 3.00
                    youtubeplayer2.cueVideo(byId: currentPost.videoid, startSeconds: time, endSeconds: currentPost.endtime, suggestedQuality: YTPlaybackQuality.default)
                    youtubeplayer2.playVideo()
                    switch(cell.playerView.playerState()){
                    case YTPlayerState.buffering:
                        print("bufferring")
                    case YTPlayerState.ended:
                        print("ended")
                    case YTPlayerState.unstarted:
                        print("unstarted")
                    case YTPlayerState.queued:
                        print("queued")
                    case YTPlayerState.playing:
                        print("playing")
                    case YTPlayerState.paused:
                        print("paused number 6")
                    default:
                        print("none of these")
                    }
                    if youtubeplayer2.playerState() == YTPlayerState.playing {
                        print ("state is playing")
                    } else {
                        print ("no it's not playing")
                    }
                }else {
                    print ("Error: MiniPlayer: Can't grab current time from youtube player for youtube player 2 ")
                }
            }
        }
        
        /*
        cell.player = SPTAudioStreamingController.sharedInstance()
        cell.player?.playbackDelegate = self as SPTAudioStreamingPlaybackDelegate
        cell.player?.delegate = self as SPTAudioStreamingDelegate
        */
        
        print(indexPath)
        cell.pausedflag = allCells[indexPath]?[1]
        print (allCells[indexPath]?[1] as Any)
        cell.playingflag = allCells[indexPath]?[0]
        print (allCells[indexPath]?[0])
        print (allCells[indexPath]?[2])
        /*
        if allCells[indexPath]?[2] == false {
            cell.timer?.invalidate()
            cell.progressBar.progress = 0.0
        }
        */
        cell.selectionStyle = .none
        return cell
    }
    
    
    func expandSong(post: Post) {
        //1.
        guard let maxiCard = storyboard?.instantiateViewController(
            withIdentifier: "MaxiSongCardViewController")
            as? MaxiSongCardViewController else {
                assertionFailure("No view controller ID MaxiSongCardViewController in storyboard")
                return
        }
        
        
        
        //var temp_frame: Frame!
        
        //2.
        
//        let contentOffset = tableView.contentOffset
//        
//        UIGraphicsBeginImageContextWithOptions(tableView.bounds.size, true, 1)
//        
//        let context = UIGraphicsGetCurrentContext()
//        
//        context?.translateBy(x: 0.0, y: -contentOffset.y)
//        
//        tableView.layer.render(in: context!)
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        
        //maxiCard.backingImage = image
        maxiCard.backingImage = tableView.makeSnapshot()
        //3.
        maxiCard.trackid = post.trackid
        maxiCard.song_name = post.songname
        maxiCard.play_bar_time = self.playBar.progress
        maxiCard.post = post
        maxiCard.second_counter = it_has_been_a_second
        
        
        
        //temp_frame.originatingFrameInWindow = CGRect(x: 0, y: 568, width: 375, height: 50)
        //temp_frame.originatingCoverImageView = self.playingImage!
        
        
        maxiCard.originatingFrameInWindow = CGRect(x: 0, y: 568, width: 375, height: 50)
        maxiCard.originatingCoverImageView = self.playingImage!
        
        if let tabBar = tabBarController?.tabBar {
            maxiCard.tabBarImage = tabBar.makeSnapshot()
        }
        
            
        
        //4.
        present(maxiCard, animated: false)
    }
    
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        if self.miniplayer! {
            self.youtubeplayer2.playVideo()
        } else {
            self.youtubeplayer?.playVideo()
        }
    }
    
    
}

extension UIProgressView {
    
    func animate(duration: Double) {
        
        setProgress(0.01, animated: true)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            self.setProgress(1.0, animated: true)
        }, completion: nil)
    }
}



/*
extension NewsFeedTableViewController: MaxiPlayerSourceProtocol {
    var originatingFrameInWindow: CGRect {
        let windowRect = playingView?.convert((playingView?.frame)!, to: nil)
        return windowRect!
    }
    
    var originatingCoverImageView: UIImageView {
        return playingImage!
    }
    
    
}

extension NewsFeedTableViewController {
    func expandSong(post: Post) {
        //1.
        guard let maxiCard = storyboard?.instantiateViewController(
            withIdentifier: "MaxiSongCardViewController")
            as? MaxiSongCardViewController else {
                assertionFailure("No view controller ID MaxiSongCardViewController in storyboard")
                return
        }
        
        //2.
        maxiCard.backingImage = view.makeSnapshot()
        //3.
        maxiCard.trackid = post.trackid
        
        maxiCard.sourceView.originatingFrameInWindow = (self.playingView?.frame)!
        maxiCard.sourceView.originatingCoverImageView = self.playingImage!
        
        if let tabBar = tabBarController?.tabBar {
            maxiCard.tabBarImage = tabBar.makeSnapshot()
        }
        
        //4.
        present(maxiCard, animated: false)
    }
}

*/


extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
