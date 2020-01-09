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
import SwiftyGiphy
import UIKit
import AVFoundation
import FLAnimatedImage
import SDWebImage

/* This is a singleton.

 This is used to keep track of what upload path we are on. The upload view controller is triggered from the following places:
 
    default - basic upload path from tab bar button
    oom - oom upload
    In these two cases we want to go to UploadViewController4, we want to give the user the option to add the post to other places as well.
 
    hero - hero upload - in this case we want to finish after UploadViewController3 - don't want to go to UploadViewController4

    It is also used to pass a post the final upload post back to the hero and oom pages

 */
class upload_path_keeper {
    
    
    static let shared = upload_path_keeper()
    var new_post_selected = false
    var upload_path = "none"
    var keeper_post: Post = Post(albumArtImage: "" , sourceAppImage: "", typeImage: "" , profileImage: "" , username: "" ,timeAgo: "", numberoflikes: "" ,caption:"", offset: 0.0, startoffset: 0.0, audiolength: 0.0, paused: false, playing: true, trackid: "", helper_id: "", helper_preview_url: "", videoid: "", starttime: 0.0 , endtime: 0.0, flag: "", lyrictext: "", songname: "", sourceapp: "", preview_url: "", albumArtUrl: "", original_track_length: 0, GIF_url: "")
    /* Values
        none - nothing is being uploaded
        default - basic upload path from tab bar button
        oom - oom upload
        hero - hero upload
    */
    
    func set_upload_path(as path: String) {
        upload_path = path
    }
    
    func get_upload_path() -> String {
        return upload_path
    }
    
    func pass_a_post(post: Post) {
        self.keeper_post = post
        self.new_post_selected = true
    }
    
    func grab_keeper_post() ->Post {
        return self.keeper_post
        self.new_post_selected = false
    }
}



/*
 
 This is the first view that we see when we hit the upload button.
    - The first thing we see is all the recently played stuff the user has  (from apple/spotify) and if there is something that is currently playing in spotify/apple music we will see that too - this is the now playing view.
        - For apple, recently played tracks are only given as albums, so we have an extra view UploadViewControllerAlbumDisplay before we go to UploadViewController3
    - We then have individual searches for apple, spotify and youtube.
    - This view controller handles the searching, displaying search contents and passing the selected song to the next view controller, which is UploadViewController3
 
 */

class UploadViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource, CALayerDelegate, UIScrollViewDelegate, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, UITextViewDelegate, YTPlayerViewDelegate, UIGestureRecognizerDelegate {
    
    
    //This was a earlier version of path keeper, can probably remove this now.
    var flow = "default_upload"
    /*
        default_upload_flow
        hero_upload_flow
        omm_upload_flow
    */
    
    let searchController = UISearchController(searchResultsController: nil)
 
    
    //var currently_active_collection_view: UICollectionView
   
  
    //The small album art that shows up for the currently playing song
    @IBOutlet weak var now_playing_mini_image_container: UIView!
    @IBOutlet weak var now_playing_mini_image: UIImageView!
    
    
    //The singleton instance from where we access the currently playing song.
    //var poller = now_playing_poller.shared
    
    @IBOutlet weak var pane_view_for_keyboard_dismiss: UIView! //the pane that darkens the background when the keyboard is active and that reacts to the tap to dismiss the keyboard
    @IBOutlet weak var url_paste_container_view: UIView!
    @IBOutlet weak var url_paste_view: UITextView!
    @IBOutlet weak var url_go_button: UIButton!
    
    //The button stack that contains the Now playing, Apple, Spotify and Youtube buttons at the bottom
    @IBOutlet weak var selector_stack: UIStackView!
    
    //leading and trailing constraints for the selector stack
    @IBOutlet weak var stack_trailing: NSLayoutConstraint!
    @IBOutlet weak var stack_leading: NSLayoutConstraint!
    
    //the buttons in the stack
    @IBOutlet weak var now_playing_button_outlet: UIButton!
    @IBOutlet weak var apple_button_outlet: UIButton!
    @IBOutlet weak var spotify_button_outlet: UIButton!
    @IBOutlet weak var youtube_button_outlet: UIButton!
    
    
    @IBOutlet weak var dismiss_chevron_bottom_constraint: NSLayoutConstraint!
    @IBOutlet weak var selector_stack_bottom_constraint: NSLayoutConstraint!
    
    //the dismiss chevron at the bottom of the view
    @IBOutlet weak var dismiss_chevron_button: UIButton!
  
    //var apple_system_player = MPMusicPlayerController.systemMusicPlayer
    var yt_id: String?
    var scroller_timer = Timer()
    
    var my_table: UITableView?
    var search_result_count: Int = 0
    @IBOutlet weak var table_view: UITableView!
    var button_array: [UIButton]?
    var selected_cell: IndexPath?
    let userDefaults = UserDefaults.standard
    var spotify_is_currently_playing : Bool = false
    var apple_is_currently_playing: Bool = false
    var temp_spotify_media_context_uri: String?
    var temp_spotify_media_context_duration: Int?
    var duration: Int = 0
    var duration_for_number_of_cells: Int = 0
    var uploading = false
    var search_result_video = GTLRYouTube_Video()
    var selected_search_result_post: Post!
    var selected_search_result_post_image: UIImage!
    var selected_search_result_song_db_struct = song_db_struct()
    var path_keeper = upload_path_keeper.shared
    
    
    var album_header_view = UIView.init(frame: CGRect(x: 0, y: 0, width: 375, height: 180))
    var album_header_image_view = UIImageView.init(frame: CGRect(x: 10, y: 15, width: 150, height: 150))
    var album_name_label_view = UILabel.init(frame: CGRect(x: 165, y: 15, width: 200, height: 30))
    var album_artist_name_label_view = UILabel.init(frame: CGRect(x: 165, y: 50, width: 200, height: 30))
    var album_artist_release_date_label_view = UILabel.init(frame: CGRect(x: 165, y: 85, width: 200, height: 30))
    var selected_album_media_item: MediaItem!
    
    
    //This array holds all the youtube search results for a given search
    var video_search_results = [GTLRYouTube_SearchResult]() {
        didSet {
            DispatchQueue.main.async {
                print ("reloading for youtube results")
                self.my_table?.reloadData()
            }
        }
    }
    
    
    private let service = GTLRYouTubeService()
    
    
    //This array holds all the apple search results for a given search AND recently played items
    var mediaItems = [[MediaItem]]() {
        didSet {
            DispatchQueue.main.async {
                print ("reloading")
                self.search_result_count = self.mediaItems.count ?? 0
                self.my_table?.reloadData()
            }
        }
    }
    
    //This array holds all the spotify search results for a given search
    var spotify_mediaItems = [[SpotifyMediaObject.item]]() {
        didSet {
            DispatchQueue.main.async {
                //print ("reloading")
                self.my_table?.reloadData()
            }
        }
    }
    
    
    //This array holds all the spotify recently played items
    var spotify_recently_played_mediaItems = [[SpotifyRecentlyPlayedMediaObject.item]] () {
        didSet {
            print ("spotify_recently_played_mediaItems didSet")
            DispatchQueue.main.async {
                //print ("reloading")
                self.my_table?.reloadData()
            }
        }
    }

   
    fileprivate var searchCoalesceTimer: Timer? {
        willSet {
            if searchCoalesceTimer?.isValid == true
            {
                searchCoalesceTimer?.invalidate()
            }
        }
    }
   
    
    let imageCacheManager = ImageCacheManager()
    let appleMusicManager = AppleMusicManager()
    var setterQueue = DispatchQueue(label: "UploadViewController2")
    
    //This flag is used to idently what upload source we are using now_playing/apple/spotify/youtube
    var upload_flag = "default"
    let gradient = CAGradientLayer()
    var post_help = Post_helper()             //This is required because sometimes in spotify if the song is part of a compilation - made by a user
    var secondary_image_url: URL?             //- then it picks up the album art for that compilation instead of the actual album art. So we
    var secondary_image: UIImage?             // do a search by URI to get the album art of the actual song - store it in secondary_image_url and give the user an option.
 
    //MARK: ViewDidload
    
    override func viewDidLoad() {
        super.viewDidLoad()
        my_table = table_view
        self.my_table?.delegate = self
        self.my_table?.dataSource = self
        
        
        //This view is added just to make sure that the last selectable cell stays above the stack view when the table is scrolled all the way up.
        let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 110))
        self.my_table?.tableFooterView = bottomView
        
        self.navigationItem.setHidesBackButton(true, animated:true);

        //Tap to select one of the search result cells
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        self.my_table?.addGestureRecognizer(tapGesture)
        tapGesture.delegate = my_table as? UIGestureRecognizerDelegate
        
        //Tap to select the currently playing song
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(tapEdit2(recognizer:)))
        self.now_playing_mini_image.addGestureRecognizer(tapGesture2)
        tapGesture2.delegate = self.now_playing_mini_image as? UIGestureRecognizerDelegate

        
        //Setup the button stack so that Now playing button is currently selected
        stack_leading.constant = 167.5
        stack_trailing.constant = -72.5
        button_array = [self.now_playing_button_outlet, self.apple_button_outlet, self.spotify_button_outlet, self.youtube_button_outlet]
        self.change_alpha(center_button: 0)
        
        //Setup serach controller
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Posts"
        searchController.searchBar.delegate = self as! UISearchBarDelegate
        searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchController.searchBar.isHidden = true
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        
        //Setup gradient and appearance stuff for table view and cancel button
        gradient.frame = (self.my_table?.bounds)!
        self.my_table?.layer.mask = gradient
        self.my_table?.separatorStyle = .none
        gradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.7, 1]
        gradient.delegate = self
        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
        
        //Add the keyboard dismiss gesture to the pane view
        let keyboard_dismiss_tap = UITapGestureRecognizer(target: self, action: #selector(UploadViewController2.dismiss_keyboard))
        self.pane_view_for_keyboard_dismiss.addGestureRecognizer(keyboard_dismiss_tap)
        self.pane_view_for_keyboard_dismiss.isHidden = true
        
        //We need this for the youtube search query calls
        service.apiKey = (userDefaults.value(forKey: "google_api_key") as! String)
        
        //Setup url view
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
        self.url_paste_view.tintColor = UIColor.black
        self.view.sendSubviewToBack(self.url_paste_container_view)
        
        
        //Setup now playing image
        self.now_playing_mini_image_container.layer.cornerRadius = 5
        self.now_playing_mini_image_container.layer.shadowColor = UIColor.black.cgColor
        self.now_playing_mini_image_container.layer.shadowOpacity = 1
        self.now_playing_mini_image_container.layer.shadowOffset = CGSize.zero
        self.now_playing_mini_image_container.layer.shadowRadius = 3
        self.now_playing_mini_image_container.layer.shadowPath = UIBezierPath(roundedRect: self.now_playing_mini_image_container.bounds, cornerRadius: 3).cgPath
        self.now_playing_mini_image.layer.cornerRadius = 5
        
        //Get the currently playing song from the poller
        //self.grab_and_load_now_playing()
        
        self.upload_flag = "now_playing"
        

        navigationItem.titleView = searchController.searchBar
        
        //Load recently played stuff in the table
        print("calling update_recently_played")
        self.update_recently_played()

        //setup header view for album  - apple recently played selection nonsense
        self.album_header_view.addSubview(album_header_image_view)
        self.album_header_view.addSubview(album_name_label_view)
        self.album_header_view.addSubview(album_artist_name_label_view)
        self.album_header_view.addSubview(album_artist_release_date_label_view)
        
    }
    
    
//    //This function gets song data for the currently playing song from the poller singleton and sets it up in the currently paying image view.
//    func grab_and_load_now_playing() {
//        if self.poller.something_is_playing {
//            print("poller is playing something")
//            if (self.userDefaults.string(forKey: "UserAccount") == "Apple") {
//                self.now_playing_mini_image.image = poller.return_image()
//                if let mediaItem = self.apple_system_player.nowPlayingItem {
//                    print ("\(mediaItem.playbackDuration)")
//                    self.now_playing_mini_image.isHidden = false
//                    self.now_playing_mini_image_container.isHidden = false
//                    self.apple_is_currently_playing = true
//                }
//            } else if (self.userDefaults.string(forKey: "UserAccount") == "Spotify") {
//                self.poller.grab_now_playing_item().done {
//                    self.now_playing_mini_image.image = self.poller.return_image()
//                }
//                self.temp_spotify_media_context_uri = self.poller.spotify_currently_playing_object.item?.uri
//                self.temp_spotify_media_context_duration = self.poller.spotify_currently_playing_object.item?.duration_ms
//                self.now_playing_mini_image.isHidden = false
//                self.now_playing_mini_image_container.isHidden = false
//                self.spotify_is_currently_playing = true
//            }
//        } else {
//            self.now_playing_mini_image.isHidden = true
//            self.now_playing_mini_image_container.isHidden = true
//            self.spotify_is_currently_playing = false
//        }
//
//    }
 
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    //Everytime the view appears, we need to grab the currently playing song and load it on the currently playing image
    override func viewWillAppear(_ animated: Bool) {
       // self.poller.grab_now_playing_item() //The poller singletion gets the currently playing song from apple/spotify
       // self.grab_and_load_now_playing()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func dismiss_chevron(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //When user taps on the now playing button - hide search bar, show the current song mini image, clear table and reload it with recently played stuff
    @IBAction func now_playing_button(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: [.curveEaseIn], animations: {
                        self.stack_leading.constant = 167.5
                        self.stack_trailing.constant = -72.5
                        self.change_alpha(center_button: 0)
                        self.view.layoutIfNeeded()
        }, completion: nil)
        self.upload_flag = "now_playing"
        show_or_hide_miniplayer()
        searchController.searchBar.isHidden = true
        self.my_table?.isHidden = false
        self.clear_tables()
        self.update_recently_played()
    }
    
    //When user taps on the apple button - setup search button, hide now playing image, etc.
    @IBAction func apple_upload_button(_ sender: Any) {
        self.appleMusicManager.performItunesCatalogSearchNew(with: "Why'd you push that button?", countryCode: "us")
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: [.curveEaseIn], animations: {
                        self.stack_leading.constant = 87.5
                        self.stack_trailing.constant = 7.5
                        self.change_alpha(center_button: 1)
                        self.view.layoutIfNeeded()
        }, completion: nil)
        searchController.searchBar.placeholder = "Search Apple Music"
        searchController.searchBar.isHidden = false
        self.upload_flag = "apple"
        self.clear_tables()
        self.my_table?.isHidden = false
        self.url_paste_container_view.isHidden = true
        self.view.sendSubviewToBack(self.url_paste_container_view)
        self.now_playing_mini_image.isHidden = true
        self.now_playing_mini_image_container.isHidden = true
        
    }
    
    //When user taps on the spotify button - setup search button, hide now playing image, etc.
    @IBAction func spotify_button(_ sender: Any) {
        self.appleMusicManager.performSpotifyCatalogSearch_users_top_music().done { searchResults in
            print ("performSpotifyCatalogSearch_users_top_music done")
            
            var top_tracks = [SpotifyTopTracksMediaObject.item]()
            
            
            top_tracks = searchResults
            print(" count from setterqueue \(searchResults.count)")
            
            for track in top_tracks {
                print(track.name)
                print(track.uri)
            }
            self.search_result_count = top_tracks.count ?? 0
           
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: [.curveEaseIn], animations: {
                        self.stack_leading.constant = 7.5
                        self.stack_trailing.constant = 87.5
//                        self.change_alpha(center_button: 2)
                        self.view.layoutIfNeeded()
        }, completion: nil )
        searchController.searchBar.placeholder = "Search Spotify"
        searchController.searchBar.isHidden = false
        self.upload_flag = "spotify"
        self.clear_tables()
        self.my_table?.isHidden = false
        self.url_paste_container_view.isHidden = true
        self.view.sendSubviewToBack(self.url_paste_container_view)
        self.now_playing_mini_image.isHidden = true
        self.now_playing_mini_image_container.isHidden = true
    }
    
    //When user taps on the spotify button - setup search button, hide now playing image, show url past container,  etc.
    @IBAction func youtube_button(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: [.curveEaseIn], animations: {
                        self.stack_leading.constant = -72.5
                        self.stack_trailing.constant = 167.5
                        self.change_alpha(center_button: 3)
                        self.view.layoutIfNeeded()
        }, completion: nil )
        self.upload_flag = "youtube"
        searchController.searchBar.placeholder = "Search Youtube"
        searchController.searchBar.isHidden = false
        self.clear_tables()
        self.my_table?.isHidden = false
        self.url_paste_container_view.isHidden = false
        self.view.bringSubviewToFront(self.url_paste_container_view)
        
       
        
        self.now_playing_mini_image.isHidden = true
        self.now_playing_mini_image_container.isHidden = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("text view did begin editing")
        if textView.textColor ==  UIColor.lightGray {
            textView.text = nil
           
        }

    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print ("text view did end")
        if textView.text.isEmpty {
            textView.textColor = UIColor.lightGray
            if self.upload_flag == "youtube" {
                textView.text = "URL"
            }
        }
        

    }

    //This function is executed when the user taps on the GO button for youtube search via link copy. We need to grab the video id from the url string and then get the youtube video object from YoutubeSearchQuery. When the query is completed, we call displayResultWithTicket2 - where the result is packed up in a Post format and then sent to UploadViewController3
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
                    print ("url_go_button_action - new kind of youtube url format !!!")
                }
                

                
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
                
                
                //Clean up before we leave UploadViewController2
                self.url_paste_view.endEditing(true)
                self.pane_view_for_keyboard_dismiss.isHidden = true
                self.url_paste_container_view.isHidden = true
                self.view.sendSubviewToBack(self.url_paste_container_view)
                self.searchController.searchBar.isHidden = true
                self.my_table?.isHidden = true
                self.searchController.view.endEditing(true)
                self.selected_cell = nil
                print ("gesture recognized")
        } else {
            print ("ERROR: Could not retrieve URL from ")
        }
    }
   
    
    //When one of the spotify/apple/youtube buttons are selected, we want the other buttons to become faint, this function handles that.
    func change_alpha (center_button: Int) {
        for i in 0...3 {
            if i == center_button {
                self.button_array![i].alpha = 1
            } else {
                self.button_array![i].alpha = 0.2
            }
        }
        
    }
 
    //Based on whether something is playing we show or hide the now playing image view.
    func show_or_hide_miniplayer() {
        
        if self.spotify_is_currently_playing || self.apple_is_currently_playing {
            self.now_playing_mini_image.isHidden = false
            self.now_playing_mini_image_container.isHidden = false
        } else {
            self.now_playing_mini_image.isHidden = true
            self.now_playing_mini_image_container.isHidden = true
        }
        
    }

    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    //we return the number of search results we get from the apple/spotify/youtube search functions.
    func numberOfSections(in tableView: UITableView) -> Int {
        print ("numberOfSections \(self.search_result_count)")
        print ("mediaItems.count is \(self.mediaItems.count)")
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
        } else if upload_flag == "now_playing" {
            if self.userDefaults.string(forKey: "UserAccount") == "Spotify" {
                print ("section \(section)")
                if spotify_recently_played_mediaItems.count != 0 {
                    return spotify_recently_played_mediaItems[section].count
                } else {
                    return 0
                }
            } else if self.userDefaults.string(forKey: "UserAccount") == "Apple" {
                print("UserAccount is Apple")
                print ("section \(section)")
                if mediaItems.count != 0 {
                    print("\(mediaItems[section].count) is the count")
                    return mediaItems[section].count
                } else {
                    return 0
                }
            } else {
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
                    if self.upload_flag == "now_playing" {
                        return NSLocalizedString("Recently Played", comment: "Recently Played")
                    } else {
                        return NSLocalizedString("Songs", comment: "Songs")
                    }
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
        print("dequeue tableview")
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
            } else if self.upload_flag == "now_playing" {
                print("dequeue now playing")
                if self.userDefaults.string(forKey: "UserAccount") == "Spotify" {
                    print ("dequeue was called")
                    print(indexPath.section)
                    print(indexPath.row)
                    
                    let isIndexValid1 = spotify_recently_played_mediaItems.indices.contains(indexPath.section)
                    let isIndexValid2 = spotify_recently_played_mediaItems[indexPath.section].indices.contains(indexPath.row)
                    if (isIndexValid1 && isIndexValid2) {
                        let spotify_recently_played_mediaItem = spotify_recently_played_mediaItems[indexPath.section][indexPath.row]
                        
                        cell.spotify_recently_played_mediaItem = spotify_recently_played_mediaItems[indexPath.section][indexPath.row]
                        
                        
                        // Image loading.
                        if spotify_recently_played_mediaItem.track?.album?.images?.count != 0 {
                            print ("hurdle one")
                            imageURL = URL(string: "\(spotify_recently_played_mediaItem.track?.album?.images?[0].url ?? "" )")
                            print (spotify_recently_played_mediaItem.track?.album?.images?[0].url)
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
                                    if (cell.spotify_recently_played_mediaItem.track?.uri ?? "") == spotify_recently_played_mediaItem.track?.uri {
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
                } else if self.userDefaults.string(forKey: "UserAccount") == "Apple" {
                    
                    print ("dequeue was called")
                    print(indexPath.section)
                    print(indexPath.row)
                    print(search_result_count)
                    print(mediaItems.count)
                    let mediaItem = mediaItems[indexPath.section][indexPath.row]
                    
                    let isIndexValid1 = mediaItems.indices.contains(indexPath.section)
                    let isIndexValid2 = mediaItems[indexPath.section].indices.contains(indexPath.row)
                    if (isIndexValid1 && isIndexValid2) {
                        
                        cell.mediaItem = mediaItem
                        print(cell.mediaItem.type)
                        
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
                }
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

    
    
    //Select a search result
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.my_table)
            if let tapIndexPath = self.my_table?.indexPathForRow(at: tapLocation) {
                
                self.clean_cached_cell()
                
                //If we are on the now_playing page and the user is a Apple user and the user selected one of the recently played items, we need to go to UploadViewControllerAlbumDisplay. Apple does this weird thing where all the recently played items are albums - it doesn't give us individual tracks. So we need to to this controller where we list out the whole album, the user selects the album and then we move on to UploadViewController3
                if self.upload_flag == "now_playing" && self.userDefaults.string(forKey: "UserAccount") == "Apple" {
                    if let tappedCell = self.my_table?.cellForRow(at: tapIndexPath) as? SearchResultCell {
                        print(tappedCell.mediaItem.type)
                        if tappedCell.mediaItem.type.rawValue == "albums" {
                            self.selected_album_media_item = tappedCell.mediaItem
                            performSegue(withIdentifier: "2_to_album_display", sender: self)
                        }
                    }
                } else {
                    self.cache_selected_cell(at: tapIndexPath)
                    self.upload_flag = (self.userDefaults.string(forKey: "UserAccount")?.lowercased())!
                    self.performSegue(withIdentifier: "upload_2_to_3", sender: self)
                }
            }
        }
    }
    

    
    @objc func end_album_header () {
        print("end album header")
        self.navigationItem.leftBarButtonItem = nil
        self.my_table?.tableHeaderView = nil
        self.update_recently_played()
        self.my_table?.scrollToRow(at: [0,0], at: UITableView.ScrollPosition.top, animated: true)
    }
    
    
    
    /*This function is called when the user taps on one of the search result cells. It then packs all the song data into internal structures that are passed to the next view controller.
        For apple and spotify posts - we pass - selected_search_result_post_image, selected_search_result_song_db_struct and selected_search_result_post
        For Youtube we pass - selected_search_result_post
 
 
    */
    func cache_selected_cell(at indexPath: IndexPath) {
        
        if let upload_cell = self.my_table?.cellForRow(at: indexPath) as? SearchResultCell, self.upload_flag != "youtube" {
            print(" != youtube")
            switch self.upload_flag {
            case "spotify" :
              
                self.selected_search_result_post_image = upload_cell.media_image.image
                self.selected_search_result_song_db_struct.album_name = upload_cell.spotify_mediaItem.album?.name
                self.selected_search_result_song_db_struct.artist_name = upload_cell.spotify_mediaItem.artists?[0].name
                self.selected_search_result_song_db_struct.isrc_number = upload_cell.spotify_mediaItem.external_ids?.isrc
                self.selected_search_result_song_db_struct.playable_id = upload_cell.spotify_mediaItem.uri
                self.selected_search_result_song_db_struct.preview_url = upload_cell.spotify_mediaItem.preview_url
                self.selected_search_result_song_db_struct.release_date = upload_cell.spotify_mediaItem.album?.release_date
                self.selected_search_result_song_db_struct.song_name = upload_cell.spotify_mediaItem.name
               
            self.selected_search_result_post = Post(albumArtImage:  "",
                                          sourceAppImage:  "Spotify_cropped",
                                          typeImage: "icons8-musical-notes-50" ,
                                          profileImage:  "FullSizeRender 10-2" ,
                                          username: "Viraj",
                                          timeAgo: "Just now",
                                          numberoflikes: "0 likes",
                                          caption: "",
                                          offset: 0.0,
                                          startoffset: 0.0, //<- Apple does not allow starting from a particular point. No workaround so far :( We keep this for spotify users playing apple posts - we give this value as 0.0 in update_apple in newsfeed controller.
                                          audiolength: 30.0 ,
                                          paused: false,
                                          playing: false,
                                          trackid: upload_cell.spotify_mediaItem.uri,
                                          helper_id: "",
                                          helper_preview_url: "",
                                          videoid: "empty",
                                          starttime: 0 ,
                                          endtime: 0,
                                          flag: "audio",
                                          lyrictext: "",
                                          songname: upload_cell.spotify_mediaItem.name,
                                          artistName: upload_cell.spotify_mediaItem.artists?[0].name,
                                          sourceapp: self.upload_flag,
                                          preview_url: (upload_cell.spotify_mediaItem.preview_url) ?? "nil",
                                          albumArtUrl: upload_cell.spotify_mediaItem.album?.images![0].url,
                                          original_track_length: upload_cell.spotify_mediaItem!.duration_ms!,
                                          GIF_url: "")
                    
            case "apple":
                print (" case apple ")
                self.selected_search_result_post_image = upload_cell.media_image.image
                self.selected_search_result_song_db_struct.album_name = upload_cell.mediaItem.albumName
                self.selected_search_result_song_db_struct.artist_name = upload_cell.mediaItem.artistName
                self.selected_search_result_song_db_struct.isrc_number = upload_cell.mediaItem.isrc
                self.selected_search_result_song_db_struct.playable_id = upload_cell.mediaItem.identifier
                self.selected_search_result_song_db_struct.preview_url = upload_cell.mediaItem.previews[0]["url"] ?? ""
                self.selected_search_result_song_db_struct.release_date = upload_cell.mediaItem.releaseDate
                self.selected_search_result_song_db_struct.song_name = upload_cell.mediaItem.name
              
                    self.selected_search_result_post = Post(albumArtImage:  "",
                                          sourceAppImage:  "apple_logo",
                                          typeImage: "icons8-musical-notes-50" ,
                                          profileImage:  "FullSizeRender 10-2" ,
                                          username: "Viraj",
                                          timeAgo: "Just now",
                                          numberoflikes: "0 likes",
                                          caption: "",
                                          offset: 0.0,
                                          startoffset: 0.0,
                                          audiolength: 30.0, //<- This has to be grabbed from user - provide physical slider
                                          paused: false,
                                          playing: false,
                                          trackid: upload_cell.mediaItem.identifier,
                                          helper_id: "",
                                          helper_preview_url: "",
                                          videoid: "empty",
                                          starttime: 0 ,
                                          endtime: 0,
                                          flag: "audio",
                                          lyrictext: "",
                                          songname: upload_cell.mediaItem.name,
                                          artistName: upload_cell.mediaItem.artistName,
                                          sourceapp: self.upload_flag,
                                          preview_url: upload_cell.mediaItem.previews[0]["url"] ?? "",
                                          albumArtUrl: upload_cell.mediaItem.artwork.imageURL(size: CGSize(width: 375, height: 375)).absoluteString,
                                          original_track_length: upload_cell.mediaItem.durationInMillis!,
                                          GIF_url: "" )
                
            case "now_playing":
                
                //this is for recently played only
                self.selected_search_result_post_image = upload_cell.media_image.image
                self.selected_search_result_song_db_struct.album_name = upload_cell.spotify_recently_played_mediaItem.track?.album?.name
                self.selected_search_result_song_db_struct.artist_name = upload_cell.spotify_recently_played_mediaItem.track?.artists?[0].name
                self.selected_search_result_song_db_struct.isrc_number = upload_cell.spotify_recently_played_mediaItem.track?.external_ids?.isrc
                self.selected_search_result_song_db_struct.playable_id = upload_cell.spotify_recently_played_mediaItem.track?.uri
                self.selected_search_result_song_db_struct.preview_url = upload_cell.spotify_recently_played_mediaItem.track?.preview_url
                self.selected_search_result_song_db_struct.release_date = upload_cell.spotify_recently_played_mediaItem.track?.album?.release_date
                self.selected_search_result_song_db_struct.song_name = upload_cell.spotify_recently_played_mediaItem.track?.name
                
                self.selected_search_result_post = Post(albumArtImage:  "",
                                                        sourceAppImage:  "Spotify_cropped",
                                                        typeImage: "icons8-musical-notes-50" ,
                                                        profileImage:  "FullSizeRender 10-2" ,
                                                        username: "Viraj",
                                                        timeAgo: "Just now",
                                                        numberoflikes: "0 likes",
                                                        caption: "",
                                                        offset: 0.0,
                                                        startoffset: 0.0, //<- Apple does not allow starting from a particular point. No workaround so far :( We keep this for spotify users playing apple posts - we give this value as 0.0 in update_apple in newsfeed controller.
                                                        audiolength: 30.0 ,
                                                        paused: false,
                                                        playing: false,
                                                        trackid: upload_cell.spotify_recently_played_mediaItem.track?.uri,
                                                        helper_id: "",
                                                        helper_preview_url: "",
                                                        videoid: "empty",
                                                        starttime: 0 ,
                                                        endtime: 0,
                                                        flag: "audio",
                                                        lyrictext: "",
                                                        songname: upload_cell.spotify_recently_played_mediaItem.track?.name,
                                                        artistName: upload_cell.spotify_mediaItem.artists?[0].name,
                                                        sourceapp: self.upload_flag,
                                                        preview_url: (upload_cell.spotify_recently_played_mediaItem.track?.preview_url) ?? "nil",
                                                        albumArtUrl: upload_cell.spotify_recently_played_mediaItem.track?.album?.images![0].url,
                                                        original_track_length: (upload_cell.spotify_recently_played_mediaItem.track?.duration_ms!)!,
                                                        GIF_url: "" )
                
            default:   //now_playing - do we need 'default' case? it's going to be apple/spotify anyway.
                print ("default")
                
                self.selected_search_result_post = Post(albumArtImage:  "",
                                      sourceAppImage:  "Spotify_cropped",
                                      typeImage: "icons8-musical-notes-50" ,
                                      profileImage:  "FullSizeRender 10-2" ,
                                      username: "Viraj",
                                      timeAgo: "Just now",
                                      numberoflikes: "0 likes",
                                      caption: "",
                                      offset: 0.0,
                                      startoffset: 0.0,
                                      audiolength: 30.0 ,
                                      paused: false,
                                      playing: false,
                                      trackid: "",
                                      helper_id: "",
                                      helper_preview_url: "",
                                      videoid: "empty",
                                      starttime: 0 ,
                                      endtime: 0,
                                      flag: "audio",
                                      lyrictext: "",
                                      songname: "",
                                      artistName: "",
                                      sourceapp: "",
                                      preview_url: "",
                                      albumArtUrl: "",
                                      original_track_length: 0,
                                      GIF_url: "")
    
            }
            
        } else if let upload_cell = self.my_table?.cellForRow(at: indexPath) as? SearchResultCell_youtube, self.upload_flag == "youtube" {
            print ("youtube")
            self.selected_search_result_post = Post(albumArtImage:  "",
                                  sourceAppImage:  "Youtube_cropped",
                                  typeImage: "video" ,
                                  profileImage:  "FullSizeRender 10-2" ,
                                  username: "Viraj",
                                  timeAgo: "Just now",
                                  numberoflikes: "0 likes",
                                  caption: "",
                                  offset: 0.0,
                                  startoffset: 0.0,
                                  audiolength: 30.0 ,
                                  paused: false,
                                  playing: false,
                                  trackid: "",
                                  helper_id: "",
                                  helper_preview_url: "",
                                  videoid: upload_cell.youtube_video_resource.identifier?.videoId,
                                  starttime: 0 ,
                                  endtime: 0,
                                  flag: "video",
                                  lyrictext: "",
                                  songname: upload_cell.youtube_video_resource.snippet?.title,
                                  artistName: "",
                                  sourceapp: self.upload_flag,
                                  preview_url: "",
                                  albumArtUrl: upload_cell.youtube_video_resource.snippet?.thumbnails?.high?.url,
                                  original_track_length: parse_youtube_track_audio(duration_string: self.search_result_video.contentDetails?.duration ?? "PT0M0S"),
                                  GIF_url: "")
            
            
        } else {
            print("Somehting weird is going on - upload flag is not set to any of the expected values")
            fatalError()
        }
        
    }
    
    func clean_cached_cell() {
        
        print ("Cleaning cache")
        self.selected_search_result_post = Post(albumArtImage:  "",
                                                sourceAppImage:  "Spotify_cropped",
                                                typeImage: "icons8-musical-notes-50" ,
                                                profileImage:  "FullSizeRender 10-2" ,
                                                username: "Viraj",
                                                timeAgo: "Just now",
                                                numberoflikes: "0 likes",
                                                caption: "",
                                                offset: 0.0,
                                                startoffset: 0.0,
                                                audiolength: 30.0 ,
                                                paused: false,
                                                playing: false,
                                                trackid: "",
                                                helper_id: "",
                                                helper_preview_url: "",
                                                videoid: "empty",
                                                starttime: 0 ,
                                                endtime: 0,
                                                flag: "audio",
                                                lyrictext: "",
                                                songname: "",
                                                sourceapp: "",
                                                preview_url: "",
                                                albumArtUrl: "",
                                                original_track_length: 0,
                                                GIF_url: "")
        
    }
    
    //this is triggered when the user taps on the now playing image. So when the user wants to upload the currently playing song. We package the song data into the internal structures and then send it to the next viewcontroller.
     @objc func tapEdit2(recognizer: UITapGestureRecognizer)  {
//        print ("tapEdit2 called ")
//
//
//        self.now_playing_mini_image.isHidden = true
//        self.now_playing_mini_image_container.isHidden = true
//
//         if (self.userDefaults.string(forKey: "UserAccount") == "Spotify") {
//        self.selected_search_result_post_image = self.poller.return_image()
//        self.selected_search_result_song_db_struct.album_name = self.poller.spotify_currently_playing_object.item?.album?.name
//        self.selected_search_result_song_db_struct.artist_name = self.poller.spotify_currently_playing_object.item?.artists?[0].name
//        self.selected_search_result_song_db_struct.isrc_number = self.poller.spotify_currently_playing_object.item?.external_ids?.isrc
//        self.selected_search_result_song_db_struct.playable_id = self.poller.spotify_currently_playing_object.item?.uri
//        self.selected_search_result_song_db_struct.preview_url = self.poller.spotify_currently_playing_object.item?.preview_url
//        self.selected_search_result_song_db_struct.release_date = self.poller.spotify_currently_playing_object.item?.album?.release_date
//        self.selected_search_result_song_db_struct.song_name = self.poller.spotify_currently_playing_object.item?.name
//
//        self.selected_search_result_post = Post(albumArtImage:  "",
//                                                sourceAppImage:  "Spotify_cropped",
//                                                typeImage: "icons8-musical-notes-50" ,
//                                                profileImage:  "FullSizeRender 10-2" ,
//                                                username: "Viraj",
//                                                timeAgo: "Just now",
//                                                numberoflikes: "0 likes",
//                                                caption: "",
//                                                offset: 0.0,
//                                                startoffset: 0.0, //<- Apple does not allow starting from a particular point. No workaround so far :( We keep this for spotify users playing apple posts - we give this value as 0.0 in update_apple in newsfeed controller.
//                                                audiolength: 30.0 ,
//                                                paused: false,
//                                                playing: false,
//                                                trackid: self.poller.spotify_currently_playing_object.item?.uri,
//                                                helper_id: "",
//                                                helper_preview_url: "",
//                                                videoid: "empty",
//                                                starttime: 0 ,
//                                                endtime: 0,
//                                                flag: "audio",
//                                                lyrictext: "",
//                                                songname: self.poller.spotify_currently_playing_object.item?.name,
//                                                sourceapp: self.upload_flag,
//                                                preview_url: (self.poller.spotify_currently_playing_object.item?.preview_url) ?? "nil",
//                                                albumArtUrl: self.poller.spotify_currently_playing_object.item?.album?.images![0].url,
//                                                original_track_length: (self.temp_spotify_media_context_duration!),
//                                                GIF_url: "" )
//
//            self.duration = (self.temp_spotify_media_context_duration!) / 1000
//            self.duration_for_number_of_cells = Int(ceil(Double(self.temp_spotify_media_context_duration!) / 1000))
//
//         } else if (self.userDefaults.string(forKey: "UserAccount") == "Apple") {
//
//            self.selected_search_result_post_image = self.poller.return_image()
//            self.selected_search_result_song_db_struct.album_name = self.poller.apple_mediaItems[0][0].albumName
//            self.selected_search_result_song_db_struct.artist_name = self.poller.apple_mediaItems[0][0].artistName
//            self.selected_search_result_song_db_struct.isrc_number = self.poller.apple_mediaItems[0][0].isrc
//            self.selected_search_result_song_db_struct.playable_id = self.poller.apple_mediaItems[0][0].identifier
//            self.selected_search_result_song_db_struct.preview_url = self.poller.apple_mediaItems[0][0].url
//            self.selected_search_result_song_db_struct.release_date = self.poller.apple_mediaItems[0][0].releaseDate
//            self.selected_search_result_song_db_struct.song_name = self.poller.apple_mediaItems[0][0].name
//
//            self.selected_search_result_post = Post(albumArtImage:  "",
//                                                    sourceAppImage:  "Spotify_cropped",
//                                                    typeImage: "icons8-musical-notes-50" ,
//                                                    profileImage:  "FullSizeRender 10-2" ,
//                                                    username: "Viraj",
//                                                    timeAgo: "Just now",
//                                                    numberoflikes: "0 likes",
//                                                    caption: "",
//                                                    offset: 0.0,
//                                                    startoffset: 0.0, //<- Apple does not allow starting from a particular point. No workaround so far :( We keep this for spotify users playing apple posts - we give this value as 0.0 in update_apple in newsfeed controller.
//                                                    audiolength: 30.0 ,
//                                                    paused: false,
//                                                    playing: false,
//                                                    trackid: self.poller.apple_mediaItems[0][0].identifier,
//                                                    helper_id: "",
//                                                    helper_preview_url: "",
//                                                    videoid: "empty",
//                                                    starttime: 0 ,
//                                                    endtime: 0,
//                                                    flag: "audio",
//                                                    lyrictext: "",
//                                                    songname: self.poller.apple_mediaItems[0][0].name,
//                                                    sourceapp: self.upload_flag,
//                                                    preview_url: (self.poller.apple_mediaItems[0][0].url) ?? "nil",
//                                                    albumArtUrl: self.poller.apple_mediaItems[0][0].artwork.imageURL(size: CGSize(width: 375, height: 375)).absoluteString,
//                                                    original_track_length: (self.poller.apple_mediaItems[0][0].durationInMillis!),
//                                                    GIF_url: "" )
//
//            self.duration = (self.poller.apple_mediaItems[0][0].durationInMillis!) / 1000
//            self.duration_for_number_of_cells = Int(ceil(Double(self.poller.apple_mediaItems[0][0].durationInMillis!) / 1000))
//
//            print ("duration we're going for now playing \(self.duration)")
//            print("duration_for_number_of_cells \(self.duration_for_number_of_cells)")
//
//
//        }
        
            self.performSegue(withIdentifier: "upload_2_to_3", sender: self)
    }
    
    //This is a search by video id query. Called when the user copies the video URL and taps GO.
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
           
            self.duration = video_duration
            self.duration_for_number_of_cells = video_duration
          
            print (video_duration)
            self.search_result_video = video
            
            self.selected_search_result_post = Post(albumArtImage:  "",
                                                    sourceAppImage:  "Youtube_cropped",
                                                    typeImage: "video" ,
                                                    profileImage:  "FullSizeRender 10-2" ,
                                                    username: "Viraj",
                                                    timeAgo: "Just now",
                                                    numberoflikes: "0 likes",
                                                    caption: "",
                                                    offset: 0.0,
                                                    startoffset: 0.0,
                                                    audiolength: 30.0 ,
                                                    paused: false,
                                                    playing: false,
                                                    trackid: "",
                                                    helper_id: "",
                                                    helper_preview_url: "",
                                                    videoid: video.identifier,
                                                    starttime: 0 ,
                                                    endtime: 0,
                                                    flag: "video",
                                                    lyrictext: "",
                                                    songname: video.snippet?.title,
                                                    sourceapp: self.upload_flag,
                                                    preview_url: "",
                                                    albumArtUrl: video.snippet?.thumbnails?.high?.url,
                                                    original_track_length: parse_youtube_track_audio(duration_string: video.contentDetails?.duration ?? "PT0M0S"),
                                                    GIF_url: "")
            
             self.performSegue(withIdentifier: "upload_2_to_3", sender: self)
            
            
        } else {
            print ("Request for specific video returned empty")
        }
        
        
        
    }
    
  //Pass the packaged selected song/youtube video to the next controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print ("prepare for segue")
        if segue.identifier == "upload_2_to_3" {
            let destinationVC = segue.destination as! UploadViewController3
            destinationVC.flow = self.flow
            destinationVC.selected_search_result_post = self.selected_search_result_post
            destinationVC.selected_search_result_song_db_struct = self.selected_search_result_song_db_struct
            destinationVC.upload_flag = self.upload_flag
            destinationVC.duration = self.duration
            destinationVC.duration_for_number_of_cells = self.duration_for_number_of_cells
            destinationVC.selected_search_result_post_image = self.selected_search_result_post_image
            destinationVC.uploading = true
            definesPresentationContext = false
        } else if segue.identifier == "2_to_album_display" {
            let destinationVC = segue.destination as! UploadViewControllerAlbumDisplay
            destinationVC.flow = self.flow
            destinationVC.albumMediaItem = self.selected_album_media_item
        }
    }
    
    
    //The youtube video duration in the search query result is given in this format PT15M51S. This funtion parses that out into seconds.
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
    
    
    func update_recently_played () {
        print("update_recently_played")
        print (self.userDefaults.string(forKey: "UserAccount"))
        if self.userDefaults.string(forKey: "UserAccount") == "Spotify" {
            appleMusicManager.performSpotifyRecentlyPlayedSearch().done { searchResults in
                print ("performSpotifyRecentlyPlayedSearch done")
                self.setterQueue.sync {
                    self.spotify_recently_played_mediaItems = []
                }
                self.setterQueue.sync {
                    self.spotify_recently_played_mediaItems = [searchResults]
                    print(" count from setterqueue \(searchResults.count)")
                                                                
                    self.search_result_count = self.spotify_recently_played_mediaItems.count ?? 0
                }
            
                return
            }
        } else if self.userDefaults.string(forKey: "UserAccount") == "Apple" {
            print("apple recently_played_search")
            let token = UserDefaults.standard.string(forKey: AppleMusicControl.userTokenUserDefaultsKey)
            print (token)
            appleMusicManager.performAppleMusicGetRecentlyPlayed(userToken: token!, completion: { [weak self] (searchResults, error) in
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
                                                                    print(searchResults)
                                                                    self?.search_result_count = self?.mediaItems.count ?? 0
                                                                    self?.mediaItems = [searchResults]
                                                                    print(searchResults.count)
                                                                    print ("media items count \(self?.mediaItems.count) ")
                                                                }
                return
            })
        }
    }
    
    
}
    

extension UploadViewController2: UISearchResultsUpdating  {


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
                                                                        self?.mediaItems = [searchResults]
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
        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        
        post_dict.updateValue(new_post.albumArtImage, forKey: "albumArtImage")
        post_dict.updateValue(new_post.audiolength, forKey: "audiolength")
        post_dict.updateValue(new_post.caption, forKey: "caption")
        post_dict.updateValue(new_post.endtime, forKey: "endtime")
        post_dict.updateValue(new_post.flag, forKey: "flag")
        post_dict.updateValue(new_post.trackid, forKey: "trackid")
        post_dict.updateValue(new_post.helper_id, forKey: "helper_id")
        post_dict.updateValue(new_post.helper_preview_url, forKey: "helper_preview_url")
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
        post_dict.updateValue(new_post.GIF_url, forKey: "GIF_url")
        
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
    

}


//MARK: SearchBar Delegate

extension UploadViewController2: UISearchBarDelegate {
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

                self.pane_view_for_keyboard_dismiss.isHidden = false
                //self.view.bringSubview(toFront: self.pane_view_for_keyboard_dismiss)
                self.url_paste_container_view.isHidden = true
                self.view.sendSubviewToBack(self.url_paste_container_view)
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
     
                //empty all tables
                setterQueue.sync {
                    self.mediaItems = []
                    self.spotify_mediaItems = []
                    self.video_search_results = []
                }
        
                //dismiss the keyboard dismiss panel
                self.pane_view_for_keyboard_dismiss.isHidden = true
                if self.upload_flag == "youtube" {
                    //bring back the url paste view
                    self.url_paste_container_view.isHidden = false
                    self.view.bringSubviewToFront(self.url_paste_container_view)
                }
                
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
                                                                            self?.mediaItems = [searchResults]
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
    
    
    //this function gives us a list of video search results for the search string entered.
    @objc func displayResultWithTicket4(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRYouTube_SearchListResponse,
        error : NSError?) {
        print("displayResultWithTicket4")
        
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
                print ("In displayResultWithTicket4 search_result_count is \(search_result_count)")
                self.search_result_count = search_result_videos.count ?? 0
            }
        }
        
    }

}


