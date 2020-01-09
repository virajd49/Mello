//
//  PostCell.swift
//  Project2
//
//  Created by virdeshp on 3/12/18.
//  Copyright © 2018 Viraj. All rights reserved.
//


//Custom cell class for the post cell: Subclass of UITableViewCell
import UIKit
import QuartzCore
import FLAnimatedImage
import SDWebImage
import YoutubeKit
import YoutubePlayer_in_WKWebView


protocol PostCellDelegate {
    func mute_feed ()
    
    func unmute_feed ()
    
    func is_muted () -> Bool
    
    func replay_post ()
    
    func play_full_song ()
    
    func temp_expand_func ()
    
    func dismiss_func () 
}

class PostCell: UITableViewCell, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, WKYTPlayerViewDelegate {


    @IBOutlet weak var full_song_mini_button: UIButton!
    @IBOutlet weak var youtube_container_view: UIView!
    @IBOutlet weak var timer_label: UILabel!
    @IBOutlet weak var dimmer_layer: UIView!
    @IBOutlet weak var dimmer_animation_protector: UIView!
    @IBOutlet weak var gif_image_view: FLAnimatedImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var albumArtImage: UIImageView!
    @IBOutlet weak var lyricView: UITextView!
    @IBOutlet weak var playerView: WKYTPlayerView!
    @IBOutlet weak var youtube_thumbnail_image: UIImageView!
    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var nativeAppImage: UIImageView!
    @IBOutlet weak var postTypeImage: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var numberofLikesButton: UIButton!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var replay_button: UIButton!
    @IBOutlet weak var full_song_button: UIButton!
    var offsetvalue: TimeInterval!
    var startoffset: TimeInterval!
    var pausedflag: Bool!
    var playingflag: Bool!
    var trackidstring: String!
    var Spotifyplayer: SPTAudioStreamingController?
    //let musicPlayerController = MPMusicPlayerController.applicationMusicPlayer
    var videoID: String!
    var videostart: Int!
    var videoend: Int!
    var typeFlag: String!
    var timer : Timer!
    var duration: Float!
    var trackname: String!
    var source: String!
    var helper_id: String!
    var helper_preview_url: String!
    var preview_url: String!
    var albumArtUrl: String!
    var isActivated: Bool!
    //When we give data to this post we want to load the data
    @IBOutlet weak var mute_button: UIButton!
    let getView = BottomView()
    
    var delegate: PostCellDelegate!
    var playback_post: PlaybackPost!
    var post: Post!{
        didSet {
            self.updateUI()
            if self.typeFlag != "video" {
            self.playerView.isHidden = true
                if self.typeFlag == "audio" {
                    self.albumArtImage.bringSubviewToFront(albumArtImage)
                    self.albumArtImage.isHidden = false
                    self.lyricView.isHidden = true
                    self.youtube_container_view.isHidden = true
                }else {
                    self.lyricView.bringSubviewToFront(lyricView)
                    self.lyricView.isHidden = false
                    self.albumArtImage.isHidden = true
                    self.youtube_container_view.isHidden = true
                }
            }else{
                self.albumArtImage.isHidden = true
                self.playerView.isHidden = true
                self.lyricView.isHidden = true
                self.youtube_container_view.isHidden = false
                //self.playerView.delegate = self
                //self.playerView.bringSubview(toFront: playerView)
                //self.playerView.load(withVideoId: self.videoID , playerVars: ["playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 1, "start": self.videostart, "end": self.videoend, "rel": 0])
                //WE CHANGED THIS - MOVED THE LOADING TO WHEN THE USER TAPS ON THE VIDEO CELL - TO PREVENT SCROLLING LAG CAUSED BY ALL THE YOUTUBE CELLS TRYING TO LOAD THE VIDEOS WHEN THEY ARE DEQUEUED - TRADEOFF - LOOKS SHITTY AND TAKES FOREVER TO LOAD BEFORE IT PLAYS - NEED TO FIND A WAY TO SHIFT THIS LOADING TO A BACKGROUND THREAD - RAN INTO A WEIRD ERROR WHEN I TRIED BEFORE
            }
        }
    }
    
    func updateUI(){
        
        self.replay_button.isHidden = true
        self.full_song_button.isHidden = true
        self.replay_button.isUserInteractionEnabled = false
        self.full_song_button.isUserInteractionEnabled = false
        self.typeFlag = post.flag
       self.albumArtUrl = post.albumArtUrl
       if self.typeFlag != "video" { self.albumArtImage.loadImageUsingCacheWithUrlString(imageurlstring: self.albumArtUrl)
       } else {
      self.youtube_thumbnail_image.loadImageUsingCacheWithUrlString(imageurlstring: self.albumArtUrl)
        }
        //self.albumArt.image = post.albumArtImage
        self.nativeAppImage.image = UIImage(named: post.sourceAppImage!)
        self.postTypeImage.image = UIImage(named: post.typeImage!)
        self.postTypeImage.layer.cornerRadius = self.postTypeImage.frame.size.width / 2
        self.postTypeImage.isHidden = true
        self.profileImageView.image = UIImage(named: post.profileImage!)
        self.usernameLabel.text = post.username
        self.captionLabel.text = post.caption
        self.timeAgoLabel.text = post.timeAgo
        self.pausedflag = post.paused
        self.playingflag = post.playing
        self.offsetvalue = post.offset
        self.startoffset = post.startoffset
        self.trackidstring = post.trackid as String
        self.videoID = post.videoid
        self.videostart = Int(post.starttime)
        self.videoend = Int(post.endtime)
        self.lyricView.text = post.lyrictext
        self.timer = Timer()
        self.timer?.invalidate()
        self.progressBar.progress = 0.0
        self.progressBar.progressTintColor = UIColor.darkGray
        self.progressBar.trackTintColor = UIColor.lightGray
        self.duration = post.audiolength
        self.trackname = post.songname
        self.source = post.sourceapp
        self.helper_id = post.helper_id
        self.helper_preview_url = post.helper_preview_url
        self.preview_url = post.preview_url
        if self.typeFlag != "video"{
            self.videoID = "empty"
        } else {
            self.trackidstring = "empty"
        }
        if post.GIF_url != "" {
            self.gif_image_view.isHidden = false
            self.gif_image_view.sd_setShowActivityIndicatorView(true)
            self.gif_image_view.sd_setIndicatorStyle(.gray)
            self.gif_image_view.sd_setImage(with: URL (string: post.GIF_url))
        }
        self.gif_image_view.isHidden = false
        set_mute_button_image()
        self.isActivated = false
    }
    
    //if the user clicks on the get button bring up the BottomView
    @IBAction func getButton(_ sender: Any) {
        print(self.trackidstring!)
        print("clicked")
        getView.bringupview(id: self.trackidstring! as String)
    }
 
    
    //These controls have been moved to the newsfeed controller instead of being embedded in each individual cell
 func playButton(_ sender: Any) {
    if self.playingflag == false {
            if self.pausedflag == true {
                self.playingflag = true
                self.pausedflag = false
                print (self.source)
                if self.source == "spotify" {
                    print ("source is spotify")
                    self.Spotifyplayer?.playSpotifyURI(self.trackidstring, startingWith: 0, startingWithPosition: self.offsetvalue, callback: { (error) in
                        if (error == nil) {
                            print("playing!")
                            print(self.Spotifyplayer?.metadata.currentTrack?.name)
                            //self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
                            //self.updateProgress()
                        }
                        else {
                            print ("error this one!")
                        }
                    })
                }else if self.source == "apple" {
                    print ("source is apple")
                    print (self.trackidstring)
                    //self.musicPlayerController.setQueue(with: [self.trackidstring])
                    //print (self.musicPlayerController.currentPlaybackTime)
                    //self.musicPlayerController.play()
                    //self.musicPlayerController.currentPlaybackTime = self.offsetvalue
                }else {
                    print ("something went wrong")
                }
            }else{
                self.playingflag = true
                 if self.source == "spotify" {
                    print ("source is spotify")
                        self.Spotifyplayer?.playSpotifyURI(self.trackidstring, startingWith: 0, startingWithPosition: self.startoffset, callback: { (error) in
                            if (error == nil) {
                                print("playing!")
                                print(self.Spotifyplayer?.metadata.currentTrack?.name)
                                //print(self.Spotifyplayer?.metadata.currentTrack?.albumName)
                                //print(self.Spotifyplayer?.metadata.nextTrack?.name)
                                //self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
                                //self.updateProgress()
                            }
                            else {
                                print ("error this one!")
                            }
                        })
                 }else if self.source == "apple"{
                    print ("source is apple")
                    print (self.trackidstring)
                    //self.musicPlayerController.setQueue(with: [self.trackidstring])
                    //self.musicPlayerController.play()
                    //self.musicPlayerController.currentPlaybackTime = self.startoffset
                 }else {
                    print ("something went very wrong")
                }
        }
        
    }

    else{
            print ("song is playing")
            
        }
    }
 func pauseButton(_ sender: Any) {
        if self.playingflag == true {
            print (self.source)
            if self.source == "spotify" {
                print ("source is spotify")
                self.Spotifyplayer?.setIsPlaying(false, callback: { (error) in
                if (error == nil) {
                    print("paused")
                    //self.timer?.invalidate()
                    self.offsetvalue = (self.Spotifyplayer!.playbackState.position)
                }
                else {
                    print ("error in pausing!")
                }
                })
            }else if self.source == "apple" {
                print ("source is apple")
                //print (self.musicPlayerController.currentPlaybackTime)
                //self.offsetvalue = self.musicPlayerController.currentPlaybackTime
                //self.musicPlayerController.pause()
                //self.offsetvalue = self.musicPlayerController.currentPlaybackTime
            }else {
                print ("something went wrong")
            }
                
            self.pausedflag = true
            self.playingflag = false
            //self.offsetvalue = (self.Spotifyplayer!.playbackState.position)
            
        }else {
            print ("nothing is playing")
        }
    }
    
 func restartButton(_ sender: Any) {
    self.Spotifyplayer?.playSpotifyURI(self.trackidstring, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error == nil) {
                print("playing!")
                
            }
            else {
                print ("error this one!")
            }
        })
        self.playingflag = true
        print ("restarted")
        
    }
    
    @IBAction func mute_button_action(_ sender: Any) {
        
        if self.delegate.is_muted() {
            self.delegate.unmute_feed()
            self.delegate.dismiss_func()
            if #available(iOS 13.0, *) {
                self.mute_button.setBackgroundImage(UIImage(systemName: "speaker.2.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
                self.mute_button.setBackgroundImage(UIImage(named: "icons8-high_volume"), for: .normal)
            }
        } else {
            self.delegate.mute_feed()
            if #available(iOS 13.0, *) {
                self.mute_button.setBackgroundImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
                self.mute_button.setBackgroundImage(UIImage(named: "icons8-mute"), for: .normal)
            }
        }
    }
    
    @IBAction func full_song_mini_button_action(_ sender: Any) {
        self.delegate.temp_expand_func()
        self.delegate.mute_feed()
    }
    
    @IBAction func full_song_button_action(_ sender: Any) {
        self.delegate.temp_expand_func()
        self.delegate.mute_feed()
    }
    
    func set_mute_button_image () {
        if self.delegate.is_muted() {
            if #available(iOS 13.0, *) {
                self.mute_button.setBackgroundImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
                self.mute_button.setBackgroundImage(UIImage(named: "icons8-mute"), for: .normal)
            }
        } else {
            if #available(iOS 13.0, *) {
                self.mute_button.setBackgroundImage(UIImage(systemName: "speaker.2.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
                self.mute_button.setBackgroundImage(UIImage(named: "icons8-high_volume"), for: .normal)
            }
        }
    }
    
    @IBAction func replay_post(_ sender: Any) {
        self.delegate.replay_post()
    }
    
    
    
    
/*
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
      print("state changed youtube")
        switch(state) {
        case WKYTPlayerState.unstarted:
            print("unstarted youtube")
            
            break;
        case WKYTPlayerState.queued:
            print("queued youtube")

            break;
        case WKYTPlayerState.buffering:
            print("buffering youtube")

            break;
        case WKYTPlayerState.ended:
            print("ended youtube")
            break;
        case WKYTPlayerState.playing:
            print("playing youtube")
            break;
        case WKYTPlayerState.paused:
            print("paused youtube")
        default:
            break;


        }
    }
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        self.playerView.playVideo()
    }
    
  
    
    func playerView(_ playerView: WKYTPlayerView, receivedError error: WKYTPlayerError) {
        //
    }
 
 */
    
    
    
}


func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangemetadata: SPTPlaybackMetadata!) {
    print ("Name should be printed")
}








