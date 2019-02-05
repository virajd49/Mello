//
//  UploadViewController2.swift
//  Project2
//
//  Created by virdeshp on 12/1/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation
import Firebase
import PromiseKit
import MediaPlayer
import GoogleAPIClientForREST


class UploadViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource, CALayerDelegate, UIScrollViewDelegate, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, UITextViewDelegate, YTPlayerViewDelegate {
    
    @IBOutlet weak var pane_view_for_keyboard_dismiss: UIView!
    @IBOutlet weak var url_paste_container_view: UIView!
    @IBOutlet weak var url_paste_view: UITextView!
    @IBOutlet weak var url_go_button: UIButton!
    @IBOutlet weak var selector_stack: UIStackView!
    @IBOutlet weak var stack_trailing: NSLayoutConstraint!
    @IBOutlet weak var stack_leading: NSLayoutConstraint!
    @IBOutlet weak var now_playing_button_outlet: UIButton!
    @IBOutlet weak var apple_button_outlet: UIButton!
    @IBOutlet weak var spotify_button_outlet: UIButton!
    @IBOutlet weak var youtube_button_outlet: UIButton!
    
    @IBOutlet weak var youtube_player: YTPlayerView!
    @IBOutlet weak var now_playing_image: UIImageView!
    @IBOutlet weak var now_playing_progress_bar: UIProgressView!
    @IBOutlet weak var upload_done: UIButton!
    
    @IBOutlet weak var search_bar_container: UIView!
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var back_button: UIButton!
    
    @IBOutlet weak var test_slider: UISlider!
    @IBOutlet weak var audio_scrubber_ot: UISlider!
    var spotifyplayer =  SPTAudioStreamingController.sharedInstance()
    var apple_player = MPMusicPlayerController.applicationMusicPlayer
    var spotify_current_uri: String?
    var apple_id: String?
    var yt_id: String?
    var timer : Timer!
    
    var my_table: UITableView?
    var search_result_count: Int = 0
    @IBOutlet weak var table_view: UITableView!
    var button_array: [UIButton]?
    var selected_cell: IndexPath?
    var lyrics = false
    let userDefaults = UserDefaults.standard
    
    var search_result_video = GTLRYouTube_Video()
    var video_search_results = [GTLRYouTube_SearchResult]() {
        didSet {
            DispatchQueue.main.async {
                print ("reloading")
                self.my_table?.reloadData()
            }
        }
    }
    private let service = GTLRYouTubeService()
    
    
    var mediaItems = [[MediaItem]]() {
        didSet {
            DispatchQueue.main.async {
                print ("reloading")
                self.my_table?.reloadData()
            }
        }
    }
    
    var spotify_mediaItems = [[SpotifyMediaObject.item]]() {
        didSet {
            DispatchQueue.main.async {
                print ("reloading")
                self.my_table?.reloadData()
            }
        }
    }
    let imageCacheManager = ImageCacheManager()
    let appleMusicManager = AppleMusicManager()
    var setterQueue = DispatchQueue(label: "UploadViewController2")
    var upload_flag = "default"
    let gradient = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        my_table = table_view
        self.my_table?.delegate = self
        self.my_table?.dataSource = self
        self.my_table?.isHidden = true
        self.back_button.isHidden = true
        self.audio_scrubber_ot.isHidden = true
        self.test_slider.isHidden = true
        self.test_slider.setThumbImage(UIImage(named: "icons8-square-filled-24"), for: .normal)
        self.test_slider.setThumbImage(UIImage(named: "icons8-square-filled-24"), for: .highlighted)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        self.my_table?.addGestureRecognizer(tapGesture)
        tapGesture.delegate = my_table as? UIGestureRecognizerDelegate
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(scrub(recognizer:)))
//        self.audio_scrubber_ot?.addGestureRecognizer(longPress)
//        longPress.delegate = audio_scrubber_ot as? UIGestureRecognizerDelegate
        longPress.minimumPressDuration = 0.1
        longPress.allowableMovement = 200
        stack_leading.constant = 167.5
        stack_trailing.constant = -72.5
        button_array = [self.now_playing_button_outlet, self.apple_button_outlet, self.spotify_button_outlet, self.youtube_button_outlet]
        self.change_alpha(center_button: 0)
        toggle_hide_now_playing(hide: false)
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Posts"
        searchController.searchBar.delegate = self
        self.search_bar_container.addSubview(searchController.searchBar)
        searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchController.searchBar.isHidden = true
        now_playing_image.layer.cornerRadius = 10
        youtube_player.isHidden = true
        youtube_player.delegate = self
        gradient.frame = (self.my_table?.bounds)!
        self.my_table?.layer.mask = gradient
        self.my_table?.separatorStyle = .none
        gradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.7, 1]
        gradient.delegate = self
        let cancelButtonAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
        
        let keyboard_dismiss_tap = UITapGestureRecognizer(target: self, action: #selector(UploadViewController2.dismiss_keyboard))
        self.pane_view_for_keyboard_dismiss.addGestureRecognizer(keyboard_dismiss_tap)
        
        self.spotifyplayer?.playbackDelegate = self as SPTAudioStreamingPlaybackDelegate
        self.spotifyplayer?.delegate = self as SPTAudioStreamingDelegate
        
        service.apiKey = (userDefaults.value(forKey: "google_api_key") as! String)
        
        self.pane_view_for_keyboard_dismiss.isHidden = true
        self.url_paste_container_view.layer.cornerRadius = 5
        self.url_paste_container_view.layer.shadowColor = UIColor.black.cgColor
        self.url_paste_container_view.layer.shadowOpacity = 0.5
        self.url_paste_container_view.layer.shadowOffset = CGSize.zero
        self.url_paste_container_view.layer.shadowRadius = 2
        self.url_paste_container_view.layer.shadowPath = UIBezierPath(roundedRect: self.url_paste_container_view.bounds, cornerRadius: 5).cgPath
        self.url_paste_container_view.layer.borderColor = UIColor.black.cgColor
        self.url_paste_container_view.isHidden = true
        self.url_paste_view.delegate = self
        self.url_paste_view.textColor = UIColor.lightGray
        self.url_paste_view.text = "URL"
        self.view.sendSubview(toBack: self.url_paste_container_view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func dismiss_chevron(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func now_playing_button(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: [.curveEaseIn], animations: {
                        self.stack_leading.constant = 167.5
                        self.stack_trailing.constant = -72.5
                        self.change_alpha(center_button: 0)
                        self.view.layoutIfNeeded()
        }, completion: nil)
        self.upload_flag = "now_playing"
        toggle_hide_now_playing(hide: false)
        searchController.searchBar.isHidden = true
        self.my_table?.isHidden = true
        self.youtube_player.isHidden = true
        self.clear_tables()
    }
    
    @IBAction func apple_upload_button(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: [.curveEaseIn], animations: {
                        self.stack_leading.constant = 87.5
                        self.stack_trailing.constant = 7.5
                        self.change_alpha(center_button: 1)
                        self.view.layoutIfNeeded()
        }, completion: nil)
        toggle_hide_now_playing(hide: true)
        searchController.searchBar.placeholder = "Search Apple Music"
        searchController.searchBar.isHidden = false
        self.upload_flag = "apple"
        self.clear_tables()
        self.my_table?.isHidden = false
        self.url_paste_container_view.isHidden = true
        self.view.sendSubview(toBack: self.url_paste_container_view)
        
    }
    
    @IBAction func spotify_button(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: [.curveEaseIn], animations: {
                        self.stack_leading.constant = 7.5
                        self.stack_trailing.constant = 87.5
                        self.change_alpha(center_button: 2)
                        self.view.layoutIfNeeded()
        }, completion: nil )
        toggle_hide_now_playing(hide: true)
        searchController.searchBar.placeholder = "Search Spotify"
        searchController.searchBar.isHidden = false
        self.upload_flag = "spotify"
        self.clear_tables()
        self.my_table?.isHidden = false
        self.url_paste_container_view.isHidden = true
        self.view.sendSubview(toBack: self.url_paste_container_view)
    }
    
    @IBAction func youtube_button(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: [.curveEaseIn], animations: {
                        self.stack_leading.constant = -72.5
                        self.stack_trailing.constant = 167.5
                        self.change_alpha(center_button: 3)
                        self.view.layoutIfNeeded()
        }, completion: nil )
        toggle_hide_now_playing(hide: true)
        self.upload_flag = "youtube"
        searchController.searchBar.placeholder = "Search Youtube"
        searchController.searchBar.isHidden = false
        self.clear_tables()
        self.my_table?.isHidden = false
        self.url_paste_container_view.isHidden = false
        self.view.bringSubview(toFront: self.url_paste_container_view)
    }
    
    @IBAction func back_button(_ sender: Any) {
        toggle_hide_now_playing(hide: true)
        searchController.searchBar.isHidden = false
        self.my_table?.isHidden = false
        self.back_button?.isHidden = true
        if self.url_paste_view.text != nil {
            self.url_paste_container_view.isHidden = false
            self.view.bringSubview(toFront: url_paste_container_view)
        }
        
        if (self.upload_flag == "spotify") {
            self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
                if (error == nil) {
                    print("paused")
                    //self.timer?.invalidate()
                    //self.offsetvalue = (self.Spotifyplayer!.playbackState.position)
                }
                else {
                    print ("error in pausing!")
                }
            })
        } else if (self.upload_flag == "apple") {
            if (self.apple_player.playbackState == .playing) {
                self.apple_player.stop()
            }
        } else if (self.upload_flag == "youtube") {
           if (self.youtube_player.playerState() == YTPlayerState.playing || self.youtube_player.playerState() == YTPlayerState.paused) {
                self.youtube_player.stopVideo()
            }
        }
        //self.timer.invalidate()
        //self.audio_scrubber_ot.value = 0.0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor ==  UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        self.pane_view_for_keyboard_dismiss.isHidden = false
        //self.view.bringSubview(toFront: self.pane_view_for_keyboard_dismiss)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = UIColor.lightGray
            textView.text = "URL"
        }
        
        self.pane_view_for_keyboard_dismiss.isHidden = true
        //self.view.sendSubview(toBack: self.pane_view_for_keyboard_dismiss)
    }
    
    @IBAction func url_go_button_action(_ sender: Any) {
        print ("clicked url_go_button ")
    
            if let video_url = self.url_paste_view.text {
                var first_split = [Substring]()
                var videoid_from_url = String()
                if video_url.contains("youtube") {
                        //youtube URL from Youtube in a web browser (chrome)
                        if video_url.contains("&") {
                            first_split = video_url.split(separator: "&")
                        } else if video_url.contains("watch?v=") {
                            first_split[0] = Substring(video_url)
                        } else {
                             print ("ERROR: URL does not contain video id ?? ")
                        }
                        var second_split = first_split[0].split(separator: "=")
                        if second_split.count > 0 && !second_split[1].isEmpty {
                            videoid_from_url = String(second_split[1])
                        }
                } else if video_url.contains("youtu.be") {
                    //youtube URL format from Youtube IOS mobile app
                    let second_split = video_url.replacingOccurrences(of: "https://youtu.be/", with: "")
                    if !second_split.isEmpty {
                        videoid_from_url = second_split
                    }
                } else {
                    print ("url_go_button_action - new kind of youtube url format")
                }
                
                self.youtube_player.isHidden = false

                    self.youtube_player.load(withVideoId: videoid_from_url , playerVars: ["autoplay": 1, "playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 1, "rel": 0, "iv_load_policy": 3])
                    let video_search_query = GTLRYouTubeQuery_VideosList.query(withPart: "snippet,contentDetails,statistics")
                    video_search_query.identifier = videoid_from_url
                
                DispatchQueue.global(qos: .userInitiated).async
                {
                    print("dispatch queue ran")
                    self.service.executeQuery(video_search_query,
                                         delegate: self,
                                         didFinish: #selector(self.displayResultWithTicket2(ticket:finishedWithObject:error:)))
                }
                    self.yt_id = videoid_from_url
                    print ("URL retrieved videoID is : \(videoid_from_url)")
                
                self.url_paste_view.endEditing(true)
                self.pane_view_for_keyboard_dismiss.isHidden = true
                //self.view.sendSubview(toBack: self.pane_view_for_keyboard_dismiss)
                self.url_paste_container_view.isHidden = true
            self.view.sendSubview(toBack: self.url_paste_container_view)
                self.toggle_hide_now_playing(hide: false)
                self.searchController.searchBar.isHidden = true
                self.my_table?.isHidden = true
                self.back_button?.isHidden = false
                self.searchController.view.endEditing(true)
                self.selected_cell = nil
                print ("gesture recognized")
                self.youtube_player.isHidden = false
        } else {
            print ("ERROR: Could not retrieve URL from ")
        }
    }
    
    @objc func scrub (recognizer: UILongPressGestureRecognizer) {
        print ("long press detected")
        self.spotifyplayer?.seek(to: TimeInterval(self.audio_scrubber_ot.value), callback: nil)
        
    }
    
    func change_alpha (center_button: Int) {
        
        for i in 0...3 {
            if i == center_button {
                self.button_array![i].alpha = 1
            } else {
                self.button_array![i].alpha = 0.2
            }
        }
        
    }
    
    @IBAction func audio_scrubber(_ sender: Any) {
        
        
        if (self.upload_flag == "spotify") {
//            if ((self.spotifyplayer?.playbackState.isPlaying)!) {
//                self.spotifyplayer?.seek(to: TimeInterval(self.audio_scrubber_ot.value), callback: nil)
//            } else {
//                self.spotifyplayer?.playSpotifyURI(spotify_current_uri, startingWith: 0, startingWithPosition: TimeInterval(self.audio_scrubber_ot.value), callback: { (error) in
//                    if (error == nil) {
//                        print("playing!")
//                    }
//
//                })
//            }
        } else if (self.upload_flag == "apple") {
            print("in scrubber")
//            if (self.apple_player.playbackState == MPMusicPlaybackState.playing) {
//                self.apple_player.currentPlaybackTime = TimeInterval((self.audio_scrubber_ot.value))
//            }
        }
        self.test_slider.setValue(self.audio_scrubber_ot.value, animated: true)
        
    }
    
    
    @IBAction func audio_scrubber_touch_down(_ sender: Any) {
        
//                if ((spotifyplayer?.playbackState.isPlaying)!) {
//                    self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
//                        if (error == nil) {
//                            print("paused")
//                            //self.timer?.invalidate()
//                            //self.offsetvalue = (self.Spotifyplayer!.playbackState.position)
//                        }
//                        else {
//                            print ("error in pausing!")
//                        }
//                    })
//                }
    }
  
    
    @IBAction func audio_scrubber_touch_up_inside(_ sender: Any) {
        
         if (self.upload_flag == "spotify") {
            if ((self.spotifyplayer?.playbackState.isPlaying)!) {
                self.spotifyplayer?.seek(to: TimeInterval(self.audio_scrubber_ot.value), callback: nil)
            } else {
                self.spotifyplayer?.playSpotifyURI(spotify_current_uri, startingWith: 0, startingWithPosition: TimeInterval(self.audio_scrubber_ot.value), callback: { (error) in
                    if (error == nil) {
                        print("playing!")
                    }

                })
            }
         } else if (self.upload_flag == "apple") {
            print("in scrubber touch up inside")
            if (self.apple_player.playbackState == MPMusicPlaybackState.playing) {
                    self.apple_player.currentPlaybackTime = TimeInterval((self.audio_scrubber_ot.value))
            }
         } else if (self.upload_flag == "youtube") {
            print("in scrubber touch up inside")
            print (self.audio_scrubber_ot.value)
            self.youtube_player.seek(toSeconds: Float(self.audio_scrubber_ot.value/1000), allowSeekAhead: true)
        }
    }
    
    
    
    @IBAction func upload_done(_ sender: Any) {
        
        var upload_post: Post?
        if (self.selected_cell != nil) {
            get_post_from_cell(cell_index: self.selected_cell!).done { upload_post in
                print ("we got_post_from_cell")
                if let presenter = self.presentingViewController as? myTabBarController {
                    print("we got tabbar as presenter")
                    
//                    print (presenter.viewControllers!.count)
//                    if presenter.viewControllers?[0] is MessageViewController{
//                        print("It's upcont2")
//                    } else if presenter.viewControllers?[0] is NewsFeedTableViewController {
//                        print ("it's searchcontroller")
//                    } else if presenter.viewControllers?[0] is FriendUpdateViewController {
//                        print ("its newsfeed")
//                    } else if  presenter.viewControllers?[0] is UploadViewController {
//                        print ("it's tabbar")
//                    } else if presenter.viewControllers?[0] is UINavigationController {
//                        print ("it's nav")
//                    }
                    
                    //Presenter is TabBarController - it's 0th controller is NavBarController
                    //NavBar's child controller is Newsfeed Controller
                    if let newsfeed = presenter.viewControllers?[0].childViewControllers[0] as? NewsFeedTableViewController {
                    print ("we got newsfeed")
                    let new_post_number = newsfeed.posts?.count
                    self.add_new_post_to_firebase(new_post: upload_post, new_post_number: new_post_number!)
                    newsfeed.fetchPosts()
                }
            }
                
                self.searchController.isActive = false
                
                
                
                if self.presentingViewController is UploadViewController2 {
                    print("It's upcont2")
                } else if self.presentingViewController is UISearchController {
                    print ("it's searchcontroller")
                } else if self.presentingViewController is NewsFeedTableViewController {
                    print ("its newsfeed")
                } else if  self.presentingViewController is myTabBarController {
                    print ("it's tabbar")
                } else if self.presentingViewController is SignInViewController {
                    print ("it's signIn")
                } else if self.presentingViewController is UINavigationController {
                    print ("it's nav")
                }
                
                if self.end_post_media() {
                    print ("Post media stopped")
                } else {
                    print("Error stoping new post media")
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        //self.dismiss(animated: true, completion: nil)
        
    }
    
    func end_post_media () -> Bool {
        
        var return_value = false
        if (self.upload_flag == "spotify") {
            if (self.spotifyplayer?.playbackState.isPlaying)! {
                self.spotifyplayer?.setIsPlaying(false, callback: { (error) in
                    if (error == nil) {
                        print("paused number 5")
                        return_value = true
                    }
                    else {
                        print ("error in pausing!")
                        return_value = false
                    }
                })
            }
        } else if (self.upload_flag == "apple") {
            if self.apple_player.playbackState == .playing {
                self.apple_player.stop()
            }
        } else if (self.upload_flag == "youtube") {
            if self.youtube_player.playerState() == YTPlayerState.playing {
                self.youtube_player.stopVideo()
            }
        }
        
//        } else if self.apple_player.isPlaying {
//
//        } else if youtube player is playing {
//
//        }
        
        return return_value
    }
    func toggle_hide_now_playing (hide: Bool) {
        if hide {
            self.now_playing_image.isHidden = true
            self.upload_done.isHidden = true
            self.now_playing_progress_bar.isHidden = true
            self.audio_scrubber_ot.isHidden = true
            self.test_slider.isHidden = true
        } else {
            self.now_playing_image.isHidden = false
            self.upload_done.isHidden = false
            self.now_playing_progress_bar.isHidden = false
            self.audio_scrubber_ot.isHidden = false
            self.test_slider.isHidden = false
        }
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.search_result_count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if upload_flag == "apple" {
            print ("section \(section)")
            if mediaItems.count != 0 {
                return mediaItems[section].count
            } else {
                return 0
            }
        } else if upload_flag == "spotify" {
            print ("section \(section)")
            if spotify_mediaItems.count != 0 {
                return spotify_mediaItems[section].count
            } else {
                return 0
            }
        } else if self.upload_flag == "youtube"{
            if !self.video_search_results.isEmpty {
                print("\n we returned 1 \n")
                return 1    //there is only one row in every section
            }
            else {
                print("\n we returned 0 for rows \n")
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.upload_flag != "youtube" {
            if section == 0 {
                if self.tableView(table_view, numberOfRowsInSection: section) > 0 {
                    return NSLocalizedString("Songs", comment: "Songs")
                }
            } else {
                if self.tableView(table_view, numberOfRowsInSection: section) > 0 {
                    return NSLocalizedString("Albums", comment: "Albums")
                }
            }
        } else {
            return nil
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.upload_flag != "youtube" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.identifier,
                                                           for: indexPath) as? SearchResultCell else {
                                                            return UITableViewCell()
            }
       
            print ("we here")
            var imageURL: URL?
            
            if self.upload_flag == "apple" {
                print ("dequeue was called")
                let mediaItem = mediaItems[indexPath.section][indexPath.row]
                
                let isIndexValid1 = mediaItems.indices.contains(indexPath.section)
                let isIndexValid2 = mediaItems[indexPath.section].indices.contains(indexPath.row)
                if (isIndexValid1 && isIndexValid2) {
            
                    cell.mediaItem = mediaItem
                
                
                    // Image loading.
                    imageURL = mediaItem.artwork.imageURL(size: CGSize(width: 400, height: 400))
                    if let image = imageCacheManager.cachedImage(url: imageURL!) {
                        // Cached: set immediately.
                        
                        cell.media_image.image = image
                        cell.media_image.alpha = 1
                    } else {
                        // Not cached, so load then fade it in.
                        cell.media_image.alpha = 0
                        
                        imageCacheManager.fetchImage(url: imageURL!, completion: { (image) in
                            // Check the cell hasn't recycled while loading.
                            
                            
                            if (cell.mediaItem?.identifier ?? "") == mediaItem.identifier {
                                cell.media_image.image = image
                                UIView.animate(withDuration: 0.3) {
                                    cell.media_image.alpha = 1
                                }
                            }
                        })
                    }
                }
            } else if self.upload_flag == "spotify" {
                print ("dequeue was called")
                print(indexPath.section)
                print(indexPath.row)
                
                let isIndexValid1 = spotify_mediaItems.indices.contains(indexPath.section)
                let isIndexValid2 = spotify_mediaItems[indexPath.section].indices.contains(indexPath.row)
                if (isIndexValid1 && isIndexValid2) {
                    let spotify_mediaItem = spotify_mediaItems[indexPath.section][indexPath.row]
                    
                     cell.spotify_mediaItem = spotify_mediaItems[indexPath.section][indexPath.row]
                    
                    
                    // Image loading.
                    if spotify_mediaItem.album?.images?.count != 0 {
                        print ("hurdle one")
                        imageURL = URL(string: "\(spotify_mediaItem.album?.images?[0].url ?? "" )")
                        print (spotify_mediaItem.album?.images?[0].url)
                        print (imageURL)
                    }
                    
                    
                        if (imageURL != nil) {
                            print ("hurdle two")
                        if let image = imageCacheManager.cachedImage(url: imageURL!) {
                        // Cached: set immediately.
                            //®print ("Cached")
                            cell.media_image.image = image
                            cell.media_image.alpha = 1
                        } else {
                            // Not cached, so load then fade it in.
                            cell.media_image.alpha = 0
                            //print ("Not cached")
                            imageCacheManager.fetchImage(url: imageURL!, completion: { (image) in
                                // Check the cell hasn't recycled while loading.
                                    if (cell.spotify_mediaItem?.uri ?? "") == spotify_mediaItem.uri {
                                        //print ("yes we load it too")
                                        cell.media_image.image = image
                                        UIView.animate(withDuration: 0.3) {
                                            cell.media_image.alpha = 1
                                        }
                                    }
                                //print ("fetched")
                            })
                        }
                    }
                }
            //cell.media_image.image = UIImage(named: "Beatles")
            }
        
            return cell
            
        } else  {
            
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell_youtube.identifier,
                                                           for: indexPath) as? SearchResultCell_youtube else {
                                                            return UITableViewCell()
            }
            
            print ("we here")
            var imageURL: URL?
            
            print ("dequeue was called")
            print(indexPath.section)
            print(indexPath.row)
            print(self.video_search_results.count)
            print (self.video_search_results[indexPath.section])
            let video_search_result = self.video_search_results[indexPath.section]
            
            let isIndexValid1 = self.video_search_results.indices.contains(indexPath.section)
            let isIndexValid2 = self.video_search_results.indices.contains(indexPath.section)
            if (isIndexValid1 && isIndexValid2) {
                
            cell.youtube_video_resource = self.video_search_results[indexPath.section]
                
            print ("\n \(self.video_search_results[indexPath.section].snippet?.title) \n ")
            print("\n \(self.video_search_results[indexPath.section].snippet?.thumbnails?.high?.url) \n")
            
            imageURL = URL(string: self.video_search_results[indexPath.section].snippet?.thumbnails?.high?.url ?? "")
            print (imageURL)
            if imageURL != nil {
                print ("\n  imageURL != nil \n")
                if let image = imageCacheManager.cachedImage(url: imageURL!) {
                    print ("\n Cached")
                    cell.media_image.image = image
                    cell.media_name_label.alpha = 1
                } else {
                    // Not cached, so load then fade it in.
                    cell.media_image.alpha = 0
                    print ("\n Not cached")
                    imageCacheManager.fetchImage(url: imageURL!, completion: { (image) in
                        // Check the cell hasn't recycled while loading.
                        if (cell.media_name_label.text ?? "") == self.video_search_results[indexPath.section].snippet!.title {
                            //print ("yes we load it too")
                            cell.media_image.image = image
                            UIView.animate(withDuration: 0.3) {
                                cell.media_image.alpha = 1
                            }
                        }
                        print ("\n fetched")
                    })
                }
            }
            
            cell.media_name_label.text = self.video_search_results[indexPath.section].snippet?.title
            print ("\n \(cell.media_name_label.text) \n ")
            
            
            }
            
            return cell
        }
        
        
    }
    
    
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizerState.ended {
            let tapLocation = recognizer.location(in: self.my_table)
            if let tapIndexPath = self.my_table?.indexPathForRow(at: tapLocation) {
                
                if self.upload_flag != "youtube" {
                    if let tappedCell = self.my_table?.cellForRow(at: tapIndexPath) as? SearchResultCell  {
                        toggle_hide_now_playing(hide: false)
                        searchController.searchBar.isHidden = true
                        self.my_table?.isHidden = true
                        self.back_button?.isHidden = false
                        self.searchController.view.endEditing(true)
                        self.selected_cell = tapIndexPath
                        
                        if (self.upload_flag == "spotify") {
                            
                            self.now_playing_image.image = tappedCell.media_image.image
                            self.spotifyplayer?.playSpotifyURI(tappedCell.spotify_mediaItem.uri, startingWith: 0, startingWithPosition: 0.0, callback: { (error) in
                                if (error == nil) {
                                    print("playing!")
                                }
                            })
                            self.audio_scrubber_ot.maximumValue = Float(tappedCell.spotify_mediaItem.duration_ms!)
                            self.test_slider.maximumValue =
                                Float(tappedCell.spotify_mediaItem.duration_ms!)
                            print (tappedCell.spotify_mediaItem.duration_ms)
                            print (Float(tappedCell.spotify_mediaItem.duration_ms!) / 1000)
                            print(self.audio_scrubber_ot.maximumValue)
                             self.spotify_current_uri = tappedCell.spotify_mediaItem.uri
                             //self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateScrubber), userInfo: nil, repeats: true)
                        } else if (self.upload_flag == "apple") {
                            self.now_playing_image.image = tappedCell.media_image.image
                            self.apple_player.setQueue(with: [tappedCell.mediaItem.identifier as! String])
                            self.apple_player.play()
                            self.audio_scrubber_ot.maximumValue = Float(tappedCell.mediaItem.durationInMillis!)
                            self.test_slider.maximumValue =
                            Float(tappedCell.mediaItem.durationInMillis!)
                            print (tappedCell.mediaItem.durationInMillis!)
                            print (Float(tappedCell.mediaItem.durationInMillis!) / 1000)
                            print(self.audio_scrubber_ot.maximumValue)
                            self.apple_id = tappedCell.mediaItem.identifier
                        }
                    }
                } else  {
                    if let tappedCell = self.my_table?.cellForRow(at: tapIndexPath) as? SearchResultCell_youtube  {
                        toggle_hide_now_playing(hide: false)
                        searchController.searchBar.isHidden = true
                        self.my_table?.isHidden = true
                        self.back_button?.isHidden = false
                        self.searchController.view.endEditing(true)
                        self.selected_cell = tapIndexPath
                        print ("gesture recognized")
                        self.youtube_player.isHidden = false
                        self.youtube_player.load(withVideoId: tappedCell.youtube_video_resource.identifier?.videoId ?? "" , playerVars: ["autoplay": 1, "playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 1, "rel": 0, "iv_load_policy": 3])
                        self.youtube_player.playVideo()
                        let video_search_query = GTLRYouTubeQuery_VideosList.query(withPart: "snippet,contentDetails,statistics")
                        video_search_query.identifier = tappedCell.youtube_video_resource.identifier?.videoId ?? ""
                        service.executeQuery(video_search_query,
                                             delegate: self,
                                             didFinish: #selector(displayResultWithTicket2(ticket:finishedWithObject:error:)))
                        self.yt_id = tappedCell.youtube_video_resource.identifier?.videoId
                    }
                }
            }
        }
    }
    
    @objc func displayResultWithTicket2(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRYouTube_VideoListResponse,
        error : NSError?) {
        print ("in displayResultWithTicket2")
        if let error = error {
            print("error search for tapped video details - youtube - displayResultWithTicket2")
            // Your application should handle these errors appropriately depending on the kind of error.
            self.setterQueue.sync {
                self.video_search_results = []
            }
            print ("\(error.localizedDescription)")
            return
            
        }
        print (response)
        if !response.items!.isEmpty  {
            let video = response.items![0]
            print ("Got the video  - in displayResultWithTicket2")
            var video_duration = parse_youtube_track_audio(duration_string: video.contentDetails?.duration ?? "PT0M0S")
            self.audio_scrubber_ot.maximumValue = Float(video_duration * 1000)
            self.test_slider.maximumValue =
                Float(video_duration * 1000)
            print (video_duration)
            print(self.audio_scrubber_ot.maximumValue)
            self.search_result_video = video
        } else {
            print ("Request for specific video returned empty")
        }
        
    }
    
    @objc func updateScrubber () {
        self.audio_scrubber_ot.value = Float((self.spotifyplayer?.playbackState.position)!)
    }
    
    func get_post_from_cell (cell_index: IndexPath) -> Promise<Post> {
        return Promise { seal in
        print("we got to get_post_from_cell")
        var post_from_cell: Post?
        
        if let upload_cell = self.my_table?.cellForRow(at: cell_index) as? SearchResultCell, self.upload_flag != "youtube" {
            
            switch self.upload_flag {
            case "spotify" :
                print("We got to case: spotify")
                var spotify_struct = song_db_struct()
                var worker = ISRC_worker()
                
                spotify_struct.album_name = upload_cell.spotify_mediaItem.album?.name
                spotify_struct.artist_name = upload_cell.spotify_mediaItem.artists?[0].name
                spotify_struct.isrc_number = upload_cell.spotify_mediaItem.external_ids?.isrc
                spotify_struct.playable_id = upload_cell.spotify_mediaItem.uri
                spotify_struct.preview_url = upload_cell.spotify_mediaItem.preview_url
                spotify_struct.release_date = upload_cell.spotify_mediaItem.album?.release_date
                spotify_struct.song_name = upload_cell.spotify_mediaItem.name
                
                worker.get_this_song(target_catalog: "apple", song_data: spotify_struct).done {p1_found_id in
                    print ("Heya wtf bruh")
                    print (p1_found_id)
                    print ("Heya wtf bruh")
                    if p1_found_id == "nil" {
                        print ("ERROR: Helper id not found !!!!!!!!!!!!!!!!!!!!!!")
                    } else {
                        print ("Helper id found !!!!!!!!!!!!!!!!!!!")
                    }
                
                
                post_from_cell = Post(albumArtImage:  "",
                                      sourceAppImage:  "Spotify_cropped",
                                      typeImage: "icons8-musical-notes-50" ,
                                      profileImage:  "FullSizeRender 10-2" ,
                                      username: "Viraj",
                                      timeAgo: "Just now",
                                      numberoflikes: "0 likes",
                                      caption: "Caption...",
                                      offset: Double(self.test_slider.value * 1000),
                                      startoffset: 0.0,
                                      audiolength: 60.0 ,
                                      paused: false,
                                      playing: false,
                                      trackid: upload_cell.spotify_mediaItem.uri,
                                      helper_id: p1_found_id,
                                      videoid: "empty",
                                      starttime: 0 ,
                                      endtime: 0,
                                      flag: ((self.lyrics) ? "lyric" : "audio"),
                                      lyrictext: "",
                                      songname: upload_cell.spotify_mediaItem.name,
                                      sourceapp: self.upload_flag,
                                      preview_url: (upload_cell.spotify_mediaItem.preview_url) ?? "nil",
                                      albumArtUrl: upload_cell.spotify_mediaItem.album?.images![0].url,
                                      original_track_length: upload_cell.spotify_mediaItem!.duration_ms!)
                    
                    seal.fulfill(post_from_cell!)
                }
                
            case "apple":
                
                var apple_struct = song_db_struct()
                var worker = ISRC_worker()
                
                apple_struct.album_name = upload_cell.mediaItem.albumName
                apple_struct.artist_name = upload_cell.mediaItem.artistName
                apple_struct.isrc_number = upload_cell.mediaItem.isrc
                apple_struct.playable_id = upload_cell.mediaItem.identifier
                apple_struct.preview_url = upload_cell.mediaItem.previews[0]["url"] ?? ""
                apple_struct.release_date = upload_cell.mediaItem.releaseDate
                apple_struct.song_name = upload_cell.mediaItem.name
                
                worker.get_this_song(target_catalog: "spotify", song_data: apple_struct).done {p1_found_id in
                    print ("Heya wtf bruh")
                    print (p1_found_id)
                    print ("Heya wtf bruh")
                post_from_cell = Post(albumArtImage:  "",
                                      sourceAppImage:  "apple_logo",
                                      typeImage: "icons8-musical-notes-50" ,
                                      profileImage:  "FullSizeRender 10-2" ,
                                      username: "Viraj",
                                      timeAgo: "Just now",
                                      numberoflikes: "0 likes",
                                      caption: "Caption...",
                                      offset: Double(self.test_slider.value * 1000),
                                      startoffset: 0.0,
                                      audiolength: 60.0, //<- This has to be grabbed from user - provide physical slider
                                      paused: false,
                                      playing: false,
                                      trackid: upload_cell.mediaItem.identifier,
                                      helper_id: p1_found_id,
                                      videoid: "empty",
                                      starttime: 0 ,
                                      endtime: 0,
                                      flag: ((self.lyrics) ? "lyric" : "audio"),
                                      lyrictext: "",
                                      songname: upload_cell.mediaItem.name,
                                      sourceapp: self.upload_flag,
                                      preview_url: upload_cell.mediaItem.previews[0]["url"] ?? "",
                                      albumArtUrl: upload_cell.mediaItem.artwork.imageURL(size: CGSize(width: 375, height: 375)).absoluteString,
                                      original_track_length: upload_cell.mediaItem.durationInMillis!)
                    
                    seal.fulfill(post_from_cell!)
                    
                }
                
           
            default:   //now_playing - do we need 'default' case? it's going to be apple/spotify anyway.
                post_from_cell = Post(albumArtImage:  "",
                                      sourceAppImage:  "Spotify_cropped",
                                      typeImage: "icons8-musical-notes-50" ,
                                      profileImage:  "FullSizeRender 10-2" ,
                                      username: "Viraj",
                                      timeAgo: "Just now",
                                      numberoflikes: "0 likes",
                                      caption: "Caption...",
                                      offset: Double(self.test_slider.value * 1000),
                                      startoffset: 0.0,
                                      audiolength: 60.0 ,
                                      paused: false,
                                      playing: false,
                                      trackid: upload_cell.spotify_mediaItem.uri,
                                      helper_id: "1282343124",
                                      videoid: "empty",
                                      starttime: 0 ,
                                      endtime: 0,
                                      flag: ((self.lyrics) ? "lyric" : "audio"),
                                      lyrictext: "",
                                      songname: upload_cell.spotify_mediaItem.name,
                                      sourceapp: self.upload_flag,
                                      preview_url: upload_cell.spotify_mediaItem.preview_url,
                                      albumArtUrl: upload_cell.spotify_mediaItem.album?.images![0].url,
                                      original_track_length: 0)
                
                seal.fulfill(post_from_cell!)
                
            }
            
        } else if let upload_cell = self.my_table?.cellForRow(at: cell_index) as? SearchResultCell_youtube, self.upload_flag == "youtube" {
            post_from_cell = Post(albumArtImage:  "",
                                  sourceAppImage:  "Youtube_cropped",
                                  typeImage: "video" ,
                                  profileImage:  "FullSizeRender 10-2" ,
                                  username: "Viraj",
                                  timeAgo: "Just now",
                                  numberoflikes: "0 likes",
                                  caption: "Caption...",
                                  offset: Double(self.test_slider.value * 1000),
                                  startoffset: 0.0,
                                  audiolength: 60.0 ,
                                  paused: false,
                                  playing: false,
                                  trackid: "",
                                  helper_id: "1282343124",
                                  videoid: upload_cell.youtube_video_resource.identifier?.videoId,
                                  starttime: 0 ,
                                  endtime: 0,
                                  flag: "video",
                                  lyrictext: "",
                                  songname: upload_cell.youtube_video_resource.snippet?.title,
                                  sourceapp: self.upload_flag,
                                  preview_url: "",
                                  albumArtUrl: upload_cell.youtube_video_resource.snippet?.thumbnails?.high?.url,
                                  original_track_length: parse_youtube_track_audio(duration_string: self.search_result_video.contentDetails?.duration ?? "PT0M0S"))
            
            seal.fulfill(post_from_cell!)
            }
    }
  
    }
    
    
    func parse_youtube_track_audio (duration_string: String) -> Int {
        
        //    PT15M51S
        var changed_string = duration_string
        var final_value = Int()
        print (" duration string is \(duration_string) ")
        
        changed_string = changed_string.replacingOccurrences(of: "S", with: "")
        changed_string = changed_string.replacingOccurrences(of: "PT", with: "")
        
        if changed_string.contains("H") {
            
            var substrings = changed_string.split(separator: "H")
            var substrings_2 = substrings[1].split(separator: "M")
            
            var seconds = (Int(substrings_2[1]) ?? 0)
            var minute_breakdown = ( (Int(substrings_2[0]) ?? 0) * 60 )
            var hour_breakdown = ((Int(substrings[0]) ?? 0) * 3600 )
            final_value =  hour_breakdown + minute_breakdown + seconds
        } else if changed_string.contains("M") {
            
            var substrings = changed_string.split(separator: "M")
            var seconds = (Int(substrings[1]) ?? 0)
            var minute_breakdown = ( (Int(substrings[0]) ?? 0) * 60 )
            final_value = (((Int(substrings[0]) ?? 0) * 60) + (Int(substrings[1]) ?? 0))
            
        } else {
            
        final_value = Int(changed_string) ?? 0
        }

        return final_value
        
        
    }
    
    func clear_tables () {
        self.searchController.searchBar.text = ""
        setterQueue.sync {
            self.mediaItems = []
            self.spotify_mediaItems = []
            self.video_search_results = []
        }
    }
    
    @objc func dismiss_keyboard () {
        
        if upload_flag == "youtube" {
            self.url_paste_view.endEditing(true)
            self.searchController.searchBar.endEditing(true)
            self.pane_view_for_keyboard_dismiss.isHidden = true
            if self.url_paste_container_view.isHidden == true {
                self.url_paste_container_view.isHidden = false
            }
        }
    }
    
    
}


extension UploadViewController2: UISearchResultsUpdating {

    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
        guard let searchString = searchController.searchBar.text else {
            return
        }
        
        if searchString == "" {
            self.setterQueue.sync {
                self.mediaItems = []
                self.spotify_mediaItems = []
                self.video_search_results = []
            }
        } else if (self.upload_flag == "apple") {
            let country_code = userDefaults.string(forKey: "Country_code")
            appleMusicManager.performAppleMusicCatalogSearch(with: searchString,
                                                             countryCode: country_code ?? "us",
                                                             completion: { [weak self] (searchResults, error) in
                                                                guard error == nil else {
                                                                    
                                                                    // Your application should handle these errors appropriately depending on the kind of error.
                                                                    self?.setterQueue.sync {
                                                                        self?.mediaItems = []
                                                                    }
                                                                    
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
                                                                
                                                                self?.setterQueue.sync {
                                                                    self?.mediaItems = searchResults
                                                                    print(searchResults.count)
                                                                    self?.search_result_count = self?.mediaItems.count ?? 0
                                                                }
                                                                
            })
        } else if (self.upload_flag == "spotify") {
            print ("spotify search flag recognized")
            appleMusicManager.performSpotifyCatalogSearch(with: searchString,
                                                          completion: { [weak self] (searchResults, error) in
                                                            guard error == nil else {
                                                                
                                                                self?.setterQueue.sync {
                                                                    self?.spotify_mediaItems = []
                                                                }
                                                                
                                                                let alertController: UIAlertController
                                                                
                                                                guard let error = error as NSError?, let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? Error else {
                                                                    print ("Encountered unexpected error")
                                                                    return
                                                                }
                                                                print ("Encountered error: \(underlyingError.localizedDescription)")
                                                                return
                                                            }
                                                            
                                                            self?.setterQueue.sync {
                                                                self?.spotify_mediaItems = [searchResults]
                                                                print(searchResults.count)
                                                                
                                                                self?.search_result_count = self?.spotify_mediaItems.count ?? 0
                                                            }
                                                            
            })
        }
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateGradientFrame()
    }
    
    private func updateGradientFrame() {
        gradient.frame = CGRect(
            x: 0,
            y: (self.my_table?.contentOffset.y)!,
            width: (self.my_table?.bounds.width)!,
            height: (self.my_table?.bounds.height)!
        )
    }
    
    func action(for layer: CALayer, forKey event: String) -> CAAction? {
        return NSNull()
    }
    
    func add_new_post_to_firebase (new_post: Post, new_post_number: Int) {
        
        var post_dict = [String: Any]()
        let ref = FIRDatabase.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        
        post_dict.updateValue(new_post.albumArtImage, forKey: "albumArtImage")
        post_dict.updateValue(new_post.audiolength, forKey: "audiolength")
        post_dict.updateValue(new_post.caption, forKey: "caption")
        post_dict.updateValue(new_post.endtime, forKey: "endtime")
        post_dict.updateValue(new_post.flag, forKey: "flag")
        post_dict.updateValue(new_post.trackid, forKey: "trackid")
        post_dict.updateValue(new_post.helper_id, forKey: "helper_id")
        post_dict.updateValue(new_post.lyrictext, forKey: "lyrictext")
        post_dict.updateValue(new_post.numberoflikes, forKey: "numberoflikes")
        post_dict.updateValue(new_post.offset, forKey: "offset")
        post_dict.updateValue(new_post.paused, forKey: "paused")
        post_dict.updateValue(new_post.playing, forKey: "playing")
        post_dict.updateValue(new_post.preview_url, forKey: "preview_url")
        post_dict.updateValue(new_post.profileImage, forKey: "profileImage")
        post_dict.updateValue(new_post.songname, forKey: "songname")
        post_dict.updateValue(new_post.sourceapp, forKey: "sourceapp")
        post_dict.updateValue(new_post.sourceAppImage, forKey: "sourceAppImage")
        post_dict.updateValue(new_post.startoffset, forKey: "startoffset")
        post_dict.updateValue(new_post.starttime, forKey: "starttime")
        post_dict.updateValue(new_post.timeAgo, forKey: "timeAgo")
        post_dict.updateValue(new_post.typeImage, forKey: "typeImage")
        post_dict.updateValue(new_post.username, forKey: "username")
        post_dict.updateValue(new_post.videoid, forKey: "videoid")
        post_dict.updateValue(new_post.albumArtUrl, forKey: "albumArtUrl")
        
        let final_post = ["Post\(new_post_number)" : post_dict]
        
        ref.child("user_db").child("post_db").updateChildValues(final_post) { (err, ref) in
            
            if err != nil {
                print ("ERROR saving post value")
                print (err)
                return
            }
            print ("saved post value to db")
        }
        
        
        
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
        self.youtube_player?.playVideo()
        
    }
    
    
    
}

extension UploadViewController2: UISearchBarDelegate {
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.pane_view_for_keyboard_dismiss.isHidden = false
        //self.view.bringSubview(toFront: self.pane_view_for_keyboard_dismiss)
        self.url_paste_container_view.isHidden = true
        self.view.sendSubview(toBack: self.url_paste_container_view)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        setterQueue.sync {
            self.mediaItems = []
            self.spotify_mediaItems = []
            self.video_search_results = []
        }
        
        self.pane_view_for_keyboard_dismiss.isHidden = true
        //self.view.sendSubview(toBack: self.pane_view_for_keyboard_dismiss)
        self.url_paste_container_view.isHidden = false
        self.view.bringSubview(toFront: self.url_paste_container_view)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        guard let searchString = searchController.searchBar.text else {
            print ("searchString != searchController.searchBar.text")
            return
        }
        
        self.pane_view_for_keyboard_dismiss.isHidden = true
        //self.view.sendSubview(toBack: self.pane_view_for_keyboard_dismiss)
        
        if searchString == "" {
            self.setterQueue.sync {
                self.mediaItems = []
                self.spotify_mediaItems = []
            }
        } else if (self.upload_flag == "apple") {
            let country_code = userDefaults.string(forKey: "Country_code")
            appleMusicManager.performAppleMusicCatalogSearch(with: searchString,
                                                             countryCode: country_code ?? "us",
                                                             completion: { [weak self] (searchResults, error) in
                                                                guard error == nil else {
                                                                    
                                                                    // Your application should handle these errors appropriately depending on the kind of error.
                                                                    self?.setterQueue.sync {
                                                                        self?.mediaItems = []
                                                                    }
                                                                    
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
                                                                
                                                                self?.setterQueue.sync {
                                                                    self?.mediaItems = searchResults
                                                                    print(searchResults.count)
                                                                    self?.search_result_count = self?.mediaItems.count ?? 0
                                                                }
                                                                
            })
        } else if (self.upload_flag == "spotify") {
            print ("spotify search flag recognized")
            appleMusicManager.performSpotifyCatalogSearch(with: searchString,
                                                          completion: { [weak self] (searchResults, error) in
                                                            guard error == nil else {
                                                                
                                                                self?.setterQueue.sync {
                                                                    self?.spotify_mediaItems = []
                                                                }
                                                                
                                                                let alertController: UIAlertController
                                                                
                                                                guard let error = error as NSError?, let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? Error else {
                                                                    print ("Encountered unexpected error")
                                                                    return
                                                                }
                                                                print ("Encountered error: \(underlyingError.localizedDescription)")
                                                                return
                                                            }
                                                            
                                                            self?.setterQueue.sync {
                                                                self?.spotify_mediaItems = [searchResults]
                                                                print(searchResults.count)
                                                                
                                                                self?.search_result_count = self?.spotify_mediaItems.count ?? 0
                                                            }
                                                            
            })
        } else if (self.upload_flag == "youtube") {
            print ("searching youtube")
            let video_search_query = GTLRYouTubeQuery_SearchList.query(withPart: "snippet")
            video_search_query.maxResults = 10
            video_search_query.type = "video"
            video_search_query.q = searchString
            
            service.executeQuery(video_search_query,
                                 delegate: self,
                                 didFinish: #selector(displayResultWithTicket4(ticket:finishedWithObject:error:)))
            
        }
        
    }
    
    @objc func displayResultWithTicket4(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRYouTube_SearchListResponse,
        error : NSError?) {
        
        if let error = error {
            print("error search youtube")
            // Your application should handle these errors appropriately depending on the kind of error.
            self.setterQueue.sync {
                self.video_search_results = []
            }
            print ("\(error.localizedDescription)")
            return
            
        }
        
        if let search_result_videos = response.items, !search_result_videos.isEmpty {
            self.setterQueue.sync {
                self.video_search_results = search_result_videos
                print ("In setter queue")
                print (self.video_search_results[0])
                self.search_result_count = search_result_videos.count ?? 0
            }
        }
        
    }

}
