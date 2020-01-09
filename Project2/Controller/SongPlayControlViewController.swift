//
//  SongPlayControlViewController.swift
//  Project2
//
//  Created by virdeshp on 8/22/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit
import MediaPlayer


/*
 
    Load song data into song detail views, figure out what player to use, and play the song

 
 */

let secret_key = "NewsFeed_SongPlay"

class SongPlayControlViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var songDuration: UILabel!
    @IBOutlet weak var play_bar: UIProgressView!
    var playbar_progress: Float!
    var timer : Timer!
    var song_name: String!
    var spotify_player: SPTAudioStreamingController?
    var apple_player = MPMusicPlayerController.applicationMusicPlayer
    var the_temp: Float?
    var the_new_temp: Float?
    var it_has_been_a_second: Int?
    var current_song_player: String?
    var user_defaults = UserDefaults.standard
    
    // MARK: - Properties
    var currentSong: Post? {
        didSet {
            configureFields()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        play_bar.progressTintColor = UIColor.darkGray
        play_bar.trackTintColor = UIColor.lightGray
        self.play_bar.progress = playbar_progress
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFields()
        //self.apple_player.beginGeneratingPlaybackNotifications()
        self.spotify_player = SPTAudioStreamingController.sharedInstance()
        the_temp = 0.0
        the_new_temp = 0.0
        current_song_player = self.user_defaults.string(forKey: "UserAccount")?.lowercased()
        if current_song_player == "apple"{
            print ("current_song_player == apple")
            if apple_player.playbackState == MPMusicPlaybackState.playing{
                print ("Timer was initiated")
                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                //self.play_bar.progress = playbar_progress
            }
        }  else if current_song_player == "spotify" {
            print ("current_song_player == spotify")
            if (spotify_player?.playbackState.isPlaying)! {
                print ("Timer was initiated")
                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_spotify), userInfo: nil, repeats: true)
                //self.play_bar.progress = playbar_progress
            }
        } else {
                //self.play_bar.progress = playbar_progress
            }

        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.timer != nil {
            self.timer.invalidate()
        }
    }

    
    @objc func updateProgress() {
        // increase progress value
        //print("updating")
        self.play_bar.progress += 0.000089/(self.currentSong?.audiolength)!
        //self.progressBar.setProgress(0.01, animated: true)
        //self.progressBar.animate(duration: 10)
        
        // invalidate timer if progress reach to 1
        if self.play_bar.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.play_bar.progress = 0.0
        }
     }
    
    @objc func updateProgress_apple() {
        self.it_has_been_a_second = self.it_has_been_a_second! + 1
        if (self.it_has_been_a_second! >= 10000){
            print("update_songplayer_apple")
            the_temp = Float((self.apple_player.currentPlaybackTime) - (self.currentSong?.startoffset)!)
            the_new_temp = Float(the_temp! / (self.currentSong?.audiolength)!)
            if ((the_new_temp!) > self.play_bar.progress) {
                self.play_bar.progress = the_new_temp!
                it_has_been_a_second = 0
                print (self.it_has_been_a_second)
            } else {
                //do regular increment
                //print("regular increment")
                self.play_bar.progress += (0.000089/(self.currentSong?.audiolength)!)
            }
        } else {
            //print("regular increment")
            self.play_bar.progress += (0.000089/(self.currentSong?.audiolength)!)
        }
        if self.play_bar.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.play_bar.progress = 0.0
            it_has_been_a_second = 0
            self.apple_player.stop()

        }
        
    }
    
    @objc func updateProgress_spotify() {
        self.it_has_been_a_second = self.it_has_been_a_second! + 1
        if (self.it_has_been_a_second! >= 10000){
            print("update_songplayer_spotify")
            the_temp = Float(((self.spotify_player?.playbackState.position)!) - (self.currentSong?.startoffset)!)
            the_new_temp = Float(the_temp! / (self.currentSong?.audiolength)!)
            if ((the_new_temp!) > self.play_bar.progress) {
                self.play_bar.progress = the_new_temp!
                it_has_been_a_second = 0
                print (self.it_has_been_a_second)
            } else {
                //do regular increment
                //print("regular increment")
                self.play_bar.progress += (0.000089/(self.currentSong?.audiolength)!)
            }
        } else {
            //print("regular increment")
            self.play_bar.progress += (0.000089/(self.currentSong?.audiolength)!)
        }
        if self.play_bar.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.play_bar.progress = 0.0
            it_has_been_a_second = 0

            self.spotify_player?.setIsPlaying(false, callback: { (error) in
                if (error == nil) {
                    print("paused number 1")
                        
                }
                else {
                    print ("error in pausing!")
                }
            })
            
        }
    }

    
}
// MARK: - Internal
extension SongPlayControlViewController {
    
    func configureFields() {
        guard songTitle != nil else {
            return
        }
        
        songTitle.text = song_name
        //songArtist.text = currentSong?.
        //songDuration.text = "Duration \(currentSong?.presentationTime ?? "")"
    }
}

