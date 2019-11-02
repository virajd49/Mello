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
import YoutubeKit
import YoutubePlayer_in_WKWebView


/* This is the New Feed and there are a few moving parts involved here:
 
    1. Posts being fetched and displayed as we scroll
    2. Appleplayer, spotifyplayer, youtube player - handle play/pause/stop for each and stop others when one plays scenarios
    3. The player view - the small player that shows up at the bottom when you click on a post.
    4. The player view post expansion into full sized player card - this has separate implementations for audio posts and video(youtube) posts.
    5. Add to my library view - this view shows up when you click the 'download/get button' for any post
 
 
 - The player view: Here is how I was trying to make it work:
    - When you click on a song post, the song starts playing, the player view is made visible(or if it was already visible then it stays visible) is loaded with details from the current post. The playBar progress bar is started to show progress of the song.
    - Now if you scroll away, the player shows you what post is playing and what the progress is. You can tap on the player view to expand it to see the post in full screen view at any time.
 - If you tap on the player view without expanding it the post with play/pause depending on the playback state. If you play a post and don't scroll way you can control playback by tapping the post too. Once you scroll away and come back the post has been reloaded so if you tao on it, it should start as a new post, it wont control playback for the currently playing post, even if they both are the same.
 - When you play a song post 1 timer is fired, the one for the player view.
 
 - With youtube posts there are big probelms with this feature:
 1. You can only have one youtube video playing on the screen at a time. So the post video and the player view video cannot be visible at the same time, or so I've found, maybe I didn't try hard enough.
 - Because of this, when you play a youtube post, the player view is initially dismissed. Now, if you don't scroll away you can control playback from the post video and the player view won't show up.
 - When you scroll away and you go past more than 1 cell after the playing video post, the player view pops up and the miniplayer video starts - now this is the tricky part - what I had to do here was, grab the current playback time of the playing video post, load the miniplayer youtube video with the starttime as the current playback time of the playing post video, so the miniplayer starts off exactly where the post player stops. The post player is stopped automatically when the miniplayer starts. The problem is because youtube takes too long to load, and I havent been able to push the loading to a background thread, there is a very evident mismatch between the post video stopping and the miniplayer starting. Sometimes, the timing works prefect, sometimes there is a full second pause between the stop and start, sometimes the post player keeps playing for too long after I have grabbed the currentplayback time, so the miniplayer actually plays some part that has already been played.  - This needs major improvements or a complete revamp.
 - Also another issue in this whole switch over from post video player to player view miniplayer involves switching the progress bar too. When the post video player is playing the progress bar increment follows one youtube player, when it is switched over, it has to follow a different youtube player, this switch does not happen smoothly and is mostly because the miniplayer takes so long to buffer and start playing. 

 
 */

enum MyError: Error {
    case runtimeError(String)
}

class NewsFeedTableViewController: UITableViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, YTSwiftyPlayerDelegate, WKYTPlayerViewDelegate  {
    
    
    // MARK: new variables to experiment with autoplay
    
    var first_cell: PostCell!
    var upper_cell: PostCell!
    var lower_cell: PostCell!
    var current_cell: PostCell!
    var upper_cell_visible_portion: CGFloat!
    var scroll_content_offset: CGFloat!
    var nav_bar_height: CGFloat!
    var status_bar_height: CGFloat!
    var lower_cell_origin_y: CGFloat!
    var fresh_load: Bool!
    var timer_current_value: Double! = 0.0
    var timer_new_value: Double! = 0.0
    var orange_square: UIView!
    var playerMaster = MusicPlayerMaster()
    var playable_posts = [PlaybackPost]()
    
    // MARK: Variable and instance declarations
    
  
    var super_temp_flag = true //this was being used for multiple experiments with setting the apple current playback time. All failed. Full description futher down the file.
    
    //var poller = now_playing_poller.shared //this is a singleton, accessed from all over the app tp grab the currently playing song from spotify/apple
    
//Forgot what I was using this for and nothing seems to be amiss if I comment it out  - ignore for now.
/*
    var navBarImage: UIImageView?
    var navBarImageView: UIView?
    var navBarImageView_leadConstraint : NSLayoutConstraint?
    var navBarImageView_trailConstraint : NSLayoutConstraint?
    var navBarImageView_topConstraint : NSLayoutConstraint?
    var navBarImageView_botConstraint : NSLayoutConstraint?
 */
    
    //All of this is for the player card that the small player expands into
    var dismiss_chevron: UIButton?
    var tabBarImageView: UIImageView?
    var tabBarImageView_leadConstraint : NSLayoutConstraint?
    var tabBarImageView_trailConstraint : NSLayoutConstraint?
    var tabBarImageView_topConstraint : NSLayoutConstraint?
    var tabBarImageView_botConstraint : NSLayoutConstraint?
    var name_label: UILabel?
    var artist_label: UILabel?
    var duration_label: UILabel?
    var prog_bar: UIProgressView?    //this is for the container view
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
    
    
    //These three are used for progress bar increments by updateProgress functions
    var the_temp: Float?
    var the_new_temp: Float?
    var it_has_been_a_second: Int?
    var current_song_player: String?     //Used by Update Progress to grab the current time from the right player. Updated everywhere a player is played.
    
    var miniplayer_is_playing: Bool? //used to indicate if the small youtube player is playing or not
    var miniplayer_just_started: Bool?
    
    //These are used for the cross platform song search algorithm
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
 
    
    var songnameLabel: UILabel?
    var playingImage: UIImageView?
    var spotifyplayer: SPTAudioStreamingController?
    var appleplayer = MPMusicPlayerController.applicationMusicPlayer
    var wkyoutubeplayer: WKYTPlayerView!
    var youtubeplayer2: YTPlayerView!
    var playingView: UIView?
    var timer = Timer()
    var duration: Float!
    var temp_duration: Float!
    var playBar : UIProgressView!   //this is for the small player view
    var executed_once: Bool!
    var playerView_offsetvalue: TimeInterval! //offset value for separate play/pause routine held by player_view
    var playerView_source_value: String!
    //let playlist_access = UserAccess(myPlaylistQuery: MPMediaQuery.playlists(), myLibrarySongsQuery: MPMediaQuery.songs(), mypodcastsQuery: MPMediaQuery.podcasts())
    let window = UIApplication.shared.keyWindow
    var currentPost: Post!
    struct Storyboard {
        
        static let postCell = "PostCell"
        static let postCellDefaultHeight : CGFloat = 550.0
        
    }
   //let getView = BottomView()
    var spotify_mediaItems: [SpotifyMediaObject.item]!
    var apple_mediaItems: [[MediaItem]]!

    @objc func showBottomView(sender: UIButton){
        /*
        Post.dict_posts()
        print(self.currently_playing_song_id!)
        getView.bringupview(id: self.currently_playing_song_id! as String)
        */
        
        //self.appleMusicManager.performItunesCatalogSearchNew(with: "Why'd you push that button?", countryCode: "us")
        
        
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
                                         [9,0] : [false, false, false],
                                         [10,0] : [false, false, false],
                                         [11,0] : [false, false, false],
                                         [12,0] : [false, false, false]]
    
    //global flags used to help with switching from one post to another
    var currently_playing_song_cell: IndexPath! //last tapped/currently playing cell, so that we can stop it if a youtube video starts playing
    var currently_playing_youtube_cell: IndexPath! //last tapped/currently playing youtube cell, so that we can stop it if a youtube video starts playing
    var currently_playing_song_id: String!
    var paused_cell: IndexPath?
    var last_viewed_youtube_cell: IndexPath?
    var no_other_video_is_active = true     //flag makes sure that the table view controller acts as the delegate of only one youtube player
    
    //Used for miniplayer to large player card expansion
    var dark = false
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if (dark) {
            return .lightContent
        } else {
            return .default
        }
    }
    
    func initialize_allcells() {
        for i in 0..<self.posts!.count {
            allCells.updateValue([false, false, false], forKey: [i, 0])
        }
    }
  
    
    // MARK: ViewdidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Newsfeed view did load")
        
        nav_bar_height = self.navigationController?.navigationBar.frame.height
        status_bar_height = UIApplication.shared.statusBarFrame.height
        //appleMusicControl.requestStorefrontCountryCode()
        enlarged = false
        /* Note to future self
                   Project2[54907:4396030] [Middleware] FINISH Request: <MPCPlayerRequest: 0x283ee9b00 label=MPMusicPlayerController playerPath=<MPCPlayerPath: route=<MPAVEndpointRoute: 0x2825570c0 name=iPhone uid=LOCAL> bundleID=com.apple.MediaPlayer.RemotePlayerService pid=54918 playerID=MPMusicPlayerApplicationController>> Response: (null) [0.073007s] error: Error Domain=MPRequestErrorDomain Code=1 "(null)" UserInfo={MPRequestUnderlyingErrorsUserInfoKey=(
                       "Error Domain=MPCPlayerRequestErrorDomain Code=2000 \"Failed to get play queue identifers\" UserInfo={NSDebugDescription=Failed to get play queue identifers, NSUnderlyingError=0x281cc4de0 {Error Domain=kMRMediaRemoteFrameworkErrorDomain Code=35 \"Could not find the specified now playing client\" UserInfo={NSLocalizedDescription=Could not find the specified now playing client}}}"
                       )}
        */
        /* The above error was showing up repeatedly to the point where the app would crash with a out-of-memory warning - spent a LOT of time trying to figure out the cause - narrowed it down to something between the apple player and youtube player - tried out a lot of combinations of keeping one and removing the other etc, nothing worked, in the end, commented out the beginGeneratingPlaybackNotifications line and let it run once without it - did not see the messages - added the line back in - messages did not show up again*/
        self.appleplayer.beginGeneratingPlaybackNotifications()
      
        self.spotifyplayer = SPTAudioStreamingController.sharedInstance()
        
        NotificationCenter.default.addObserver(self,
                                       selector: #selector(handleMusicPlayerControllerPlaybackStateDidChange),
                                       name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                       object: self.appleplayer)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: secret_key), object: nil, queue: nil, using: handleMusicPlayerControllerPlaybackStateDidChange_fromSongPlayController)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.firebase_addition), name: Notification.Name(rawValue: "FireBaseloginSuccessfull"), object: nil )
         NotificationCenter.default.addObserver(self, selector: #selector(stopAudioplayerforYoutube(notification:)), name: Notification.Name(rawValue: "Stop Audio Player!"), object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(stop_newsfeed_player(notification:)), name: Notification.Name(rawValue: "Stop NewsFeed Player!"), object: nil)
        
        // Adding the currently playing bar on top of the table view
        playingView = UIView(frame: CGRect(origin: CGPoint(x:0, y: (window?.frame.height)!), size: CGSize(width: 375, height: 50)))
        playingView?.backgroundColor = UIColor.white
        self.navigationController?.view.addSubview(playingView!)
        
        /*  All of the following is for the animation where the small youtube player expands into the big youtube player
            It is done in the fashion of how the apple player shows up, but in a hacky way.
         I followed this guide: https://www.raywenderlich.com/221-recreating-the-apple-music-now-playing-transition to make the transition animation for audio posts, but that involves presenting another controller and I couldnt figure out how to pass the youtube player to a different controller without causing a proper stop and start in the video.
         */
        
        
        //---------------SETTINGS START HERE ------------------------------//
        
        //temp_view2 contains the small youtube player, we manipulate these temp_view2 contraints for the animation. What I basically wanted to implement was the youtube player expanding smoothly from a small square to a large square. But something about the webview that the actual youtube player is in does not let that happen.
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
        
        //temp_view is the black background way at the back
        temp_view = UIView(frame: (UIApplication.shared.keyWindow?.frame)!)
        temp_view?.backgroundColor = UIColor.black
        
        let aspectRatio1 = self.mainWindow!.frame.height / self.mainWindow!.frame.width
        mainWindow!.addSubview(self.temp_view!)
        
        //backingImageView is the snapshot of the tableviewcontroller that looks like it is receding into the back like a card - this sits on top of temp_view, we manipulate the following contraints for the animation
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
        
        
        //this is a layer that sits on top of the backingImageView and dims everything underneath to add to the effect of everything being in the background
        dimmmerLayer = UIView(frame: (UIApplication.shared.keyWindow?.frame)!)
        dimmmerLayer?.backgroundColor = UIColor.black
        dimmmerLayer?.alpha = 0
        mainWindow!.addSubview(self.dimmmerLayer!)
        dimmmerLayer?.isHidden = true
        
        
        //The conatiner view is the big white card like player view which contains the fully expanded youtube player  - this sits on top of the dimmer view
        containerView = UIView(frame: CGRect(origin: CGPoint(x:0, y: 568), size: CGSize(width: 375.0, height: 647.0)))
        containerView?.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        containerView?.layer.cornerRadius = 0
        
        //The conatiner view has all the following buttons and labels
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
        
        
        //Setting up contraints for everything inside the card player view
        self.containerView?.addConstraintWithFormat(format: "H:|-169.5-[v0]-169.5-|", views: self.dismiss_chevron!)
        self.containerView?.addConstraintWithFormat(format: "H:|-16-[v0]-16-|", views: self.name_label!)
        self.containerView?.addConstraintWithFormat(format: "H:|-16-[v0]-16-|", views: self.artist_label!)
        self.containerView?.addConstraintWithFormat(format: "H:|-16-[v0]-16-|", views: self.duration_label!)
        self.containerView?.addConstraintWithFormat(format: "H:|-22.5-[v0]-22.5-|", views: self.prog_bar!)
        self.containerView?.addConstraintWithFormat(format: "V:|-4-[v0]-355-[v1]-8-[v2]-8-[v3]-20-[v4]-150-|", views: self.dismiss_chevron!, self.name_label!, self.artist_label!, self.duration_label!, self.prog_bar!)

        mainWindow!.addSubview(self.containerView!)
        
        //we manipulate these constraints to animate the view into it's place
        self.containerView!.translatesAutoresizingMaskIntoConstraints = false
        containerView_leadConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        containerView_trailConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        containerView_topConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 568)
        containerView_botConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 531)
        mainWindow?.addConstraints([containerView_topConstraint!, containerView_botConstraint!, containerView_leadConstraint!, containerView_trailConstraint!])
        containerView?.isHidden = true
        
        
        //So because the temp_view, backingImageview, dimmer_layer and container_view basically sit on top of everything in the controller - but are hidden until required - when they are shown the tab bar goes away all of a sudden because it's actually below them. So to make it go away in a nicer way, we take a snapshot of the tab bar, place it exactly where the real tabbar is - make it hidden - and when all the above views are shown, we make this snapshot visible and then animate-slide it out of the bottom of the view.
        tabBarImageView = UIImageView(frame: CGRect(origin: CGPoint(x:0, y: 618), size: CGSize(width: 375.0, height: 49))) // 375 x 49
        mainWindow?.addSubview(tabBarImageView!)
        self.tabBarImageView!.translatesAutoresizingMaskIntoConstraints = false
        
        //we use these contraints to animate it out of view
        tabBarImageView_leadConstraint = NSLayoutConstraint(item: tabBarImageView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        tabBarImageView_trailConstraint = NSLayoutConstraint(item: tabBarImageView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        tabBarImageView_topConstraint = NSLayoutConstraint(item: tabBarImageView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 618)
        tabBarImageView_botConstraint = NSLayoutConstraint(item: tabBarImageView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        mainWindow?.addConstraints([tabBarImageView_topConstraint!, tabBarImageView_botConstraint!, tabBarImageView_leadConstraint!, tabBarImageView_trailConstraint!])
        tabBarImageView?.isHidden = true
        
        
        //Forgot what I was using this for and nothing seems to be amiss if I comment this out so...we can ignore this for now
        /*
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
        */
        
        //We add the temp_view2 at the very end because we need it to be on top of all the views we added so far. The small youtube player sits within this temp_view2
        mainWindow!.addSubview(self.temp_view2!)
        temp_view?.isHidden = true
        
        print (backingImageView?.layer.frame.height)
        print (backingImageView?.layer.frame.width)
        print (backingImageView?.frame.height)
        print (backingImageView?.frame.width)
        
        //the small youtube player that shows up in the miniplayer view
        //Setting it up inside temp_view2
        youtubeplayer2 = YTPlayerView.init(frame: CGRect(x: 12, y: 573, width: 40, height: 40))
        youtubeplayer2.contentMode = UIView.ContentMode.scaleAspectFit
        mainWindow!.bringSubviewToFront(self.temp_view2!)
        self.temp_view2?.addSubview(self.youtubeplayer2!) //small youtube player sits in temp_view2
        self.temp_view2?.addConstraintWithFormat(format: "H:|-0-[v0]-0-|", views: self.youtubeplayer2)
        self.temp_view2?.addConstraintWithFormat(format: "V:|-0-[v0]-0-|", views: self.youtubeplayer2)
        self.temp_view2!.translatesAutoresizingMaskIntoConstraints = false
        self.temp_view2?.bringSubviewToFront(youtubeplayer2)
        youtubeplayer2.backgroundColor = UIColor.black
        //youtubeplayer2?.delegate = self
        youtubeplayer2.isHidden = true
        temp_view2?.isHidden = true
        
        //wkyoutubeplayer = YTPlayerView.init(frame: CGRect(x: 0, y: 0 , width: 375, height: 375))
        //wkyoutubeplayer.contentMode = UIView.ContentMode.scaleAspectFit
        //wkyoutubeplayer.load(withVideoId: "kyAA2C5wk4Y" , playerVars: [ "playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 1, "rel": 0, "iv_load_policy": 3])
        
        
        wkyoutubeplayer = newsfeed_yt_player
        wkyoutubeplayer.isUserInteractionEnabled = false
        wkyoutubeplayer.isHidden = true
        
        
        
        
        orange_square = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 375))
        orange_square.backgroundColor = UIColor.orange
        orange_square.isHidden = true
        //---------------------------SETTINGS END HERE---------------------------//
        
    
        //Playing view is the small view(miniplayer) that shows up just above the tab bar when you play a post.
        
        //--------------------------SETTINGS BEGIN HERE-------------------------//
        songnameLabel = UILabel(frame: CGRect(origin: CGPoint(x:67, y:5), size: CGSize(width: 203, height:37)))
        songnameLabel?.text = "Song Name"
        songnameLabel?.textAlignment = NSTextAlignment.center
        songnameLabel?.font = songnameLabel?.font.withSize(13)
        playingView?.addSubview(songnameLabel!)
        it_has_been_a_second = 0
        current_song_player = "apple"
        the_temp = 0.0
        the_new_temp = 0.0
        
        playingImage = UIImageView(image: #imageLiteral(resourceName: "clapton"))
        playingImage?.contentMode = UIView.ContentMode.scaleAspectFill
        playingImage?.frame = CGRect(x: 12, y: 5, width: 40, height: 40)
        playingView?.addSubview(playingImage!)
        
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
        
        //------------------------SETTINGS END HERE---------------------------//
        
        
        
        playerView_source_value = "default"
        duration = 60
        miniplayer_is_playing = false
        miniplayer_just_started = false
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(tapEdit2(recognizer:)))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(tapEdit3(recognizer:)))
        let tapGesture4 = UISwipeGestureRecognizer(target: self, action: #selector(tapEdit4(recognizer:)))
        tapGesture4.direction = UISwipeGestureRecognizer.Direction.down
        //temp_view?.addGestureRecognizer(tapGesture4)
        containerView?.addGestureRecognizer(tapGesture4) //This gesture closes the expanded youtube player view back to the small youtube player playing in the miniplayer
        
        //This tap gesture is the one that plays or pauses a post when you tap on it
        tableView.addGestureRecognizer(tapGesture)
        
        //This tap gesture is the one that plays or pauses a post when you tap on the player view
        playingView?.addGestureRecognizer(tapGesture2)
        
        
        //playingImage?.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self as? UIGestureRecognizerDelegate
        tapGesture2.delegate = playingView as? UIGestureRecognizerDelegate
        
        //index_for_progress_bar = nil //when you hit pause, spotify stops the song, but the progress bar keeps running. This variable is part of the functionality that pauses and restarts the progress bar
        
        
        //initiate global flags
        currently_playing_youtube_cell = nil
        last_viewed_youtube_cell = nil
        currently_playing_song_cell = nil
        currently_playing_song_id = ""
        
        
        //grab all the posts for the newfeed
        self.fetchPosts()
        
        
        self.spotifyplayer?.playbackDelegate = self as SPTAudioStreamingPlaybackDelegate
        self.spotifyplayer?.delegate = self as SPTAudioStreamingDelegate
        self.wkyoutubeplayer?.delegate = self
        
        print(allCells)
        
        let play = false
        print (play)
        print("oi")

        tableView.estimatedRowHeight = Storyboard.postCellDefaultHeight //estimate the minimum height to  be this value
        tableView.rowHeight = UITableView.automaticDimension //Actual height resized as per autolayout
        tableView.separatorColor = UIColor.clear //we don't want the default separator between the cells to be seen
    }
    
    
    @objc func stop_newsfeed_player(notification: NSNotification) {
        print("Something is started playing in FriendUpdateController - stop News Feed player")
        self.timer.invalidate()
        if currently_playing_song_cell != nil {
            allCells[currently_playing_song_cell]?[0] =  false
            allCells[currently_playing_song_cell]?[1] = false
            currently_playing_song_cell = nil
        }
        
    }
    
    // MARK: APPLE MUSIC PLAYBACK TIME EXPERIMENTS
    //------------------------------------------------------------------------------------------------------------------------------------------------------//
    
    /* We let users select the 20 - 30 second part of the song that they want to post. So when we play a song from a post, it should start playing from whatever point the user selected. This does not work for the applemusic player. The playback simply doesn't start or starts from the beggining. Following are all my attempts to make it work, I have filed a bug with apple, no response so far. These functions are called from the play/pause routines further down the file.
     
        none of the following three functions work -> don't have a perfect workaround yet -> all the surrounding comments are the remnants of attempted workarounds - still see Domain=MPCPlayerRequestErrorDomain Code=1 "No commands provided." intermittently - need to open bug with Apple
     */
    /*
    @objc func setcurrentplaybacktime() {
        
        print ("cureent playback time is \(self.appleplayer.currentPlaybackTime)")
        if ((self.appleplayer.playbackState == .playing) && (self.appleplayer.currentPlaybackTime > 0.01)) {
            self.timer.invalidate()
            print(Float((self.appleplayer.currentPlaybackTime)))
            self.appleplayer.currentPlaybackTime = 0.0 //->setting this to anyhting other than 0 causes a lot of error logs of this kind :
            /*
            Project2[54907:4396030] [Middleware] FINISH Request: <MPCPlayerRequest: 0x283ee9b00 label=MPMusicPlayerController playerPath=<MPCPlayerPath: route=<MPAVEndpointRoute: 0x2825570c0 name=iPhone uid=LOCAL> bundleID=com.apple.MediaPlayer.RemotePlayerService pid=54918 playerID=MPMusicPlayerApplicationController>> Response: (null) [0.073007s] error: Error Domain=MPRequestErrorDomain Code=1 "(null)" UserInfo={MPRequestUnderlyingErrorsUserInfoKey=(
                "Error Domain=MPCPlayerRequestErrorDomain Code=2000 \"Failed to get play queue identifers\" UserInfo={NSDebugDescription=Failed to get play queue identifers, NSUnderlyingError=0x281cc4de0 {Error Domain=kMRMediaRemoteFrameworkErrorDomain Code=35 \"Could not find the specified now playing client\" UserInfo={NSLocalizedDescription=Could not find the specified now playing client}}}",
                "Error Domain=MPCPlayerRequestErrorDomain Code=4000 \"Failed to get supported commands\" UserInfo={NSDebugDescription=Failed to get supported commands, NSUnderlyingError=0x281cc27f0 {Error Domain=kMRMediaRemoteFrameworkErrorDomain Code=35 \"Could not find the specified now playing client\" UserInfo={NSLocalizedDescription=Could not find the specified now playing client}}}"
                )}
            */
            print(Float((self.appleplayer.currentPlaybackTime)))
            print("current test")
            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
        }
        
    }
 */
    
    
    //failed
    /*
    func set_curr_playback() {
        DispatchQueue.global(qos: .userInteractive).async {
            let group  = DispatchGroup()
            group.enter()
            while (self.super_temp_flag) {
                print ("while true")
                if ((self.appleplayer.currentPlaybackTime > 0.01) && (self.appleplayer.currentPlaybackTime < 30.0) ) {
                    self.super_temp_flag = false
                    print(Float((self.appleplayer.currentPlaybackTime)))
                    self.appleplayer.currentPlaybackTime = 0.0
                    print(Float((self.appleplayer.currentPlaybackTime)))
                    print("current test")
                }
            }
            group.leave()
            group.notify(queue: .main) {
                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
            }
        }
    }
    
    //failed
    func set_current_playback_time () {
        while (self.super_temp_flag) {
            print ("while true")
            if ((self.appleplayer.currentPlaybackTime > 0.01)) {
                self.super_temp_flag = false
                print(Float((self.appleplayer.currentPlaybackTime)))
                self.appleplayer.currentPlaybackTime = 0.0
                print(Float((self.appleplayer.currentPlaybackTime)))
                print("current test")
                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
            }
        }
    }
 */
    //------------------------------------------------------------------------------------------------------------------------------------------------------//

    
    //MARK: TIMER UPDATE FUCNTIONS
    
    /*The following four functions, one for each player, are used for the progress bar animation - a simple progress bar that moves along as the song plays and indicates how much of the song is completed. The reason there is so much code and calculation is because I wanted a smooth constantly forward flowing progress bar instead of a progress bar where the flow is incrementing in steps. So what I did was, initiate a timer that fires every 0.00005 seconds. Every time it fires it calls this function and it makes a very very very small step increment -> (0.000189/self.duration), where duration is the length of the currently playing audio/video piece.
    
        These extremely small increments happening 20,000 times a second make the overall progress seem like a continous flow to the user.
        The 0.00005 and 0.000189 numbers came from a lot of trial and error to get the smooth flow.
     
     After testing it out a lot, I found that it wasn't accurately tracking the song, it was lagging behind sometimes, so every half a second, we sync up to the current time of the player we are tracking.
     
     In hindsight I should have probabaly used a cocoapod or someother open source library to set up this animation, because this:
        a. Is a hack of monumental proportions
        b. Does not work as smoothly as expected, sometimes the jump when we try to catch up to the current playback time is just too big.
     
     So this needs major improvements OR replaced with well implemented library OR last resort - chuck out entirely and just make do with a regualar step increase progress bar.
    */
    @objc func updateProgress_apple() {
        /*
        self.it_has_been_a_second = self.it_has_been_a_second! + 1 //keep track of seconds -
        if (self.it_has_been_a_second! >= 10000) { //check if half a second has passed
            print("update_apple \(Float(self.appleplayer.currentPlaybackTime))")
            
            //print("duration is \(self.duration)")
            //print ("current post startoffset \(currentPost.startoffset)")
            //print(Float((self.appleplayer.currentPlaybackTime)))
            
            //we grab the current playback time
            the_temp = Float(self.appleplayer.currentPlaybackTime) - 0.0 //<- Apple does not allow starting from a different point. No workaround so far. -> this does not work -> don't have a perfect workaround yet -> all the surrounding comments are the remnants of attempted workarounds - still see Domain=MPCPlayerRequestErrorDomain Code=1 "No commands provided." intermittently - need to open bug with Apple
            
            
            the_new_temp = Float(the_temp!)/Float(self.duration)
            
            //if we are behind the playe, we jump to the current progress level.
            if ((the_new_temp!) > self.playBar.progress) {
                self.playBar.progress = the_new_temp!
                self.prog_bar!.progress = the_new_temp!
                it_has_been_a_second = 0
                print (self.it_has_been_a_second)
            } else {
                // otherwise we do regular increment
                //print("regular increment")
                self.playBar.progress += (0.000189/self.duration)
                self.prog_bar!.progress += (0.000189/self.duration)
            }
        } else {
            //print("regular increment")
            self.playBar.progress += (0.000189/self.duration)
            self.prog_bar!.progress += (0.000189/self.duration)
            
        }
        if self.playBar.progress >= 1 { //once progress fills completely, we invalidate the timer and stop the song.
            // invalidate timer
            print ("invalidate timer happened")
            self.timer.invalidate()
            self.playBar.progress = 0.0
            self.prog_bar!.progress = 0.0
            it_has_been_a_second = 0
            if currently_playing_song_cell != nil {
                self.appleplayer.stop() //stop the player
                if let tappedCell = self.tableView.cellForRow(at: currently_playing_song_cell!) as? PostCell {
                    
                    //set the post cell flags to the right state
                    tappedCell.playingflag = false
                    tappedCell.pausedflag = false
                    print (tappedCell.pausedflag)
                    print("updated cell immediately")
                }
                
                //set the global flags to the right state
                allCells[currently_playing_song_cell!]?[0] = false
                allCells[currently_playing_song_cell!]?[1] = false
                print ("updated global flags")
                currently_playing_song_cell = nil
                currently_playing_song_id = ""
            }
        }
 */
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
            self.timer.invalidate()
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
        /*
        //print ("updateProgress_yt current playback time \(Float(((youtubeplayer?.currentTime())!))) ")
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
                miniplayer_is_playing = false
                no_other_video_is_active = true
            }
        }
 */
    }
    
    
    //there is a separate player for youtube when it plays in the player view.
    @objc func updateProgress_ytmini() {
        print ("updateProgress_ytmini youtubeplayer2?.currentTime \(Float(((youtubeplayer2?.currentTime())!))) current post starttime \(currentPost.starttime)")
        self.it_has_been_a_second = self.it_has_been_a_second! + 1
        if (self.it_has_been_a_second! >= 10000){
            print("update_ytmini duration is \(Float(self.duration))")
            the_temp = Float(((youtubeplayer2?.currentTime())!) - currentPost.starttime)
            the_new_temp = Float(the_temp!) / Float(self.duration)
            
            print ("temp is \(the_temp) and new_temp is \(the_new_temp) and playbar progress is \(self.playBar.progress)")
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
            print("regular increment")
            self.playBar.progress += (0.000089/self.duration)
            self.prog_bar?.progress += (0.000089/self.duration)
        }
        if self.playBar.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer.invalidate()
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
                miniplayer_is_playing = false
                no_other_video_is_active = true
            }
        }
    }
    
    @objc func updateProgress_av() {
        print("updateProgress_av")
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
            self.timer.invalidate()
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
  
    
    //not used anymore - the above four used to be this single function.
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
                if (youtubeplayer2.playerState() == YTPlayerState.playing && self.miniplayer_is_playing!) {
                    the_temp = Float((youtubeplayer2?.currentTime())! - currentPost.starttime)
                } else {
                    
                    wkyoutubeplayer.getCurrentTime({ time, error in
                               if error == nil {
                                   print ("current time is \(time)")
                                   self.the_temp = time - self.currentPost.starttime
                               } else {
                                   print("error retrieving time")
                               }
                           })
                   // the_temp = Float((wkyoutubeplayer?.getCurrentTime(<#T##completionHandler: ((Float, Error?) -> Void)?##((Float, Error?) -> Void)?##(Float, Error?) -> Void#>))! - currentPost.starttime)
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
            self.timer.invalidate()
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
                //self.appleplayer.stop()
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
    
    
    // MARK: Playback state change notification handlers
    
    //The apple music player MPMusicPlayer is set to generate notifications for playback change. This function is set up to observe those notifications
    @objc func handleMusicPlayerControllerPlaybackStateDidChange () {
        
        if self.appleplayer.playbackState == .playing {
            print ("apple player ksjnkwrnlwinw just started playing - newsfeed - handleMusicPlayerControllerPlaybackStateDidChange")
//            self.youtubeplayer?.stopVideo()    //Stop the post youtube player
//            self.youtubeplayer2?.stopVideo()   //Stop the miniplayer youtube player
//            //Set the miniplayer flags
//            self.miniplayer_is_playing = false
//            self.miniplayer_just_started = false
//
//            //hide the miniplayer in the playerView.
//            youtubeplayer2.isHidden = true
//            temp_view2?.isHidden = true
        } else if self.appleplayer.playbackState == .interrupted {
            print ("apple player was interrupted - newsfeed - handleMusicPlayerControllerPlaybackStateDidChange")
//            if currently_playing_song_cell != nil {
//                allCells[currently_playing_song_cell!]?[0] = false
//                allCells[currently_playing_song_cell!]?[1] = false
//            }
        } else if self.appleplayer.playbackState == .paused {
            print ("apple player was paused - newsfeed - handleMusicPlayerControllerPlaybackStateDidChange")
        } else if self.appleplayer.playbackState == .stopped {
            print ("apple player was stopped - newsfeed - handleMusicPlayerControllerPlaybackStateDidChange")
//            if currently_playing_song_cell != nil {
//                allCells[currently_playing_song_cell!]?[0] = false
//                allCells[currently_playing_song_cell!]?[1] = false
//            }
        }
 
    }
    
    
    //not used now - When we expand an audio post from the playerview into the full view player  - we go to  - MaxiSongCardViewController -> SongPlayControlViewController -> and the song plays in appleplayer, spotifyplayer from there, this function was used to get notifications from that player
    @objc func handleMusicPlayerControllerPlaybackStateDidChange_fromSongPlayController (notification: Notification) -> Void {
        guard var player_state = notification.userInfo!["State"] as? String else { return }
        if player_state == "playing" {
            self.wkyoutubeplayer?.stopVideo()
            self.youtubeplayer2?.stopVideo()
            self.miniplayer_is_playing = false
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
    
//If we already have a spotify/apple song playing and we play a youtube video, the spotify/apple song does not automatically stop. We have to stop it, so when a youtube video playback state changes to "buffering" - we call this function o stop any audio that might be playing,this function stops the spotify/apple post when it recieves the stop notification
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
                
                //set global flags
                self.allCells[self.currently_playing_song_cell!]?[0] = false
                self.allCells[self.currently_playing_song_cell!]?[1] = false
                
                //set previously playing cell flags
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
            //self.appleplayer.stop()
            
            //set global flags
            self.allCells[self.currently_playing_song_cell!]?[0] = false
            self.allCells[self.currently_playing_song_cell!]?[1] = false
            
            //set previously playing cell cell flags
            let previous_cell = self.tableView.cellForRow(at: self.currently_playing_song_cell!) as? PostCell
            previous_cell?.playingflag = false
            previous_cell?.pausedflag = false
            currently_playing_song_cell = nil
        }else if self.av_player.isPlaying {
            self.av_player.stop()
            
            //set global flags
            self.allCells[self.currently_playing_song_cell!]?[0] = false
            self.allCells[self.currently_playing_song_cell!]?[1] = false
            
            //set previously playing cell cell flags
            let previous_cell = self.tableView.cellForRow(at: self.currently_playing_song_cell!) as? PostCell
            previous_cell?.playingflag = false
            previous_cell?.pausedflag = false
            currently_playing_song_cell = nil
        } else {
            print ("something went very wrong: Youtube cell was tapped: In Stop Audio Notification Observer")
        }
        
        
    }
    
    
//this function identify's that a youtube post has been played and sends the stop spotify/apple player notification
//    @nonobjc func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState)
//    {
//        print("state changed youtube")
//        switch(state){
//        case YTPlayerState.unstarted:
//            if self.wkyoutubeplayer.isHidden == true {
//                self.wkyoutubeplayer.isHidden = false
//            }
//            print("unstarted youtube")
//            break;
//        case YTPlayerState.queued:
//            print("queued youtube")
//            break;
//        case YTPlayerState.buffering:
//            print("buffering youtube")
//
//            //print ("current playing song cell is \(currently_playing_song_cell)")
////            if currently_playing_song_cell != nil{
////                print("there is a audio cell playing")
////                //If a youtube video is about to play and there is another song post playing, we want to stop that. So we send a notification to stop that spotify/apple post, this is observed by stopAudioplayerforYoutube
////                NotificationCenter.default.post(name: Notification.Name(rawValue: "Stop Audio Player!"), object: nil)
////            }else{
////                print ("there is no audio cell playing")
////            }
//            break;
//        case YTPlayerState.ended:
//
//            //When a youtube video is done playing it ends up in this playback state. We set all the relevant flags and stop the progress bar timer.
//            print("Ended - Yes we come here")
//            /*
//            currently_playing_youtube_cell = nil
//            miniplayer_is_playing = false
//            no_other_video_is_active = true
//            self.timer?.invalidate()
//            self.playBar.progress = 0
//            print("no_other_video_is_active")
//            */
//
//            break;
//        case YTPlayerState.playing:
//           if self.wkyoutubeplayer.isHidden == true {
//                self.wkyoutubeplayer.isHidden = false
//            }
//            /* We come here in two cases:
//               - When a post youtube player is played
//               - When the miniplayer starts playing - When the user scrolls away from a playing youtube post and we need to continue playing the video in the miniplayer.
//
//             */
//            print ("we know state changed - playing")
//            /*
//            self.current_song_player = "youtube"
//            print("miniplayer is \(self.miniplayer_is_playing)")
//            //When a post youtube video is played and starts playing
//            if !(self.miniplayer_is_playing!) { //We'll be here again when the miniplayer starts and post player is paused. Don't need any of this setup for the miniplayer
//                temp_view2?.isHidden = true    //hide miniplayer if it is visible
//                if currently_playing_youtube_cell == nil {  //If no other youtube video is playing make sure the progress bar starts from 0 and the timer is invalidated
//                    print ("this works")
//                    playBar.progress = 0
//                    self.timer?.invalidate()
//                }
//                self.duration = self.temp_duration //Get the duration for the video that just moved into .playing state
//                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_yt), userInfo: nil, repeats: true) //fire the timer to start the progress bar in the the player view - this view is not currenlty visisble and will only be shown when the user scrolls away
//                RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
//                print("-----------------------------------------Timer started------------------------------------------")
//                currently_playing_youtube_cell = last_viewed_youtube_cell   //global flag to track what is currently playing
//                no_other_video_is_active = false                            //global flag to track what is currently playing
//                print(currently_playing_youtube_cell)
//                if let cell  = self.tableView.cellForRow(at: currently_playing_youtube_cell!) as? PostCell {
//                    print("video should load man")
//                    youtubeplayer = cell.playerView   //make the cell youtube player view equal to the new feed controller player view so we can control playback as the delegate even if the cell scrolls away and gets reused.
//                    currentPost = cell.post
//                    youtubeplayer2?.load (withVideoId: cell.videoID , playerVars: [ "playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 0, "start": cell.videostart, "end": cell.videoend, "rel": 0, "iv_load_policy": 3])  //Load the miniplayer so we are ready when it needs to be played
//                } else {
//
//                    //I think I was trying to cover a corner case here, which I am no longer able to reproduce, unsure if this is required or not.
//                        print ("stopping video")
//                        //If a playing youtube cell scrolls away, and is handed over to
//                        self.youtubeplayer?.stopVideo() //Comment this out if we load the post cell ytplayer every time the cell is dequeued
//                    //otherwise, leave this in, since we don't load the cell ytplayer everytime it just remains paused at the position where the miniplayer started and we don't want to see that when we scroll back.
//                }
//
//
//            } else {
//                //When the miniplayer starts playing
//                self.miniplayer_just_started = false //change this to false, use for this flag is done for now.
//                print("did we even come here ?? what is going on?")
//                //stop and restart the timer  - handoff from youtubeplayer to youtubeplayer2 which is the miniplayer youtube player.
//                self.timer.invalidate()
//                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_ytmini), userInfo: nil, repeats: true)
//                RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
//            }
// */
//            break;
//
//        case YTPlayerState.paused:
//            print("Nah we come here") //when the miniplayer cuts off the post player, it goes to paused state, not ended state.
//            print("state changed to paused")
//
//            //if the miniplayer has just started and we come here, let the timer run, we handle it when the miniplayer cuts off the post player in .isPlaying for miniplayer, handing it over from the post player to the miniplayer. Skip the rest of the settings as well
//           /*
//            if !(self.miniplayer_just_started!) && (currently_playing_youtube_cell != nil) && !self.miniplayer_is_playing! {
//                print (self.miniplayer_just_started)
//                //We should only come here when a youtube video has been paused directly by the user.
//                self.timer?.invalidate()
//                allCells[currently_playing_youtube_cell!]?[0] = false
//                allCells[currently_playing_youtube_cell!]?[1] = true
//                paused_cell = currently_playing_youtube_cell
//                currently_playing_youtube_cell = nil
//                print ("we didnt let it run")
//            }
// */
//            break;
//        default:
//            print("none of these")
//            break;
//        }
//    }
    
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
                     print("state changed youtube")
          switch(state){
          case WKYTPlayerState.unstarted:
              print("unstarted youtube")
              if self.wkyoutubeplayer.isHidden == true {
                  self.wkyoutubeplayer.isHidden = false
              }
              
              break;
          case WKYTPlayerState.queued:
              print("queued youtube")
              //appleplayer.stop()
              break;
          case WKYTPlayerState.buffering:
              print("buffering youtube")
              //appleplayer.stop()

              break;
          case WKYTPlayerState.ended:
              print("ended youtube")
              break;
          case WKYTPlayerState.playing:
              if self.wkyoutubeplayer.isHidden == true {
                  self.wkyoutubeplayer.isHidden = false
              }
              print("playing youtube")
              
              break;
          case WKYTPlayerState.paused:
              print("paused youtube")
          default:
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
    
    // MARK: Tap responders
    
    
    //The small player view at the bottom expands into a large player card view, for youtube the whole animation stays in this controller - so expansion and contraction fucntions are both in this file. For apple and spotify the expanding view is MaxiSongCardViewController - control goes to that controller - so the expand triggerging funtion is in this file, but the contraction triggering function is in MaxiSongCardViewController.
    
    
    //This is for youtube posts only - not for spotify/apple posts.
    //this contracts the large youtube player back into the small miniplayer
    @objc func tapEdit4(recognizer: UITapGestureRecognizer) {
        print("tapedit 4")
        if (enlarged!) {
            print ("enlarged!")
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
            print("first animate done")
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
            print("second animate done")
            self.youtubeplayer2.isHidden = false
            self.temp_view2?.isHidden = false
        } else {
            print("enlarged")
            self.window?.bringSubviewToFront(self.temp_view!)
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
                
                self.temp_view?.frame = CGRect(origin: CGPoint(x: 25, y: 5), size: CGSize(width: 325, height: 325))
                
            }, completion: nil)
            enlarged = true
        }
    }
    
    
    //This is for all posts - youtube/spotify/apple
    //this contains the entire animation of how the player view at the bottom expands into the large player
     @objc func tapEdit3(recognizer: UITapGestureRecognizer)  {
        print("tapedit 3")
        guard let post = currentPost else {
            return
        }
        
        if (miniplayer_is_playing!) { //expanding a youtube video
            print("miniplayer !")
            self.youtubeplayer2.isHidden = true
            temp_view2?.isHidden = true
            self.backingImageView?.image = tableView.makeSnapshot() //we take a snapshot of the current view of the controller
            temp_view?.isHidden = false
            name_label?.text = currentPost.songname
            self.dimmmerLayer?.isHidden = false
            self.backingImageView?.isHidden = false
            self.containerView?.isHidden = false
            if let tabBar = tabBarController?.tabBar {
                self.tabBarImageView?.image = tabBar.makeSnapshot() //we take a snapshot of the current view of the tabbar
            }
            
            self.tabBarImageView?.isHidden = false  //the tabbar image view is placed exactly above the tabbar, so at this point we are seeing tabbarImageView but we can;t tell the difference
            
            UIView.animate(withDuration: 0.5/2) { //We slide the tabbarimage view down and out
                self.tabBarImageView_topConstraint?.constant = 667
                self.tabBarImageView_botConstraint?.constant = 49
            }
            
            UIView.animate(withDuration: 0.5/4) { //We bring the container view from transparent to white
                self.containerView?.backgroundColor = UIColor.white
            }
        
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                           options: [.curveEaseOut], animations: {
                
                self.configureBackingImageInPosition(presenting: true) //this causes the tableview snapshot to look like it is receding into a card in the background
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
        } else { //expanding an apple/spotify audio post
            print ("")
            self.expandSong(post: post)
        }
        
    }
    
    //this handles the animation which makes it look like the table view is retreating backwards in card form.
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
    
    
    //this is used to play/pause the currently playing post from the player view.
     @objc func tapEdit2(recognizer: UITapGestureRecognizer)  {
        
        print("In tap edit2")
        if (currently_playing_song_cell != nil) {  //something is playing right now
            print("User tapped on the player view and an audio cell is playing - so we have to pause the song ")
            
            /*
            if (self.appleplayer.playbackState == .playing){
                print("true")
            }
           */
            let previousCell = self.tableView.cellForRow(at: currently_playing_song_cell!) as? PostCell
            
            /*
            if (previousCell?.source == "apple" && self.appleplayer.playbackState == .playing){
                print("true")}
             */
            
            
            //Apple user playing a spotify post
            if (self.playerView_source_value == "spotify" &&  userDefaults.string(forKey: "UserAccount") == "Apple") {
                    print("something is playing : apple")
                if self.appleplayer.playbackState == .playing {
                    self.appleplayer.pause()
                    self.playerView_offsetvalue = self.appleplayer.currentPlaybackTime //Grab this now so we can start the player from the same position when the user hits play again
                    print (self.playerView_offsetvalue)
                }
                
                //Spotify user playing an apple post
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
                    self.playerView_offsetvalue = (self.spotifyplayer!.playbackState.position) //Grab this now so we can start the player from the same position when the user hits play again

                print(self.spotifyplayer!.playbackState.position)
                }
                
                //Apple user playing a apple post
            } else if ( self.playerView_source_value == "apple" && self.appleplayer.playbackState == .playing){

                    print("something is playing : apple")
                    self.appleplayer.pause()
                self.playerView_offsetvalue = self.appleplayer.currentPlaybackTime //Grab this now so we can start the player from the same position when the user hits play again

                    print (self.playerView_offsetvalue)
                
                //Spotify user playing an apple post
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
                self.playerView_offsetvalue = (self.spotifyplayer!.playbackState.position) //Grab this now so we can start the player from the same position when the user hits play again

                print(self.spotifyplayer!.playbackState.position)
    
            }
            
            //Stop the playBar progress bar
            self.timer.invalidate()
            
            //Update global here
            allCells[currently_playing_song_cell!]?[0] = false
            allCells[currently_playing_song_cell!]?[1] = true
            previousCell?.pausedflag = true
            previousCell?.playingflag = false
            paused_cell = currently_playing_song_cell
            currently_playing_song_cell = nil
            
        } else if currently_playing_youtube_cell != nil {
            print ("currently_playing_youtube_cell != nil")
            print("User tapped on the player view and a youtube post is playing - so we have to pause the miniplayer video ")
            if (self.miniplayer_is_playing!) {
                self.youtubeplayer2.pauseVideo()
                //ALL THE STUFF BELOW IS HANDLED IN YTSTATE.isPAUSED - BECAUSE for the POST players WHEN THE YT VIDEO IS PAUSED THERE IS NO TAPEDIT TO CAPTURE THAT - SO NONE OF THE FLAG SETTING WILL HAPPEN IN THAT CASE IF WE DONT DO IT IN YTSTATE.isPAUSED.
//                self.timer?.invalidate()
//                allCells[currently_playing_youtube_cell!]?[0] = false
//                allCells[currently_playing_youtube_cell!]?[1] = true
//                paused_cell = currently_playing_youtube_cell
//                currently_playing_youtube_cell = nil
            } else {
               print ("miniplayer should be playing if we are pausing it from the player view!!!!!!")
            }
            

        } else if (paused_cell != nil) { //something was paused and nothing new was played
            print("User tapped on the player view and nothing is playing - so we have to play the paused post ")
            print("something was paused")
            let previousCell = self.tableView.cellForRow(at: paused_cell!) as? PostCell
            
            
            if playerView_source_value == "spotify" {
                //Spotify user playing spotify post
                if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                    print("something was paused: spotify")
                    print(previousCell?.trackidstring)
                    self.spotifyplayer?.playSpotifyURI(previousCell!.trackidstring, startingWith: 0, startingWithPosition: self.playerView_offsetvalue, callback: { (error) in
                            if (error == nil) {
                                print("playing number 3")
                                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_spotify), userInfo: nil, repeats: true)
                                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                                self.current_song_player = "spotify"
                            }else {
                                print ("error in playing 3!")
                            }
                        })
                    
                    //Apple user playing spotify post
                    }else if userDefaults.string(forKey: "UserAccount") == "Apple" {
                        print (self.playerView_offsetvalue)
                        //self.appleplayer.setQueue(with: [self.currently_playing_song_id])
                        //self.appleplayer.currentPlaybackTime = self.playerView_offsetvalue
                        self.appleplayer.play()
                        //self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                        //RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
                        self.current_song_player = "apple"
                        //self.appleplayer.currentPlaybackTime = self.playerView_offsetvalue  //<- this is broken for apple right now
                        print (self.playerView_offsetvalue)
                    }
                    currently_playing_song_cell = paused_cell
                    //paused_cell = nil
                
                
            }else if (playerView_source_value == "apple") {
                
                //Spotify user playing apple post
                if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                    print("something was paused: spotify")
                    print(previousCell?.helper_id)
                    self.spotifyplayer?.playSpotifyURI(previousCell!.helper_id, startingWith: 0, startingWithPosition: self.playerView_offsetvalue, callback: { (error) in
                        if (error == nil) {
                            print("playing number 3")
                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_spotify), userInfo: nil, repeats: true)
                            RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                            self.current_song_player = "spotify"
                        }
                        else {
                            print ("error in playing 3!")
                        }
                    })
                    
                    //Apple user playing spotify
                }else if userDefaults.string(forKey: "UserAccount") == "Apple" {
                    print("something was paused: apple")
                    print (self.playerView_offsetvalue)
                    //self.appleplayer.setQueue(with: [self.currently_playing_song_id])
                    //self.appleplayer.currentPlaybackTime = self.playerView_offsetvalue //<- this is broken for apple right now
                    self.appleplayer.play()
                    //self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                    //RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
                    self.current_song_player = "apple"
                    //self.appleplayer.currentPlaybackTime = self.playerView_offsetvalue //<- this is broken for apple right now
                    print (self.playerView_offsetvalue)
                }
                currently_playing_song_cell = paused_cell
                //paused_cell = nil
                
                //youtube
            } else if (playerView_source_value == "youtube"){
                if (self.miniplayer_is_playing!) { //this flag indicates youtube video being active in player view - so stays true for playing or paused both.
                    self.youtubeplayer2.playVideo()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_ytmini), userInfo: nil, repeats: true)
                    RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
                    currently_playing_youtube_cell = paused_cell
                } else {
                }
                
            }
            
            //update flags
            allCells[paused_cell!]?[0] = true
            allCells[paused_cell!]?[1] = false
            paused_cell = nil
            previousCell?.pausedflag = false
            previousCell?.playingflag = true
        }
        
        
    }
    

    //This triggered when the user taps on a post - used to play a new post or pause an already playing post
    //Tap a post for the first time, it starts playing, tap it again it will pause, tap again it will play from the paused point.
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        print ("tapedit here 1")
        if recognizer.state == UIGestureRecognizer.State.ended {
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
                    
                    if tappedCell.typeFlag != "video" {//If the tapped cell is not a Video cell
                        /*
                        print("this is not a video cell")
                    if tappedCell.playingflag == false {     //If this is a new untapped cell OR paused cell
                        print ("tappedCell.playingflag == false")
                        if currently_playing_song_cell == nil {      //if no other cell is currently playing
                            print ("currently_playing_song_cell == nil")
                            
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
                                    print ("paused_cell != tapIndexPath")
                                            //Here - since paused_cell != tapIndexPath(the currently tapped cell) - we need to check if there is any previously paused cell - and reset it's playing/paused flags to false/false.
                                    
                                    if paused_cell != nil {
                                        print ("paused_cell != nil setting paused cell flags")
                                        let pausedCell = self.tableView.cellForRow(at: paused_cell!) as? PostCell
                                        update_global(cell_control: false, tapped_cell: pausedCell!, tapped_index: paused_cell!)
                                        paused_cell = nil
                                        
                                    }
 
                                            print ("paused_cell != tapIndexPath")   //If this is a new untapped cell
                                            playerView_source_value = tappedCell.source
                                            currently_playing_song_cell = tapIndexPath
                                            currently_playing_song_id = tappedCell.trackidstring
                                            currentPost = tappedCell.post
                                    
                                            //Stop/end any previously paused/playing youtube video in the miniplayer
                                            self.wkyoutubeplayer?.stopVideo()      //stops the last playing/paused youtube cell
                                            self.youtubeplayer2?.stopVideo()
                                    
                                            //reset all miniplayer flags
                                            self.miniplayer_is_playing = false
                                            self.miniplayer_just_started = false
                                            //hide miniplayer
                                            youtubeplayer2.isHidden = true
                                            temp_view2?.isHidden = true
                                            currently_playing_youtube_cell = nil
                                            no_other_video_is_active = true //songnameLabel?.text = tappedCell.player?.metadata.currentTrack?.name
                                    
                                            //Load the player view with new post
                                            setup_player_view(tapped_cell: tappedCell) //we call this before playbutton because timer reset happens here and initialization happens further down in playbutton
                                    
                                            //play new post
                                            self.playButton(cell: tappedCell)
                                            print ()
                                            //debug
                                            print (tappedCell.playingflag)
                                            print (tappedCell.pausedflag)
                                            //debug
                                    
                                            //sync to global settings
                                            update_global(cell_control: true, tapped_cell: tappedCell, tapped_index: currently_playing_song_cell!)
                            }
                        } else { //if some other cell is playing right now
                            print ("some other cell is playing right now")
                            let previousCell = self.tableView.cellForRow(at: currently_playing_song_cell!) as? PostCell //record what the other cell that was playing was
                            //debug
                            
                            //we may not be htting this condition anymore
                            if tappedCell.pausedflag == true {
                                print ("tappedCell.pausedflag == true")
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
                            
                            //If a user has apple and spotify accounts we would need the following two checks, otherwise we would be switching a song within the same player
                            if (tappedCell.source == "spotify" && self.userDefaults.string(forKey: "UserAccount") != "Spotify" ) {
                                if self.appleplayer.playbackState == .playing {
                                self.appleplayer.stop()
                                print ("switching from apple to spotify")
                                }
                            }else if (tappedCell.source == "apple" && self.userDefaults.string(forKey: "UserAccount") != "Apple") {
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
                            self.wkyoutubeplayer?.stopVideo()         //stops the last playing youtube cell
                            self.youtubeplayer2?.stopVideo()
                            self.miniplayer_is_playing = false
                            self.miniplayer_just_started = false
                            youtubeplayer2.isHidden = true
                            temp_view2?.isHidden = true
                            currently_playing_youtube_cell = nil
                            no_other_video_is_active = true
                            update_global(cell_control: true, tapped_cell: tappedCell, tapped_index: currently_playing_song_cell!) //sync to global settings for current cell
                        }
                        
                    } else { //if this cell is currently playing
                        print ("if this cell is currently playing")
                        if currently_playing_song_cell == tapIndexPath {
                            print ("currently_playing_song_cell == tapIndexPath ")
                            //we are pausing the cell so turn all currently playing flags to nil
                            currently_playing_song_id = ""
                            paused_cell = tapIndexPath
                            self.pauseButton(cell: tappedCell)
                            self.timer.invalidate()
                            update_global(cell_control: true, tapped_cell: tappedCell, tapped_index: currently_playing_song_cell!)  //sync to global settings for current cell
                            currently_playing_song_cell = nil
                        }
                    }
                        
                        */
                    }else{ //if the tapped cell is a video cell
                        print ("the tapped cell is a video cell")
                        if currently_playing_youtube_cell != nil { //check if the tableview player is playing a previously tapped video cell
                            self.wkyoutubeplayer?.stopVideo()  //stop it
                            self.youtubeplayer2?.stopVideo()
                            self.miniplayer_is_playing = false
                            self.miniplayer_just_started = false
                            youtubeplayer2.isHidden = true
                            temp_view2?.isHidden = true
                            currently_playing_youtube_cell = nil
                            self.timer.invalidate()
                            self.playBar.progress = 0
                        }
//                        tappedCell.playerView.isUserInteractionEnabled = true
//                        tappedCell.playerView.delegate = self                     //if a cell is a video cell, declare the tableview as its delegate,
                        //youtubeplayer = tappedCell.playerView                     //so that we can have playback control on the 'last played' youtube
                        //tappedCell.playerView.bringSubview(toFront: tappedCell.playerView)
                        //WE MOVED THE LOADING OF THE VIDEO HERE FROM PostCell.swift - TO PREVENT SCROLL LAG - TRADEOFF - LOOKS SHITTY AND TAKES FOREVER TO LOAD BEFORE IT PLAYS - NEED TO FIND A WAY TO SHIFT THIS LOADING TO A BACKGROUND THREAD - RAN INTO A WEIRD ERROR WHEN I TRIED BEFORE
//                        tappedCell.playerView.load(withVideoId: tappedCell.post.videoid , playerVars: ["autoplay": 1,"playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 0, "start": Int(tappedCell.post.starttime), "end": Int(tappedCell.post.endtime), "rel": 0, "iv_load_policy": 3])
                        
                        print ("should be cueing now")
                        tappedCell.addSubview(wkyoutubeplayer)
                        tappedCell.layoutIfNeeded()
                        self.wkyoutubeplayer.cueVideo(byId: tappedCell.post.videoid, startSeconds: 0.0, suggestedQuality: WKYTPlaybackQuality.default)
                        self.wkyoutubeplayer?.playVideo()
                        //self.youtubeplayer.isHidden = false
//                        tappedCell.playerView.isHidden = false                      //internal control because otherwise you would need two taps: 1 to
//                        playerView_source_value = tappedCell.source
//                        temp_duration = tappedCell.duration                         //enable user interaction and one to play the video
//                        dismiss_player_view()
//                        youtubeplayer2.isHidden = true
//                        temp_view2?.isHidden = true
//                        setup_player_view(tapped_cell: tappedCell)     //timer reset happens here, timer initialization happens in YTPlayerState check
//                        last_viewed_youtube_cell = tapIndexPath
                    }
                }
            }
        }
    }
    
    
    //get all the posts, load them in the table
    //Also initialize the global all_cells table
    func fetchPosts()
    {
        playerMaster.make_posts_newfeed_ready().done {
            self.posts = self.playerMaster.newsfeed_posts
            self.playable_posts = self.playerMaster.playback_ready_posts
            print("---------------------These are the playabale posts ------------------------")
            print(self.playable_posts)
            self.initialize_allcells()
            self.tableView.reloadData()
            self.fresh_load = true
        }
        self.tableView.reloadData()
        
    }
    
    
    //Every time a post is played or paused or interrupted or stopped, we update it's global flags. The global flags are used to set a cell's flags when it is dequeued.
    func update_global(cell_control: Bool, tapped_cell: PostCell, tapped_index: IndexPath) {
        print ("set the global flags")
        if (cell_control) {                     //"cell_control" : If true, we are setting the global variables as per the flags set by tapped_cell.play and tapped_cell.pause buttons
            print ("cell control play flag\(tapped_cell.playingflag) paused flag\(tapped_cell.pausedflag)")
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
    
    
    //When a new post is played we use this function to set it up with the Post details like image, song name and start the progress bar.
    func setup_player_view(tapped_cell: PostCell){
        print("setup_player_view")
        
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
            print ("invalidate timer happened  - setup_player_view ")
            self.timer.invalidate()
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
    
    
    //hide the player view
    func dismiss_player_view(){
        print("dismiss_player_view")
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.playingView?.frame = CGRect(origin: CGPoint(x:0, y: (self.window?.frame.height)!), size: CGSize(width: 375, height: 50))
        }, completion: nil)
        
    }
    
    // MARK: Play pause buttons
    
    //THIS IS STUPID
    //THIS HAS TO BE SIMPLIFIED - GIVE MORE INFO TO THE POST SO THAT IT KNOWS WHAT HAS TO BE PLAYED INSTEAD OF SO MANY INFO CHECKS EVERY TIME PLAY/PAUSE IS HIT.
    //The play function, called from tapEdit only, when a post is tapped on, to play a song
    func playButton(cell: PostCell) {/*
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
                            RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                            self.current_song_player = "spotify"
                            print(self.spotifyplayer?.metadata.currentTrack?.name)
                        }
                        else {
                            print ("error this one!")
                        }
                    })
                    } else if userDefaults.string(forKey: "UserAccount") == "Apple" {
                        if cell.helper_id != "" {
                            self.appleplayer.play()
                            self.appleplayer.currentPlaybackTime = playerView_offsetvalue
                            //self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                            //RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
                            print ("Apple is playing")
                            self.current_song_player = "apple"
                        } else if cell.preview_url != "nil"{
                            self.play_av()
                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_av), userInfo: nil, repeats: true)
                            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
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
                        //self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                        //RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
                        self.current_song_player = "apple"
                        print("Apple is playing")
                    } else if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                        if cell.helper_id != "" {
                            self.spotifyplayer = SPTAudioStreamingController.sharedInstance()
                            self.spotifyplayer?.playSpotifyURI(cell.helper_id, startingWith: 0, startingWithPosition: cell.offsetvalue, callback: { (error) in
                            if (error == nil) {
                               print("Spotify is playing! 1")
                                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_spotify), userInfo: nil, repeats: true)
                                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
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
                            RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
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
            } else {
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
                                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                                self.current_song_player = "spotify"
                                //print(self.Spotifyplayer?.metadata.currentTrack?.name)
                                //print(self.Spotifyplayer?.metadata.currentTrack?.albumName)
                                //print(self.Spotifyplayer?.metadata.nextTrack?.name)
                            } else {
                            print ("error this one!")
                            }
                        })
                    } else if userDefaults.string(forKey: "UserAccount") == "Apple" {
                        if cell.helper_id != "" {
                            print ("helper id is \(cell.helper_id)")
                            self.appleplayer.setQueue(with: [cell.helper_id])
                            //self.appleplayer.setQueue(with: ["1295289748"])
                            //self.appleplayer.stop()
                            print ("current playback time after the stop \(self.appleplayer.currentPlaybackTime)")
                            print("should be calling setcurrentplaybacktime")
//                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.setcurrentplaybacktime), userInfo: nil, repeats: true)
//                            RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                            self.appleplayer.play()
                            //self.appleplayer.currentPlaybackTime = cell.startoffset //-> this does not work -> don't have a perfect workaround yet -> all the surrounding comments are the remnants of attempted workarounds - still se Domain=MPCPlayerRequestErrorDomain Code=1 "No commands provided." intermittently - need to open bug with Apple
                            //self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                            //RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                            //self.super_temp_flag = true
                            //self.set_current_playback_time()
                            //self.set_curr_playback()
                            print("Apple is playing")
                            self.current_song_player = "apple"
                        } else if cell.preview_url != "nil" {
                            print ("playing preview")
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
                        //self.appleplayer.setQueue(with: ["1295289748"])
                        //self.appleplayer.stop()
                        print ("current playback time after the stop \(self.appleplayer.currentPlaybackTime)")
                        print("should be calling setcurrentplaybacktime")
//                        self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.setcurrentplaybacktime), userInfo: nil, repeats: true)
//                        RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                        self.appleplayer.play()
                        //self.appleplayer.currentPlaybackTime = cell.startoffset //-> this does not work -> don't have a perfect workaround yet -> all the surrounding comments are the remnants of attempted workarounds - still se Domain=MPCPlayerRequestErrorDomain Code=1 "No commands provided." intermittently - need to open bug with Apple
                        //self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                        //RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                        self.super_temp_flag = true
                        //self.set_current_playback_time()
                        //self.set_curr_playback()
                        self.current_song_player = "apple"
                        print("Apple is playing")
                    } else if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                        if cell.helper_id != "" {
                            print (cell.helper_id)
                            self.spotifyplayer = SPTAudioStreamingController.sharedInstance()
                            self.spotifyplayer?.playSpotifyURI(cell.helper_id, startingWith: 0, startingWithPosition: currentPost.startoffset, callback: { (error) in
                                if (error == nil) {
                                    print("Spotify is playing! 2")
                                    self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_spotify), userInfo: nil, repeats: true)
                                    RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
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
 */
    }

    //The pause function, called from tapEdit only, when a post is tapped on, to pause a song
    func pauseButton(cell: PostCell) {
        /*
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
                    if cell.helper_id != "" {
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
                    if cell.helper_id != "" {
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
            
            print ("set the flags")
            cell.pausedflag = true
            cell.playingflag = false
            //self.offsetvalue = (self.Spotifyplayer!.playbackState.position)
            
        }else {
            print ("nothing is playing")
        }
 */
    }
    
    
    //If a user does not have a spotify premium/apple music subscription OR if a user is playing a spotify post and that song does not exist in the apple catalogue, we have to download the 30 sec preview provided by spotify/apple and play that using the av_player.
    
    func download_preview (url : URL) {
        
        var download_task = URLSessionDownloadTask()
        
        download_task = URLSession.shared.downloadTask(with: url, completionHandler: {(downloadedURL, response, error) in
            
            self.initiate_av(url: downloadedURL!)
        })
        
        download_task.resume()
    }
    
    func initiate_av (url : URL) {
        
        print ("initiate_av")
        do {
            av_player = try AVAudioPlayer(contentsOf: url)
            av_player.prepareToPlay()
            av_player.play()
            //ISSUE - thsi timer doesn't fire because initiate_av is called from a background thread, it's called after the url download is completed in download_preview - need to figure out the right way to do this.
            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
            print("timer should have started for av_player")
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
    

    // MARK: Table view functions
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print ("About to dequeue cell indexPath \(indexPath)")
        var cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.postCell, for: indexPath) as! PostCell
        
        cell.post = self.posts?.reversed()[indexPath.section]
        cell.playback_post = self.playable_posts.reversed()[indexPath.section]
        //cell.imageView?.loadImageUsingCacheWithUrlString(imageurlstring: cell.post.albumArtUrl)
        
        //If the cell we just dequeued is a video cell.
        if (cell.post.flag == "video") {
            print ("we have a video cell indexPath \(indexPath)")
            
            //This is where I was trying to load it on a background thread
//            DispatchQueue.global(qos: .utility).async {
//                        print ("async is happenning now cell is \(indexPath)")
//                        cell.playerView.load(withVideoId: cell.post.videoid , playerVars: ["playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 1, "start": cell.post.starttime, "end": cell.post.endtime, "rel": 0])
//                        }
            /*
            DispatchQueue.global(qos: .userInitiated).async {
                       // Download file or perform expensive task
                print ("About to cue video in player")
                self.youtubeplayer.cueVideo(byId: cell.videoID, startSeconds: Float(cell.videostart), endSeconds: Float(cell.videoend), suggestedQuality: YTPlaybackQuality.default)
                print ("loading video")
                       DispatchQueue.main.async {
                           // Update the UI
                        //cell.playerView = self.youtubeplayer
                        cell.addSubview(self.youtubeplayer)
                        self.youtubeplayer.playVideo()
                        print ("back to main thread")
                        }
            }
            */
            
           // youtubeplayer.cueVideo(byId: cell.videoID, startSeconds: Float(cell.videostart), endSeconds: Float(cell.videoend), suggestedQuality: YTPlaybackQuality.default)
            //cell.addSubview(youtubeplayer)
            //print("added to cell view")
            //youtubeplayer.playVideo()
            
            //executed_once = false
            switch(cell.playerView.playerState()) {
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
            
        } else {
//            print ("indexpath is \(indexPath)")
//            print ("tableView.contentOffset.y is \(tableView.contentOffset.y)")
//            print ("tableView.isDecelerating is \(tableView.isDecelerating)")
            if (indexPath[0] == 0 && tableView.visibleCells.count == 0) {
                print("we're at the top")
                cell.dimmer_layer.alpha = 0
                if playable_posts[playable_posts.count - 1].post.flag == "audio" {
                    print("first cell is audio cell")
                    if playable_posts[playable_posts.count - 1].player == player_type.appleplayer {
                        print ("first cell player is apple")
                        self.appleplayer.setQueue(with: [playable_posts[playable_posts.count - 1].trackid])
                        self.appleplayer.prepareToPlay()
                        self.appleplayer.play()
                        self.first_cell = cell
                        self.current_cell = cell
                        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.first_cell_update_progress_spotify), userInfo: nil, repeats: true)
                        RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                        print ("helper id is \(self.posts![posts!.count - 1].helper_id)")
//                        self.spotifyplayer?.playSpotifyURI(self.posts![posts!.count - 1].helper_id, startingWith: 0, startingWithPosition: 0.0, callback: { (error) in
//                            if (error == nil) {
//                                print("playing number 3")
//                                self.first_cell = cell
//                                 self.current_cell = cell
//                                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.first_cell_update_progress_spotify), userInfo: nil, repeats: true)
//                                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
//                               // self.current_song_player = "spotify"
//                            }else {
//                                print ("error in playing autoplay 1!")
//                            }
//                        })
                    } else if playable_posts[playable_posts.count - 1].player == player_type.spotifyplayer {
                        print("first cell player is spotify")
                        //self.appleplayer.setQueue(with: [self.posts![posts!.count - 1].trackid])
                        print ("track id is \(self.posts![posts!.count - 1].trackid)")
                        self.spotifyplayer?.playSpotifyURI(playable_posts[playable_posts.count - 1].trackid, startingWith: 0, startingWithPosition: 0.0, callback: { (error) in
                            if (error == nil) {
                              print("playing number 3")
                                self.first_cell = cell
                                self.current_cell = cell
                               self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.first_cell_update_progress_spotify), userInfo: nil, repeats: true)
                                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                               // self.current_song_player = "spotify"
                            }else {
                                print ("error in playing autoplay 1!")
                            }
                        })
                    }
                }
                //self.appleplayer.prepareToPlay()
               // self.appleplayer.play()
            }
        }
        
        
        
        
//        print (mainWindow!.frame.height)
//        print (UIScreen.main.bounds.height)
//        print ("right before the block ")
//        print("currently_playing_youtube_cell is \(currently_playing_youtube_cell)")
//        print (self.miniplayer_is_playing)
        
        
        //When the user plays a youtube post and then scrolls away, the video goes out of view, once we are past more than one cell after the playing post, we want to make the player view visible and start up the youtube miniplayer. Ideally, the video would just seamlessly continue playing in the miniplayer without any breaks at all and the progress bar in the player view (which has just become visible) would just continue progressing like nothing had stoppped.
        /*
        if currently_playing_youtube_cell != nil && self.miniplayer_is_playing == false { //so if a youtube post is playing and the miniplayer is not playing
            
            
            //check the difference between the playing post and the post we just dequeued
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
                    self.miniplayer_is_playing = true                   //this variable indicates that the miniplayer is currently playing
                    self.miniplayer_just_started = true      //used to avoid invalidating timer when post youtube player is paused.
                    youtubeplayer2.isHidden = false
                    temp_view2?.isHidden = false
                    bring_up_player_view()
                    print("youtube player current time is self.youtubeplayer?.currentTime()")
                    
                    //we want the miniplayer to start seamlessly from where the original player shuts off. It's tricky to achieve this, because the miniplayer itself takes a while to buffer, which happens after the line below this line. The + 3.00 is to account for that buffer time, but this sometimes works, sometimes doesn't and varies depending on internet connection, load on phone CPU etc. This needs major fixing/improvement/overhaul.
                    
                    // - could try using the seekTo feature on the mini youtube player in the .isPlaying playback state section for when the miniplayer starts playing and cutsoff the post youtube player ?
                    
                    let time : Float = (self.youtubeplayer?.currentTime())! + 3.00
                    print ("miniplayer start time should be \(time)")
                    print ("current post start time is \(currentPost.starttime), end time is \(currentPost.endtime), video name is \(currentPost.songname)")
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
        }*/
        
        /*
        cell.player = SPTAudioStreamingController.sharedInstance()
        cell.player?.playbackDelegate = self as SPTAudioStreamingPlaybackDelegate
        cell.player?.delegate = self as SPTAudioStreamingDelegate
        */
        
        
        //Set the post flags as per the global flags, I think I did this because the cells get reused and setting the flag when the cell is not currenlty dequeued doesn't work. So instead we set the flags for that cell in the global structure and then when we dequeue the cell, we set the flags in the cell.
        //print(indexPath)
        cell.pausedflag = allCells[indexPath]?[1]
        //print (allCells[indexPath]?[1] as Any)
        cell.playingflag = allCells[indexPath]?[0]
        //print (allCells[indexPath]?[0])
        //print (allCells[indexPath]?[2])
        /*
        if allCells[indexPath]?[2] == false {
            cell.timer?.invalidate()
            cell.progressBar.progress = 0.0
        }
        */
        cell.selectionStyle = .none
        return cell
    }
    

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print ("About to display cell at indexPath \(indexPath)")
        
        
        /*
        var cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.postCell, for: indexPath) as! PostCell
        
        
        cell.post = self.posts?.reversed()[indexPath.section]
        
        
         if (cell.post.flag == "video") {
            //youtubeplayer.playVideo()
        }
         */
//        print("indexPath \(indexPath)" )
//        print("tableview count \(tableView.visibleCells.count)")
//
//        if (indexPath[0] == 0 && tableView.visibleCells.count == 1) {
//             print("we're at the top")
//             autoplay(content_offset: tableView.contentOffset.y)
//         }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print ("About to end displaying cell at indexPath \(indexPath)")
        
        
       
             
        /*
        var cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.postCell, for: indexPath) as! PostCell
        
        
        cell.post = self.posts?.reversed()[indexPath.section]
        
        
         if (cell.post.flag == "video") {
            //youtubeplayer.removeFromSuperview()
            print ("removed from cell")
            //youtubeplayer.stopVideo()
        }
         */
    }
    
    
    override func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        //
        
        //print ("scrollViewDidScrollToTop")
    }
    
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //
        
       // print ("scrollViewDidEndDecelerating")
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //
       // print ("scrollViewWillEndDragging")
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //
        //print ("scrollViewDidEndDragging")
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scroll_content_offset = scrollView.contentOffset.y
        autoplay(content_offset: scroll_content_offset)
    }
    
    
   
    
    
    
    func autoplay(content_offset: CGFloat) {
        //            print ("Scroll view offset is \(scrollView.contentOffset.y)")
        //            print(" Visible cell count is \(self.tableView.visibleCells.count) ")
        if tableView.visibleCells.count > 1 {
                        upper_cell = tableView.visibleCells[0] as? PostCell
                        lower_cell = tableView.visibleCells[1] as? PostCell
                        //print("\(upper_cell.playback_post.player)")
                        //print("\(lower_cell.playback_post.player)")
                        lower_cell_origin_y = lower_cell.frame.origin.y
                        var temp_height = self.upper_cell.frame.size.height
        //                print("Upper cell index path is \(tableView.indexPath(for: upper_cell))")
        //                print("Lower cell index path is \(tableView.indexPath(for: lower_cell))")
        //                print("lower cell origin.y is \(lower_cell.frame.origin.y)")
        //
        //                print ("difference is \(lower_cell.frame.origin.y - scrollView.contentOffset.y )")
        //                print ("upper cell visible portion height is \(lower_cell.frame.origin.y - scrollView.contentOffset.y - (nav_bar_height)! - status_bar_height)")
        //
                        
                DispatchQueue.global(qos: .userInitiated).async {
                            self.upper_cell_visible_portion = CGFloat(self.lower_cell_origin_y - content_offset - (self.nav_bar_height)! - self.status_bar_height)
                            
                            if self.upper_cell_visible_portion < ((temp_height * 2) / 3) {
                                
                                
                                if self.fresh_load {
                                    print("fresh load is false")
                                    self.fresh_load = false
                                }
                               
                                guard self.lower_cell.playingflag == false else {
                                    return
                                }
                                //Scrolling downwards
                                print("PLAY LOWER CELL")
                                self.upper_cell.playingflag = false
                                self.lower_cell.playingflag = true
                                
                                //print ("\(self.appleplayer.nowPlayingItem?.playbackStoreID)")
                                //print ("\(self.appleplayer.indexOfNowPlayingItem)")
                                
                               //self.appleplayer.stop()
                                DispatchQueue.main.async {
                                    self.upper_cell.dimmer_layer.alpha = 0.5
                                    self.lower_cell.dimmer_layer.alpha = 0
                                    self.upper_cell.timer_label.text = "0:00"
                                    if self.wkyoutubeplayer.isDescendant(of: self.upper_cell) {
                                        print("is descendant removing now")
                                        self.wkyoutubeplayer.isHidden = true
                                        self.wkyoutubeplayer.stopVideo()
                                        self.wkyoutubeplayer.removeFromSuperview()
                                        self.upper_cell.layoutIfNeeded()
                                    }
                                }
                                
                                
                                
                                //self.appleplayer.pause()
                                if self.upper_cell.playback_post.player == .appleplayer {
                                    if self.appleplayer.playbackState == .playing {
                                        self.appleplayer.pause()
                                    }
                                } else if self.upper_cell.playback_post.player == .spotifyplayer {
                                    if (self.spotifyplayer?.playbackState.isPlaying)! {
                                        self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
                                                                                       if (error == nil) {
                                                                                       
                                                                                       
                                                                                       } else {
                                                                                           print ("error in pausing!")
                                                                                       }
                                                                                   })
                                    }
                                }
                                if self.timer.isValid {
                                     print("paused number 1 timer stopped")
                                     self.timer.invalidate()
                                     self.reset_timer_values()
                                     DispatchQueue.main.async {
                                         self.current_cell.timer_label.text = "0:00"
                                     }
                                }
                               
                                if self.lower_cell.typeFlag != "video" {
                                   
                                    if self.lower_cell.source == "apple" && self.lower_cell.helper_id == "" {
                                        //Need to play 30 second sample here using AV player
                                      
                                    } else {
                                        print("Skipping to next")
                                        if self.lower_cell.playback_post.trackid == self.current_cell.playback_post.trackid  {
                                            print("same song consecutive")
                                            if self.lower_cell.playback_post.player == .appleplayer {
                                                        self.appleplayer.currentPlaybackTime = 0.0
                                                        self.appleplayer.prepareToPlay()
                                                        self.appleplayer.play()
                                            } else if self.lower_cell.playback_post.player == .spotifyplayer {
                                                self.spotifyplayer?.seek(to: 0.0, callback: { (error) in
                                                    if (error == nil) {
                                                    }else {
                                                        print ("error in playing seeking 1!")
                                                    }
                                                })
                                                self.spotifyplayer?.setIsPlaying(true, callback: { (error) in
                                                    if (error == nil) {
                                                        print("playing number 3 - timer fired")
                                                    } else {
                                                        print ("error in playing autoplay 1!")
                                                    }
                                                })
                                            }
                                            self.current_cell = self.lower_cell
                                            DispatchQueue.main.async {
                                                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.lower_cell_update_progress_spotify), userInfo: nil, repeats: true)
                                                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                                            }
                                        } else {
                                            print ("different song")
                                    
                                            if self.lower_cell.playback_post.player == .appleplayer {
                                                self.appleplayer.setQueue(with: [self.lower_cell.playback_post.trackid])
                                                self.appleplayer.prepareToPlay()
                                                self.appleplayer.play()
                                            } else if self.lower_cell.playback_post.player == .spotifyplayer {
                                                self.spotifyplayer?.playSpotifyURI(self.lower_cell.playback_post.trackid, startingWith: 0, startingWithPosition: 0.0, callback: { (error) in
                                                    if (error == nil) {
                                                    } else {
                                                        print ("error in playing autoplay 1!")
                                                    }
                                                })
                                            }
                                            self.current_cell = self.lower_cell
                                            print ("should initiate timer now")
                                            if self.timer.isValid {
                                                print("timer is valid")
                                            }
                                            DispatchQueue.main.async {
                                                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.lower_cell_update_progress_spotify), userInfo: nil, repeats: true)
                                                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                                            }
                                        }
                                     
                                    }
                                } else {
                                    self.current_cell = self.lower_cell
                                }
                            } else if (!self.fresh_load) {
                                guard self.upper_cell.playingflag == false else {
                                    return
                                }
                               
                                    //Scrolling upwards
                                 print("PLAY UPPER CELL")
                                self.lower_cell.playingflag = false
                                self.upper_cell.playingflag = true
                                
                                //self.appleplayer.stop()
                                DispatchQueue.main.async {
                                    self.lower_cell.dimmer_layer.alpha = 0.5
                                    self.upper_cell.dimmer_layer.alpha = 0
                                    self.lower_cell.timer_label.text = "0:00"
                                    if self.wkyoutubeplayer.isDescendant(of: self.lower_cell) {
                                        print("is descendant - removing")
                                        self.wkyoutubeplayer.isHidden = true
                                        self.wkyoutubeplayer.stopVideo()
                                        self.wkyoutubeplayer.removeFromSuperview()
                                        self.lower_cell.layoutIfNeeded()
                                    }
                                }
                                
                               if self.lower_cell.playback_post.player == .appleplayer {
                                    if self.appleplayer.playbackState == .playing {
                                        self.appleplayer.pause()
                                    }
                               } else if self.lower_cell.playback_post.player == .spotifyplayer {
                                    if (self.spotifyplayer?.playbackState.isPlaying)! {
                                        self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
                                            if (error == nil) {
                                            } else {
                                                print ("error in pausing!")
                                            }
                                        })
                                    }
                                }
                                if self.timer.isValid {
                                    print("paused number 1 timer stopped")
                                    self.timer.invalidate()
                                    self.reset_timer_values()
                                    DispatchQueue.main.async {
                                        self.current_cell.timer_label.text = "0:00"
                                    }
                                   
                                }
                                
                                if self.upper_cell.typeFlag != "video" {
                                    
                                    if self.upper_cell.source == "apple" && self.upper_cell.helper_id == "" {
                                        //Need to play 30 second sample here using AV player
                                        print ("empty helper id - pause if playing")
                                    } else {
                                        if self.upper_cell.playback_post.trackid == self.current_cell.playback_post.trackid  {
                                            print("same song consecutive")
                                            if self.upper_cell.playback_post.player == .appleplayer {
                                                self.appleplayer.currentPlaybackTime = 0.0
                                                self.appleplayer.prepareToPlay()
                                                self.appleplayer.play()
                                            } else if self.upper_cell.playback_post.player == .spotifyplayer {
                                                self.spotifyplayer?.seek(to: 0.0, callback: { (error) in
                                                      if (error == nil) {
                                                      } else {
                                                         print ("error in playing autoplay 1!")
                                                    }
                                                })
                                                self.spotifyplayer?.setIsPlaying(true, callback: { (error) in
                                                    if (error == nil) {
                                                        print("paused number 1 timer statrted")
                                                    }  else {
                                                       print ("error in pausing!")
                                                    }
                                                })
                                            }
                                            self.current_cell = self.upper_cell
                                            DispatchQueue.main.async {
                                                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.upper_cell_update_progress_spotify), userInfo: nil, repeats: true)
                                                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                                            }
                                        } else {
                                            print("Skipping to previous")
                                            if self.upper_cell.playback_post.player == .appleplayer {
                                                self.appleplayer.setQueue(with: [self.upper_cell.playback_post.trackid])
                                                self.appleplayer.prepareToPlay()
                                                self.appleplayer.play()
                                            } else if self.upper_cell.playback_post.player == .spotifyplayer {
                                                self.spotifyplayer?.playSpotifyURI(self.upper_cell.playback_post.trackid, startingWith: 0, startingWithPosition: 0.0, callback: { (error) in
                                                        if (error == nil) {
                                                        } else {
                                                            print ("error in playing autoplay 1!")
                                                        }
                                                })
                                            }
                                            print("playing number 3 timer started")
                                            self.current_cell = self.upper_cell
                                            DispatchQueue.main.async {
                                                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.upper_cell_update_progress_spotify), userInfo: nil, repeats: true)
                                                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                                            }
                                        }
                                    }
                                   
                                } else {
                                     self.current_cell = self.upper_cell
                                }
                                
                            }
                      
            }
                        
        } else if tableView.visibleCells.count > 0 {
//            print ("tableView.visibleCells.count > 0")
//            upper_cell = tableView.visibleCells[0] as? PostCell
//
//            DispatchQueue.global(qos: .userInitiated).async {
//                         print("PLAY UPPER CELL single cell visible")
//                        self.upper_cell.playingflag = true
//
//
//                        //DispatchQueue.main.async {
//                            self.appleplayer.stop()
//                        //}
//
//                            if self.upper_cell.source == "spotify" {
//                                print("helper id is \(self.upper_cell.helper_id)")
//                                self.appleplayer.setQueue(with: [self.upper_cell.helper_id])
//                            } else {
//                                print(" id is \(self.upper_cell.helper_id)")
//                                self.appleplayer.setQueue(with: [self.upper_cell.trackidstring])
//                            }
//                            //DispatchQueue.main.async {
//                                self.appleplayer.play()
//                            //}
//                }
//
        }
        
    }
    
    
    func reset_timer_values () {
        timer_new_value = 0.0
        timer_current_value = 0.0
    }
    
    
    
    @objc func lower_cell_update_progress_spotify () {
       print("lower_cell_update_progress_spotify")
        
        if self.timer_current_value == 0.0 {
            self.timer_current_value = self.spotifyplayer?.playbackState.position
        }
        
        self.timer_new_value = self.spotifyplayer?.playbackState.position
        //print(" floor(self.timer_current_value) is \(floor(self.timer_current_value))  and  floor( self.timer_new_value) is \(floor( self.timer_new_value)) ")
        if floor(self.timer_current_value) == floor( self.timer_new_value) {
            //do nothing
        } else if floor(self.timer_current_value) < floor( self.timer_new_value) {
            // print(" LESS THAN floor(self.timer_current_value) is \(floor(self.timer_current_value))  and  floor( self.timer_new_value) is \(floor( self.timer_new_value)) ")
            current_cell.timer_label.text = String(format:"%d", Int(floor( self.timer_new_value)))
             self.timer_current_value = self.spotifyplayer?.playbackState.position
        }
        // floor first value
        // print first value
        // till next value == first value don't print
        
    }
    
    
    @objc func upper_cell_update_progress_spotify () {
        //print("upper_cell_update_progress_spotify")
        if self.timer_current_value == 0.0 {
                   self.timer_current_value = self.spotifyplayer?.playbackState.position
               }
               
               self.timer_new_value = self.spotifyplayer?.playbackState.position
               
               if floor(self.timer_current_value) == floor( self.timer_new_value) {
                   //do nothing
               } else if floor(self.timer_current_value) < floor( self.timer_new_value) {
                   current_cell.timer_label.text = String(format:"%d", Int(floor( self.timer_new_value)))
                    self.timer_current_value = self.spotifyplayer?.playbackState.position
               }
    }
    
    @objc func first_cell_update_progress_spotify () {
        //print("first_cell_update_progress_spotify")
        first_cell.timer_label.text = String(format:"%.1f", (self.spotifyplayer?.playbackState.position)!)
    }
    
    //Won't work - problem when there are duplicates in the queue - consecutive or otherwise
    func setup_apple_queue () {
        
        //print("setup_apple_queue")
        var apple_queue =  [String]()
        
        var posts_reversed = (self.posts?.reversed())!
        for post in posts_reversed {
            if post.flag != "video" {
                if post.sourceapp == "spotify" {
                    if post.helper_id == "1224353521" {
                         apple_queue.append("1478826748")
                    } else if post.helper_id != ""
                    {
                         apple_queue.append(post.helper_id)
                    }
                } else {
                    
                    if post.trackid == "1224353521" {
                        apple_queue.append("1478826748")
                    } else {
                        apple_queue.append(post.trackid)
                    }
                   
                }
            }
            //self.appleplayer.setQueue(with: apple_queue)
            print(apple_queue)
        }
        
    }
    
    
    /*
    DispatchQueue.global(qos: .userInitiated).async {
               // Download file or perform expensive task
               cell.imageviewThumb?.image =   self.getThumbnailFrom(path: URL.init(string:strUrl )!)
               DispatchQueue.main.async {
                   // Update the UI
               }
    */
    
    
    //This function instantiates the MaxiSongCardViewController with the currently playing song. The MaxiSongCardViewController has the animation for the small player expanding into a full card music player. The whole MaxiSongCardViewController - SongPlayControlViewControlller setup came from here:  https://www.raywenderlich.com/221-recreating-the-apple-music-now-playing-transition
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
    
    
    
    //this is youtube player function. There seemed to be a problem where the miniplayer youtube player would not play after the play call in the cellForRowAt function. So I was trying to force the issue here :)
    @nonobjc func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        print("playerViewDidBecomeReady")
        if !fresh_load {
            print ("should be visible now")
            self.wkyoutubeplayer.isHidden = false
        }
        if self.miniplayer_is_playing! {
            self.youtubeplayer2.playVideo()
        } else {
            //self.youtubeplayer?.playVideo()
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        print("isPlaying: \(isPlaying)")
        if (isPlaying) {
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try! AVAudioSession.sharedInstance().setActive(true)
        } else {
            try! AVAudioSession.sharedInstance().setActive(false)
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
