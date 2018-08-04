//
//  NewsFeedTableViewController.swift
//  Project2
//
//  Created by virdeshp on 3/12/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit
import MediaPlayer

class NewsFeedTableViewController: UITableViewController, YTPlayerViewDelegate, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    let userDefaults = UserDefaults.standard
    var posts: [Post]?
    var index_for_progress_bar : IndexPath? //for checking runaway porgress bars for other cells
    var currently_playing_Spotify_cell: IndexPath? //last tapped/currently playing cell, so that we can stop it if a youtube video starts playing
    var currently_playing_youtube_cell: IndexPath? //last tapped/currently playing youtube cell, so that we can stop it if a youtube video starts playing
    var currently_playing_song_id: String?
    var paused_cell: IndexPath?
    var last_viewed_youtube_cell: IndexPath?
    var songnameLabel: UILabel?
    var playingImage: UIImageView?
    var spotifyplayer  = SPTAudioStreamingController.sharedInstance()
    var appleplayer = MPMusicPlayerController.applicationMusicPlayer
    var youtubeplayer: YTPlayerView?
    var no_other_video_is_active = true     //flag makes sure that the table view controller acts as the delegate of only one youtube player
    var playingView: UIView?
    var timer : Timer!
    var duration: Float!
    var temp_duration: Float!
    var playBar : UIProgressView!
    var executed_once: Bool!
    let playlist_access = UserAccess(musicPlayerController: MPMusicPlayerController.applicationMusicPlayer, myPlaylistQuery: MPMediaQuery.playlists(), myLibrarySongsQuery: MPMediaQuery.songs())
    struct Storyboard {
        
        static let postCell = "PostCell"
        static let postCellDefaultHeight : CGFloat = 550.0
        
    }
   let getView = BottomView()
    

    @objc func showBottomView(sender: UIButton){
        
        print(self.currently_playing_song_id!)
        getView.bringupview(id: self.currently_playing_song_id! as String)
        
    }

    //global cell settings checker for @objc @objc the cell reuse problem
    
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
  

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appleplayer.beginGeneratingPlaybackNotifications()
        
        NotificationCenter.default.addObserver(self,
                                       selector: #selector(handleMusicPlayerControllerPlaybackStateDidChange),
                                       name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                       object: self.appleplayer)
        
         NotificationCenter.default.addObserver(self, selector: #selector(stopAudioplayerforYoutube(notification:)), name: Notification.Name(rawValue: "Stop Audio Player!"), object: nil )
//        Adding the currently playing bar on top of the table view
        playingView = UIView(frame: CGRect(origin: CGPoint(x:0, y:568), size: CGSize(width: 375, height: 50)))
        playingView?.backgroundColor = UIColor.white
        self.navigationController?.view.addSubview(playingView!)
        playingImage = UIImageView(image: #imageLiteral(resourceName: "clapton"))
        playingImage?.contentMode = UIViewContentMode.scaleAspectFill
        playingImage?.frame = CGRect(x: 12, y: 5, width: 40, height: 40)
        playingView?.addSubview(playingImage!)
        songnameLabel = UILabel(frame: CGRect(origin: CGPoint(x:67, y:5), size: CGSize(width: 203, height:37)))
        songnameLabel?.text = "Song Name"
        songnameLabel?.textAlignment = NSTextAlignment.center
        songnameLabel?.font = songnameLabel?.font.withSize(13)
        playingView?.addSubview(songnameLabel!)
        var getbutton = UIButton(frame: CGRect(origin: CGPoint(x: 283, y: 9), size: CGSize(width: 32, height: 32)))
        getbutton.setImage(#imageLiteral(resourceName: "icons8-below-96"), for: .normal)
        getbutton.addTarget(self, action: #selector(showBottomView(sender:)), for: .touchUpInside)
        playingView?.addSubview(getbutton)
        var playbutton = UIButton(frame: CGRect(origin: CGPoint(x: 331, y: 9), size: CGSize(width: 32, height: 32)))
        playbutton.setImage(#imageLiteral(resourceName: "icons8-play-100"), for: .normal)
       
        playingView?.addSubview(playbutton)
        playBar = UIProgressView(frame: CGRect(origin: CGPoint(x:67, y:42), size: CGSize(width: 203, height: 2)))
        playBar.progressTintColor = UIColor.darkGray
        playBar.trackTintColor = UIColor.lightGray
        playBar.progress = 0.0
        playingView?.addSubview(playBar)
        playingView?.isHidden = true
        
        duration = 60
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        
        
        tableView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self as? UIGestureRecognizerDelegate
        index_for_progress_bar = nil //when you hit pause, spotify stops the song, but the progress bar keeps running. This variable is part of the functionality that pauses and restarts the progress bar
        currently_playing_youtube_cell = nil
        last_viewed_youtube_cell = nil
        currently_playing_Spotify_cell = nil
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
    
    @objc func updateProgress() {
        // increase progress value
        //print("updating")
        self.playBar.progress += 0.00005/(self.duration)
        //self.progressBar.setProgress(0.01, animated: true)
        //self.progressBar.animate(duration: 10)
        
        // invalidate timer if progress reach to 1
        if self.playBar.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
             self.playBar.progress = 0.0
            if currently_playing_Spotify_cell != nil{
            self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
                if (error == nil) {
                    print("paused")
                }
                else {
                    print ("error in pausing!")
                }
            })
                self.appleplayer.stop()
                
                if let tappedCell = self.tableView.cellForRow(at: currently_playing_Spotify_cell!) as? PostCell {
                tappedCell.playingflag = false
                tappedCell.pausedflag = false
                print (tappedCell.pausedflag)
                print("updated cell immediately")
                }
                
                
                allCells[currently_playing_Spotify_cell!]?[0] = false
                allCells[currently_playing_Spotify_cell!]?[1] = false
                print ("updated global flags")
               
                index_for_progress_bar = nil                          
                currently_playing_Spotify_cell = nil
                currently_playing_song_id = ""
                
                
            }
            self.playBar.progress = 0.0
        }
    }
    
    
    @objc func handleMusicPlayerControllerPlaybackStateDidChange (notification: NSNotification) {
        if self.appleplayer.playbackState == .playing {
            self.youtubeplayer?.stopVideo()
        } else if self.appleplayer.playbackState == .interrupted {
            print ("interrupted")
            allCells[currently_playing_Spotify_cell!]?[0] = false
            allCells[currently_playing_Spotify_cell!]?[1] = false
        } else if self.appleplayer.playbackState == .paused {
            print ("paused")
        } else if self.appleplayer.playbackState == .stopped {
            print ("stopped")
            allCells[currently_playing_Spotify_cell!]?[0] = false
            allCells[currently_playing_Spotify_cell!]?[1] = false
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
                print("paused")
                self.allCells[self.currently_playing_Spotify_cell!]?[0] = false
                self.allCells[self.currently_playing_Spotify_cell!]?[1] = false
            }
            else {
                print ("error in pausing!")
            }
        })
        }else if (self.appleplayer.playbackState == .playing){
            self.appleplayer.stop()
            self.allCells[self.currently_playing_Spotify_cell!]?[0] = false
            self.allCells[self.currently_playing_Spotify_cell!]?[1] = false
            
        }else {
            print ("something went very wrong: Youtube cell was tapped: In Stop Audio Notification Observer")
        }
        
        
    }
    
    
//this function identify's that a youtube post has been played and sends the stop spotify player notification
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState)
    {
        print("state changed")
        switch (state){
        case YTPlayerState.ended:
            
            currently_playing_youtube_cell = nil
            no_other_video_is_active = true
            self.timer?.invalidate()
            print("no_other_video_is_active")
            break;
        case YTPlayerState.playing:
            print ("we know state changed")
            if executed_once == true{
            if (playingView?.isHidden == true){
                playingView?.isHidden = false
            }
            if currently_playing_youtube_cell == nil{
            print ("this works")
            playBar.progress = 0
            self.timer?.invalidate()
            }
            self.duration = self.temp_duration
            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
            currently_playing_youtube_cell = last_viewed_youtube_cell
            no_other_video_is_active = false
            if let cell  = self.tableView.cellForRow(at: currently_playing_youtube_cell!) as? PostCell {
                youtubeplayer = cell.playerView
            }
            if currently_playing_Spotify_cell != nil{
            print("there is a audio cell playing but i wont shut it")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Stop Audio Player!"), object: nil)
            }else{
                print ("there is no audio cell playing")
                }
            }else{
                executed_once = true
            }
            break;
        case YTPlayerState.paused:
            print("state changed to paused")
            self.timer?.invalidate()
            break;
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
    

    
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizerState.ended {
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? PostCell {  //find the cell we tapped on
                    
                    //debug
                   print("detects video cell too")
                   print (tapIndexPath)
                   print (index_for_progress_bar as Any)
                   print (tappedCell.playingflag)
                   print (tappedCell.pausedflag)
                    //debug
                    if tappedCell.typeFlag != "video"{
                        print("this is not a video cell")
                    if tappedCell.playingflag == false {
                        if index_for_progress_bar == nil {      //if no other cell is currently playing
                                if paused_cell == tapIndexPath{
                                    print ("paused_cell == tapIndexPath")
                                            index_for_progress_bar = tapIndexPath     //record current cell
                                            currently_playing_Spotify_cell = tapIndexPath
                                            currently_playing_song_id = tappedCell.trackidstring
                                            tappedCell.playButton(tappedCell)
                                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
                                    
                                            allCells[tapIndexPath]?[0] = tappedCell.playingflag
                                            allCells[tapIndexPath]?[1] = tappedCell.pausedflag
                                            allCells[tapIndexPath]?[2] = true
                                }
                                else{
                                            print ("paused_cell != tapIndexPath")
                                            index_for_progress_bar = tapIndexPath     //record current cell
                                            currently_playing_Spotify_cell = tapIndexPath
                                            currently_playing_song_id = tappedCell.trackidstring
                                            tappedCell.playButton(tappedCell)
                                            if (playingView?.isHidden == true){
                                                playingView?.isHidden = false
                                            }
                                            playBar.progress = 0
                                            self.timer?.invalidate()
                                            duration = tappedCell.duration
                                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
                                            self.youtubeplayer?.stopVideo()      //stops the last playing youtube cell
                                            currently_playing_youtube_cell = nil
                                            //self.executed_once = false
                                            no_other_video_is_active = true//songnameLabel?.text = tappedCell.player?.metadata.currentTrack?.name
                                            songnameLabel?.text = tappedCell.trackname
                                            playingImage?.image = tappedCell.albumArtImage.image
                                            print ()
                                            //debug
                                            print (tappedCell.playingflag)
                                            print (tappedCell.pausedflag)
                                            //debug
                                
                                            //sync to global settings
                                            allCells[tapIndexPath]?[0] = tappedCell.playingflag
                                            allCells[tapIndexPath]?[1] = tappedCell.pausedflag
                                            allCells[tapIndexPath]?[2] = true
                            }
                        }else{
                            let previousCell = self.tableView.cellForRow(at: index_for_progress_bar!) as? PostCell //record what the other cell that was playing was
                            //debug
                            print (index_for_progress_bar as Any)
                            print(previousCell?.playingflag as Any)
                            print(previousCell?.pausedflag as Any)
                            //debug
                            
                            //previousCell?.timer.invalidate()      //stop the progress bar on that cell
                            
                            //sync to global settings for previous cell
                            allCells[index_for_progress_bar!]?[2] = false
                            allCells[index_for_progress_bar!]?[1] = false
                            //previousCell?.pausedflag = false   <-- not required because it is updated when the cell comes up when scrolling
                            allCells[index_for_progress_bar!]?[0] =  false
                           // previousCell?.playingflag = false    <-- not required because it is updated when the cell comes up when scrolling
                            if (tappedCell.source == "spotify" && self.appleplayer.playbackState == .playing){
                                self.appleplayer.stop()
                                print ("switching from apple to spotify")
                            }else if (tappedCell.source == "apple" && self.spotifyplayer!.playbackState.isPlaying){
                                print("switching from spotify to apple")
                                self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
                                    if (error == nil) {
                                        print("paused")
                                    }
                                    else {
                                        print ("error in pausing!")
                                    }
                                })
                            }else{
                                    print ("switching within same player")
                                    }
                            index_for_progress_bar = tapIndexPath
                            currently_playing_Spotify_cell = tapIndexPath
                            currently_playing_song_id = tappedCell.trackidstring
                            tappedCell.playButton(tappedCell)
                            if (playingView?.isHidden == true){
                                playingView?.isHidden = false
                            }
                            playBar.progress = 0
                            self.timer?.invalidate()
                            
                            //sync to global settings for current cell
                            duration = tappedCell.duration
                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
                            self.youtubeplayer?.stopVideo()         //stops the last playing youtube cell
                            //self.executed_once = false
                            currently_playing_youtube_cell = nil
                            no_other_video_is_active = true
                            songnameLabel?.text = tappedCell.trackname
                            playingImage?.image = tappedCell.albumArtImage.image
                            allCells[tapIndexPath]?[0] = tappedCell.playingflag
                            allCells[tapIndexPath]?[1] = tappedCell.pausedflag
                            allCells[tapIndexPath]?[2] = true
                        }
                    }else{
                        if index_for_progress_bar == tapIndexPath{
                            index_for_progress_bar = nil                          //if no other cell is currently playing
                            currently_playing_Spotify_cell = nil
                            currently_playing_song_id = ""
                            paused_cell = tapIndexPath
                            if (playingView?.isHidden == false){
                                //playingView?.isHidden = true
                            }
                            tappedCell.pauseButton(tappedCell)
                            self.timer?.invalidate()
                            
                            //sync to global settings for current cell
                            allCells[tapIndexPath]?[0] = tappedCell.playingflag
                            allCells[tapIndexPath]?[1] = tappedCell.pausedflag
                            allCells[tapIndexPath]?[2] = false
                        }
                            
                    }
                    }else{
                        if currently_playing_youtube_cell != nil{
                        self.youtubeplayer?.stopVideo()
                        currently_playing_youtube_cell = nil
                        //self.executed_once = false
                        self.timer.invalidate()
                        self.playBar.progress = 0
                        }
                        tappedCell.playerView.isUserInteractionEnabled = true
                        tappedCell.playerView.delegate = self                     //if a cell is a video cell, declare the tableview as its delegate,
                        youtubeplayer = tappedCell.playerView                     //so that we can have playback control on the 'last played' youtube
                        self.youtubeplayer?.playVideo()                            //internal control because otherwise you would need two taps: 1 to
                        temp_duration = tappedCell.duration                         //enable user interaction and one to play the video
                    }
                }
            }
        }
    }
    
    func fetchPosts()
    {
        self.posts = Post.fetchPosts()
        self.tableView.reloadData()
        
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.postCell, for: indexPath) as! PostCell
        
        
        cell.post = self.posts?[indexPath.section]
        if (cell.post.flag == "video"){
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
                print("paused")
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
    
    
}

extension UIProgressView {
    
    func animate(duration: Double) {
        
        setProgress(0.01, animated: true)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            self.setProgress(1.0, animated: true)
        }, completion: nil)
    }
}

