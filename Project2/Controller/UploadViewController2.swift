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


class upload_path_keeper {
    
    
    static let shared = upload_path_keeper()
    var new_post_selected = false
    var upload_path = "none"
    var keeper_post: Post = Post(albumArtImage: "" , sourceAppImage: "", typeImage: "" , profileImage: "" , username: "" ,timeAgo: "", numberoflikes: "" ,caption:"", offset: 0.0, startoffset: 0.0, audiolength: 0.0, paused: false, playing: true, trackid: "", helper_id: "", videoid: "", starttime: 0.0 , endtime: 0.0, flag: "", lyrictext: "", songname: "", sourceapp: "", preview_url: "", albumArtUrl: "", original_track_length: 0, GIF_url: "")
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


class UploadViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource, CALayerDelegate, UIScrollViewDelegate, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, UITextViewDelegate, YTPlayerViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, SwiftyGiphyGridLayoutDelegate {
    
    var flow = "default_upload"
    /*
        default_upload_flow
        hero_upload_flow
        omm_upload_flow
    */
    let kSwiftyGiphyCollectionViewCell = "SwiftyGiphyCollectionViewCell"
    var allowResultPaging: Bool = true
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var selected_GIF_view: FLAnimatedImageView!
    @IBOutlet weak var mycollectionview2: UICollectionView!
    //let mycollectionview2: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SwiftyGiphyGridLayout())
    @IBOutlet weak var Text_or_animation_switch_top_to_express_view: NSLayoutConstraint!
    @IBOutlet weak var GIF_SearchBar_top_to_express_view: NSLayoutConstraint!
    @IBOutlet weak var GIF_SearchBar: UISearchBar!
    @IBOutlet weak var upload_done: UIButton!
    @IBOutlet weak var lyric_view: UITextView!
    
    @IBOutlet weak var caption_text_view: UITextView!
    @IBOutlet weak var caption_view_bottom_constraint_to_express_view: NSLayoutConstraint!
    
    //var currently_active_collection_view: UICollectionView
    var is_selecting_animation: Bool = false
    var is_selecting_audio_clip: Bool = false
    @IBOutlet weak var text_or_animation_switch: UIButton!
    var GIF_Search_is_ON: Bool = false
    @IBOutlet weak var express_view: UIView!
    @IBOutlet weak var express_view_to_search_bar_super_container: NSLayoutConstraint!
    @IBOutlet weak var album_art_or_lyric_switch: UIButton!
    @IBOutlet weak var select_audio_clip_button: UIButton!
    @IBOutlet weak var express_button: UIButton!
    @IBOutlet weak var song_name_label: UILabel!
    @IBOutlet weak var time_label: UILabel!
    @IBOutlet weak var artist_name_label: UILabel!
    @IBOutlet weak var now_playing_mini_image_container: UIView!
    @IBOutlet weak var now_playing_mini_image: UIImageView!
    var poller = now_playing_poller.shared
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
    
    @IBOutlet weak var dismiss_chevron_bottom_constraint: NSLayoutConstraint!
    @IBOutlet weak var selector_stack_bottom_constraint: NSLayoutConstraint!
    @IBOutlet weak var dismiss_chevron_button: UIButton!
    @IBOutlet weak var youtube_player: YTPlayerView!
    @IBOutlet weak var now_playing_image: UIImageView!
    @IBOutlet weak var now_playing_progress_bar: UIProgressView!

    
    @IBOutlet weak var search_bar_container: UIView!
    
    @IBOutlet weak var search_bar_subview: UIView!
    //let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var back_button: UIButton!
    
    @IBOutlet weak var custom_progress_bar_slider: UIView!
    @IBOutlet weak var slider_width: NSLayoutConstraint!
    @IBOutlet weak var slider_leading_constraint: NSLayoutConstraint!
    @IBOutlet weak var color_animate_trailing: NSLayoutConstraint!
    @IBOutlet weak var custom_progress_bar_bar: UIView!
    @IBOutlet weak var custom_progress_bar_container: UIView!
    @IBOutlet weak var collection_view_for_scroll: UICollectionView!
    @IBOutlet weak var color_animate_view: UIView!
    @IBOutlet weak var Selection_view: UIView!
//    @IBOutlet weak var test_slider: UISlider!
//    @IBOutlet weak var audio_scrubber_ot: UISlider!
    var spotifyplayer =  SPTAudioStreamingController.sharedInstance()
    var apple_player = MPMusicPlayerController.applicationMusicPlayer
    var apple_system_player = MPMusicPlayerController.systemMusicPlayer
    var spotify_current_uri: String?
    var apple_id: String?
    var yt_id: String?
    var scroller_timer = Timer()
    
    var my_table: UITableView?
    var search_result_count: Int = 0
    @IBOutlet weak var table_view: UITableView!
    var button_array: [UIButton]?
    var selected_cell: IndexPath?
    var lyrics = false
    let userDefaults = UserDefaults.standard
    var spotify_is_currently_playing : Bool = false
    var apple_is_currently_playing: Bool = false
    var temp_spotify_media_context_uri: String?
    var temp_spotify_media_context_duration: Int?
    var duration: Int = 0
    var duration_for_number_of_cells: Int = 0
    var uploading = false
    var search_result_video = GTLRYouTube_Video()
    var selected_GIF_url: URL!
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
    
    var video_search_results = [GTLRYouTube_SearchResult]() {
        didSet {
            DispatchQueue.main.async {
                //print ("reloading")
                self.my_table?.reloadData()
            }
        }
    }
    private let service = GTLRYouTubeService()
    
    
    var mediaItems = [[MediaItem]]() {
        didSet {
            DispatchQueue.main.async {
                print ("reloading")
                self.search_result_count = self.mediaItems.count ?? 0
                self.my_table?.reloadData()
            }
        }
    }
    
    var spotify_mediaItems = [[SpotifyMediaObject.item]]() {
        didSet {
            DispatchQueue.main.async {
                //print ("reloading")
                self.my_table?.reloadData()
            }
        }
    }
    
    var spotify_recently_played_mediaItems = [[SpotifyRecentlyPlayedMediaObject.item]] () {
        didSet {
            print ("spotify_recently_played_mediaItems didSet")
            DispatchQueue.main.async {
                //print ("reloading")
                self.my_table?.reloadData()
            }
        }
    }
    
    //MARK: GIPHY Variables
    var currentGifs: [GiphyItem]? {
        didSet {
            print("currentGIFS did Set")
            mycollectionview2.reloadData()
        }
    }
    
    var mycollectionViewLayout: SwiftyGiphyGridLayout? {
        get {
            print ("mycollectionViewLayout get")
            return mycollectionview2.collectionViewLayout as? SwiftyGiphyGridLayout
        }
    }
    
    var currentSearchPageOffset: Int = 0
    var searchCounter: Int = 0
    var isSearchPageLoadInProgress: Bool = false
    var contentRating: SwiftyGiphyAPIContentRating = .pg13
    var combinedTrendingGifs: [GiphyItem] = [GiphyItem]()
    var combinedSearchGifs: [GiphyItem] = [GiphyItem]()
    fileprivate var searchCoalesceTimer: Timer? {
        willSet {
            if searchCoalesceTimer?.isValid == true
            {
                searchCoalesceTimer?.invalidate()
            }
        }
    }
    var maxSizeInBytes: Int = 2048000
    var latestSearchResponse: GiphyMultipleGIFResponse?
    
    let imageCacheManager = ImageCacheManager()
    let appleMusicManager = AppleMusicManager()
    var setterQueue = DispatchQueue(label: "UploadViewController2")
    var upload_flag = "default"
    let gradient = CAGradientLayer()
    var post_help = Post_helper()             //This is required because sometimes in spotify if the song is part of a compilation - made by a user
    var secondary_image_url: URL?             //- then it picks up the album art for that compilation instead of the actual album art. So we
    var secondary_image: UIImage?             // do a search by URI to get the album art of the actual song - store it in secondary_image_url and give the user an option.
    var tapGesture_test_lyric_view: UITapGestureRecognizer!
    var tapGesture_test_caption_view: UITapGestureRecognizer!
    
    func hide_custom_scrolling_aparattus_toggle (set: Bool) {
        if set {
            self.custom_progress_bar_container.isHidden = true
            self.collection_view_for_scroll.isHidden = true
            self.collection_view_for_scroll.isUserInteractionEnabled = false
            self.collection_view_for_scroll.isScrollEnabled = false
            self.Selection_view.isHidden = true
            self.color_animate_view.isHidden = true
            self.time_label.isHidden = true
            
        } else {
            self.custom_progress_bar_container.isHidden = false
            self.collection_view_for_scroll.isHidden = false
            self.collection_view_for_scroll.isUserInteractionEnabled = true
            self.collection_view_for_scroll.isScrollEnabled = true
            self.Selection_view.isHidden = false
            self.color_animate_view.isHidden = false
            self.time_label.isHidden = false
          
            
        }
    }
    
    //MARK: ViewDidload
    
    override func viewDidLoad() {
        super.viewDidLoad()
        my_table = table_view
        self.my_table?.delegate = self
        self.my_table?.dataSource = self
        //self.my_table?.isHidden = true
        
        let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 110))
        self.my_table?.tableFooterView = bottomView
        self.back_button.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated:true);

        hide_custom_scrolling_aparattus_toggle(set : true)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        self.my_table?.addGestureRecognizer(tapGesture)
        tapGesture.delegate = my_table as? UIGestureRecognizerDelegate
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(scrub(recognizer:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(tapEdit2(recognizer:)))
        self.now_playing_mini_image.addGestureRecognizer(tapGesture2)
        tapGesture2.delegate = self.now_playing_mini_image as? UIGestureRecognizerDelegate
        
        tapGesture_test_lyric_view = UITapGestureRecognizer(target: self, action: #selector(tapEdit_test_for_lyric_view(recognizer:)))
        self.lyric_view.addGestureRecognizer(tapGesture_test_lyric_view)
        tapGesture_test_lyric_view.delegate = self.lyric_view as! UIGestureRecognizerDelegate
        
        
        tapGesture_test_caption_view = UITapGestureRecognizer(target: self, action: #selector(tapEdit_test_for_caption_view(recognizer:)))
        self.caption_text_view.addGestureRecognizer(tapGesture_test_caption_view)
        tapGesture_test_caption_view.delegate = self.caption_text_view as! UIGestureRecognizerDelegate
//      self.audio_scrubber_ot?.addGestureRecognizer(longPress)
//      longPress.delegate = audio_scrubber_ot as? UIGestureRecognizerDelegate
//        longPress.minimumPressDuration = 0.1
//        longPress.allowableMovement = 200
        stack_leading.constant = 167.5
        stack_trailing.constant = -72.5
        button_array = [self.now_playing_button_outlet, self.apple_button_outlet, self.spotify_button_outlet, self.youtube_button_outlet]
        self.change_alpha(center_button: 0)
        toggle_hide_upload_selection(hide: true)
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Posts"
        searchController.searchBar.delegate = self
        //self.search_bar_container.addSubview(searchController.searchBar)
        searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchController.searchBar.isHidden = true
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        //self.search_bar_container.isHidden = true
        
        GIF_SearchBar.delegate = self
        GIF_SearchBar.searchBarStyle = UISearchBar.Style.minimal
        self.GIF_SearchBar.isHidden = true
        
        now_playing_image.layer.cornerRadius = 10
        youtube_player.isHidden = true
        youtube_player.delegate = self
        gradient.frame = (self.my_table?.bounds)!
        self.my_table?.layer.mask = gradient
        self.my_table?.separatorStyle = .none
        gradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.7, 1]
        gradient.delegate = self
        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
        
        let keyboard_dismiss_tap = UITapGestureRecognizer(target: self, action: #selector(UploadViewController2.dismiss_keyboard))
        self.pane_view_for_keyboard_dismiss.addGestureRecognizer(keyboard_dismiss_tap)
        
        self.spotifyplayer.playbackDelegate = self as SPTAudioStreamingPlaybackDelegate
        self.spotifyplayer.delegate = self as SPTAudioStreamingDelegate
        
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
        self.url_paste_view.tintColor = UIColor.black
        self.view.sendSubviewToBack(self.url_paste_container_view)
        self.now_playing_image.isHidden = true
        
        hide_custom_scrolling_aparattus_toggle(set : true)
        
        
        self.now_playing_mini_image_container.layer.cornerRadius = 5
        self.now_playing_mini_image_container.layer.shadowColor = UIColor.black.cgColor
        self.now_playing_mini_image_container.layer.shadowOpacity = 1
        self.now_playing_mini_image_container.layer.shadowOffset = CGSize.zero
        self.now_playing_mini_image_container.layer.shadowRadius = 3
        self.now_playing_mini_image_container.layer.shadowPath = UIBezierPath(roundedRect: self.now_playing_mini_image_container.bounds, cornerRadius: 3).cgPath
        self.now_playing_mini_image.layer.cornerRadius = 5
        self.time_label.text = "0:00"
        
        
        self.express_button.layer.borderColor = UIColor.black.cgColor
        self.express_button.layer.cornerRadius = 5
        
        self.text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-type-60"), for: .normal)
        
        self.lyric_view.layer.cornerRadius = 10
        self.lyric_view.delegate = self
        self.lyric_view.tintColor = UIColor.lightGray
        self.express_view.layer.cornerRadius = 5
        self.express_view.layer.borderWidth = 2
        self.express_view.layer.borderColor = UIColor.black.cgColor

        
        //self.currently_active_collection_view.dataSource = self
        //self.currently_active_collection_view.delegate = self

        self.caption_text_view.delegate = self
        self.caption_text_view.layer.cornerRadius = 5
        self.caption_text_view.tintColor = UIColor.black
        setup_custom_scroller()
        
        
        // MARK: Collection View for GIPHY
        mycollectionview2.collectionViewLayout = SwiftyGiphyGridLayout()
        mycollectionview2.backgroundColor = UIColor.clear
        mycollectionview2.delegate = self
        mycollectionview2.dataSource = self
        mycollectionview2.layer.cornerRadius = 10
        mycollectionview2.keyboardDismissMode = .interactive
        
        mycollectionview2.isHidden = true
        selected_GIF_view.isHidden = true
        selected_GIF_view.translatesAutoresizingMaskIntoConstraints = false
        selected_GIF_view.clipsToBounds = true
        mycollectionview2.translatesAutoresizingMaskIntoConstraints = false
        mycollectionview2.register(SwiftyGiphyCollectionViewCell.self, forCellWithReuseIdentifier: kSwiftyGiphyCollectionViewCell)
        
        if let mycollectionViewLayout = mycollectionview2.collectionViewLayout as? SwiftyGiphyGridLayout
        {
            print ("GRID LAYOUT DELEGATE SET!!!!!!!!!!!!!!!!!!!!!!! ")
            self.mycollectionViewLayout!.delegate = self
        }
        
        
        if self.poller.something_is_playing {
            print("poller is playing something")
            if (self.userDefaults.string(forKey: "UserAccount") == "Apple") {
                
                self.now_playing_mini_image.image = poller.return_image()
                self.now_playing_image.image = poller.return_image()
                
              if let mediaItem = self.apple_system_player.nowPlayingItem {
                print ("\(mediaItem.playbackDuration)")
                //self.audio_scrubber_ot.maximumValue = Float(mediaItem.playbackDuration)
                //self.test_slider.maximumValue = Float(mediaItem.playbackDuration)
                self.now_playing_mini_image.isHidden = false
                self.now_playing_mini_image_container.isHidden = false
                self.apple_is_currently_playing = true
              }
            } else if (self.userDefaults.string(forKey: "UserAccount") == "Spotify") {
           
                self.poller.grab_now_playing_item().done {
                    
                    self.now_playing_mini_image.image = self.poller.return_image()
                    self.now_playing_image.image = self.poller.return_image()
                }
                
                self.temp_spotify_media_context_uri = self.poller.spotify_currently_playing_object.item?.uri
                self.temp_spotify_media_context_duration = self.poller.spotify_currently_playing_object.item?.duration_ms
                self.now_playing_mini_image.isHidden = false
                self.now_playing_mini_image_container.isHidden = false
                self.spotify_is_currently_playing = true
                let id = self.poller.spotify_currently_playing_object.item?.id
          
                
            }
        } else {
            self.now_playing_mini_image.isHidden = true
            self.now_playing_mini_image_container.isHidden = true
            self.spotify_is_currently_playing = false
        }
        
        self.upload_flag = "now_playing"
        
        
        
        //trialsearchController.searchResultsUpdater = self as? UISearchResultsUpdating
        //trialsearchController.obscuresBackgroundDuringPresentation = true
        //trialsearchController.searchBar.placeholder = "Search Posts"
        //self.searchBar = searchController.searchBar
        //navigationItem.searchController = searchController
        //self. = searchController.searchBar
        //self.tableView.tableHeaderView = searchController.searchBar
        navigationItem.titleView = searchController.searchBar
        self.update_recently_played()
        
        
        
        //setup header view for album  - apple recently played selection nonsense
        
        self.album_header_view.addSubview(album_header_image_view)
        self.album_header_view.addSubview(album_name_label_view)
        self.album_header_view.addSubview(album_artist_name_label_view)
        self.album_header_view.addSubview(album_artist_release_date_label_view)
        
    }
 
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.poller.grab_now_playing_item()
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
        toggle_hide_upload_selection(hide: true)
        show_or_hide_miniplayer()
        searchController.searchBar.isHidden = true
        self.my_table?.isHidden = false
        self.youtube_player.isHidden = true
        self.clear_tables()
        if !(self.back_button?.isHidden)! {
            self.back_button?.isHidden = true
        }
        self.update_recently_played()
    }
    
    @IBAction func apple_upload_button(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: [.curveEaseIn], animations: {
                        self.stack_leading.constant = 87.5
                        self.stack_trailing.constant = 7.5
                        self.change_alpha(center_button: 1)
                        self.view.layoutIfNeeded()
        }, completion: nil)
        toggle_hide_upload_selection(hide: true)
        searchController.searchBar.placeholder = "Search Apple Music"
        searchController.searchBar.isHidden = false
        self.upload_flag = "apple"
        self.clear_tables()
        self.my_table?.isHidden = false
        self.url_paste_container_view.isHidden = true
        self.view.sendSubviewToBack(self.url_paste_container_view)
        if !(self.back_button?.isHidden)! {
            self.back_button?.isHidden = true
        }
        self.now_playing_mini_image.isHidden = true
        self.now_playing_mini_image_container.isHidden = true
        
    }
    
    @IBAction func spotify_button(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: [.curveEaseIn], animations: {
                        self.stack_leading.constant = 7.5
                        self.stack_trailing.constant = 87.5
                        self.change_alpha(center_button: 2)
                        self.view.layoutIfNeeded()
        }, completion: nil )
        toggle_hide_upload_selection(hide: true)
        searchController.searchBar.placeholder = "Search Spotify"
        searchController.searchBar.isHidden = false
        self.upload_flag = "spotify"
        self.clear_tables()
        self.my_table?.isHidden = false
        self.url_paste_container_view.isHidden = true
        self.view.sendSubviewToBack(self.url_paste_container_view)
        if !(self.back_button?.isHidden)! {
            self.back_button?.isHidden = true
        }
        self.now_playing_mini_image.isHidden = true
        self.now_playing_mini_image_container.isHidden = true
    }
    
    @IBAction func youtube_button(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: [.curveEaseIn], animations: {
                        self.stack_leading.constant = -72.5
                        self.stack_trailing.constant = 167.5
                        self.change_alpha(center_button: 3)
                        self.view.layoutIfNeeded()
        }, completion: nil )
        toggle_hide_upload_selection(hide: true)
        self.upload_flag = "youtube"
        searchController.searchBar.placeholder = "Search Youtube"
        searchController.searchBar.isHidden = false
        self.clear_tables()
        self.my_table?.isHidden = false
        self.url_paste_container_view.isHidden = false
        self.view.bringSubviewToFront(self.url_paste_container_view)
        
        if !(self.back_button?.isHidden)! {
            self.back_button?.isHidden = true
        }
        self.now_playing_mini_image.isHidden = true
        self.now_playing_mini_image_container.isHidden = true
    }
    
    @IBAction func back_button(_ sender: Any) {
        toggle_hide_upload_selection(hide: true)
        self.back_button?.isHidden = true
        self.uploading = false
       
        
        if (self.upload_flag == "spotify") {
            self.spotifyplayer.setIsPlaying(false, callback: { (error) in
                if (error == nil) {
                    print("paused")
                    //self.timer?.invalidate()
                    //self.offsetvalue = (self.Spotifyplayer!.playbackState.position)
                }
                else {
                    print ("error in pausing!")
                }
            })
            searchController.searchBar.isHidden = false
            self.my_table?.isHidden = false
        } else if (self.upload_flag == "apple") {
            if (self.apple_player.playbackState == .playing) {
                self.apple_player.stop()
            }
            searchController.searchBar.isHidden = false
            self.my_table?.isHidden = false
        } else if (self.upload_flag == "youtube") {
           if (self.youtube_player.playerState() == YTPlayerState.playing || self.youtube_player.playerState() == YTPlayerState.paused) {
                self.youtube_player.stopVideo()
            }
            if self.url_paste_view.text != "URL" {
                self.url_paste_container_view.isHidden = false
                self.view.bringSubviewToFront(url_paste_container_view)
            }
            searchController.searchBar.isHidden = false
            self.my_table?.isHidden = false
            self.youtube_player.isHidden = true
        } else if (self.upload_flag == "now_playing") {
            self.now_playing_mini_image.isHidden = false
            self.now_playing_mini_image_container.isHidden = false
            self.my_table?.isHidden = false
            if (self.userDefaults.string(forKey: "UserAccount") == "Apple") {
                if self.apple_system_player.playbackState == .playing {
                    self.apple_system_player.stop()
                } else if self.apple_player.playbackState == .playing {
                    self.apple_player.stop()
                }
            } else if (self.userDefaults.string(forKey: "UserAccount") == "Spotify") {
                if ((self.spotifyplayer.playbackState.isPlaying)) {
                    self.spotifyplayer.setIsPlaying(false, callback: { (error) in
                        if (error == nil) {
                            print("paused")
                            //self.timer?.invalidate()
                            //self.offsetvalue = (self.Spotifyplayer!.playbackState.position)
                        }
                        else {
                            print ("error in pausing!")
                        }
                    })
                }
            }
            
        }
        
        self.reset_custom_scroller()
        self.scroller_timer.invalidate()
        //self.timer.invalidate()
        //self.audio_scrubber_ot.value = 0.0
        print ("scroll enabled \(self.collection_view_for_scroll.isScrollEnabled)")
        print ("touch enabled \(self.collection_view_for_scroll.isUserInteractionEnabled)")
       
    }
    
    
    
    @IBAction func express_button_action(_ sender: Any) {
        
        
        if self.uploading {
        
            
            self.is_selecting_animation = true
            self.is_selecting_audio_clip = false
            self.express_button.isHidden = true
            self.select_audio_clip_button.isHidden = false
            
            //show express_view
            self.express_view.isHidden = false
            
            
            //Hide selection view
            self.custom_progress_bar_container.isHidden = true
            self.Selection_view.isHidden = true
            self.collection_view_for_scroll.isHidden = true
            self.color_animate_view.isHidden = true
            self.time_label.isHidden = true
            self.caption_text_view.isHidden = true
            self.GIF_SearchBar.isHidden = false
            self.text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-type-60"), for: .normal)
            
        }
        
        
    }
    
    
    @IBAction func album_art_or_lyric_switch_action(_ sender: Any) {
        
        if self.now_playing_image.isHidden &&  !self.lyric_view.isHidden {
            self.now_playing_image.isHidden = false
            self.lyric_view.isHidden = true
            self.lyrics = false
            self.album_art_or_lyric_switch.setBackgroundImage(UIImage(named: "icons8-l-filled-100"), for: .normal)
        } else if self.lyric_view.isHidden  && !self.now_playing_image.isHidden{
            self.lyric_view.isHidden = false
            self.now_playing_image.isHidden = true
            self.lyrics = true
            self.album_art_or_lyric_switch.setBackgroundImage(UIImage(named: "icons8-xlarge-icons-filled-100"), for: .normal)
        }
        
        
    }
    
    @IBAction func text_or_animation_switch_action(_ sender: Any) {
        print("text_or_animation_switch_action")
        if self.GIF_Search_is_ON {
            self.GIF_SearchBar.endEditing(true)
            self.express_view_to_search_bar_super_container.constant = 319
            self.GIF_SearchBar_top_to_express_view.constant = 4
            self.Text_or_animation_switch_top_to_express_view.constant = 13
            self.GIF_Search_is_ON = false
            self.text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-type-60"), for: .normal)
            
        } else {
            
            if self.is_selecting_animation {
                self.is_selecting_animation = false
                self.caption_text_view.isHidden = false
                self.GIF_SearchBar.isHidden = true
                self.text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-typography-52"), for: .normal)
            } else {
                self.is_selecting_animation = true
                self.caption_text_view.isHidden = true
                self.GIF_SearchBar.isHidden = false
                self.text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-type-60"), for: .normal)
            }
        }
      
    }
    
    @IBAction func select_audio_clip_show_hide(_ sender: Any) {
        
        if self.uploading {
        
            self.is_selecting_animation = false
            self.is_selecting_audio_clip = true
            
            self.collection_view_for_scroll.reloadData()
            
            self.express_button.isHidden = false
            self.select_audio_clip_button.isHidden = true
            
            self.express_view.isHidden = true
            self.caption_text_view.isHidden = true
            self.Selection_view.isHidden = false
            self.collection_view_for_scroll.isHidden = false
            self.color_animate_view.isHidden = false
            self.custom_progress_bar_container.isHidden = false
            self.time_label.isHidden = false
     
            
        }
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("text view did begin editing")
        if textView.textColor ==  UIColor.lightGray {
            textView.text = nil
            if !self.lyric_view.isHidden {
                textView.textColor = UIColor.black
            }
        }
//        self.pane_view_for_keyboard_dismiss.isHidden = false
//
//        if !self.caption_text_view.isHidden {
//            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                 self.caption_view_bottom_constraint_to_express_view.constant = 273
//            }, completion: nil)
//            self.express_view.backgroundColor = UIColor.clear
//            self.search_bar_subview.layer.backgroundColor = UIColor.black.withAlphaComponent(0.7).cgColor
//            self.back_button.layer.backgroundColor = UIColor.clear.cgColor
//            self.upload_done.layer.backgroundColor = UIColor.clear.cgColor
//
//        } else if !self.lyric_view.isHidden {
//            self.search_bar_subview.layer.backgroundColor = UIColor.black.withAlphaComponent(0.7).cgColor
//            self.back_button.layer.backgroundColor = UIColor.clear.cgColor
//            self.upload_done.layer.backgroundColor = UIColor.clear.cgColor
//
//        }
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
            self.view.sendSubviewToBack(self.url_paste_container_view)
                self.toggle_hide_upload_selection(hide: false)
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
    
//    @objc func scrub (recognizer: UILongPressGestureRecognizer) {
//        print ("long press detected")
//        self.spotifyplayer?.seek(to: TimeInterval(((self.collection_view_for_scroll.contentOffset.x + 96.5) / 5) * 1000), callback: nil)
//
//    }
    
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
        print ("audio_scrubber")
        
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
        //self.test_slider.setValue(self.audio_scrubber_ot.value, animated: true)
        
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
        
        let seek_to_time = ((self.collection_view_for_scroll.contentOffset.x + 96.5) / 5) * 1000
        
        print ("audio_scrubber_touch_up_inside")
         if (self.upload_flag == "spotify") {
            if ((self.spotifyplayer.playbackState.isPlaying)) {
                self.spotifyplayer.seek(to: TimeInterval(seek_to_time), callback: {error in
                    if error != nil {
                        print (error)
                    } else {
                        print ("seeking succesfull")
                    }
                })
            } else {
                self.spotifyplayer.playSpotifyURI(spotify_current_uri!, startingWith: 0, startingWithPosition: TimeInterval(seek_to_time), callback: { (error) in
                    if (error == nil) {
                        print("playing!")
                    }

                })
            }
         } else if (self.upload_flag == "apple") {
            print("in scrubber touch up inside")
            if (self.apple_player.playbackState == MPMusicPlaybackState.playing) {
                    self.apple_player.currentPlaybackTime = TimeInterval(seek_to_time)
            }
         } else if (self.upload_flag == "youtube") {
            print("in scrubber touch up inside")
            //print (self.audio_scrubber_ot.value)
            self.youtube_player.seek(toSeconds: Float(seek_to_time), allowSeekAhead: true)
        } else if (self.upload_flag == "now_playing") {
            if (self.userDefaults.string(forKey: "UserAccount") == "Apple") {
                if self.apple_system_player.playbackState == .playing {
                    print ("trying to ring in system player")
                    if (self.apple_player.playbackState == MPMusicPlaybackState.playing) {
                        self.apple_player.currentPlaybackTime = TimeInterval(seek_to_time)
                    }
                    self.poller.apple_system_player.currentPlaybackTime = TimeInterval(seek_to_time)
                    self.poller.internal_keep_time = self.poller.apple_system_player.currentPlaybackTime
                }
            } else if (self.userDefaults.string(forKey: "UserAccount") == "Spotify") {
                //print (TimeInterval(self.audio_scrubber_ot.value / 1000))
                print (spotify_current_uri)
                if ((self.spotifyplayer.playbackState.isPlaying)) {
                    self.spotifyplayer.seek(to: TimeInterval(seek_to_time), callback: {error in
                        if error != nil {
                            print (error)
                        } else {
                            print ("seeking succesfull")
                        }
                    })
                } else {
                    self.spotifyplayer.playSpotifyURI(spotify_current_uri!, startingWith: 0, startingWithPosition: TimeInterval(seek_to_time),  callback: { (error) in
                        if (error == nil) {
                            print("playing!")
                        }

                    })
                }
            }
            
        }
        
    }
    
    
 /*
    @IBAction func upload_done(_ sender: Any) {
        
        self.uploading = false
        self.is_selecting_audio_clip = true
        self.is_selecting_animation = false
        var upload_post: Post?
        if (self.selected_cell != nil) && self.upload_flag != "now_playing" {
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
                    print ("\(newsfeed.posts?.count)")
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
        } else if self.upload_flag == "now_playing" {
            
            if self.userDefaults.string(forKey: "UserAccount") == "Apple" {
                if !self.poller.apple_mediaItems.isEmpty {
                    self.get_post_from_now_playing().done { upload_post in
                        print ("we got_post_from_cell")
                        if let presenter = self.presentingViewController as? myTabBarController {
                            print("we got tabbar as presenter")
             
                            //Presenter is TabBarController - it's 0th controller is NavBarController
                            //NavBar's child controller is Newsfeed Controller
                            if let newsfeed = presenter.viewControllers?[0].childViewControllers[0] as? NewsFeedTableViewController {
                                print ("we got newsfeed")
                                print ("\(newsfeed.posts?.count)")
                                let new_post_number = newsfeed.posts?.count
                                self.add_new_post_to_firebase(new_post: upload_post, new_post_number: new_post_number!)
                                newsfeed.fetchPosts()
                            }
                        }
                        
                        self.searchController.isActive = false
                        if self.end_post_media() {
                            print ("Post media stopped")
                        } else {
                            print("Error stoping new post media")
                        }
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }
            } else if self.userDefaults.string(forKey: "UserAccount") == "Spotify" {
                if self.poller.spotify_currently_playing_object.item != nil {
                    self.get_post_from_now_playing().done { upload_post in
                        print ("we got_post_from_cell")
                        if let presenter = self.presentingViewController as? myTabBarController {
                            print("we got tabbar as presenter")
                            
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
                        if self.end_post_media() {
                            print ("Post media stopped")
                        } else {
                            print("Error stoping new post media")
                        }
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }
                
            }
        }
        
        
        self.reset_custom_scroller()
        self.scroller_timer.invalidate()
    }
 */
    
    func end_post_media () -> Bool {
        
        var return_value = false
        if (self.upload_flag == "spotify") {
            if (self.spotifyplayer.playbackState.isPlaying) {
                self.spotifyplayer.setIsPlaying(false, callback: { (error) in
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
        } else if (self.upload_flag == "now_playing") {
            
            if (self.userDefaults.string(forKey: "UserAccount") == "Apple") {
                if self.apple_player.playbackState == .playing {
                    self.apple_player.stop()
                }
                
            } else if (self.userDefaults.string(forKey: "UserAccount") == "Spotify") {
                if (self.spotifyplayer.playbackState.isPlaying) {
                    self.spotifyplayer.setIsPlaying(false, callback: { (error) in
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
            }
            
        }
        
        
        return return_value
    }
    
    
    
    func toggle_hide_upload_selection (hide: Bool) {
        if hide {
            self.now_playing_image.isHidden = true
            self.upload_done.isHidden = true
            self.upload_done.isUserInteractionEnabled = false    //why is this not working?
            self.now_playing_progress_bar.isHidden = true        //why is this not working? : Using the 'uploading' flag in back_button to prevent scrolling when the view is hidden for now
            hide_custom_scrolling_aparattus_toggle(set : true)
            self.song_name_label.isHidden = true
            self.artist_name_label.isHidden = true
            self.select_audio_clip_button.isHidden = true
            self.express_button.isHidden = true
            self.lyric_view.isHidden = true
            self.express_view.isHidden = true
            self.caption_text_view.isHidden = true
            self.GIF_SearchBar.isHidden = true
            self.album_art_or_lyric_switch.isHidden = true
            self.selector_stack_show_or_hide(hide: false)
            //self.is_selecting_audio_clip = false
            self.is_selecting_audio_clip = true
            self.is_selecting_animation = false
        } else {
            self.now_playing_image.isHidden = false
            self.upload_done.isHidden = false
            self.upload_done.isUserInteractionEnabled = true   //same as above two comments
            self.now_playing_progress_bar.isHidden = true      //same as above two comments
           hide_custom_scrolling_aparattus_toggle(set : false)
            self.song_name_label.isHidden = false
            self.artist_name_label.isHidden = false
            self.selector_stack_show_or_hide(hide: true)
            self.album_art_or_lyric_switch.isHidden = false
            self.express_button.isHidden = false
            self.is_selecting_audio_clip = true
        }
    }
    

    func show_or_hide_miniplayer() {
        
        if self.spotify_is_currently_playing || self.apple_is_currently_playing {
            self.now_playing_mini_image.isHidden = false
            self.now_playing_mini_image_container.isHidden = false
        } else {
            self.now_playing_mini_image.isHidden = true
            self.now_playing_mini_image_container.isHidden = true
        }
        
    }
    
    
    func selector_stack_show_or_hide (hide: Bool) {
        if hide {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
               self.selector_stack_bottom_constraint.constant = -50
                self.dismiss_chevron_bottom_constraint.constant = -78
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.selector_stack_bottom_constraint.constant = 42
                self.dismiss_chevron_bottom_constraint.constant = 14
            }, completion: nil)
        }
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print ("numberOfSections \(self.search_result_count)")
        return self.mediaItems.count
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
    
    @objc func tapEdit_test_for_lyric_view(recognizer: UITapGestureRecognizer) {
        
        print ("tap gesture lyric")
        self.pane_view_for_keyboard_dismiss.isHidden = false
        if !self.lyric_view.isHidden {
            self.express_view.backgroundColor = UIColor.clear
            self.search_bar_subview.layer.backgroundColor = UIColor.black.withAlphaComponent(0.7).cgColor
            self.back_button.layer.backgroundColor = UIColor.clear.cgColor
            self.upload_done.layer.backgroundColor = UIColor.clear.cgColor
            
        }
        self.lyric_view.becomeFirstResponder()
        self.tapGesture_test_lyric_view.isEnabled = false
        self.tapGesture_test_caption_view.isEnabled = false

        
        
    }
    
    @objc func tapEdit_test_for_caption_view(recognizer: UITapGestureRecognizer) {
      
        
        print("tap gesture caption")
        self.pane_view_for_keyboard_dismiss.isHidden = false
        
        if !self.caption_text_view.isHidden {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.caption_view_bottom_constraint_to_express_view.constant = 273
            }, completion: nil)
            self.express_view.backgroundColor = UIColor.clear
            self.search_bar_subview.layer.backgroundColor = UIColor.black.withAlphaComponent(0.7).cgColor
            self.back_button.layer.backgroundColor = UIColor.clear.cgColor
            self.upload_done.layer.backgroundColor = UIColor.clear.cgColor
            
        }
        self.caption_text_view.becomeFirstResponder()
        self.tapGesture_test_caption_view.isEnabled = false
        self.tapGesture_test_lyric_view.isEnabled = false
        
    }
    
    
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.my_table)
            if let tapIndexPath = self.my_table?.indexPathForRow(at: tapLocation) {
                
                self.clean_cached_cell()
                
                
                if self.upload_flag == "now_playing" && self.userDefaults.string(forKey: "UserAccount") == "Apple" {
                    if let tappedCell = self.my_table?.cellForRow(at: tapIndexPath) as? SearchResultCell {
                        print(tappedCell.mediaItem.type)
                        if tappedCell.mediaItem.type.rawValue == "albums" {
                            self.selected_album_media_item = tappedCell.mediaItem
                            performSegue(withIdentifier: "2_to_album_display", sender: self)
                        }
                    }
                } else {
                
                   if self.upload_flag != "youtube" {
                       if let tappedCell = self.my_table?.cellForRow(at: tapIndexPath) as? SearchResultCell  {
    //                        self.youtube_player.isHidden = true
    //                        toggle_hide_upload_selection(hide: false)
    //                        self.searchController.view.endEditing(true)
    //                        searchController.searchBar.isHidden = true
    //                        self.my_table?.isHidden = true
    //                        self.back_button?.isHidden = false
    //                        self.view.bringSubview(toFront: self.back_button)
    //                        //self.search_bar_container.bringSubview(toFront: self.back_button)
    //                        self.selected_cell = tapIndexPath
    //
                            if (self.upload_flag == "spotify") {
    //
    //                            self.now_playing_image.image = tappedCell.media_image.image
    //                            self.spotifyplayer.playSpotifyURI(tappedCell.spotify_mediaItem.uri!, startingWith: 0, startingWithPosition: 0.0, callback: { (error) in
    //                                if (error == nil) {
    //                                    print("playing!")
    //                                    self.animate_color()
    //                                }
    //                            })
    //                            //self.audio_scrubber_ot.maximumValue = Float(tappedCell.spotify_mediaItem.duration_ms!)
    //                            //self.test_slider.maximumValue = Float(tappedCell.spotify_mediaItem.duration_ms!)
    //                            self.duration = (tappedCell.spotify_mediaItem.duration_ms!) / 1000
    //                            self.duration_for_number_of_cells = Int(ceil(Double(tappedCell.spotify_mediaItem.duration_ms!) / 1000))
    //                            print (tappedCell.spotify_mediaItem.duration_ms)
    //                            print (Float(tappedCell.spotify_mediaItem.duration_ms!) / 1000)
    //                            //print(self.audio_scrubber_ot.maximumValue)
    //                            self.spotify_current_uri = tappedCell.spotify_mediaItem.uri
    //                            self.song_name_label.text = tappedCell.spotify_mediaItem.name
    //                            self.artist_name_label.text = tappedCell.spotify_mediaItem.artists![0].name
    //                             //self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateScrubber), userInfo: nil, repeats: true)
    //                            self.uploading = true
                            } else if (self.upload_flag == "apple") {
    //                            self.now_playing_image.image = tappedCell.media_image.image
    //                            self.apple_player.setQueue(with: [tappedCell.mediaItem.identifier as! String])
    //                            self.apple_player.play()
    //                            self.apple_player.currentPlaybackTime = 30.0
    //                            self.animate_color()
    //                            //self.audio_scrubber_ot.maximumValue = Float(tappedCell.mediaItem.durationInMillis!)
    //                            //self.test_slider.maximumValue = Float(tappedCell.mediaItem.durationInMillis!)
    //                            print (tappedCell.mediaItem.durationInMillis!)
    //                            print (Float(tappedCell.mediaItem.durationInMillis!) / 1000)
    //                            self.duration = (tappedCell.mediaItem.durationInMillis!) / 1000
    //                            self.duration_for_number_of_cells = Int(ceil(Double(tappedCell.mediaItem.durationInMillis!) / 1000))
    //                            //print(self.audio_scrubber_ot.maximumValue)
    //                            self.apple_id = tappedCell.mediaItem.identifier
    //                            self.song_name_label.text = tappedCell.mediaItem.name
    //                            self.artist_name_label.text = tappedCell.mediaItem.artistName
    //                            self.uploading = true
                            }
                        }
                    } else  {
                        if let tappedCell = self.my_table?.cellForRow(at: tapIndexPath) as? SearchResultCell_youtube  {
    //                        self.youtube_player.isHidden = false
    //                        self.searchController.view.endEditing(true)
    //                        toggle_hide_upload_selection(hide: false)
    //                        searchController.searchBar.isHidden = true
    //                        self.my_table?.isHidden = true
    //                        self.back_button?.isHidden = false
    //                        self.selected_cell = tapIndexPath
    //                        print ("gesture recognized")
    //                        self.youtube_player.isHidden = false
    //                        self.youtube_player.load(withVideoId: tappedCell.youtube_video_resource.identifier?.videoId ?? "" , playerVars: ["autoplay": 1, "playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 1, "rel": 0, "iv_load_policy": 3])
    //                        self.youtube_player.playVideo()
    //                        self.song_name_label.text = tappedCell.youtube_video_resource.snippet?.title
    //                        self.artist_name_label.text = ""
                            //Here we do the query to get the video reponse object to get the duration - we set it in displayResultWithTicket2
                            //let video_search_query = GTLRYouTubeQuery_VideosList.query(withPart: "snippet,contentDetails,statistics")
                            //video_search_query.identifier = tappedCell.youtube_video_resource.identifier?.videoId ?? ""
                            //service.executeQuery(video_search_query,
                                                // delegate: self,
                                                 //didFinish: #selector(displayResultWithTicket2(ticket:finishedWithObject:error:)))
    //                        self.yt_id = tappedCell.youtube_video_resource.identifier?.videoId
    //                        self.uploading = true
                        }
                   }
                    
    //                self.collection_view_for_scroll.reloadData()
    //                self.slider_width.constant = (self.custom_progress_bar_bar.frame.width * self.Selection_view.frame.width) / CGFloat((self.duration_for_number_of_cells * 5) - 3)
    //                self.slider_leading_constraint.constant = 0
    //                self.color_animate_trailing.constant = 262.5
    //                self.collection_view_for_scroll.setContentOffset(CGPoint(x: -97.0, y: 0.0), animated: true)
                    self.cache_selected_cell(at: tapIndexPath)
                    
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
                                          videoid: "empty",
                                          starttime: 0 ,
                                          endtime: 0,
                                          flag: ((self.lyrics) ? "lyric" : "audio"),
                                          lyrictext: "",
                                          songname: upload_cell.spotify_mediaItem.name,
                                          sourceapp: self.upload_flag,
                                          preview_url: (upload_cell.spotify_mediaItem.preview_url) ?? "nil",
                                          albumArtUrl: upload_cell.spotify_mediaItem.album?.images![0].url,
                                          original_track_length: upload_cell.spotify_mediaItem!.duration_ms!,
                                          GIF_url: "" )
                    
                   
                
                
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
                                          videoid: "empty",
                                          starttime: 0 ,
                                          endtime: 0,
                                          flag: ((self.lyrics) ? "lyric" : "audio"),
                                          lyrictext: "",
                                          songname: upload_cell.mediaItem.name,
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
                                                        videoid: "empty",
                                                        starttime: 0 ,
                                                        endtime: 0,
                                                        flag: ((self.lyrics) ? "lyric" : "audio"),
                                                        lyrictext: "",
                                                        songname: upload_cell.spotify_recently_played_mediaItem.track?.name,
                                                        sourceapp: self.upload_flag,
                                                        preview_url: (upload_cell.spotify_recently_played_mediaItem.track?.preview_url) ?? "nil",
                                                        albumArtUrl: upload_cell.spotify_recently_played_mediaItem.track?.album?.images![0].url,
                                                        original_track_length: upload_cell.spotify_recently_played_mediaItem.track?.duration_ms!,
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
                                      videoid: "empty",
                                      starttime: 0 ,
                                      endtime: 0,
                                      flag: ((self.lyrics) ? "lyric" : "audio"),
                                      lyrictext: self.lyric_view.text,
                                      songname: "",
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
                                  videoid: upload_cell.youtube_video_resource.identifier?.videoId,
                                  starttime: 0 ,
                                  endtime: 0,
                                  flag: "video",
                                  lyrictext: "",
                                  songname: upload_cell.youtube_video_resource.snippet?.title,
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
                                                videoid: "empty",
                                                starttime: 0 ,
                                                endtime: 0,
                                                flag: ((self.lyrics) ? "lyric" : "audio"),
                                                lyrictext: self.lyric_view.text,
                                                songname: "",
                                                sourceapp: "",
                                                preview_url: "",
                                                albumArtUrl: "",
                                                original_track_length: 0,
                                                GIF_url: "")
        
    }
    
     @objc func tapEdit2(recognizer: UITapGestureRecognizer)  {
        print ("tapEdit2 called ")
        
        //the miniplayer should fade out and the final upload page should show up
        //we get the media item data from the now playing poller
        
        self.now_playing_mini_image.isHidden = true
        self.now_playing_mini_image_container.isHidden = true
        //self.back_button?.isHidden = false
        //toggle_hide_upload_selection(hide: false)
        
        //get the song id from the current_playing_context and play the song from the start in our own player - this should stop the system player
 /*
        if (self.userDefaults.string(forKey: "UserAccount") == "Spotify") {
            self.spotifyplayer.playSpotifyURI(self.temp_spotify_media_context_uri!, startingWith: 0, startingWithPosition: 0.0, callback: { (error) in
                if (error == nil) {
                    print("playing!")
                    self.animate_color()
                }
            })
            //self.audio_scrubber_ot.maximumValue = Float(self.temp_spotify_media_context_duration!)
            //self.test_slider.maximumValue = Float(self.temp_spotify_media_context_duration!)
            print (self.temp_spotify_media_context_duration)
            print (Float(self.temp_spotify_media_context_duration!) / 1000)
            //print(self.audio_scrubber_ot.maximumValue)
            self.spotify_current_uri = self.temp_spotify_media_context_uri
            self.duration = (self.temp_spotify_media_context_duration!) / 1000
            self.duration_for_number_of_cells = Int(ceil(Double(self.temp_spotify_media_context_duration!) / 1000))
            self.song_name_label.text = self.poller.spotify_currently_playing_object.item?.name
            self.artist_name_label.text = self.poller.spotify_currently_playing_object.item?.artists?[0].name
            self.uploading = true
        } else if (self.userDefaults.string(forKey: "UserAccount") == "Apple") {
            
            print ("now playing tap edit - account Apple")
            if let mediaItem = self.apple_system_player.nowPlayingItem {
                print ("\(mediaItem.playbackDuration)")
                self.apple_system_player.pause()
                self.apple_player.setQueue(with: [mediaItem.playbackStoreID as! String])
                self.apple_player.play()
                self.apple_player.currentPlaybackTime = 30.0
                self.animate_color()
                print (mediaItem.playbackDuration)
                print (mediaItem.playbackStoreID)
                //self.audio_scrubber_ot.maximumValue = Float(mediaItem.playbackDuration)
                //self.test_slider.maximumValue = Float(mediaItem.playbackDuration)
                self.apple_id = mediaItem.playbackStoreID
                self.duration = Int(mediaItem.playbackDuration)
                self.duration_for_number_of_cells = Int(ceil(mediaItem.playbackDuration))
                self.song_name_label.text = mediaItem.title
                self.artist_name_label.text = mediaItem.artist
                self.uploading = true
            }
        }
        
        self.collection_view_for_scroll.reloadData()
        print (self.collection_view_for_scroll.contentSize.width)
        print (self.custom_progress_bar_bar.frame.width)
        print (self.Selection_view.frame.width)
        self.slider_width.constant = (self.custom_progress_bar_bar.frame.width * self.Selection_view.frame.width) / CGFloat((self.duration_for_number_of_cells * 5) - 3)
        self.slider_leading_constraint.constant = 0
        self.color_animate_trailing.constant = 262.5
        self.collection_view_for_scroll.setContentOffset(CGPoint(x: -97.0, y: 0.0), animated: true)
    */
        
        self.selected_search_result_post_image = self.poller.return_image()
        self.selected_search_result_song_db_struct.album_name = self.poller.spotify_currently_playing_object.item?.album?.name
        self.selected_search_result_song_db_struct.artist_name = self.poller.spotify_currently_playing_object.item?.artists?[0].name
        self.selected_search_result_song_db_struct.isrc_number = self.poller.spotify_currently_playing_object.item?.external_ids?.isrc
        self.selected_search_result_song_db_struct.playable_id = self.poller.spotify_currently_playing_object.item?.uri
        self.selected_search_result_song_db_struct.preview_url = self.poller.spotify_currently_playing_object.item?.preview_url
        self.selected_search_result_song_db_struct.release_date = self.poller.spotify_currently_playing_object.item?.album?.release_date
        self.selected_search_result_song_db_struct.song_name = self.poller.spotify_currently_playing_object.item?.name
        
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
            trackid: self.poller.spotify_currently_playing_object.item?.uri,
            helper_id: "",
            videoid: "empty",
            starttime: 0 ,
            endtime: 0,
            flag: ((self.lyrics) ? "lyric" : "audio"),
            lyrictext: "",
            songname: self.poller.spotify_currently_playing_object.item?.name,
            sourceapp: self.upload_flag,
            preview_url: (self.poller.spotify_currently_playing_object.item?.preview_url) ?? "nil",
            albumArtUrl: self.poller.spotify_currently_playing_object.item?.album?.images![0].url,
            original_track_length: (self.temp_spotify_media_context_duration!) / 1000,
            GIF_url: "" )
        
            self.duration = (self.temp_spotify_media_context_duration!) / 1000
            self.duration_for_number_of_cells = Int(ceil(Double(self.temp_spotify_media_context_duration!) / 1000))
        
            self.performSegue(withIdentifier: "upload_2_to_3", sender: self)
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
            //self.audio_scrubber_ot.maximumValue = Float(video_duration * 1000)
            //self.test_slider.maximumValue = Float(video_duration * 1000)
            self.duration = video_duration
            self.duration_for_number_of_cells = video_duration
            self.collection_view_for_scroll.reloadData()
            self.slider_width.constant = (self.custom_progress_bar_bar.frame.width * self.Selection_view.frame.width) / CGFloat((self.duration_for_number_of_cells * 5) - 3)
            print (video_duration)
            //print(self.audio_scrubber_ot.maximumValue)
            self.search_result_video = video
        } else {
            print ("Request for specific video returned empty")
        }
        
    }
    
    @objc func updateScrubber () {
        //self.audio_scrubber_ot.value = Float((self.spotifyplayer?.playbackState.position)!)
    }
/*
    func get_post_from_cell (cell_index: IndexPath) -> Promise<Post> {
        return Promise { seal in
        print("we got to get_post_from_cell")
        var post_from_cell: Post?
            
        let start_offset = Double(((self.collection_view_for_scroll.contentOffset.x + 96.5) / 5))
        
            if let upload_cell_2 = self.my_table?.cellForRow(at: cell_index) as? SearchResultCell {
                print ("cell exists")
            } else {
                print ("cell does not exist")
            }
        if self.upload_flag != "youtube" {
            print(" != youtube")
            switch self.upload_flag {
            case "spotify" :
                print("We got to case: spotify")
                var spotify_struct = song_db_struct()
                var worker = ISRC_worker()
                
                spotify_struct.album_name = self.selected_search_result_song_db_struct.album_name
                spotify_struct.artist_name = self.selected_search_result_song_db_struct.artist_name
                spotify_struct.isrc_number = self.selected_search_result_song_db_struct.isrc_number
                spotify_struct.playable_id = self.selected_search_result_song_db_struct.playable_id
                spotify_struct.preview_url = self.selected_search_result_song_db_struct.preview_url
                spotify_struct.release_date = self.selected_search_result_song_db_struct.release_date
                spotify_struct.song_name = self.selected_search_result_song_db_struct.song_name
                
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
                                      caption: self.caption_text_view.text,
                                      offset: 0.0,
                                      startoffset: start_offset, //<- Apple does not allow starting from a particular point. No workaround so far :( We keep this for spotify users playing apple posts - we give this value as 0.0 in update_apple in newsfeed controller.
                                      audiolength: 30.0 ,
                                      paused: false,
                                      playing: false,
                                      trackid: self.selected_search_result_post.trackid,
                                      helper_id: p1_found_id,
                                      videoid: "empty",
                                      starttime: 0 ,
                                      endtime: 0,
                                      flag: ((self.lyrics) ? "lyric" : "audio"),
                                      lyrictext: self.lyric_view.text,
                                      songname: self.selected_search_result_post.songname,
                                      sourceapp: self.upload_flag,
                                      preview_url: (self.selected_search_result_post.preview_url) ?? "nil",
                                      albumArtUrl: self.selected_search_result_post.albumArtUrl,
                                      original_track_length: self.selected_search_result_post.original_track_length,
                                      GIF_url: self.selected_GIF_url?.absoluteString ?? "")
                    
                    seal.fulfill(post_from_cell!)
                }
                
            case "apple":
                print (" case apple ")
                var apple_struct = song_db_struct()
                var worker = ISRC_worker()
                
                apple_struct.album_name = self.selected_search_result_song_db_struct.album_name
                apple_struct.artist_name = self.selected_search_result_song_db_struct.artist_name
                apple_struct.isrc_number = self.selected_search_result_song_db_struct.isrc_number
                apple_struct.playable_id = self.selected_search_result_song_db_struct.playable_id
                apple_struct.preview_url = self.selected_search_result_song_db_struct.preview_url
                apple_struct.release_date = self.selected_search_result_song_db_struct.release_date
                apple_struct.song_name = self.selected_search_result_song_db_struct.song_name
                
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
                                      caption: self.caption_text_view.text,
                                      offset: 0.0,
                                      startoffset: start_offset,
                                      audiolength: 30.0, //<- This has to be grabbed from user - provide physical slider
                                      paused: false,
                                      playing: false,
                                      trackid: self.selected_search_result_post.trackid,
                                      helper_id: p1_found_id,
                                      videoid: "empty",
                                      starttime: 0 ,
                                      endtime: 0,
                                      flag: ((self.lyrics) ? "lyric" : "audio"),
                                      lyrictext: self.lyric_view.text,
                                      songname: self.selected_search_result_post.songname,
                                      sourceapp: self.upload_flag,
                                      preview_url: self.selected_search_result_post.preview_url,
                                      albumArtUrl: self.selected_search_result_post.albumArtUrl,
                                      original_track_length: self.selected_search_result_post.original_track_length,
                                      GIF_url: self.selected_GIF_url.absoluteString ?? "")
                    
                    seal.fulfill(post_from_cell!)
                    
                }
                
           
            default:   //now_playing - do we need 'default' case? it's going to be apple/spotify anyway.
                print ("default")
                post_from_cell = Post(albumArtImage:  "",
                                      sourceAppImage:  "Spotify_cropped",
                                      typeImage: "icons8-musical-notes-50" ,
                                      profileImage:  "FullSizeRender 10-2" ,
                                      username: "Viraj",
                                      timeAgo: "Just now",
                                      numberoflikes: "0 likes",
                                      caption: self.caption_text_view.text,
                                      offset: 0.0,
                                      startoffset: start_offset,
                                      audiolength: 30.0 ,
                                      paused: false,
                                      playing: false,
                                      trackid: self.selected_search_result_post.trackid,
                                      helper_id: "1282343124",
                                      videoid: "empty",
                                      starttime: 0 ,
                                      endtime: 0,
                                      flag: ((self.lyrics) ? "lyric" : "audio"),
                                      lyrictext: self.lyric_view.text,
                                      songname: self.selected_search_result_post.songname,
                                      sourceapp: self.upload_flag,
                                      preview_url: self.selected_search_result_post.preview_url,
                                      albumArtUrl: self.selected_search_result_post.albumArtUrl,
                                      original_track_length: 0,
                                      GIF_url: self.selected_GIF_url.absoluteString ?? "")
                
                seal.fulfill(post_from_cell!)
                
            }
            
        } else if self.upload_flag == "youtube" {
            print ("youtube")
            post_from_cell = Post(albumArtImage:  "",
                                  sourceAppImage:  "Youtube_cropped",
                                  typeImage: "video" ,
                                  profileImage:  "FullSizeRender 10-2" ,
                                  username: "Viraj",
                                  timeAgo: "Just now",
                                  numberoflikes: "0 likes",
                                  caption: self.caption_text_view.text,
                                  offset: 0.0,
                                  startoffset: start_offset,
                                  audiolength: 30.0 ,
                                  paused: false,
                                  playing: false,
                                  trackid: "",
                                  helper_id: "1282343124",
                                  videoid: self.selected_search_result_post.videoid,
                                  starttime: 0 ,
                                  endtime: 0,
                                  flag: "video",
                                  lyrictext: "",
                                  songname: self.selected_search_result_post.songname,
                                  sourceapp: self.upload_flag,
                                  preview_url: "",
                                  albumArtUrl: self.selected_search_result_post.albumArtUrl,
                                  original_track_length: self.selected_search_result_post.original_track_length,
                                  GIF_url: self.selected_GIF_url.absoluteString ?? "")
            
            seal.fulfill(post_from_cell!)
        } else {
            print ("seal reject")
            seal.reject(MyError.runtimeError("Weird upload flag"))
        }
    }
  
    }
    
    func get_post_from_now_playing () -> Promise<Post> {
        return Promise { seal in
            
            let start_offset =  Double(((self.collection_view_for_scroll.contentOffset.x + 96.5) / 5))
            var worker = ISRC_worker()
            var post_from_now_playing: Post?
            
            if (self.userDefaults.string(forKey: "UserAccount") == "Apple") {
                var apple_struct = song_db_struct()
            
                apple_struct.album_name = self.poller.apple_mediaItems[0][0].albumName
                apple_struct.artist_name = self.poller.apple_mediaItems[0][0].artistName
                apple_struct.isrc_number = self.poller.apple_mediaItems[0][0].isrc
                apple_struct.playable_id = self.poller.apple_mediaItems[0][0].identifier
                apple_struct.preview_url = self.poller.apple_mediaItems[0][0].previews[0]["url"] ?? ""
                apple_struct.release_date = self.poller.apple_mediaItems[0][0].releaseDate
                apple_struct.song_name = self.poller.apple_mediaItems[0][0].name
                
                worker.get_this_song(target_catalog: "spotify", song_data: apple_struct).done {p1_found_id in
                    print ("Heya wtf bruh")
                    print (p1_found_id)
                    print ("Heya wtf bruh")
                    post_from_now_playing = Post(albumArtImage:  "",
                                          sourceAppImage:  "apple_logo",
                                          typeImage: "icons8-musical-notes-50" ,
                                          profileImage:  "FullSizeRender 10-2" ,
                                          username: "Viraj",
                                          timeAgo: "Just now",
                                          numberoflikes: "0 likes",
                                          caption: self.caption_text_view.text,
                                          offset: 0.0,
                                          startoffset: start_offset,    //<-Apple does not allow starting from a different point of time - No workaround so far :(. We keep this for spotify users playing apple posts - we give this value as 0.0 in update_apple in newsfeed controller.
                                          audiolength: 30.0, //<- This has to be grabbed from user - provide physical slider - for now - width of the selection view = 30 times 1 second unit in the collection view  - which is 5 units = so width is 150
                                          paused: false,
                                          playing: false,
                                          trackid: self.poller.apple_mediaItems[0][0].identifier,
                                          helper_id: p1_found_id,
                                          videoid: "empty",
                                          starttime: 0 ,
                                          endtime: 0,
                                          flag: ((self.lyrics) ? "lyric" : "audio"),
                                          lyrictext: self.lyric_view.text,
                                          songname: self.poller.apple_mediaItems[0][0].name,
                                          sourceapp: self.userDefaults.string(forKey: "UserAccount")!.lowercased(),
                                          preview_url: self.poller.apple_mediaItems[0][0].previews[0]["url"] ?? "",
                                          albumArtUrl: self.poller.apple_mediaItems[0][0].artwork.imageURL(size: CGSize(width: 375, height: 375)).absoluteString,
                                          original_track_length: self.poller.apple_mediaItems[0][0].durationInMillis!,
                                          GIF_url: self.selected_GIF_url.absoluteString ?? "")
                    
                    seal.fulfill(post_from_now_playing!)
                
                }
        
            } else if (self.userDefaults.string(forKey: "UserAccount") == "Spotify") {
                print("We got to now playing spotify")
                var spotify_struct = song_db_struct()
                var worker = ISRC_worker()
                
                spotify_struct.album_name = self.poller.spotify_currently_playing_object.item!.album?.name
                spotify_struct.artist_name = self.poller.spotify_currently_playing_object.item!.artists?[0].name
                spotify_struct.isrc_number = self.poller.spotify_currently_playing_object.item!.external_ids?.isrc
                spotify_struct.playable_id = self.poller.spotify_currently_playing_object.item!.uri
                spotify_struct.preview_url = self.poller.spotify_currently_playing_object.item!.preview_url
                spotify_struct.release_date = self.poller.spotify_currently_playing_object.item!.album?.release_date
                spotify_struct.song_name = self.poller.spotify_currently_playing_object.item!.name
                
                worker.get_this_song(target_catalog: "apple", song_data: spotify_struct).done {p1_found_id in
                    print ("Heya wtf bruh")
                    print (p1_found_id)
                    print ("Heya wtf bruh")
                    if p1_found_id == "nil" {
                        print ("ERROR: Helper id not found !!!!!!!!!!!!!!!!!!!!!!")
                    } else {
                        print ("Helper id found !!!!!!!!!!!!!!!!!!!")
                    }
                    
                    
                    post_from_now_playing = Post(albumArtImage:  "",
                                          sourceAppImage:  "Spotify_cropped",
                                          typeImage: "icons8-musical-notes-50" ,
                                          profileImage:  "FullSizeRender 10-2" ,
                                          username: "Viraj",
                                          timeAgo: "Just now",
                                          numberoflikes: "0 likes",
                                          caption: self.caption_text_view.text,
                                          offset: 0.0,
                                          startoffset: start_offset,
                                          audiolength: 30.0 ,
                                          paused: false,
                                          playing: false,
                                          trackid: self.poller.spotify_currently_playing_object.item!.uri,
                                          helper_id: p1_found_id,
                                          videoid: "empty",
                                          starttime: 0 ,
                                          endtime: 0,
                                          flag: ((self.lyrics) ? "lyric" : "audio"),
                                          lyrictext: self.lyric_view.text,
                                          songname: self.poller.spotify_currently_playing_object.item!.name,
                                          sourceapp:  self.userDefaults.string(forKey: "UserAccount")!.lowercased(),
                                          preview_url: (self.poller.spotify_currently_playing_object.item!.preview_url) ?? "nil",
                                          albumArtUrl: self.poller.spotify_currently_playing_object.item!.album?.images![0].url,
                                          original_track_length: self.poller.spotify_currently_playing_object.item!.duration_ms!,
                                          GIF_url: self.selected_GIF_url.absoluteString)
                    
                    seal.fulfill(post_from_now_playing!)
                }
                
            
            }
        }
    }
*/
    
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
            if self.upload_flag != "now_playing" {
    //            destinationVC.selected_search_result_post = self.selected_search_result_post
    //            destinationVC.selected_search_result_song_db_struct = self.selected_search_result_song_db_struct
    //            destinationVC.upload_flag = self.upload_flag
    //            destinationVC.duration = self.duration
    //            destinationVC.duration_for_number_of_cells = self.duration_for_number_of_cells
    //            destinationVC.selected_search_result_post_image = self.selected_search_result_post_image
                definesPresentationContext = false //If you keep it as true then, the search bar in the controller that you push on the navigation stack remains unresponsive.

            } else {
                 destinationVC.upload_flag = self.upload_flag
                
                if (self.userDefaults.string(forKey: "UserAccount") == "Spotify") {
                  
    //                destinationVC.spotify_current_uri = self.temp_spotify_media_context_uri
    //                destinationVC.duration = self.duration
    //                destinationVC.duration_for_number_of_cells = self.duration_for_number_of_cells
                    destinationVC.uploading = true
                    
                } else if (self.userDefaults.string(forKey: "UserAccount") == "Apple") {
                    
                    if let mediaItem = self.apple_system_player.nowPlayingItem {
                      
    //                    destinationVC.apple_id = mediaItem.playbackStoreID
    //                    destinationVC.duration = Int(mediaItem.playbackDuration)
    //                    destinationVC.duration_for_number_of_cells = Int(ceil(mediaItem.playbackDuration))
                        destinationVC.uploading = true
                    }
                }
                
                
            }
            
        } else if segue.identifier == "2_to_album_display" {
             let destinationVC = segue.destination as! UploadViewControllerAlbumDisplay
            
            destinationVC.flow = self.flow
            destinationVC.albumMediaItem = self.selected_album_media_item
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
        
        if (self.uploading && (self.caption_view_bottom_constraint_to_express_view.constant == 4)) {
            self.lyric_view.endEditing(true)
            self.pane_view_for_keyboard_dismiss.isHidden = true
            print ("lyric is not hidden")
            self.search_bar_subview.layer.backgroundColor = UIColor.white.cgColor
            self.express_view.backgroundColor = UIColor.white
            self.back_button.layer.backgroundColor = UIColor.white.cgColor
            self.upload_done.layer.backgroundColor = UIColor.white.cgColor
            self.tapGesture_test_lyric_view.isEnabled = true
            self.tapGesture_test_caption_view.isEnabled = true
            
        } else if (self.uploading && (self.caption_view_bottom_constraint_to_express_view.constant == 273)) {
            self.caption_text_view.endEditing(true)
            self.pane_view_for_keyboard_dismiss.isHidden = true
            print ("caption is not hidden")
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.caption_view_bottom_constraint_to_express_view.constant = 4
            }, completion: nil)
            self.express_view.backgroundColor = UIColor.white
            self.search_bar_subview.layer.backgroundColor = UIColor.white.cgColor
            self.back_button.layer.backgroundColor = UIColor.white.cgColor
            self.upload_done.layer.backgroundColor = UIColor.white.cgColor
            self.tapGesture_test_caption_view.isEnabled = true
            self.tapGesture_test_lyric_view.isEnabled = true
        } else if upload_flag == "youtube" {
            self.url_paste_view.endEditing(true)
            self.searchController.searchBar.endEditing(true)
            self.pane_view_for_keyboard_dismiss.isHidden = true
            if self.url_paste_container_view.isHidden == true {
                self.url_paste_container_view.isHidden = false
            }
        }
    }
    
    
    func update_recently_played () {
        
        
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
        
        if !GIF_Search_is_ON {
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
            
        }  else {
            
            // Destroy current results
            searchCounter += 1
            latestSearchResponse = nil
            currentSearchPageOffset = 0
            combinedSearchGifs = [GiphyItem]()
            currentGifs = [GiphyItem]()
            fetchNextSearchPage()
        }
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.uploading {
            if self.is_selecting_audio_clip {
                print ("scrollViewDidScroll")
                self.scroller_timer.invalidate()
                self.color_animate_trailing.constant = 262.5
                print (" scroll view content offset x \(scrollView.contentOffset.x)")
                print ("collection view content size width \(self.collection_view_for_scroll.contentSize.width)")
                print ("progress bar width \(self.custom_progress_bar_bar.frame.width)")
                
                if (self.collection_view_for_scroll.contentSize.width != 0) {
                    self.slider_leading_constraint.constant = ((scrollView.contentOffset.x + 96.5) * (self.custom_progress_bar_bar.frame.width)) / (self.collection_view_for_scroll.contentSize.width)
                }
                
                var slider_constraint = Float(self.slider_leading_constraint.constant)
                var retranslate_value = round (((slider_constraint) * Float(self.duration_for_number_of_cells)) / 267)
                var minutes = Int (retranslate_value / 60)
                var seconds =  (Int(retranslate_value) - (minutes * 60))
                self.time_label.text = "\(minutes):\(seconds)"
                print (" seconds \(retranslate_value) ")
                print (" seconds offset value will be \((scrollView.contentOffset.x + 96.5) / 5)")
            } else if self.GIF_Search_is_ON {
            //GIF Search
                guard self.allowResultPaging else {
                    print ("we returning from allow result paging")
                    return
                }
                print("scrollView.contentOffset.y + scrollView.bounds.height + 100 \(scrollView.contentOffset.y + scrollView.bounds.height + 100)")
                print("scrollView.contentSize.height \(scrollView.contentSize.height)")
                if scrollView.contentOffset.y + scrollView.bounds.height + 100 >= scrollView.contentSize.height
                {
                    print ("scrollView.contentOffset.y + scrollView.bounds.height + 100 >= scrollView.contentSize.height")
                    if searchController.isActive
                    {
                        if !isSearchPageLoadInProgress && latestSearchResponse != nil
                        {
                            // Load next search page
                            fetchNextSearchPage()
                        }
                    }
                    
                }
            }
        } else {
            updateGradientFrame()
        }
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
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        
        self.youtube_player?.playVideo()
        
    }
    
    
    func setup_custom_scroller() {
        self.collection_view_for_scroll.delegate = self
        self.collection_view_for_scroll.dataSource = self
        self.collection_view_for_scroll.layer.borderColor = UIColor.clear.cgColor
        self.collection_view_for_scroll.showsHorizontalScrollIndicator = false
        self.collection_view_for_scroll.layer.backgroundColor = UIColor.clear.cgColor
        self.collection_view_for_scroll.backgroundView?.backgroundColor = UIColor.clear
        self.Selection_view.layer.backgroundColor = UIColor.clear.cgColor
        self.Selection_view.backgroundColor = UIColor.clear
        self.Selection_view.layer.cornerRadius = 5
        self.Selection_view.layer.borderWidth = 3
        print (self.Selection_view.frame.minX)
        print (self.Selection_view.frame.maxX)
        self.color_animate_view.backgroundColor = UIColor.magenta
        //self.color_animate_trailing.constant = 138
        self.color_animate_view.layer.cornerRadius = 5
        self.custom_progress_bar_container.layer.borderColor = UIColor.clear.cgColor
        self.custom_progress_bar_bar.layer.cornerRadius = 1
        self.custom_progress_bar_slider.layer.cornerRadius = 2
        self.collection_view_for_scroll.contentInset.left = 96.5 //112.5 - 16
        self.collection_view_for_scroll.contentInset.right = 96.5
        self.slider_width.constant = 15
        print ("slider_width \(self.slider_width.constant)")
        
        print ("my_collection_view.contentOffset \(self.collection_view_for_scroll.contentOffset.x)")
        print ("my_collection_view.contentOffset \(self.collection_view_for_scroll.contentOffset.y)")
        print (" custom_progress_bar_bar.frame.width\(self.custom_progress_bar_bar.frame.width)")
        self.slider_leading_constraint.constant = 0
        
    }
        
        func reset_custom_scroller () {
            
            self.slider_width.constant = 15
            self.slider_leading_constraint.constant = 0
            self.color_animate_trailing.constant = 262.5
            self.collection_view_for_scroll.setContentOffset(CGPoint(x: -97.0, y: 0.0), animated: true)
            self.time_label.text = "0:00"
        }
    
    func animate_color () {
        print ("animate color")
        print ("1")
        self.scroller_timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update_color_animate), userInfo: nil, repeats: true)
        
        //        UIView.animate(withDuration: 5.0, delay: 0, options: .curveLinear, animations: {
        //            print ("2")
        //            print ("3")
        //            self.color_animate_trailing.constant = 138
        //            self.view.layoutIfNeeded()
        //            print ("4")
        //        }, completion: nil)
        //
    }
    
    @objc func update_color_animate () {
        print ("\(Float(self.color_animate_trailing.constant))")
        if Float(self.color_animate_trailing.constant) <= 112.5 {
            self.scroller_timer.invalidate()
            self.color_animate_trailing.constant = 262.5
            self.audio_seek_to()
        } else {
            UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
                //print ("2")
                //print ("3")
                self.color_animate_trailing.constant -= 5
                self.view.layoutIfNeeded()
                //print ("4")
            }, completion: nil)
            
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print ("did end decelerating")
        
        if self.uploading && self.is_selecting_audio_clip {
            print ("\(scrollView.contentOffset.x)")
            //self.animate_color()
            if !self.scroller_timer.isValid {    //sometimes due to user action, decelerating and end dragging might happen at the same time - we don't want the timer to fire multiple times
            self.audio_seek_to()
            }
        }
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print ("did end dragging")
        
        if self.uploading && self.is_selecting_audio_clip {
            print ("\(scrollView.contentOffset.x)")
            //self.animate_color()
            if !self.scroller_timer.isValid {     //sometimes due to user action, decelerating and end dragging might happen at the same time - we don't want the timer to fire multiple times
             self.audio_seek_to()
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print ("scrollViewWillBeginDragging")
        
        
        if self.uploading && self.is_selecting_audio_clip {
            self.scroller_timer.invalidate()
            self.color_animate_trailing.constant = 262.5
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.uploading {
            if self.is_selecting_audio_clip {
                return self.duration_for_number_of_cells
            } else if self.GIF_Search_is_ON {
                print("GIF search number of items \(currentGifs?.count ?? 0)")
                return currentGifs?.count ?? 0
            }
        }
        return 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print ("cellForItemAt")
                print ("COLLECTION VIEW DEQUEUE")
                //print("collection view dequeue ")
                if self.is_selecting_audio_clip {
                    //print("collection view dequeue for audio clip selection")
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionview_cell_for_scroll_bar", for: indexPath) as! collectionview_cell_for_scroll_bar
                    //print (indexPath[1])
                    cell.center_view.backgroundColor = UIColor.black
                    cell.layer.cornerRadius = 1.5
                    cell.center_view.layer.cornerRadius = 1.5
                    
                    if (indexPath[1] % 2 == 0) {
                        //print ("cell 1")
                       
                        cell.backgroundColor = UIColor.clear
                    } else  {
                        //print ("cell2")
                        cell.backgroundColor = UIColor.black
                      
                    }
                    //print (" content size is \(self.my_collection_view.contentSize)")
                    
                    return cell
                } else {
                    // GIF Search is on
                    print ("GIF SEARCH DEQUEUE")
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kSwiftyGiphyCollectionViewCell, for: indexPath) as! SwiftyGiphyCollectionViewCell
                    
                    if let collectionViewLayout = mycollectionview2.collectionViewLayout as? SwiftyGiphyGridLayout {
                        print("collection view layout is fine")
                    } else {
                        print ("collection view layout is not fine")
                    }
                    
                    if let collectionViewLayout = mycollectionview2.collectionViewLayout as? SwiftyGiphyGridLayout, let imageSet = currentGifs?[indexPath.row].imageSetClosestTo(width: self.mycollectionViewLayout!.columnWidth, animated: true)
                    {
                        print ("calling configure for")
                        cell.configureFor(imageSet: imageSet)
                    }
                    
                    return cell

                }
    }
    
    func audio_seek_to () {
        
        let seek_to_time = ((self.collection_view_for_scroll.contentOffset.x + 96.5) / 5)
        print ("audio_seek_to")
        if (self.upload_flag == "spotify") {
            print ("spotify")
            if ((self.spotifyplayer.playbackState.isPlaying)) {
                self.animate_color()
                self.spotifyplayer.seek(to: TimeInterval(((self.collection_view_for_scroll.contentOffset.x + 96.5) / 5)), callback: {error in
                    if error != nil {
                        print (error)
                    } else {
                        print ("seeking succesfull")
                    }
                })
            } else {
                self.spotifyplayer.playSpotifyURI(spotify_current_uri!, startingWith: 0, startingWithPosition: TimeInterval(seek_to_time), callback: { (error) in
                    if (error == nil) {
                        print("playing!")
                        self.animate_color()
                    }
                    
                })
            }
        } else if (self.upload_flag == "apple") {
            print("in audio_seek_to")
            if (self.apple_player.playbackState == MPMusicPlaybackState.playing) {
                self.apple_player.currentPlaybackTime = TimeInterval(seek_to_time)
                self.animate_color()
            } else {
                self.apple_player.currentPlaybackTime = 0.0
                self.apple_player.play()
            }
        } else if (self.upload_flag == "youtube") {
            print("in audio_seek_to")
            //print (self.audio_scrubber_ot.value)
            self.youtube_player.seek(toSeconds: Float(seek_to_time), allowSeekAhead: true)
        } else if (self.upload_flag == "now_playing") {
            print ("now_playing")
            print ("\(self.userDefaults.string(forKey: "UserAccount"))")
            if (self.userDefaults.string(forKey: "UserAccount") == "Apple") {
                    print ("now playing Apple")
               // if self.apple_system_player.playbackState == .playing {
                   // print ("trying to ring in system player")
                    if (self.apple_player.playbackState == MPMusicPlaybackState.playing) {
                        self.apple_player.currentPlaybackTime = TimeInterval(seek_to_time)
                        self.animate_color()
                    } else {
                        self.apple_player.currentPlaybackTime = 0.0
                        self.apple_player.play()
                    }
                    //self.poller.apple_system_player.currentPlaybackTime = TimeInterval(((self.collection_view_for_scroll.contentOffset.x + 96.5) / 5) * 1000)
                   // self.poller.internal_keep_time = self.poller.apple_system_player.currentPlaybackTime
                //}
            } else if (self.userDefaults.string(forKey: "UserAccount") == "Spotify") {
                print ("now playing spotify")
            
                //print (TimeInterval(self.audio_scrubber_ot.value / 1000))
                print (spotify_current_uri)
                if ((self.spotifyplayer.playbackState.isPlaying)) {
                    print ("Spotify Is playing trying to seek to \(TimeInterval(seek_to_time))")
                    
                    self.spotifyplayer.seek(to: TimeInterval(seek_to_time), callback: { error in
                        if error != nil {
                            print (error)
                        } 
                    })
                    self.animate_color()
                } else {
                    self.spotifyplayer.playSpotifyURI(spotify_current_uri!, startingWith: 0, startingWithPosition: TimeInterval(seek_to_time),  callback: { (error) in
                        if (error == nil) {
                            print("playing!")
                            self.animate_color()
                        }
                        
                    })
                }
            }
            
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
            print("buffering youtube")
            break;
        case YTPlayerState.ended:
            print("ended youtube")
            break;
        case YTPlayerState.playing:
            print("playing youtube")
            self.animate_color()
            break;
        case YTPlayerState.paused:
            print("paused youtube")
        default:
            break;
            
            
        }
    }
    
    
    
}


//MARK: SearchBar Delegate

extension UploadViewController2: UISearchBarDelegate {
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
       if searchBar.tag == 1 {
            self.searchController.searchBar.isHidden = false
            self.searchController.searchBar.placeholder = "Search GIFs"
            self.searchController.searchBar.text = ""
            if (!self.searchController.isActive) {
                self.searchController.isActive = true
            }
            self.GIF_SearchBar.endEditing(true)
            self.express_view_to_search_bar_super_container.constant = 5
            //self.GIF_SearchBar_top_to_express_view.constant = -60
            //self.Text_or_animation_switch_top_to_express_view.constant = -51
            self.GIF_SearchBar.isHidden = true
            self.text_or_animation_switch.isHidden = true
            self.back_button.isHidden = true
            self.upload_done.isHidden = true
            self.selected_GIF_view.isHidden = true
            self.GIF_Search_is_ON = true
            
            if #available(iOS 11, *)
            {
                print("collection view content insets ios 11")
                mycollectionview2.contentInset = UIEdgeInsets.init(top: 24.0, left: 0.0, bottom: 5.0, right: 0.0)
                mycollectionview2.scrollIndicatorInsets = UIEdgeInsets.init(top: 24.0, left: 0.0, bottom: 5.0, right: 0.0)
            }
            else
            {
                print("collection view content inset")
                mycollectionview2.contentInset = UIEdgeInsets.init(top: self.topLayoutGuide.length + 24.0, left: 0.0, bottom: 10.0, right: 0.0)
                mycollectionview2.scrollIndicatorInsets = UIEdgeInsets.init(top: self.topLayoutGuide.length + 24.0, left: 0.0, bottom: 10.0, right: 0.0)
            }
            
            if let mycollectionViewLayout = mycollectionview2.collectionViewLayout as? SwiftyGiphyGridLayout
            {
                print ("GRID LAYOUT DELEGATE SET!!!!!!!!!!!!!!!!!!!!!!! ")
                self.mycollectionViewLayout!.delegate = self
            }
            
            mycollectionview2.isHidden = false
            //self.text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-cancel-50"), for: .normal)
        } else {
            if (!self.GIF_Search_is_ON) {
                self.pane_view_for_keyboard_dismiss.isHidden = false
                //self.view.bringSubview(toFront: self.pane_view_for_keyboard_dismiss)
                self.url_paste_container_view.isHidden = true
                self.view.sendSubviewToBack(self.url_paste_container_view)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
     if searchBar.tag == 1 {
            self.express_view_to_search_bar_super_container.constant = 319
            self.GIF_SearchBar_top_to_express_view.constant = 4
            self.Text_or_animation_switch_top_to_express_view.constant = 13
            self.GIF_Search_is_ON = false
            self.text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-type-60"), for: .normal)
            
        } else {
            if (self.GIF_Search_is_ON) {
                self.searchController.searchBar.placeholder = "Search Apple Music"
                self.searchController.searchBar.text = ""
                self.searchController.searchBar.isHidden = true
                self.GIF_SearchBar.endEditing(true)
                self.express_view_to_search_bar_super_container.constant = 319
                self.GIF_Search_is_ON = false
                self.GIF_SearchBar.isHidden = false
                self.text_or_animation_switch.isHidden = false
                self.back_button.isHidden = false
                self.upload_done.isHidden = false
                self.selected_GIF_view.isHidden = false
                self.mycollectionview2.isHidden = true
            } else {
                setterQueue.sync {
                    self.mediaItems = []
                    self.spotify_mediaItems = []
                    self.video_search_results = []
                }
                
                self.pane_view_for_keyboard_dismiss.isHidden = true
                //self.view.sendSubview(toBack: self.pane_view_for_keyboard_dismiss)
                if self.upload_flag == "youtube" {
                    self.url_paste_container_view.isHidden = false
                    self.view.bringSubviewToFront(self.url_paste_container_view)
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      if searchBar.tag == 1 {
            searchCounter += 1
            latestSearchResponse = nil
            currentSearchPageOffset = 0
            combinedSearchGifs = [GiphyItem]()
            currentGifs = [GiphyItem]()
            fetchNextSearchPage()
        } else {
            if (!self.GIF_Search_is_ON) {
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
            } else {
                // MARK: GIF Search
                
            }
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

extension UploadViewController2 {
    
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        //print("heightForPhotoAtIndexPath")
        guard let imageSet = currentGifs?[indexPath.row].imageSetClosestTo(width: withWidth, animated: true) else {
            return 0.0
        }
        //print("\(AVMakeRect(aspectRatio: CGSize(width: imageSet.width, height: imageSet.height), insideRect: CGRect(x: 0.0, y: 0.0, width: withWidth, height: CGFloat.greatestFiniteMagnitude)).height)")
        //print ("collection view height \(self.mycollectionview2.frame.height)")
        //print ("collection view width \(self.mycollectionview2.frame.width)")
        //print ("collection contentSize height \(self.mycollectionview2.contentSize.height)")
        //print ("collection contentSize width \(self.mycollectionview2.contentSize.width)")
        //print ("collection X position \(self.mycollectionview2.frame.minX)")
        //print ("collection Y position \(self.mycollectionview2.frame.minY)")
        return AVMakeRect(aspectRatio: CGSize(width: imageSet.width, height: imageSet.height), insideRect: CGRect(x: 0.0, y: 0.0, width: withWidth, height: CGFloat.greatestFiniteMagnitude)).height
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let selectedimageSet = currentGifs![indexPath.row].imageSetClosestTo(width: self.selected_GIF_view.frame.width, animated: true)
        let imageSetforNewsFeedPost = currentGifs![indexPath.row].imageSetClosestTo(width: 351.0, animated: true) // Set it for the width of the GIF image view in the Post cell.
        //let selectedGif = currentGifs![indexPath.row]
        self.searchController.searchBar.placeholder = "Search Apple Music"
        self.searchController.searchBar.text = ""
        self.searchController.searchBar.isHidden = true
        self.back_button.isHidden = false
        self.upload_done.isHidden = false
        self.text_or_animation_switch.isHidden = false
        self.searchController.isActive = false
        self.searchController.searchBar.endEditing(true)
        self.mycollectionview2.isHidden = true
        //DO STUFF HERE
        self.GIF_SearchBar.endEditing(true)
        self.GIF_SearchBar.isHidden = false
        self.express_view_to_search_bar_super_container.constant = 319
        self.GIF_SearchBar_top_to_express_view.constant = 4
        self.Text_or_animation_switch_top_to_express_view.constant = 13
        self.GIF_Search_is_ON = false
        self.text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-type-60"), for: .normal)
        self.selected_GIF_view.sd_setShowActivityIndicatorView(true)
        self.selected_GIF_view.sd_setIndicatorStyle(.gray)
        print ("selected GIF url is \(selectedimageSet?.url)")
        self.selected_GIF_view.sd_setImage(with: selectedimageSet?.url)
        self.selected_GIF_url = imageSetforNewsFeedPost?.url
        self.selected_GIF_view.isHidden = false
    }
    
    func fetchNextSearchPage()
    {
        mycollectionview2.isHidden = false
        print ("collection view height \(self.mycollectionview2.frame.height)")
        print ("collection view width \(self.mycollectionview2.frame.width)")
        print ("collection contentSize height \(self.mycollectionview2.contentSize.height)")
        print ("collection contentSize width \(self.mycollectionview2.contentSize.width)")
        print("fetchNextSearchPage 1")
        guard !isSearchPageLoadInProgress else {
            print ("we returning")
            return
        }
        print("fetchNextSearchPage 2")
        guard let searchText = searchController.searchBar.text, searchText.count > 0 else {
            
            self.searchCounter += 1
            self.currentGifs = combinedTrendingGifs
            return
        }
        print("fetchNextSearchPage 3")
        searchCoalesceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, block: { [unowned self] () -> Void in
          print("fetchNextSearchPage 4")
            self.isSearchPageLoadInProgress = true
            
            if self.currentGifs?.count ?? 0 == 0
            {
                //self.loadingIndicator.startAnimating()
                //self.errorLabel.isHidden = true
            }
            print("fetchNextSearchPage 5")
            self.searchCounter += 1
            
            let currentCounter = self.searchCounter
            print("fetchNextSearchPage 6")
            let maxBytes = self.maxSizeInBytes
            let width = max((self.mycollectionview2.collectionViewLayout as? SwiftyGiphyGridLayout)?.columnWidth ?? 0.0, 0.0)
            print("fetchNextSearchPage 7")
            SwiftyGiphyAPI.shared.getSearch(searchTerm: searchText, limit: 100, rating: self.contentRating, offset: self.currentSearchPageOffset) { [weak self] (error, response) in
                
                self?.isSearchPageLoadInProgress = false
                
                guard currentCounter == self?.searchCounter else {
                    
                    return
                }
                print("fetchNextSearchPage 8")
                //self?.loadingIndicator.stopAnimating()
                //self?.errorLabel.isHidden = true
                
                guard error == nil else {
                    print("fetchNextSearchPage 9")
                    if self?.currentGifs?.count ?? 0 == 0
                    {
                        //self?.errorLabel.text = error?.localizedDescription
                        //self?.errorLabel.isHidden = false
                    }
                    
                    print("Giphy error: \(String(describing: error?.localizedDescription))")
                    return
                }
                print("fetchNextSearchPage 10")
                self?.latestSearchResponse = response
                self?.combinedSearchGifs.append(contentsOf: response!.gifsSmallerThan(sizeInBytes: maxBytes, forWidth: width))
                self?.currentSearchPageOffset = (response!.pagination?.offset ?? (self?.currentSearchPageOffset ?? 0)) + (response!.pagination?.count ?? 0)
                
                self?.currentGifs = self?.combinedSearchGifs
                
                self?.mycollectionview2.reloadData()
                
                if self?.currentGifs?.count ?? 0 == 0
                {
                    print("No GIFs match this search")
                    //self?.errorLabel.text = NSLocalizedString("No GIFs match this search.", comment: "No GIFs match this search.")
                    //self?.errorLabel.isHidden = false
                }
            }
            }, repeats: false) as! Timer?
        print("fetchNextSearchPage 11")
    }
    
 
    
    
    
    
    
    
}
