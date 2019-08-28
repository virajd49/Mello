//
//  PostViewController.swift
//  Project2
//
//  Created by virdeshp on 6/9/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import MediaPlayer
import QuartzCore
import PromiseKit


//The global youtube player is used for the benefit of OOM. The global youtube player is instantiated and loaded when the Profile page loads, and when the OOM page is displayed we hand this off to the OOM VC's youtube player.
// global_yt_player_init - this is called when ProfilePageViewController appears
// youtube_player_setup_from_global_player - this is called when we prepare for segue from Profile page to OOM - this hands off the player.
//the player is then played from 4 different places -
//                                                    - view will appear - everytime view appears - required
//                                                    - youtube_player_setup_from_global_player - this is only triggered when we segue
//                                                    - player did become ready - this is only triggered if player is loaded/reloaded


class PostViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, YTPlayerViewDelegate{
    

    @IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var album_art: UIImageView!
    @IBOutlet weak var visual_aid_container: UIView!
    @IBOutlet weak var add_button: UIButton!
    var spotifyplayer: SPTAudioStreamingController?
    var appleplayer = MPMusicPlayerController.applicationMusicPlayer
    var av_player : AVAudioPlayer!
    var OOM_post: Post!
    var userDefaults = UserDefaults.standard
    var timer : Timer!
    var the_temp: Float?
    var the_new_temp: Float?
    var it_has_been_a_second: Int?
    var grab_oom = grab_and_store_oom.shared
    var youtubeplayer: YTPlayerView!
    @IBOutlet weak var lyric_view: UITextView!
    @IBOutlet weak var prog_bar: UIProgressView!
    
    
    override func viewDidLoad() {
        self.profile_image.layer.cornerRadius = 50
        self.profile_image.clipsToBounds = true
        self.appleplayer.beginGeneratingPlaybackNotifications()
        self.spotifyplayer = SPTAudioStreamingController.sharedInstance()

        the_temp = 0.0
        the_new_temp = 0.0
        it_has_been_a_second = 0
        
        //this adds the title but not the image
        var back_button = UIButton(type: .custom)
        back_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        back_button.translatesAutoresizingMaskIntoConstraints = false
        back_button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 5)
        back_button.setImage(UIImage(named: "icons8-back-30"), for: .normal)
        back_button.tintColor = UIColor.black
        back_button.setTitle("", for: .normal)
        back_button.setTitleColor(back_button.tintColor, for: .normal)
        back_button.addTarget(self, action: "backAction", for: .touchUpInside)
        back_button.layer.borderColor = UIColor.black.cgColor
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back_button)
        
        
        self.navigationController?.navigationBar.layer.borderColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        if self.grab_oom.stored_oom.flag == "audio" {
            self.youtubeplayer.isHidden = true
            self.lyric_view.isHidden = true
            self.visual_aid_container.bringSubviewToFront(self.album_art)
        } else if self.grab_oom.stored_oom.flag == "video" {
            self.album_art.isHidden = true
            self.lyric_view.isHidden = true
            self.view.bringSubviewToFront(self.youtubeplayer)
        } else if self.grab_oom.stored_oom.flag == "lyric" {
            self.youtubeplayer.isHidden = true
            self.album_art.isHidden = true
            self.visual_aid_container.bringSubviewToFront(self.lyric_view)
        }
        
        self.prog_bar.progress = 0

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.layer.zPosition = -1
        self.setup_media().done {
            self.play_media()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.layer.zPosition = 0
    }
    
    @IBAction func go_to_profile_page_button(_ sender: Any) {
        
        if let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "profileviewcontroller") {
            self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: " BACK", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
 
 
    @IBAction func add_button_action(_ sender: Any) {
  
        if let uploadVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadViewController2") {
          
            self.navigationController?.navigationBar.layer.borderColor = UIColor.black.cgColor
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.pushViewController(uploadVC, animated: true)
        }
        
        //Stop media
        self.appleplayer.stop()
        
        if self.youtubeplayer.playerState() == YTPlayerState.playing {
            self.youtubeplayer.stopVideo()
        }
        self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
            if (error == nil) {
                print("paused number 1")
                
            }
            else {
                print ("error in pausing!")
            }
        })
        
        //Reset timer
        if self.timer.isValid {
            self.timer.invalidate()
        }
        self.prog_bar?.progress = 0
       
    }
    
    func setup_media() ->Promise<Void> {
        return Promise { seal in
        print("setup media")
            oom_post.fetch_oom_post().done { fetched_post in
            self.album_art.loadImageUsingCacheWithUrlString(imageurlstring: fetched_post.albumArtUrl)
            self.OOM_post = fetched_post
            seal.fulfill(())
            }
        }
    }
    

    func youtube_player_setup_from_global_player() {
        print("youtube_player_setup_from_global_player")
        self.youtubeplayer = global_yt_player
        self.youtubeplayer.delegate = self
        self.view.addSubview(self.youtubeplayer)
        //self.youtubeplayer.playVideo()
        //print("playing from youtube_player_setup_from_global_player")
    }
    
    
    @objc func backAction () {
        self.dismiss(animated: true, completion: nil)
        self.appleplayer.stop()
        if self.youtubeplayer.playerState() == YTPlayerState.playing {
            self.youtubeplayer.stopVideo()
        }
        self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
            if (error == nil) {
                print("paused number 1")
                
            }
            else {
                print ("error in pausing!")
            }
        })
        if self.timer.isValid {
            self.timer.invalidate()
        }
        
        self.prog_bar?.progress = 0
        
    }
    
    
    func play_media() {
        print("play_media")
            if OOM_post.sourceapp == "spotify" {
                print ("source is spotify 2")
                print(OOM_post.trackid)
                print(OOM_post.startoffset)
                if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                    self.spotifyplayer = SPTAudioStreamingController.sharedInstance()
                    self.spotifyplayer?.playSpotifyURI(OOM_post.trackid, startingWith: 0, startingWithPosition: OOM_post.startoffset, callback: { (error) in
                        if (error == nil) {
                            print("Spotify is playing! 2")
                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_spotify), userInfo: nil, repeats: true)
                            RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                            //print(self.Spotifyplayer?.metadata.currentTrack?.name)
                            //print(self.Spotifyplayer?.metadata.currentTrack?.albumName)
                            //print(self.Spotifyplayer?.metadata.nextTrack?.name)
                        } else {
                            print ("error this one!")
                        }
                    })
                } else if userDefaults.string(forKey: "UserAccount") == "Apple" {
                    if OOM_post.helper_id != "default" {
                        self.appleplayer.setQueue(with: [OOM_post.helper_id])
                        //self.appleplayer.stop()
                        print ("current playback time after the stop \(self.appleplayer.currentPlaybackTime)")
                        print("should be calling setcurrentplaybacktime")
                        //                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.setcurrentplaybacktime), userInfo: nil, repeats: true)
                        //                            RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                        self.appleplayer.play()
                        //self.appleplayer.currentPlaybackTime = cell.startoffset //-> this does not work -> don't have a perfect workaround yet -> all the surrounding comments are the remnants of attempted workarounds - still se Domain=MPCPlayerRequestErrorDomain Code=1 "No commands provided." intermittently - need to open bug with Apple
                        self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                        RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                        //self.super_temp_flag = true
                        //self.set_current_playback_time()
                        //self.set_curr_playback()
                        print("Apple is playing")
                    } else if OOM_post.preview_url != "nil" {
                        self.download_preview(url: URL(string: OOM_post.preview_url)!)
                    } else {
                        print ("Last resort gracious faliure - song cannot be played")
                    }
                } else {
                    print ("Error no UserAccount specified")
                }
            } else if OOM_post.sourceapp == "apple" {
                print ("source is apple")
                print (OOM_post.trackid)
                print (OOM_post.startoffset)
                if userDefaults.string(forKey: "UserAccount") == "Apple" {
                    self.appleplayer.setQueue(with: [OOM_post.trackid])
                    //self.appleplayer.stop()
                    print ("current playback time after the stop \(self.appleplayer.currentPlaybackTime)")
                    print("should be calling setcurrentplaybacktime")
                    //                        self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.setcurrentplaybacktime), userInfo: nil, repeats: true)
                    //                        RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
                    self.appleplayer.play()
                    //self.appleplayer.currentPlaybackTime = cell.startoffset //-> this does not work -> don't have a perfect workaround yet -> all the surrounding comments are the remnants of attempted workarounds - still se Domain=MPCPlayerRequestErrorDomain Code=1 "No commands provided." intermittently - need to open bug with Apple
                    self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_apple), userInfo: nil, repeats: true)
                    RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                    //self.set_current_playback_time()
                    //self.set_curr_playback()
                    print("Apple is playing")
                } else if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                    if OOM_post.helper_id != "default" {
                        print (OOM_post.helper_id)
                        self.spotifyplayer = SPTAudioStreamingController.sharedInstance()
                        self.spotifyplayer?.playSpotifyURI(OOM_post.helper_id, startingWith: 0, startingWithPosition: OOM_post.startoffset, callback: { (error) in
                            if (error == nil) {
                                print("Spotify is playing! 2")
                                self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_spotify), userInfo: nil, repeats: true)
                                RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
                                //print(self.Spotifyplayer?.metadata.currentTrack?.name)
                                //print(self.Spotifyplayer?.metadata.currentTrack?.albumName)
                                //print(self.Spotifyplayer?.metadata.nextTrack?.name)
                            } else {
                                print ("error this one!")
                            }
                        })
                    } else if OOM_post.preview_url != nil {
                        self.download_preview(url: URL(string: OOM_post.preview_url)!)
                    } else {
                        print ("Last resort gracious faliure - song cannot be played")
                    }
                } else {
                    print ("Error no UserAccount specified")
                }
                
            } else if OOM_post.sourceapp == "youtube" {
                
                print("playing now")
                self.youtubeplayer.playVideo()
                }
            else {
                print ("something went very wrong")
            }
    }

    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        print("playerViewDidBecomeReady")
        self.youtubeplayer.playVideo()
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
                RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
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
    
    
    
    @objc func updateProgress_apple() {
        self.it_has_been_a_second = self.it_has_been_a_second! + 1
        if (self.it_has_been_a_second! >= 10000) {
            print("update_apple \(Float(self.appleplayer.currentPlaybackTime))")
            
            //print("duration is \(self.duration)")
            //print ("current post startoffset \(currentPost.startoffset)")
            //print(Float((self.appleplayer.currentPlaybackTime)))
            the_temp = Float(self.appleplayer.currentPlaybackTime) - 0.0 //<- Apple does not allow starting from a different point. No workaround so far. -> this does not work -> don't have a perfect workaround yet -> all the surrounding comments are the remnants of attempted workarounds - still see Domain=MPCPlayerRequestErrorDomain Code=1 "No commands provided." intermittently - need to open bug with Apple
            the_new_temp = Float(the_temp!)/Float(OOM_post.audiolength)
            if ((the_new_temp!) > self.prog_bar!.progress) {
                self.prog_bar!.progress = the_new_temp!
                it_has_been_a_second = 0
                print (self.it_has_been_a_second)
            } else {
                //do regular increment
                //print("regular increment")
                self.prog_bar!.progress += (0.000189/OOM_post.audiolength)
            }
        } else {
            //print("regular increment")
            self.prog_bar!.progress += (0.000189/OOM_post.audiolength)
            
        }
        if self.prog_bar!.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.prog_bar!.progress = 0.0
            it_has_been_a_second = 0
            self.appleplayer.stop()
            
            
        }
    }
    
    @objc func updateProgress_spotify() {
        self.it_has_been_a_second = self.it_has_been_a_second! + 1
        if (self.it_has_been_a_second! >= 10000){
            print("update_spotify")
            the_temp = Float(((self.spotifyplayer?.playbackState.position)!) - OOM_post.startoffset)
            the_new_temp = Float(the_temp!) / Float(OOM_post.audiolength)
            if ((the_new_temp!) > self.prog_bar!.progress) {
                self.prog_bar!.progress = the_new_temp!
                it_has_been_a_second = 0
                print (self.it_has_been_a_second)
            } else {
                //do regular increment
                //print("regular increment")
                self.prog_bar!.progress += (0.000089/OOM_post.audiolength)
                
                
            }
        } else {
            //print("regular increment")
            self.prog_bar!.progress += (0.000089/OOM_post.audiolength)
        }
        if self.prog_bar!.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.prog_bar!.progress = 0.0
            it_has_been_a_second = 0
            self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
                if (error == nil) {
                    print("paused number 1")
                    
                }
                else {
                    print ("error in pausing!")
                }
            })
        }
    }
    
    @objc func updateProgress_yt() {
        self.it_has_been_a_second = self.it_has_been_a_second! + 1
        if (self.it_has_been_a_second! >= 10000){
            //print("update_yt")
            the_temp = Float(((youtubeplayer?.currentTime())!) - OOM_post.starttime)
            the_new_temp = Float(the_temp!) / Float(OOM_post.audiolength)
            if ((the_new_temp!) > self.prog_bar!.progress) {
                self.prog_bar!.progress = the_new_temp!
                it_has_been_a_second = 0
                print (self.it_has_been_a_second)
            } else {
                //do regular increment
                //print("regular increment")
                self.prog_bar!.progress += (0.000089/OOM_post.audiolength)
            }
        } else {
            //print("regular increment")
            self.prog_bar!.progress += (0.000089/OOM_post.audiolength)
        }
        if self.prog_bar!.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.prog_bar?.progress = 0.0
            it_has_been_a_second = 0
        }
    }
    
    
    @objc func updateProgress_av() {
        self.it_has_been_a_second = self.it_has_been_a_second! + 1
        if (self.it_has_been_a_second! >= 10000){
            print("update_av")
            the_temp = Float(((self.av_player?.deviceCurrentTime)!) - 0.0)
            the_new_temp = Float(the_temp!) / 30.0
            if ((the_new_temp!) > self.prog_bar!.progress) {
                self.prog_bar!.progress = the_new_temp!
                it_has_been_a_second = 0
                print (self.it_has_been_a_second)
            } else {
                //do regular increment
                //print("regular increment")
                self.prog_bar!.progress += (0.000089/OOM_post.audiolength)
            }
        } else {
            //print("regular increment")
            self.prog_bar!.progress += (0.000089/OOM_post.audiolength)
        }
        if self.prog_bar!.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.prog_bar!.progress = 0.0
            it_has_been_a_second = 0
            self.av_player.stop()

        }
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
            print ("buffering")
      
            break;
        case YTPlayerState.ended:
            print("Ended - Yes we come here")
       
            self.timer?.invalidate()
            self.prog_bar!.progress = 0
            
            break;
        case YTPlayerState.playing:
            print ("PostVC we know state changed")
            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress_yt), userInfo: nil, repeats: true)
            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
            print("-----------------------------------------Timer started------------------------------------------")
            break;
        case YTPlayerState.paused:
            print("Nah we come here") //when the miniplayer cuts off the post player, it goes to paused state not ended state.
            print("state changed to paused")
           
            self.timer?.invalidate()        //if the miniplayer has just started and we come here, let the timer run, we handle it in .isPlaying for miniplayer, handing it over from the post player to the miniplayer. Skip the rest of the settings as well
          
            break;
        default:
            print("none of these")
            break;
        }
    }
    
    
}
