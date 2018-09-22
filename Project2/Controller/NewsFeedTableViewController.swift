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

class NewsFeedTableViewController: UITableViewController, YTPlayerViewDelegate, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    var av_player : AVAudioPlayer!
    let appleMusicControl = AppleMusicControl()
    let appleMusicManager = AppleMusicManager()
    let userDefaults = UserDefaults.standard
    var posts: [Post]?
    //var index_for_progress_bar : IndexPath? //for checking runaway porgress bars for other cells
    var currently_playing_song_cell: IndexPath? //last tapped/currently playing cell, so that we can stop it if a youtube video starts playing
    var currently_playing_youtube_cell: IndexPath? //last tapped/currently playing youtube cell, so that we can stop it if a youtube video starts playing
    var currently_playing_song_id: String!
    var paused_cell: IndexPath?
    var last_viewed_youtube_cell: IndexPath?
    var songnameLabel: UILabel?
    var playingImage: UIImageView?
    var spotifyplayer: SPTAudioStreamingController?
    var appleplayer = MPMusicPlayerController.applicationMusicPlayer
    var youtubeplayer: YTPlayerView?
    var no_other_video_is_active = true     //flag makes sure that the table view controller acts as the delegate of only one youtube player
    var playingView: UIView?
    var timer : Timer!
    var duration: Float!
    var temp_duration: Float!
    var playBar : UIProgressView!
    var executed_once: Bool!
    var playerView_offsetvalue: TimeInterval! //offset value for separate play/pause routine held by player_view
    var playerView_source_value: String!
    let playlist_access = UserAccess(musicPlayerController: MPMusicPlayerController.applicationMusicPlayer, myPlaylistQuery: MPMediaQuery.playlists(), myLibrarySongsQuery: MPMediaQuery.songs())
    let window = UIApplication.shared.keyWindow
    var currentPost: Post!
    struct Storyboard {
        
        static let postCell = "PostCell"
        static let postCellDefaultHeight : CGFloat = 550.0
        
    }
   let getView = BottomView()
    var mediaItems: [SpotifyMediaObject.item]!

    @objc func showBottomView(sender: UIButton){
        
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
  

    override func viewDidLoad() {
        super.viewDidLoad()
        //appleMusicControl.requestStorefrontCountryCode()
        
        self.appleplayer.beginGeneratingPlaybackNotifications()
        self.spotifyplayer = SPTAudioStreamingController.sharedInstance()
        NotificationCenter.default.addObserver(self,
                                       selector: #selector(handleMusicPlayerControllerPlaybackStateDidChange),
                                       name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                       object: self.appleplayer)
        
         NotificationCenter.default.addObserver(self, selector: #selector(stopAudioplayerforYoutube(notification:)), name: Notification.Name(rawValue: "Stop Audio Player!"), object: nil )
//        Adding the currently playing bar on top of the table view
        //playingView = UIView(frame: CGRect(origin: CGPoint(x:0, y:568), size: CGSize(width: 375, height: 50)))
        playingView = UIView(frame: CGRect(origin: CGPoint(x:0, y: (window?.frame.height)!), size: CGSize(width: 375, height: 50)))
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
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(tapEdit2(recognizer:)))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(tapEdit3(recognizer:)))
        
        
        
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
        //search_trial()
        
       
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
            self.playBar.progress = 0.0
        }
    }
    
    
    @objc func handleMusicPlayerControllerPlaybackStateDidChange (notification: NSNotification) {
        if self.appleplayer.playbackState == .playing {
            self.youtubeplayer?.stopVideo()
        } else if self.appleplayer.playbackState == .interrupted {
            print ("interrupted")
            allCells[currently_playing_song_cell!]?[0] = false
            allCells[currently_playing_song_cell!]?[1] = false
        } else if self.appleplayer.playbackState == .paused {
            print ("paused number 7")
        } else if self.appleplayer.playbackState == .stopped {
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
            if currently_playing_song_cell != nil{
                print("there is a audio cell playing but i wont shut it")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "Stop Audio Player!"), object: nil)
            }else{
                print ("there is no audio cell playing")
            }
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
    
     @objc func tapEdit3(recognizer: UITapGestureRecognizer)  {
        guard let post = currentPost else {
            return
        }
        
        self.expandSong(post: post)
        
    }
    
     @objc func tapEdit2(recognizer: UITapGestureRecognizer)  {
        
        print("In tap edit2")
        if (currently_playing_song_cell != nil){  //something is playing right now
            print("something is playing")
            if (self.appleplayer.playbackState == .playing){
                print("true")}
           
            print(self.spotifyplayer!.playbackState)
            let previousCell = self.tableView.cellForRow(at: currently_playing_song_cell!) as? PostCell
            if (previousCell?.source == "apple" && self.appleplayer.playbackState == .playing){
                print("true")}
            
        if ( self.playerView_source_value == "apple" && self.appleplayer.playbackState == .playing){
            print("something is playing : apple")
            self.appleplayer.pause()
            self.playerView_offsetvalue = self.appleplayer.currentPlaybackTime
            print (self.playerView_offsetvalue)
            
        }else if ( self.playerView_source_value == "spotify" && self.spotifyplayer!.playbackState.isPlaying){
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
            
           
        }else if (self.playerView_source_value == "youtube"){
            print("something is playing : Youtube")
            self.youtubeplayer?.pauseVideo()      //stops the last playing youtube cell
            currently_playing_youtube_cell = nil
            no_other_video_is_active = true 
          
                
            }
            
            self.timer?.invalidate()
            
            //Update global here
            allCells[currently_playing_song_cell!]?[0] = false
            allCells[currently_playing_song_cell!]?[1] = true
            previousCell?.pausedflag = true
            previousCell?.playingflag = false
            paused_cell = currently_playing_song_cell
            currently_playing_song_cell = nil
        }else if (paused_cell != nil){ //something was paused and nothing new was played
        
            print("something was paused")
            let previousCell = self.tableView.cellForRow(at: paused_cell!) as? PostCell
            if playerView_source_value == "spotify" {
                print("something was paused: spotify")
                print(previousCell?.trackidstring
                )
                self.spotifyplayer?.playSpotifyURI(previousCell?.trackidstring, startingWith: 0, startingWithPosition: self.playerView_offsetvalue, callback: { (error) in
                    if (error == nil) {
                    print("paused number 3")
                    }
                    else {
                    print ("error in pausing!")
                    }
                    })
                /*
                self.spotifyplayer?.setIsPlaying(true, callback: { (error) in
                    if (error == nil) {
                        print("paused")
                    }
                    else {
                        print ("error in pausing!")
                    }
                })
                */
            }else if (playerView_source_value == "apple"){
                print("something was paused: apple")
                print (self.playerView_offsetvalue)
                //self.appleplayer.setQueue(with: [self.currently_playing_song_id])
                //self.appleplayer.currentPlaybackTime = self.playerView_offsetvalue
                self.appleplayer.play()
                //self.appleplayer.currentPlaybackTime = self.playerView_offsetvalue
                print (self.playerView_offsetvalue)
            }
            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
            
            allCells[paused_cell!]?[0] = true
            allCells[paused_cell!]?[1] = false
            previousCell?.pausedflag = false
            previousCell?.playingflag = true
            currently_playing_song_cell = paused_cell
            paused_cell = nil
            
            
        }
        
        
    }
    
    func search_trial () {
        
        appleMusicManager.performSpotifyCatalogSearch(with: "Hotel California",
                                                         completion: { [weak self] (searchResults, error) in
                                                            guard error == nil else {
                                                                
                                                                // Your application should handle these errors appropriately depending on the kind of error.
                                                               
                                                                
                                                                let alertController: UIAlertController
                                                                
                                                                guard let error = error as NSError?, let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? Error else {
                                                                    
                                                                    alertController = UIAlertController(title: "Error",
                                                                                                        message: "Encountered unexpected error.",
                                                                                                        preferredStyle: .alert)
                                                                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                                                                    
                                                                    DispatchQueue.main.async {
                                                                        self?.present(alertController, animated: true, completion: nil)
                                                                    }
                                                                    
                                                                    return
                                                                }
                                                                
                                                                alertController = UIAlertController(title: "Error",
                                                                                                    message: underlyingError.localizedDescription,
                                                                                                    preferredStyle: .alert)
                                                                alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                                                                
                                                                DispatchQueue.main.async {
                                                                    self?.present(alertController, animated: true, completion: nil)
                                                                }
                                                                
                                                                return
                                                            }
                                                            
                                                            
                                                            print("Search got to here")
                                                            self?.mediaItems = searchResults
                                                            print ("----------------------------------")
                                                            print (self?.mediaItems[0].preview_url)
                                                            print (self?.mediaItems[0].album?.name)
                                                            print (self?.mediaItems[0].artists?[0].name)
                                                            print (self?.mediaItems[0].uri)
                                                            
                                                            print (self?.mediaItems[0].external_ids?.isrc)
                                                            print ("-----------------------------------")
                                                            //print (self?.mediaItems[0][0].composerName)
                                                            //print (self?.mediaItems[0][0].genreNames)
                                                           
                                                            
        })
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
                                if paused_cell == tapIndexPath{     //If this is a previously paused cell
                                    print ("paused_cell == tapIndexPath")
                                    
                                            currently_playing_song_cell = tapIndexPath  //record current cell
                                            currently_playing_song_id = tappedCell.trackidstring
                                            currentPost = tappedCell.post
                                            if (self.playerView_offsetvalue != nil) {
                                                tappedCell.offsetvalue = self.playerView_offsetvalue
                                            }
                                            self.playButton(cell: tappedCell)
                                            self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
                                            update_global(cell_control: true, tapped_cell: tappedCell, tapped_index: currently_playing_song_cell!)
                                }
                                else{
                                            print ("paused_cell != tapIndexPath")   //If this is a new untapped cell
                                            playerView_source_value = tappedCell.source
                                            currently_playing_song_cell = tapIndexPath
                                            currently_playing_song_id = tappedCell.trackidstring
                                            currentPost = tappedCell.post
                                            self.youtubeplayer?.stopVideo()      //stops the last playing youtube cell
                                            currently_playing_youtube_cell = nil
                                            no_other_video_is_active = true //songnameLabel?.text = tappedCell.player?.metadata.currentTrack?.name
                                            self.playButton(cell: tappedCell)
                                            setup_player_view(tapped_cell: tappedCell)
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
                            if (tappedCell.source == "spotify" && self.appleplayer.playbackState == .playing){
                                self.appleplayer.stop()
                                print ("switching from apple to spotify")
                            }else if (tappedCell.source == "apple" && (self.spotifyplayer?.playbackState.isPlaying)!){
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
                            }else{
                                    print ("switching within same player")
                                    }
                            playerView_source_value = tappedCell.source
                            currently_playing_song_cell = tapIndexPath
                            currently_playing_song_id = tappedCell.trackidstring
                            currentPost = tappedCell.post
                            self.playButton(cell: tappedCell)
                            self.youtubeplayer?.stopVideo()         //stops the last playing youtube cell
                            currently_playing_youtube_cell = nil
                            no_other_video_is_active = true
                            setup_player_view(tapped_cell: tappedCell)
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
                                currently_playing_youtube_cell = nil
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
    
    func update_global(cell_control: Bool, tapped_cell: PostCell, tapped_index: IndexPath) {
        if (cell_control) {                     //"cell_control" : If true, we are setting the global variables as per the flags set by cell.play and cell.pause buttons
            allCells[tapped_index]?[0] = tapped_cell.playingflag
            allCells[tapped_index]?[1] = tapped_cell.pausedflag
            
        }else{                                  //else we are setting them by ourselves: usually to false, because we are force stopping something
            allCells[tapped_index]?[0] =  false
            allCells[tapped_index]?[1] = false
        }
        
    }
    
    func setup_player_view(tapped_cell: PostCell){
        //Bring up and setup the player view
        if (playingView?.isHidden == true){
            playingView?.isHidden = false
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
           
            self.playingView?.frame = CGRect(x: 0, y: 568, width: 375, height: 50)
        }, completion: nil)
        playBar.progress = 0
        self.timer?.invalidate()
        duration = tapped_cell.duration
        self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
        songnameLabel?.text = tapped_cell.trackname
        playingImage?.image = tapped_cell.albumArtImage.image
        //Bring up and setup the player view
        
        
    }
    
    func playButton(cell: PostCell) {
        if cell.playingflag == false {
            if cell.pausedflag == true {
                cell.playingflag = true
                cell.pausedflag = false
                print (cell.source)
                if cell.source == "spotify" {
                    print ("source is spotify")
                    print(cell.trackidstring)
                    self.play_av()
//                    self.spotifyplayer = SPTAudioStreamingController.sharedInstance()
//                    self.spotifyplayer?.playSpotifyURI("spotify:track:3ZakaL0QEt5eeD3N7HbaN1", startingWith: 0, startingWithPosition: cell.offsetvalue, callback: { (error) in
//                        if (error == nil) {
//                            print("playing! 1")
//                            print(self.spotifyplayer?.metadata.currentTrack?.name)
//                            //self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
//                            //self.updateProgress()
//                        }
//                        else {
//                            print ("error this one!")
//                        }
//                    })
                }else if cell.source == "apple" {
                    print ("source is apple 1")
                    print (cell.trackidstring)
                    //self.musicPlayerController.setQueue(with: [self.trackidstring])
                    print (self.appleplayer.currentPlaybackTime)
                    self.appleplayer.play()
                    self.appleplayer.currentPlaybackTime = playerView_offsetvalue
                }else {
                    print ("something went wrong")
                }
            }else{
                cell.playingflag = true
                if cell.source == "spotify" {
                    print ("source is spotify 2")
                    print(cell.trackidstring)
                    print(cell.startoffset)
                    self.download_preview(url: URL(string: "https://p.scdn.co/mp3-preview/6865d7e96e4d20c8e29880ced3e0a2c243545ac5?cid=5b5198fe415746c0a9410281d041a4f9")!)
//                    self.spotifyplayer = SPTAudioStreamingController.sharedInstance()
//                    self.spotifyplayer?.playSpotifyURI("spotify:track:3ZakaL0QEt5eeD3N7HbaN1", startingWith: 0, startingWithPosition: 0, callback: { (error) in
//                        if (error == nil) {
//                            print("playing! 2")
//
//                            //print(self.Spotifyplayer?.metadata.currentTrack?.name)
//                            //print(self.Spotifyplayer?.metadata.currentTrack?.albumName)
//                            //print(self.Spotifyplayer?.metadata.nextTrack?.name)
//                            //self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
//                            //self.updateProgress()
//                        }
//                        else {
//                            print ("error this one!")
//                        }
//                    })
                    
                }else if cell.source == "apple"{
                    print ("source is apple")
                    print (cell.trackidstring)
                    self.appleplayer.setQueue(with: [cell.trackidstring])
                    self.appleplayer.play()
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
    
    func pauseButton(cell: PostCell) {
        if cell.playingflag == true {
            print (cell.source)
            if cell.source == "spotify" {
                print ("source is spotify 3")
                self.pause_av()
//                self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
//                    if (error == nil) {
//                        print("paused number 5")
//                        //self.timer?.invalidate()
//                        cell.offsetvalue = (self.spotifyplayer!.playbackState.position)
//                    }
//                    else {
//                        print ("error in pausing!")
//                    }
//                })
            }else if cell.source == "apple" {
                print ("source is apple")
                print (self.appleplayer.currentPlaybackTime)
                cell.offsetvalue = self.appleplayer.currentPlaybackTime
                playerView_offsetvalue = self.appleplayer.currentPlaybackTime
                self.appleplayer.pause()
                //self.offsetvalue = self.musicPlayerController.currentPlaybackTime
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
        
        let contentOffset = tableView.contentOffset
        
        UIGraphicsBeginImageContextWithOptions(tableView.bounds.size, true, 1)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.translateBy(x: 0.0, y: -contentOffset.y)
        
        tableView.layer.render(in: context!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //maxiCard.backingImage = image
        maxiCard.backingImage = tableView.makeSnapshot()
        //3.
        maxiCard.trackid = post.trackid
        maxiCard.song_name = post.songname
        maxiCard.play_bar_time = self.playBar.progress
        maxiCard.post = post
        
        
        
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



