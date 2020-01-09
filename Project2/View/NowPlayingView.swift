//
//  NowPlayingView.swift
//  Project2
//
//  Created by virdeshp on 11/30/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import Firebase
import Foundation
import YoutubePlayer_in_WKWebView


protocol FullMediaPlayerDelegate {
    
    func temp_expand_func (last_played_post_index: Int, posts: [PlaybackPost], tabbar_snapshot: UIImage, albumArtImage: UIImage, sourceController: String)
    
    func dismiss_player_view ()
    
    func cue_video (last_played_post: PlaybackPost)

}

class FullMediaPlayer: NSObject {

    static let shared = FullMediaPlayer()
    var delegate: FullMediaPlayerDelegate!
    
    override init() {
        super.init()
    }
    
    
    func expand (last_played_post_index: Int, posts: [PlaybackPost], tabbar_snapshot: UIImage, albumArtImage: UIImage, sourceController: String) {
        self.delegate.temp_expand_func(last_played_post_index: last_played_post_index, posts: posts, tabbar_snapshot: tabbar_snapshot, albumArtImage: albumArtImage, sourceController: sourceController)
    }
    
    func dismiss () {
        self.delegate.dismiss_player_view()
    }
    
    func cue_video (last_played_post: PlaybackPost) {
        self.delegate.cue_video(last_played_post: last_played_post)
    }
}

protocol NowPlayingViewDelegate {
    
    func hide_status_bar ()
    
    func show_status_bar ()

}


class NowPlayingView: NSObject, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, WKYTPlayerViewDelegate, FullMediaPlayerDelegate {
    
    let kCONTENT_XIB_NAME = "PlayerView"
    //Should contain all three players - apple/youtube/spotify
    //Should contain the animation
    //Delegate should be able to pass Single Post and List of Posts to it.
    var smallPlayer: UIView!
    var bigPlayerView = BigPlayerView()
    var postView = PostView()
    var delegate: NowPlayingViewDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var np_spotifyplayer: SPTAudioStreamingController?
    var np_appleplayer = MPMusicPlayerController.applicationQueuePlayer
    var np_systemplayer = MPMusicPlayerController.systemMusicPlayer
    var np_youtubeplayer: WKYTPlayerView!
    var np_av_player : AVAudioPlayer!
    var songnameLabel: UILabel!
    var playingImage: UIImageView!
    var getbutton: UIButton!
    var playBar: UIProgressView!
    var playbutton: UIButton!
    var timer = Timer()
    var timer_current_value: Double! = 0.0
    var timer_new_value: Double! = 0.0
    var current_index: Int = 0
    var np_posts = [PlaybackPost]()
    var is_playing: Bool = false
    var showing_player: Bool = true
    var postView_leadingConstraint: NSLayoutConstraint?
    var postView_trailingConstraint: NSLayoutConstraint?
    var postView_topConstraint: NSLayoutConstraint?
    var postView_bottomConstraint: NSLayoutConstraint?
    var postView_widthConstraint: NSLayoutConstraint?
    var last_played_post = PlaybackPost(post: Post(albumArtImage: "" , sourceAppImage: "", typeImage: "" , profileImage: "" , username: "" ,timeAgo: "", numberoflikes: "" ,caption:"", offset: 0.0, startoffset: 0.0, audiolength: 0.0, paused: false, playing: true, trackid: "", helper_id: "", helper_preview_url: "", videoid: "", starttime: 0.0 , endtime: 0.0, flag: "", lyrictext: "", songname: "", sourceapp: "", preview_url: "", albumArtUrl: "", original_track_length: 0, GIF_url: ""), player: .avplayer , trackid: "", can_play_this_post: true ,  message_for_user: "" )

    var dismiss_chevron: UIButton?
    var tabBarImageView: UIImageView?
    var tabBarImageView_leadConstraint : NSLayoutConstraint?
    var tabBarImageView_trailConstraint : NSLayoutConstraint?
    var tabBarImageView_topConstraint : NSLayoutConstraint?
    var tabBarImageView_botConstraint : NSLayoutConstraint?
    var name_label: UILabel?
    var artist_label: UILabel?
    var playingFrom_label: UILabel?
    var play_pause_button: UIButton?
    var next_button: UIButton?
    var previous_button: UIButton?
    var duration_label: UILabel?
    var prog_bar: UIProgressView?    //this is for the container view
    var containerView: UIView?
    var content_view_leadConstraint : NSLayoutConstraint?
    var content_view_trailConstraint : NSLayoutConstraint?
    var content_view_topConstraint : NSLayoutConstraint?
    var content_view_botConstraint : NSLayoutConstraint?
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
    var dark: Bool!
    var tableViewImage: UIImage!
    var tabBarImage: UIImage!
    
    override init() { //for using the view programmatically
        super.init()
        
        self.np_appleplayer.beginGeneratingPlaybackNotifications()
        self.np_spotifyplayer = SPTAudioStreamingController.sharedInstance()
                
        smallPlayer = UIView(frame: CGRect(origin: CGPoint(x:5, y:(self.mainWindow!.frame.height)), size: CGSize(width: (self.mainWindow!.frame.width - 10), height: 50)))
        smallPlayer.backgroundColor = UIColor.white
        smallPlayer.layer.cornerRadius = 5
        
        /*
         
         Measurements for the small player
         |-5-|-5-image(40)-5-name(flexible)-(10)-button(32)-(10)-button(32)-5-|
         
         */
        smallPlayer.layer.shadowColor = UIColor.black.cgColor
        smallPlayer.layer.shadowOpacity = 0.5
        smallPlayer.clipsToBounds = false
        smallPlayer.layer.shadowOffset = CGSize(width: 0, height: 5)
        smallPlayer.layer.shadowRadius = 5
        self.smallPlayer.layer.shadowPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: 0, y: 0) , size: CGSize(width: smallPlayer.frame.width, height: smallPlayer.frame.height)), cornerRadius: 5).cgPath
        
        songnameLabel = UILabel(frame: CGRect(origin: CGPoint(x:50, y:5), size: CGSize(width: smallPlayer.frame.width - (139), height:37)))
        songnameLabel?.text = "Song Name"
        songnameLabel?.textAlignment = NSTextAlignment.center
        songnameLabel?.font = songnameLabel?.font.withSize(13)
        self.smallPlayer.addSubview(songnameLabel!)
 
        
        playingImage = UIImageView(image: #imageLiteral(resourceName: "clapton"))
        playingImage?.contentMode = UIView.ContentMode.scaleAspectFill
        playingImage?.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        self.smallPlayer.addSubview(playingImage!)
        
        
        getbutton = UIButton(frame: CGRect(origin: CGPoint(x: 286, y: 9), size: CGSize(width: 32, height: 32)))
        getbutton.setImage(#imageLiteral(resourceName: "icons8-below-96"), for: .normal)
        getbutton.addTarget(self, action: #selector(showBottomView), for: .touchUpInside)
        self.smallPlayer.addSubview(getbutton)
        
        playbutton = UIButton(frame: CGRect(origin: CGPoint(x: 328, y: 9), size: CGSize(width: 32, height: 32)))
        playbutton.setBackgroundImage(UIImage(named: "icons8-pause-button-90"), for: .normal)
        playbutton.addTarget(self, action: #selector(play_pause(recognizer:)), for: .touchUpInside)
        self.smallPlayer.addSubview(playbutton)
        
        playBar = UIProgressView(frame: CGRect(origin: CGPoint(x:50, y:42), size: CGSize(width: smallPlayer.frame.width - (139), height: 2)))
        playBar.progressTintColor = UIColor.darkGray
        playBar.trackTintColor = UIColor.lightGray
        playBar.progress = 0.0
        self.smallPlayer.addSubview(playBar)
        
        let expand_tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit3))
        self.smallPlayer.addGestureRecognizer(expand_tapGesture)
 
         /*
        playingFrom_label = UILabel(frame: CGRect(origin: CGPoint(x:47.5, y:5), size: CGSize(width: 280, height:37)))
        playingFrom_label?.text = "Playing from Feed"
        playingFrom_label?.textAlignment = NSTextAlignment.center
        playingFrom_label?.font = playingFrom_label?.font.withSize(13)
        
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
        /*
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
         */
        
        //this is a layer that sits on top of the backingImageView and dims everything underneath to add to the effect of everything being in the background
        /*
        dimmmerLayer = UIView(frame: (UIApplication.shared.keyWindow?.frame)!)
        dimmmerLayer?.backgroundColor = UIColor.black
        dimmmerLayer?.alpha = 0
        mainWindow!.addSubview(self.dimmmerLayer!)
        dimmmerLayer?.isHidden = true
        */
        
        
        //The conatiner view is the big white card like player view which contains the fully expanded youtube player  - this sits on top of the dimmer view
        /*
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
        containerView!.addSubview(self.playingFrom_label!)
        containerView!.addSubview(self.name_label!)
        containerView!.addSubview(self.artist_label!)
        containerView!.addSubview(self.duration_label!)
        containerView!.addSubview(self.prog_bar!)
        
        
        //Setting up contraints for everything inside the card player view
        self.containerView?.addConstraintWithFormat(format: "H:|-10-[v0]-1.5-[v1]-47.5-|", views: self.dismiss_chevron!, self.playingFrom_label!)
        self.containerView?.addConstraintWithFormat(format: "H:|-16-[v0]-16-|", views: self.name_label!)
        self.containerView?.addConstraintWithFormat(format: "H:|-16-[v0]-16-|", views: self.artist_label!)
        self.containerView?.addConstraintWithFormat(format: "H:|-16-[v0]-16-|", views: self.duration_label!)
        self.containerView?.addConstraintWithFormat(format: "H:|-22.5-[v0]-22.5-|", views: self.prog_bar!)
        self.containerView?.addConstraintWithFormat(format: "V:|-4-[v0]-340-[v1]-8-[v2]-8-[v3]-20-[v4]-150-|", views: self.playingFrom_label!, self.prog_bar!, self.name_label!, self.artist_label!, self.duration_label!)

        mainWindow!.addSubview(self.containerView!)
        */
        
        //we manipulate these constraints to animate the view into it's place
        /*
        self.containerView!.translatesAutoresizingMaskIntoConstraints = false
        containerView_leadConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        containerView_trailConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        containerView_topConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 568)
        containerView_botConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 531)
        mainWindow?.addConstraints([containerView_topConstraint!, containerView_botConstraint!, containerView_leadConstraint!, containerView_trailConstraint!])
        containerView?.isHidden = true
        */
        
        commonInit()
      
        temp_view?.isHidden = true
        
        print (backingImageView?.layer.frame.height)
        print (backingImageView?.layer.frame.width)
        print (backingImageView?.frame.height)
        print (backingImageView?.frame.width)
        
        //the small youtube player that shows up in the miniplayer view
        //Setting it up inside temp_view2
        np_youtubeplayer = WKYTPlayerView.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        np_youtubeplayer.contentMode = UIView.ContentMode.scaleAspectFit
        mainWindow!.bringSubviewToFront(self.temp_view2!)
        self.temp_view2?.addSubview(self.np_youtubeplayer!) //small youtube player sits in temp_view2
        self.temp_view2?.addConstraintWithFormat(format: "H:|-0-[v0]-0-|", views: self.np_youtubeplayer)
        self.temp_view2?.addConstraintWithFormat(format: "V:|-0-[v0]-0-|", views: self.np_youtubeplayer)
        self.temp_view2!.translatesAutoresizingMaskIntoConstraints = false
        self.temp_view2?.bringSubviewToFront(np_youtubeplayer)
        np_youtubeplayer.backgroundColor = UIColor.black
        np_youtubeplayer?.delegate = self
        np_youtubeplayer.isHidden = true
        temp_view2?.isHidden = true
        np_youtubeplayer.load(withVideoId: "kyAA2C5wk4Y", playerVars: ["autoplay": 0, "playsinline": 1, "showinfo" : 1,"modestbranding" : 1, "controls": 1, "rel": 0,"origin" : "https://www.youtube.com", "iv_load_policy": 3])
        
        /*
        let tapGesture4 = UISwipeGestureRecognizer(target: self, action: #selector(tapEdit4(recognizer:)))
        tapGesture4.direction = UISwipeGestureRecognizer.Direction.down
        //temp_view?.addGestureRecognizer(tapGesture4)
        containerView?.addGestureRecognizer(tapGesture4) //This gesture closes the expanded youtube player view back to the small youtube player playing in the miniplayer
         */
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(play_pause(recognizer:)))
        self.bigPlayerView.playPauseButton.addGestureRecognizer(tapGesture1)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(next_song(recognizer:)))
        self.bigPlayerView.nextSong.addGestureRecognizer(tapGesture2)
        
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(previous_song(recognizer:)))
        self.bigPlayerView.previousSong.addGestureRecognizer(tapGesture3)
        
        
        let tapGesture_seePost = UITapGestureRecognizer(target: self, action: #selector(see_post(recognizer:)))
        self.bigPlayerView.seePost.addGestureRecognizer(tapGesture_seePost)
        self.bigPlayerView.seePost.isUserInteractionEnabled = true
        
        
        //This gesture closes the expanded youtube player view back to the small youtube player playing in the miniplayer
        
        
        //So because the temp_view, backingImageview, dimmer_layer and container_view basically sit on top of everything in the controller - but are hidden until required - when they are shown the tab bar goes away all of a sudden because it's actually below them. So to make it go away in a nicer way, we take a snapshot of the tab bar, place it exactly where the real tabbar is - make it hidden - and when all the above views are shown, we make this snapshot visible and then animate-slide it out of the bottom of the view.
        tabBarImageView = UIImageView(frame: CGRect(origin: CGPoint(x:0, y: 618), size: CGSize(width: 375.0, height: 49))) // 375 x 49

        self.tabBarImageView!.translatesAutoresizingMaskIntoConstraints = false

        mainWindow?.addSubview(tabBarImageView!)

        mainWindow?.bringSubviewToFront(tabBarImageView!)
           
           //we use these contraints to animate it out of view
           tabBarImageView_leadConstraint = NSLayoutConstraint(item: tabBarImageView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
           tabBarImageView_trailConstraint = NSLayoutConstraint(item: tabBarImageView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
           tabBarImageView_topConstraint = NSLayoutConstraint(item: tabBarImageView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 618)
           tabBarImageView_botConstraint = NSLayoutConstraint(item: tabBarImageView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
           mainWindow?.addConstraints([tabBarImageView_topConstraint!, tabBarImageView_botConstraint!, tabBarImageView_leadConstraint!, tabBarImageView_trailConstraint!])
           //tabBarImageView?.isHidden = true

        self.setup_post_view()
    }
    /*
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 */
    
     
      
      func commonInit() {
        print("commonInit ran ---------------------------------")
       
       
        //we manipulate these constraints to animate the view into it's place
        self.bigPlayerView.translatesAutoresizingMaskIntoConstraints = false
        content_view_leadConstraint = NSLayoutConstraint(item: bigPlayerView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        content_view_trailConstraint = NSLayoutConstraint(item: bigPlayerView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        content_view_topConstraint = NSLayoutConstraint(item: bigPlayerView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 568)
        content_view_botConstraint = NSLayoutConstraint(item: bigPlayerView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 568)
        mainWindow?.addSubview(bigPlayerView)
        mainWindow?.addConstraints([content_view_topConstraint!, content_view_botConstraint!, content_view_leadConstraint!, content_view_trailConstraint!])
        bigPlayerView.isHidden = true
        
        let tapGesture4 = UISwipeGestureRecognizer(target: self, action: #selector(tapEdit4(recognizer:)))
        tapGesture4.direction = UISwipeGestureRecognizer.Direction.down
        
        let tapGesture5 = UITapGestureRecognizer(target: self, action: #selector(tapEdit4(recognizer:)))
     
        //temp_view?.addGestureRecognizer(tapGesture4)
        bigPlayerView.addGestureRecognizer(tapGesture4)
        bigPlayerView.dismissChevron.addGestureRecognizer(tapGesture5)
        bigPlayerView.dismissChevron.isUserInteractionEnabled = true //This gesture closes the expanded youtube player view back to the small youtube player playing in the miniplayer
        //bigPlayerView.dismissChevron.addGestureRecognizer(tapGesture4)
        
      }
   
    @objc func showBottomView () {
        
    }
    
    func cue_video (last_played_post: PlaybackPost) {
        print ("cue_video")
        //self.np_youtubeplayer.cueVideo(byId: self.last_played_post.post.videoid, startSeconds: 0.0, suggestedQuality: WKYTPlaybackQuality.default)
    }
    
  
    
    //This is for all posts youtube/spotify/apple
    //this contains the entire animation of how the player view at the bottom expands into the large player
    
     @objc func tapEdit3(recognizer: UITapGestureRecognizer)  {
        print("tapedit 3")
        guard let post = self.last_played_post.post else {
            return
        }
        
        if self.last_played_post.player == .youtubeplayer {
           self.np_youtubeplayer.isHidden = true
            temp_view2?.isHidden = true
        }
        
        temp_view?.isHidden = false
        self.dimmmerLayer?.isHidden = false
        self.bigPlayerView.isHidden = false

        UIView.animate(withDuration: 0.5/2) { //We slide the tabbarimage view down and out
            self.tabBarImageView_topConstraint?.constant = 667
            self.tabBarImageView_botConstraint?.constant = 49
        }
            
        UIView.animate(withDuration: 0.5/4) { //We bring the container view from transparent to white
            self.bigPlayerView.backgroundColor = UIColor.white
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                            options: [.curveEaseOut], animations: {

                self.delegate!.hide_status_bar()
                self.leadingConstraint?.constant = 0
                self.trailingConstraint?.constant = 0
                self.topConstraint?.constant = 53 //(40 + 38)
                self.bottomConstraint?.constant = -308
                self.content_view_topConstraint?.constant = 0
                self.content_view_botConstraint?.constant = 10
                self.bigPlayerView.layer.cornerRadius = 10
                self.dismiss_chevron?.alpha = 1
                self.np_youtubeplayer?.layoutIfNeeded()
                self.temp_view2?.layoutIfNeeded()
                self.mainWindow!.layoutIfNeeded()
                                
                }, completion: { (value: Bool) in
                    if self.last_played_post.player == .youtubeplayer {
                        self.np_youtubeplayer.isHidden = false
                        self.temp_view2?.isHidden = false
                    }
                    self.temp_view?.isHidden = false
            })
        
    }
    
    func bring_up_player_view () {
            
        if (self.smallPlayer!.isHidden == true){
            self.smallPlayer!.isHidden = false
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.smallPlayer!.frame = CGRect(x: 0, y: 568, width: 375, height: 50)
            }, completion: nil)
    }
        
        
    //When a new post is played we use this function to set it up with the Post details like image, song name and start the progress bar.
    func setup_player_view(tapped_post: PlaybackPost, albumArtImage: UIImage) {
        print("setup_player_view")
            
        if (self.smallPlayer!.isHidden == true) {
            self.smallPlayer!.isHidden = false
        }
        
        playBar.progress = 0
             
        songnameLabel?.text = tapped_post.post.songname
        artist_label?.text = "Artist Name"
        playingImage.image = albumArtImage
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.smallPlayer!.frame = CGRect(x: 5, y: 563, width: (self.mainWindow!.frame.width - 10), height: 50)
        }, completion: nil)

    }
        
        
        //hide the player view
    func dismiss_player_view(){
        print("dismiss_player_view")
        
        //stop media
        self.pause()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
            self.smallPlayer!.frame = CGRect(origin: CGPoint(x:5, y: (self.mainWindow!.frame.height)), size: CGSize(width: (self.mainWindow!.frame.width - 10), height: 50))
            }, completion: nil)
    }
    
    //Dismissal function
    @objc func tapEdit4(recognizer: UITapGestureRecognizer) {
        print("tapedit 4")
        if self.last_played_post.player == .youtubeplayer {
            self.np_youtubeplayer.isHidden = true
            self.temp_view2?.isHidden = true
        }
        self.temp_view?.isHidden = true
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                        options: [.curveEaseIn], animations: {
                        self.temp_view?.frame = CGRect(origin: CGPoint(x: 0, y: (self.mainWindow?.frame.height)!), size: CGSize(width: (self.mainWindow?.frame.width)!, height: (self.mainWindow?.frame.height)!))
        }, completion: nil)
                
  
        UIView.animate(withDuration: 0.5/2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                                                    options: [.curveEaseIn], animations:  {
            self.tabBarImageView_topConstraint?.constant = 618
            self.tabBarImageView_botConstraint?.constant = 0
            }, completion: { (value: Bool) in
        })

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                        options: [.curveEaseIn], animations: {
                        self.delegate!.show_status_bar()
                        self.leadingConstraint?.constant = 8
                        self.trailingConstraint?.constant = -319
                        self.topConstraint?.constant = 573
                        self.bottomConstraint?.constant = (-54)
                        self.content_view_topConstraint?.constant = 568
                        self.content_view_botConstraint?.constant = 568
                        self.bigPlayerView.layer.cornerRadius = 0
                        self.dismiss_chevron?.alpha = 0
                        self.temp_view2?.layoutIfNeeded()
                        self.mainWindow!.layoutIfNeeded()
            }, completion: { (value: Bool) in
                self.bigPlayerView.isHidden = true
                if self.last_played_post.player == .youtubeplayer {
                    self.np_youtubeplayer.isHidden = false
                    self.temp_view2?.isHidden = false
                }
                self.dimmmerLayer?.isHidden = true
                self.temp_view?.isHidden = true
                self.temp_view?.frame = (UIApplication.shared.keyWindow?.frame)!
                self.bigPlayerView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            })
    }
        
        
 //Needs following inputs - last played post - tabbar snapshot
    func temp_expand_func (last_played_post_index: Int, posts: [PlaybackPost], tabbar_snapshot: UIImage, albumArtImage: UIImage, sourceController: String) {
                
        print("Cell index is \(last_played_post_index)")
        self.last_played_post = posts[last_played_post_index]
        
        guard let post = self.last_played_post.post else {
            return
        }
        
        self.np_posts = posts
        self.current_index = last_played_post_index
        
        setup_player_view(tapped_post: self.last_played_post, albumArtImage: albumArtImage)
        
        self.bigPlayerView.playingFromLabel.text = "Playing from \(sourceController)"
        self.bigPlayerView.songName.text = self.last_played_post.post.songname
        self.bigPlayerView.artistName.text = "Artist Name"
        self.bigPlayerView.timeLeft.text = timeDisplayFormat(totalSeconds: Int(self.last_played_post.post!.audiolength))
        self.bigPlayerView.progressSlider.value = 0
        self.playBar.progress = 0
        self.bigPlayerView.progressSlider.addTarget(self, action: #selector(handleSliderTouchUpInside), for: .touchUpInside)
        self.bigPlayerView.progressSlider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        //If youtube post
        if self.last_played_post.player == .youtubeplayer {
            self.bigPlayerView.albumArtContainerView.isHidden = true
        } else {
            //If song post
            //PLAY THE SONG HERE
            self.bigPlayerView.bringSubviewToFront(self.bigPlayerView.albumArtContainerView)
            self.bigPlayerView.albumArtView.image = albumArtImage
        }
        
        self.setup_player()

        self.bigPlayerView.playPauseButton.setBackgroundImage(UIImage(named: "icons8-pause-button-90"), for: .normal)
        self.playbutton.setBackgroundImage(UIImage(named: "icons8-pause-button-90"), for: .normal)
        
        self.np_youtubeplayer.isHidden = true
        temp_view2?.isHidden = true
        temp_view?.isHidden = false
        self.dimmmerLayer?.isHidden = false
        self.bigPlayerView.isHidden = false
        self.tabBarImageView?.image = tabbar_snapshot //we take a snapshot of the current view of the tabbar
        self.tabBarImageView?.isHidden = false
        UIView.animate(withDuration: 0.5/2) { //We slide the tabbarimage view down and out
            self.tabBarImageView_topConstraint?.constant = 667
            self.tabBarImageView_botConstraint?.constant = 49
        }
        
        UIView.animate(withDuration: 0.5/4) { //We bring the container view from transparent to white
            self.bigPlayerView.backgroundColor = UIColor.white
        }
    
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                        options: [.curveEaseOut], animations: {
   
            self.delegate!.hide_status_bar()
            self.leadingConstraint?.constant = 0
            self.trailingConstraint?.constant = 0
            self.topConstraint?.constant = 53 //(40 + 38)
            self.bottomConstraint?.constant = -308
            self.content_view_topConstraint?.constant = 0
            self.content_view_botConstraint?.constant = 10
            self.bigPlayerView.layer.cornerRadius = 10
            self.dismiss_chevron?.alpha = 1
            self.np_youtubeplayer?.layoutIfNeeded()
            self.temp_view2?.layoutIfNeeded()
            self.mainWindow!.layoutIfNeeded()
                            
            }, completion: { (value: Bool) in
                
                self.temp_view?.isHidden = false
                if self.last_played_post.player == .youtubeplayer {
                    self.np_youtubeplayer.isHidden = false
                    self.temp_view2?.isHidden = false
                }
        })
       
    }
    
    
    @objc func handleSliderTouchUpInside () {
        print("progressSlider.value is \(self.bigPlayerView.progressSlider.value) audio lenght is \(self.last_played_post.post.audiolength)")
        let seekToValue = self.bigPlayerView.progressSlider.value * self.last_played_post.post.audiolength
        self.timer_current_value = 0.0
        if self.last_played_post.player == .youtubeplayer {
            self.np_youtubeplayer.seek(toSeconds: seekToValue, allowSeekAhead: true)
            print("seeking to time \(TimeInterval(seekToValue)) youtube")
            self.timer_new_value = TimeInterval(seekToValue)
        } else if self.last_played_post.player == .spotifyplayer {
            self.np_spotifyplayer?.seek(to: TimeInterval(seekToValue), callback: {error in
                if error == nil {
                    print("seeking to time \(TimeInterval(seekToValue)) spotify ")
                    self.timer_new_value = TimeInterval(seekToValue)
                } else {
                    print ("error seeking \(error)")
                }
            })
        } else if self.last_played_post.player == .appleplayer {
            self.np_appleplayer.currentPlaybackTime = TimeInterval(seekToValue)
            print("seeking to time \(TimeInterval(seekToValue)) apple ")
            self.timer_new_value = TimeInterval(seekToValue)
        } else if self.last_played_post.player == .avplayer {
            self.np_av_player.currentTime = TimeInterval(seekToValue)
            print("seeking to time \(TimeInterval(seekToValue)) avplayer ")
            self.timer_new_value = TimeInterval(seekToValue)
        }
        
        
    }
    
    @objc func handleSliderChange () {
        print("handleSliderChange")
        let seekToValue = self.bigPlayerView.progressSlider.value * self.last_played_post.post.audiolength
        self.bigPlayerView.timeCompleted.text = timeDisplayFormat(totalSeconds: Int(floor(seekToValue)))
        self.bigPlayerView.timeLeft.text = timeDisplayFormat(totalSeconds: Int(self.last_played_post.post.audiolength) - Int(floor(seekToValue)))
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
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
         
         print("state changed youtube")
           switch(state){
           case WKYTPlayerState.unstarted:
               print(" np_player unstarted youtube")
               break;
           case WKYTPlayerState.queued:
               print(" np_player queued youtube")
               break;
           case WKYTPlayerState.buffering:
               print(" np_player buffering youtube")
               break;
           case WKYTPlayerState.ended:
               print(" np_player ended youtube")
               break;
           case WKYTPlayerState.playing:
                print(" np_player playing youtube")
               break;
           case WKYTPlayerState.paused:
               print(" np_player paused youtube")
           default:
               break;
           }
    }
}


extension NowPlayingView {
    
    func setup_player () {
        
        print("newsfeed play")
        if self.last_played_post.player == player_type.appleplayer {
            //print ("first cell player is apple")
            //print("track id is \(playable_post.trackid)")
            //print("setQueue")
            self.np_appleplayer.setQueue(with: [self.last_played_post.trackid])
            self.np_appleplayer.prepareToPlay(completionHandler: {_ in
                self.np_appleplayer.play()
                print("prepared to play")
                self.is_playing = true
            })
            self.reset_timer_values()
            DispatchQueue.main.async {
                if self.timer.isValid {
                    self.timer.invalidate()
                }
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.current_cell_update_progress_apple), userInfo: nil, repeats: true)
                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                  
            }
            //we set the timer in 'apple player did start playing notif handler'
            // print ("helper id is \(self.posts![posts!.count - 1].helper_id)")
        } else if self.last_played_post.player == player_type.spotifyplayer {
            //print("first cell player is spotify")
            //print ("track id is \(self.posts![posts!.count - 1].trackid)")
            self.np_spotifyplayer?.playSpotifyURI(self.last_played_post.trackid, startingWith: 0, startingWithPosition: 0.0, callback: { (error) in
                if (error == nil) {
                    print("playing number 3")
                    self.is_playing = true
                    self.reset_timer_values()
                    DispatchQueue.main.async {
                        if self.timer.isValid {
                            self.timer.invalidate()
                        }
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.current_cell_update_progress_spotify), userInfo: nil, repeats: true)
                        RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                    }
                } else {
                    print ("error in playing autoplay 1!")
                }
            })
        } else if self.last_played_post.player == player_type.avplayer {
            if self.last_played_post.trackid != nil && self.last_played_post.trackid != "" {
                self.download_preview(url: URL(string: self.last_played_post.trackid)!)
            }
        } else if self.last_played_post.player == .youtubeplayer {
            self.np_youtubeplayer.cueVideo(byId: self.last_played_post.post.videoid, startSeconds: 0.0, suggestedQuality: WKYTPlaybackQuality.default)
            self.np_youtubeplayer.playVideo()
            self.is_playing = true
            self.reset_timer_values()
            DispatchQueue.main.async {
                if self.timer.isValid {
                        self.timer.invalidate()
                }
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.current_cell_update_progress_youtube), userInfo: nil, repeats: true)
                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                  
            }
        }
        
    }
    
    func play () {
        print("newsfeed play")
        if self.last_played_post.player == player_type.appleplayer {
            self.np_appleplayer.prepareToPlay(completionHandler: {_ in
                self.np_appleplayer.play()
                self.is_playing = true
                print("prepared to play")
            })
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.current_cell_update_progress_apple), userInfo: nil, repeats: true)
                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                
            }
            //we set the timer in 'apple player did start playing notif handler'
            // print ("helper id is \(self.posts![posts!.count - 1].helper_id)")
        } else if self.last_played_post.player == player_type.spotifyplayer {
            //print("first cell player is spotify")
            //print ("track id is \(self.posts![posts!.count - 1].trackid)")
            self.np_spotifyplayer?.setIsPlaying(true, callback: { (error) in
                if (error == nil) {
                    self.is_playing = true
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.current_cell_update_progress_spotify), userInfo: nil, repeats: true)
                    RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                } else {
                    print ("error in playing autoplay 1!")
                }
            })
        } else if self.last_played_post.player == player_type.avplayer {
            if last_played_post.trackid != nil && last_played_post.trackid != "" {
                self.play_av()
                self.is_playing = true
            }
        } else if self.last_played_post.player == .youtubeplayer {
            self.np_youtubeplayer.playVideo()
            self.is_playing = true
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.current_cell_update_progress_youtube), userInfo: nil, repeats: true)
                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                  
            }
            
        }
    }
    
    func pause () {
        print("np_pause")
        if last_played_post.player == .appleplayer {
            //DispatchQueue.main.async {
            if self.np_appleplayer.playbackState == .playing {
                print("apple is playing")
                // print("self.appleplayer.playbackState == .playing")
                self.np_appleplayer.pause()
                self.is_playing = false
            } else {
                print("apple is not playing")
             }
             //}
         } else if last_played_post.player == .spotifyplayer {
              if (self.np_spotifyplayer?.playbackState.isPlaying)! {
                  self.np_spotifyplayer?.setIsPlaying(false, callback: { (error) in
                      if (error == nil) {
                         print("pausing from np_pause")
                        self.is_playing = false
                      } else {
                          print ("error in pausing!")
                      }
                  })
              }
         } else if last_played_post.player == .avplayer {
             self.stop_av()
             self.is_playing = false
         } else if self.last_played_post.player == .youtubeplayer {
              self.np_youtubeplayer.pauseVideo()
              self.is_playing = false
         }
         if self.timer.isValid {
             print("timer should be invalidated")
             self.timer.invalidate()
          }
        
    }
    
    func play_next () {
        print("play_next")
        print(self.current_index)
        print(self.np_posts.count)
        if self.current_index >= (self.np_posts.count - 1)  {
            if self.bigPlayerView.loopPlaylist {
                print("Loop playlist is enabled - moving from last song to first song")
                self.current_index = -1
            } else {
                print("returning")
                return
            }
        }

        if self.current_index == -1 {
            self.bigPlayerView.previousSong.isSelected = true
        } else {
            self.bigPlayerView.previousSong.isSelected = false
        }
        
        //moving to last song in the list
        if self.current_index == self.np_posts.count - 2 {
            self.bigPlayerView.nextSong.isSelected = true
        } else {
            self.bigPlayerView.previousSong.isSelected = false
        }
        
        
        self.current_index = self.current_index + 1
        self.pause()
        self.reset_timer_values()
        self.bigPlayerView.progressSlider.value = 0
        self.playBar.progress = 0
        self.last_played_post = self.np_posts[current_index]
        self.bigPlayerView.timeCompleted.text = "0:00"
        self.bigPlayerView.timeLeft.text = "\(timeDisplayFormat(totalSeconds: Int(self.last_played_post.post.audiolength)))"
        self.setup_player()
        self.update_song_details_UI()
        
    }
    
    func play_previous () {
        
        guard self.current_index > 0 else {
            return
        }
        
        if self.current_index == 1 {
            self.bigPlayerView.previousSong.isSelected = true
        } else {
            self.bigPlayerView.previousSong.isSelected = false
        }
        
        //moving from last to second last song in the list
        if self.current_index == self.np_posts.count - 1 {
            self.bigPlayerView.nextSong.isSelected = false
        }
        
        self.current_index = self.current_index - 1
        self.pause()
        self.reset_timer_values()
        self.bigPlayerView.progressSlider.value = 0
        self.playBar.progress = 0
        self.last_played_post = self.np_posts[current_index]
        self.bigPlayerView.timeCompleted.text = "0:00"
        self.bigPlayerView.timeLeft.text = "\(timeDisplayFormat(totalSeconds: Int(self.last_played_post.post.audiolength)))"
        self.setup_player()
        self.update_song_details_UI()
        
        
    }
    
    func replay () {
        self.reset_timer_values()
        self.bigPlayerView.progressSlider.value = 0
        self.playBar.progress = 0
        self.last_played_post = self.np_posts[current_index]
        self.bigPlayerView.timeCompleted.text = "0:00"
        self.bigPlayerView.timeLeft.text = "\(timeDisplayFormat(totalSeconds: Int(self.last_played_post.post.audiolength)))"
        self.setup_player()
    }
    
    func stop () {
        
    }
    
    @objc func play_pause(recognizer: UITapGestureRecognizer) {
        if self.is_playing {
            self.pause()
            self.bigPlayerView.playPauseButton.setBackgroundImage(UIImage(named: "icons8-play-button-circled-90"), for: .normal)
            self.playbutton.setBackgroundImage(UIImage(named: "icons8-play-button-circled-90"), for: .normal)
        } else {
            self.play()
            self.bigPlayerView.playPauseButton.setBackgroundImage(UIImage(named: "icons8-pause-button-90"), for: .normal)
            self.playbutton.setBackgroundImage(UIImage(named: "icons8-pause-button-90"), for: .normal)
        }
    }
    
    @objc func next_song(recognizer: UITapGestureRecognizer) {
        self.play_next()
        self.bigPlayerView.playPauseButton.setBackgroundImage(UIImage(named: "icons8-pause-button-90"), for: .normal)
    }
    
    @objc func previous_song(recognizer: UITapGestureRecognizer) {
        self.play_previous()
        self.bigPlayerView.playPauseButton.setBackgroundImage(UIImage(named: "icons8-pause-button-90"), for: .normal)
    }
    
    func reset_timer_values () {
        self.timer_new_value = 0.0
        self.timer_current_value = 0.0
    }
    
    func download_preview (url : URL) {
        print("download_preview url is \(url.absoluteString)")
        var download_task = URLSessionDownloadTask()
            
        download_task = URLSession.shared.downloadTask(with: url, completionHandler: {(downloadedURL, response, error) in
                
            self.initiate_av(url: downloadedURL!)
        })
            
        download_task.resume()
        self.reset_timer_values()
        DispatchQueue.main.async {
            if self.timer.isValid {
                self.timer.invalidate()
            }
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.current_cell_update_progress_av), userInfo: nil, repeats: true)
                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
            }
    }
        
    func initiate_av (url : URL) {
            
        print ("initiate_av")
        do {
                np_av_player = try AVAudioPlayer(contentsOf: url)
                np_av_player.prepareToPlay()
                do {
                   try AVAudioSession.sharedInstance().setCategory(.playback)
                } catch(let error) {
                    print(error.localizedDescription)
                }
                np_av_player.play()
                self.is_playing = true
                //ISSUE - thsi timer doesn't fire because initiate_av is called from a background thread, it's called after the url download is completed in download_preview - need to figure out the right way to do this.
    //            DispatchQueue.main.async {
    //                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.current_cell_update_progress_av), userInfo: nil, repeats: true)
    //                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
    //            }
                print("timer should have started for av_player")
            } catch {
                print (error)
            }
            
        }
        
    func play_av () {
        np_av_player.play()
    }
        
    func pause_av () {
        if self.np_av_player != nil {
            if np_av_player.isPlaying {
                print ("av beign paused now")
                np_av_player.pause()
            }
        }
    }
        
    func stop_av () {
        if self.np_av_player != nil {
            if np_av_player.isPlaying {
                print ("av beign paused now")
                np_av_player.stop()
                np_av_player.currentTime = 0.0
            }
        }
    }
    
    func update_song_details_UI () {
        if self.last_played_post.player == .youtubeplayer {
            self.bigPlayerView.albumArtContainerView.isHidden = true
            self.np_youtubeplayer.isHidden = false
            self.temp_view2?.isHidden = false
        } else {
            self.bigPlayerView.albumArtView.loadImageUsingCacheWithUrlString(imageurlstring: self.last_played_post.post.albumArtUrl)
            self.playingImage.loadImageUsingCacheWithUrlString(imageurlstring: self.last_played_post.post.albumArtUrl)
            self.bigPlayerView.albumArtContainerView.isHidden = false
            self.np_youtubeplayer.isHidden = true
            self.temp_view2?.isHidden = true
        }
        self.bigPlayerView.songName.text = self.last_played_post.post.songname
        self.bigPlayerView.artistName.text = self.last_played_post.post.artistName
        self.songnameLabel?.text = self.last_played_post.post.songname
        
    }
    
    
     @objc func current_cell_update_progress_spotify () {
          print("current_cell_update_progress_spotify \(self.np_spotifyplayer?.playbackState.position) timer_current_value \(self.timer_current_value) timer_new_value \(self.timer_new_value) ")
           
            if Int(floor((self.np_spotifyplayer?.playbackState.position)!)) != 0 {
               if (Int(self.last_played_post.post.audiolength) - Int(floor((self.np_spotifyplayer?.playbackState.position)!)) == 0) {
                   self.stop()
                
                //Play next song/video
                if self.bigPlayerView.loopOne {
                    self.replay()
                } else {
                    self.play_next()
                }
                return
               }
           }
           
           if self.timer_current_value == 0.0 {
                      self.timer_current_value = self.np_spotifyplayer?.playbackState.position
           }
                  
           self.timer_new_value = self.np_spotifyplayer?.playbackState.position
                  
           if floor(self.timer_current_value) == floor( self.timer_new_value) {
               //do nothing
           } else if floor(self.timer_current_value) < floor( self.timer_new_value) {
               self.bigPlayerView.timeCompleted.text = timeDisplayFormat(totalSeconds: Int(floor(self.timer_new_value)))
               self.bigPlayerView.timeLeft.text = timeDisplayFormat(totalSeconds: Int(self.last_played_post.post.audiolength) - Int(floor((self.np_spotifyplayer?.playbackState.position)!)))
               self.timer_current_value = self.np_spotifyplayer?.playbackState.position
                //var prog = (305/(self.last_played_post.post.original_track_length/1000))
                var prog = (1/(self.last_played_post.post.audiolength))
                self.bigPlayerView.progressSlider.value += Float(prog)
                self.playBar.progress += Float(prog)
           }
       }
       
       @objc func current_cell_update_progress_av () {
           //print("current_cell_update_progress_av self.timer_current_value \(self.timer_current_value) ")
           
           guard self.np_av_player != nil else {
               return
           }
          // print("current_cell_update_progress_av self.av_player.currentTime \(self.av_player.currentTime)")
           
           if (self.np_av_player.currentTime == 30.0) {
                 self.stop()
            
            //Play next song/video
            if self.bigPlayerView.loopOne {
                self.replay()
            } else {
                self.play_next()
            }
                 return
             }

           if self.timer_current_value == 0.0 {
               self.timer_current_value = self.np_av_player.currentTime
           }
           self.timer_new_value = self.np_av_player.currentTime
                  if floor(self.timer_current_value) == floor( self.timer_new_value) {
                      //do nothing
                  } else if floor(self.timer_current_value) < floor( self.timer_new_value) {
                      self.bigPlayerView.timeCompleted.text = timeDisplayFormat(totalSeconds: Int(floor(self.timer_new_value)))
                      self.bigPlayerView.timeLeft.text = timeDisplayFormat(totalSeconds: Int(self.last_played_post.post.audiolength) - Int(floor(self.np_av_player.currentTime)))
                      self.timer_current_value = self.np_av_player.currentTime
                      //var prog = (305/(self.last_played_post.post.original_track_length/1000))
                      var prog = (1/(self.last_played_post.post.audiolength))
                      self.bigPlayerView.progressSlider.value += Float(prog)
                      self.playBar.progress += Float(prog)
                  }
       }
       
       @objc func current_cell_update_progress_youtube () {
           print("current_cell_update_progress_youtube self.timer_current_value \(self.timer_current_value) ")
           
           
          // print("current_cell_update_progress_av self.av_player.currentTime \(self.av_player.currentTime)")
           
           self.np_youtubeplayer.getCurrentTime({currenttime, error in
               
               if (self.last_played_post.post.endtime <= currenttime) {
                       self.np_youtubeplayer.pauseVideo()
                
                //Play next song/video
                if self.bigPlayerView.loopOne {
                    self.replay()
                } else {
                    self.play_next()
                }
                   return
               }
               

               if self.timer_current_value == 0.0 {
                   self.timer_current_value = Double(currenttime)
               }
               self.timer_new_value = Double(currenttime)
               if floor(self.timer_current_value) == floor( self.timer_new_value) {
                   //do nothing
               } else if floor(self.timer_current_value) < floor( self.timer_new_value) {
                   self.bigPlayerView.timeCompleted.text = timeDisplayFormat(totalSeconds: Int(floor(self.timer_new_value)))
                   self.bigPlayerView.timeLeft.text = timeDisplayFormat(totalSeconds: Int(self.last_played_post.post.audiolength) - Int(floor(currenttime)))
                   self.timer_current_value = Double(currenttime)
                    //var prog = (305/(self.last_played_post.post.original_track_length))
                    var prog = (1/(self.last_played_post.post.audiolength))
                    self.bigPlayerView.progressSlider.value += Float(prog)
                    self.playBar.progress += Float(prog)
               }
           })
       
       }
       
    
       
       @objc func current_cell_update_progress_apple () {
           print("current_cell_update_progress_apple \(self.np_appleplayer.currentPlaybackTime) timer_current_value \(self.timer_current_value) timer_new_value \(self.timer_new_value) ")
           guard self.np_appleplayer.playbackState == .playing else {
               return
           }

           if (30 - Int(floor(self.np_appleplayer.currentPlaybackTime)) == 0) {
            self.np_appleplayer.pause()
            
            //Play next song/video
            if self.bigPlayerView.loopOne {
                self.replay()
            } else {
                self.play_next()
            }
               return
           }
           
           if self.timer_current_value == 0.0 {
               self.timer_current_value = self.np_appleplayer.currentPlaybackTime
           }
                  
           self.timer_new_value = self.np_appleplayer.currentPlaybackTime
                  
           if floor(self.timer_current_value) == floor( self.timer_new_value) {
               //print (" == ")
                     // do nothing
           } else if floor(self.timer_current_value) < floor( self.timer_new_value) {
               //print (" < " )
               self.bigPlayerView.timeCompleted.text = timeDisplayFormat(totalSeconds: Int(floor(self.timer_new_value)))
               self.bigPlayerView.timeLeft.text = timeDisplayFormat(totalSeconds: Int(self.last_played_post.post.audiolength) - Int(floor(self.np_appleplayer.currentPlaybackTime)))
               self.timer_current_value = self.np_appleplayer.currentPlaybackTime
                //var prog = (305/(self.last_played_post.post.original_track_length/1000))
                var prog = (1/(self.last_played_post.post.audiolength))
                self.bigPlayerView.progressSlider.value += Float(prog)
                self.playBar.progress += Float(prog)
           }
       }
    
}



extension NowPlayingView {
    
    
    
    @objc func see_post (recognizer: UITapGestureRecognizer)  {
        print("see_post")
        if showing_player {
            print("showing_player")
            
            /*
            self.bigPlayerView.albumArtTop.constant = 0
            self.bigPlayerView.albumArtLeading.constant = 70
            self.bigPlayerView.albumArtTrailing.constant = 70
            self.bigPlayerView.albumArtContainerView.layoutIfNeeded()
            self.bigPlayerView.albumArtContainerView.layoutSubviews()
            var width = (self.mainWindow?.frame.width)! - (2 * self.bigPlayerView.albumArtTrailing.constant)
            self.bigPlayerView.albumArtContainerView.layer.shadowPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: 0, y: 0) , size: CGSize(width: width, height: width)), cornerRadius: 10).cgPath
             */
            
            self.load_and_show_post_view()
            self.bigPlayerView.seePost.titleLabel?.text = "Player"
            self.showing_player = false
        } else {
            print("showing post")
            /*
            self.bigPlayerView.albumArtTop.constant = 0
            self.bigPlayerView.albumArtLeading.constant = 35
            self.bigPlayerView.albumArtTrailing.constant = 35
            self.bigPlayerView.albumArtContainerView.layoutIfNeeded()
            self.bigPlayerView.albumArtContainerView.layoutSubviews()
            var width = (self.mainWindow?.frame.width)! - (2 * self.bigPlayerView.albumArtTrailing.constant)
            self.bigPlayerView.albumArtContainerView.layer.shadowPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: 0, y: 0) , size: CGSize(width: width, height: width)), cornerRadius: 10).cgPath
             */
            self.hide_post_view()
            self.bigPlayerView.seePost.titleLabel?.text = "See Post"
            self.showing_player = true
        }
    }
    
    func setup_post_view () {
        
        self.bigPlayerView.scroll_view.isHidden = true
        self.bigPlayerView.scroll_view.isScrollEnabled = false
        self.bigPlayerView.scroll_view.isUserInteractionEnabled = false
        self.postView.commonInit(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 375, height: 604)))
        self.postView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 375, height: 604))
        self.bigPlayerView.scroll_view.addSubview(postView)
        postView_leadingConstraint = NSLayoutConstraint(item: self.postView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.bigPlayerView.scroll_view.contentLayoutGuide, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        postView_trailingConstraint = NSLayoutConstraint(item: self.postView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.bigPlayerView.scroll_view.contentLayoutGuide, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        postView_topConstraint = NSLayoutConstraint(item: self.postView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.bigPlayerView.scroll_view.contentLayoutGuide, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        postView_bottomConstraint = NSLayoutConstraint(item: self.postView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.bigPlayerView.scroll_view.contentLayoutGuide, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        postView_widthConstraint = NSLayoutConstraint(item: self.postView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.bigPlayerView.scroll_view.frameLayoutGuide, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
        self.bigPlayerView.scroll_view.addConstraints([postView_leadingConstraint!, postView_trailingConstraint!, postView_topConstraint!, postView_bottomConstraint!, postView_widthConstraint!])
        self.bigPlayerView.scroll_view.contentSize = self.postView.frame.size
        
        self.bigPlayerView.scroll_view.backgroundColor = UIColor.white
      
       
        self.postView.caption_og_text = self.postView.captionLabelView.text!
        let readmoreFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let readmoreFontColor = UIColor.black
        DispatchQueue.main.async {
            self.postView.captionLabelView.addTrailing(with: "...", moreText: "more", moreTextFont: readmoreFont, moreTextColor: readmoreFontColor)
            let tapGesture5 = UITapGestureRecognizer(target: self, action: #selector(self.labelTapFunction(recognizer:)))
            self.postView.captionLabelView.isUserInteractionEnabled = true
            self.postView.captionLabelView.addGestureRecognizer(tapGesture5)
        }
        
        
        print("scroll view content size is width \(self.bigPlayerView.scroll_view.contentSize.width), height \(self.bigPlayerView.scroll_view.contentSize.height)")
        print("scroll view content layout is width \(self.bigPlayerView.scroll_view.contentLayoutGuide.widthAnchor), height \(self.bigPlayerView.scroll_view.contentLayoutGuide.heightAnchor)")
        print("scroll view post view is width \(self.postView.frame.width), height \(self.postView.frame.height)")
        
    }
    
    
    @objc func labelTapFunction (recognizer: UITapGestureRecognizer) {
        print("Tapped on 'Read More'")
        
        if !self.postView.label_is_expanded {
            self.postView.captionLabelView.numberOfLines = 0
            self.postView.captionLabelView.text! = self.postView.caption_og_text
            self.postView.captionLabelView.sizeToFit()
            let label_height = self.postView.captionLabelView.frame.height
            self.postView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 375, height: 605 + (label_height - 60)))
            self.postView.layoutIfNeeded()
            self.postView.label_is_expanded = true
        } else {
             self.postView.captionLabelView.numberOfLines = 3
             self.postView.caption_label_height.constant = 60
             let readmoreFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
             let readmoreFontColor = UIColor.black
             DispatchQueue.main.async {
                 self.postView.captionLabelView.addTrailing(with: "...", moreText: "more", moreTextFont: readmoreFont, moreTextColor: readmoreFontColor)
                 let tapGesture5 = UITapGestureRecognizer(target: self, action: #selector(self.labelTapFunction(recognizer:)))
             }
             self.postView.label_is_expanded = false
        }
    }
    
    func load_and_show_post_view () {
        
        if self.last_played_post.player == .youtubeplayer {
            self.postView.wkwebviewContainer.isHidden = false
            self.postView.albumArtContainerView.isHidden = true
            self.postView.wkwebviewContainer.backgroundColor = UIColor.red
            if self.temp_view2!.isDescendant(of: self.mainWindow!) {
                self.temp_view2?.removeFromSuperview()
                self.postView.wkwebviewContainer.addSubview(temp_view2!)
                leadingConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.postView.wkwebviewContainer, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
                trailingConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.postView.wkwebviewContainer, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
                topConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.postView.wkwebviewContainer, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
                bottomConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.postView.wkwebviewContainer, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
                //heightConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
                //widthConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
                self.postView.wkwebviewContainer?.addConstraints([topConstraint!, bottomConstraint!, leadingConstraint!, trailingConstraint!])
            }
            
        } else {
            self.postView.wkwebviewContainer.isHidden = true
            self.postView.albumArtContainerView.isHidden = false
            self.postView.albumArtView.loadImageUsingCacheWithUrlString(imageurlstring: self.last_played_post.post.albumArtUrl)
        }
        
        self.bigPlayerView.scroll_view.isHidden = false
        self.bigPlayerView.scroll_view.isScrollEnabled = true
        self.bigPlayerView.scroll_view.isUserInteractionEnabled = true
        
        print("scroll view content size is width \(self.bigPlayerView.scroll_view.contentSize.width), height \(self.bigPlayerView.scroll_view.contentSize.height)")
            print("scroll view content layout is width \(self.bigPlayerView.scroll_view.contentLayoutGuide.widthAnchor), height \(self.bigPlayerView.scroll_view.contentLayoutGuide.heightAnchor)")
            print("scroll view post view is width \(self.postView.frame.width), height \(self.postView.frame.height)")
        
    }
    
    func hide_post_view () {
        
        if self.last_played_post.player == .youtubeplayer {
            self.reset_youtube_player()
        }
        
        self.bigPlayerView.scroll_view.isHidden = true
        self.bigPlayerView.scroll_view.isScrollEnabled = false
        self.bigPlayerView.scroll_view.isUserInteractionEnabled = false
        
    }
    
    
    func reset_youtube_player () {
        
        if (self.temp_view2?.isDescendant(of: self.postView.wkwebviewContainer))! {
            self.temp_view2?.removeFromSuperview()
        }
        
        mainWindow!.addSubview(self.temp_view2!)
        self.temp_view2!.translatesAutoresizingMaskIntoConstraints = false
        leadingConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        trailingConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        topConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 53)
        bottomConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainWindow, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -308)
        //heightConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
        //widthConstraint = NSLayoutConstraint(item: temp_view2, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
        mainWindow?.addConstraints([topConstraint!, bottomConstraint!, leadingConstraint!, trailingConstraint!])
    }
    
}
