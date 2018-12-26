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
import MediaPlayer

class PostCell: UITableViewCell, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {


    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var albumArtImage: UIImageView!
    @IBOutlet weak var lyricView: UITextView!
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var nativeAppImage: UIImageView!
    @IBOutlet weak var postTypeImage: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var numberofLikesButton: UIButton!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    var offsetvalue: TimeInterval!
    var startoffset: TimeInterval!
    var pausedflag: Bool!
    var playingflag: Bool!
    var trackidstring: String!
    var Spotifyplayer: SPTAudioStreamingController?
    let musicPlayerController = MPMusicPlayerController.applicationMusicPlayer
    var videoID: String!
    var videostart: Float!
    var videoend: Float!
    var typeFlag: String!
    var timer : Timer!
    var duration: Float!
    var trackname: String!
    var source: String!
    var helper_id: String!
    var preview_url: String!
    //When we give data to this post we want to load the data
    let getView = BottomView()
    
    
    var post: Post!{
        didSet {
            self.updateUI()
            //self.Spotifyplayer = SPTAudioStreamingController.sharedInstance()
            if self.typeFlag != "video" {
            self.playerView.isHidden = true
            
                if self.typeFlag == "audio" {
                    self.albumArtImage.bringSubview(toFront: albumArtImage)
                    self.albumArtImage.isHidden = false
                    self.lyricView.isHidden = true
                    /*
                    if self.source == "apple" {
                        self.musicPlayerController.setQueue(with: [self.trackidstring])
                    }
                    */
                }else {
                    //self.albumArtButton.bringSubview(toFront: albumArtButton)
                    //self.albumArtButton.backgroundColor = UIColor.clear
                    self.lyricView.bringSubview(toFront: lyricView)
                    self.lyricView.isHidden = false
                    self.albumArtImage.isHidden = true
                }
            }else{
            self.playerView.isHidden = false
            self.playerView.bringSubview(toFront: playerView)
                self.playerView.load(withVideoId: self.videoID , playerVars: ["playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 1, "start": self.videostart, "end": self.videoend, "rel": 0])
                
            }
        }
    }
    func updateUI(){
        
        self.albumArtImage.image  = UIImage(named: post.albumArtImage!)
        //self.albumArt.image = post.albumArtImage
        self.nativeAppImage.image = UIImage(named: post.sourceAppImage!)
        self.postTypeImage.image =  UIImage(named: post.typeImage!)
        self.postTypeImage.layer.cornerRadius = self.postTypeImage.frame.size.width / 2
        self.profileImageView.image = UIImage(named: post.profileImage!)
        self.usernameLabel.text = post.username
        self.captionLabel.text = post.caption
        self.timeAgoLabel.text = post.timeAgo
        self.pausedflag = post.paused
        self.playingflag = post.playing
        self.typeFlag = post.flag
        self.offsetvalue = post.offset
        self.startoffset = post.startoffset
        self.trackidstring = post.trackid as String
        self.videoID = post.videoid
        self.videostart = post.starttime
        self.videoend = post.endtime
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
        self.preview_url = post.preview_url
        if self.typeFlag != "video"{
            self.videoID = "empty"
        }else{
            self.trackidstring = "empty"
        }
        
    }
    

    @IBAction func getButton(_ sender: Any) {
        print(self.trackidstring!)
        print("clicked")
        getView.bringupview(id: self.trackidstring! as String)
    }
    
 //
   // @IBAction func clickOnImage(_ sender: Any) {
     //   if self.playingflag == false {
       //     playButton(self)
        //}else{
          //  pauseButton(self)
        //}
        //
    //}
    /*
    @objc func updateProgress() {
        // increase progress value
        self.progressBar.progress += 0.00005/(self.duration)
        //self.progressBar.setProgress(0.01, animated: true)
        //self.progressBar.animate(duration: 10)

        // invalidate timer if progress reach to 1
                if self.progressBar.progress >= 1 {
            // invalidate timer
                    print ("invalidate timer happened")
            self.timer?.invalidate()
            pauseButton(self)
            self.progressBar.progress = 0.0
           }
        }
  */
 
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
                    print (self.musicPlayerController.currentPlaybackTime)
                    self.musicPlayerController.play()
                    self.musicPlayerController.currentPlaybackTime = self.offsetvalue
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
                    self.musicPlayerController.setQueue(with: [self.trackidstring])
                    self.musicPlayerController.play()
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
                print (self.musicPlayerController.currentPlaybackTime)
                self.offsetvalue = self.musicPlayerController.currentPlaybackTime
                self.musicPlayerController.pause()
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
}


func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangemetadata: SPTPlaybackMetadata!) {
    print ("Name should be printed")
}








