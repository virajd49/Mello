//
//  UploadViewController3.swift
//  Project2
//
//  Created by virdeshp on 6/11/19.
//  Copyright © 2019 Viraj. All rights reserved.
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


class UploadViewController3: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, UITextViewDelegate, YTPlayerViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, SwiftyGiphyGridLayoutDelegate {
    
    
   
    @IBOutlet weak var Express_view: UIView!
    @IBOutlet weak var GIFSearch_Bar: UISearchBar!
    @IBOutlet weak var Caption_text_view: UITextView!
    @IBOutlet weak var Text_or_animation_switch: UIButton!
    @IBOutlet weak var Mycollectionview2: UICollectionView!
    @IBOutlet weak var SelectedGIF_view: FLAnimatedImageView!
    @IBOutlet weak var Custom_progress_bar_container: UIView!
    @IBOutlet weak var Custom_progress_bar_bar: UIView!
    @IBOutlet weak var Custom_progress_bar_slider: UIView!
    @IBOutlet weak var Color_animate_view: UIView!
    @IBOutlet weak var Selection_view: UIView!
    @IBOutlet weak var Artist_name_label: UILabel!
    @IBOutlet weak var Time_label: UILabel!
    @IBOutlet weak var Song_name_label: UILabel!
    @IBOutlet weak var Now_playing_image: UIImageView!
    @IBOutlet weak var Youtube_player: YTPlayerView!
    @IBOutlet weak var Lyric_view: UITextView!
    @IBOutlet weak var Select_audio_clip_button: UIButton!
    
    @IBOutlet weak var Express_button: UIButton!
    @IBOutlet weak var Album_art_or_lyric_switch: UIButton!
    
    @IBOutlet weak var now_playing_progress_bar: UIProgressView!
    // @IBOutlet weak var Text_or_animation_switch_top_to_express_view: NSLayoutConstraint!
    @IBOutlet weak var GIF_SearchBar_top_to_express_view: NSLayoutConstraint!
    
     @IBOutlet weak var caption_view_bottom_constraint_to_express_view: NSLayoutConstraint!
    
    @IBOutlet weak var slider_width: NSLayoutConstraint!
    @IBOutlet weak var slider_leading_constraint: NSLayoutConstraint!
    @IBOutlet weak var color_animate_trailing: NSLayoutConstraint!
    
    @IBOutlet weak var pane_view_for_keyboard_dismiss: UIView!
    @IBOutlet weak var collection_view_for_scroll: UICollectionView!
    @IBOutlet weak var express_view_to_search_bar_super_container: NSLayoutConstraint!
    let searchController = UISearchController(searchResultsController: nil)
    let kSwiftyGiphyCollectionViewCell = "SwiftyGiphyCollectionViewCell"
    var allowResultPaging: Bool = true
    var is_selecting_animation: Bool = false
    var is_selecting_audio_clip: Bool = false
    var GIF_Search_is_ON: Bool = false
    var poller = now_playing_poller.shared
    var spotifyplayer =  SPTAudioStreamingController.sharedInstance()
    var apple_player = MPMusicPlayerController.applicationMusicPlayer
    var apple_system_player = MPMusicPlayerController.systemMusicPlayer
    var spotify_current_uri: String?
    var apple_id: String?
    var yt_id: String?
    var scroller_timer = Timer()
    
    var my_table: UITableView?
    var search_result_count: Int = 0
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
    var selected_search_result_song_db_struct = song_db_struct()
    var selected_search_result_post_image: UIImage!
    private let service = GTLRYouTubeService()
    
    //MARK: GIPHY Variables
    var currentGifs: [GiphyItem]? {
        didSet {
            print("currentGIFS did Set")
            Mycollectionview2.reloadData()
        }
    }
    
    var mycollectionViewLayout: SwiftyGiphyGridLayout? {
        get {
            print ("mycollectionViewLayout get")
            return Mycollectionview2.collectionViewLayout as? SwiftyGiphyGridLayout
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
    var setterQueue = DispatchQueue(label: "UploadViewController3")
    var upload_flag = "default"
    let gradient = CAGradientLayer()
    var post_help = Post_helper()             //This is required because sometimes in spotify if the song is part of a compilation - made by a user
    var secondary_image_url: URL?             //- then it picks up the album art for that compilation instead of the actual album art. So we
    var secondary_image: UIImage?             // do a search by URI to get the album art of the actual song - store it in secondary_image_url and give the user an option.
    var tapGesture_test_lyric_view: UITapGestureRecognizer!
    var tapGesture_test_caption_view: UITapGestureRecognizer!
    
    func hide_custom_scrolling_aparattus_toggle (set: Bool) {
        if set {
            self.Custom_progress_bar_container.isHidden = true
            self.collection_view_for_scroll.isHidden = true
            self.collection_view_for_scroll.isUserInteractionEnabled = false
            self.collection_view_for_scroll.isScrollEnabled = false
            self.Selection_view.isHidden = true
            self.Color_animate_view.isHidden = true
            self.Time_label.isHidden = true
            
        } else {
            self.Custom_progress_bar_container.isHidden = false
            self.collection_view_for_scroll.isHidden = false
            self.collection_view_for_scroll.isUserInteractionEnabled = true
            self.collection_view_for_scroll.isScrollEnabled = true
            self.Selection_view.isHidden = false
            self.Color_animate_view.isHidden = false
            self.Time_label.isHidden = false
            
            
        }
    }
    
    
    //MARK: ViewWillAppear
    
    
    override func viewWillAppear(_ animated: Bool) {
        let height: CGFloat = 50 //whatever height you want to add to the existing height
        let bounds = self.navigationController!.navigationBar.bounds
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let height: CGFloat = 50 //whatever height you want to add to the existing height
        let bounds = self.navigationController!.navigationBar.bounds
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
        
    }
    
    func toggle_hide_upload_selection (hide: Bool) {
        if hide {
            self.Now_playing_image.isHidden = true
             //why is this not working?
            self.now_playing_progress_bar.isHidden = true        //why is this not working? : Using the 'uploading' flag in back_button to prevent scrolling when the view is hidden for now
            hide_custom_scrolling_aparattus_toggle(set : true)
            self.Song_name_label.isHidden = true
            self.Artist_name_label.isHidden = true
            self.Select_audio_clip_button.isHidden = true
            self.Express_button.isHidden = true
            self.Lyric_view.isHidden = true
            self.Express_view.isHidden = true
            self.Caption_text_view.isHidden = true
            self.GIFSearch_Bar.isHidden = true
            self.Album_art_or_lyric_switch.isHidden = true
            //self.is_selecting_audio_clip = false
            self.is_selecting_audio_clip = true
            self.is_selecting_animation = false
        } else {
            self.Now_playing_image.isHidden = false
              //same as above two comments
            self.now_playing_progress_bar.isHidden = true      //same as above two comments
            hide_custom_scrolling_aparattus_toggle(set : false)
            self.Song_name_label.isHidden = false
            self.Artist_name_label.isHidden = false
            self.Album_art_or_lyric_switch.isHidden = false
            self.Express_button.isHidden = false
            self.is_selecting_audio_clip = true
        }
    }
    
    
    //MARK: ViewDidload
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let height: CGFloat = 20 //whatever height you want to add to the existing height
        let bounds = self.navigationController!.navigationBar.bounds
        print ("nav bar height is \(bounds.height)")
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
        print ("nav bar height is \(bounds.height)")
        toggle_hide_upload_selection(hide: false)
        hide_custom_scrolling_aparattus_toggle(set : false)
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(tapEdit2(recognizer:)))
        tapGesture2.delegate = self.Now_playing_image as? UIGestureRecognizerDelegate
        
        tapGesture_test_lyric_view = UITapGestureRecognizer(target: self, action: #selector(tapEdit_test_for_lyric_view(recognizer:)))
        self.Lyric_view.addGestureRecognizer(tapGesture_test_lyric_view)
        tapGesture_test_lyric_view.delegate = self.Lyric_view as! UIGestureRecognizerDelegate
        
        
        tapGesture_test_caption_view = UITapGestureRecognizer(target: self, action: #selector(tapEdit_test_for_caption_view(recognizer:)))
        self.Caption_text_view.addGestureRecognizer(tapGesture_test_caption_view)
        tapGesture_test_caption_view.delegate = self.Caption_text_view as! UIGestureRecognizerDelegate
        //      self.audio_scrubber_ot?.addGestureRecognizer(longPress)
        //      longPress.delegate = audio_scrubber_ot as? UIGestureRecognizerDelegate
        //        longPress.minimumPressDuration = 0.1
        //        longPress.allowableMovement = 200
       
        
        
        GIFSearch_Bar.delegate = self
        GIFSearch_Bar.searchBarStyle = UISearchBarStyle.minimal
        self.GIFSearch_Bar.isHidden = true
        
        Now_playing_image.layer.cornerRadius = 10
        Youtube_player.isHidden = true
        Youtube_player.delegate = self
      
        let cancelButtonAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
        
        let keyboard_dismiss_tap = UITapGestureRecognizer(target: self, action: #selector(UploadViewController3.dismiss_keyboard))
        
        self.spotifyplayer.playbackDelegate = self as SPTAudioStreamingPlaybackDelegate
        self.spotifyplayer.delegate = self as SPTAudioStreamingDelegate
        
        service.apiKey = (userDefaults.value(forKey: "google_api_key") as! String)
        
       
        
        hide_custom_scrolling_aparattus_toggle(set : false)
        Select_audio_clip_button.isHidden = true
        
      
        self.Time_label.text = "0:00"
        
        
        self.Express_button.layer.borderColor = UIColor.black.cgColor
        self.Express_button.layer.cornerRadius = 5
        
        self.Text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-type-60"), for: .normal)
        
        self.Lyric_view.layer.cornerRadius = 10
        self.Lyric_view.delegate = self
        self.Lyric_view.tintColor = UIColor.lightGray
        self.Lyric_view.isHidden = true
        self.Express_view.layer.cornerRadius = 5
        self.Express_view.layer.borderWidth = 2
        self.Express_view.layer.borderColor = UIColor.black.cgColor
        self.Express_view.isHidden = true
        
        
        
        self.Caption_text_view.delegate = self
        self.Caption_text_view.layer.cornerRadius = 5
        self.Caption_text_view.tintColor = UIColor.black
        setup_custom_scroller()
        
        collection_view_for_scroll.tag = 1
        
        // MARK: Collection View for GIPHY
        Mycollectionview2.tag = 2
        Mycollectionview2.collectionViewLayout = SwiftyGiphyGridLayout()
        Mycollectionview2.backgroundColor = UIColor.clear
        Mycollectionview2.delegate = self
        Mycollectionview2.dataSource = self
        Mycollectionview2.layer.cornerRadius = 10
        Mycollectionview2.keyboardDismissMode = .interactive
        
        Mycollectionview2.isHidden = true
        SelectedGIF_view.isHidden = true
        SelectedGIF_view.translatesAutoresizingMaskIntoConstraints = false
        SelectedGIF_view.clipsToBounds = true
        Mycollectionview2.translatesAutoresizingMaskIntoConstraints = false
        Mycollectionview2.register(SwiftyGiphyCollectionViewCell.self, forCellWithReuseIdentifier: kSwiftyGiphyCollectionViewCell)
        
        if let mycollectionViewLayout = Mycollectionview2.collectionViewLayout as? SwiftyGiphyGridLayout
        {
            print ("GRID LAYOUT DELEGATE SET!!!!!!!!!!!!!!!!!!!!!!! ")
            self.mycollectionViewLayout!.delegate = self
        }
        
        
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Posts"
        searchController.searchBar.delegate = self
        //self.search_bar_container.addSubview(searchController.searchBar)
        searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchController.searchBar.isHidden = true
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        setup_selected_media()
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            // Your code...
            //toggle_hide_upload_selection(hide: true)
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
            } else if (self.upload_flag == "apple") {
                if (self.apple_player.playbackState == .playing) {
                    self.apple_player.stop()
                }
            } else if (self.upload_flag == "youtube") {
                if (self.Youtube_player.playerState() == YTPlayerState.playing || self.Youtube_player.playerState() == YTPlayerState.paused) {
                    self.Youtube_player.stopVideo()
                }
                
                self.Youtube_player.isHidden = true
            } else if (self.upload_flag == "now_playing") {
                
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
            print ("Invalidating scroller_timer 4")
            self.scroller_timer.invalidate()
            //self.timer.invalidate()
            //self.audio_scrubber_ot.value = 0.0
            print ("scroll enabled \(self.collection_view_for_scroll.isScrollEnabled)")
            print ("touch enabled \(self.collection_view_for_scroll.isUserInteractionEnabled)")
            
        }
    }
    
    
    func setup_selected_media () {
        print("In setup_selected_media ")
        print ("upload flag is \(self.upload_flag)")
        print ("past the checks")
        self.duration = (self.selected_search_result_post.original_track_length) / 1000
        self.duration_for_number_of_cells = Int(ceil(Double(self.selected_search_result_post.original_track_length) / 1000))
        self.collection_view_for_scroll.reloadData()
        print ("past the checks 2 - duration for number of cells \(self.duration_for_number_of_cells)")
        self.slider_width.constant = (self.Custom_progress_bar_bar.frame.width * self.Selection_view.frame.width) / CGFloat((self.duration_for_number_of_cells * 5) - 3)
        print ("slider width is \(self.slider_width.constant)")
        print ("past the checks 3")
        self.slider_leading_constraint.constant = 0
        print ("past the checks 4")
        self.color_animate_trailing.constant = 262.5
        print ("past the checks 5")
        self.collection_view_for_scroll.setContentOffset(CGPoint(x: -97.0, y: 0.0), animated: true)
        print ("past the checks 6")
        self.collection_view_for_scroll.reloadData()
        if self.upload_flag != "youtube" {
            print (" != youtube")
            self.Youtube_player.isHidden = true
            
            //self.search_bar_container.bringSubview(toFront: self.back_button)
            
            if (self.upload_flag == "spotify") {
                print(" setup_selected_media == spotify")
                self.Now_playing_image.image = self.selected_search_result_post_image
                self.spotifyplayer.playSpotifyURI(self.selected_search_result_post.trackid, startingWith: 0, startingWithPosition: 0.0, callback: { (error) in
                    if (error == nil) {
                        print("playing!")
                        self.animate_color()
                    }
                })
                //self.audio_scrubber_ot.maximumValue = Float(tappedCell.spotify_mediaItem.duration_ms!)
                //self.test_slider.maximumValue = Float(tappedCell.spotify_mediaItem.duration_ms!)
                self.duration = (self.selected_search_result_post.original_track_length) / 1000
                self.duration_for_number_of_cells = Int(ceil(Double(self.selected_search_result_post.original_track_length) / 1000))
                print (self.selected_search_result_post.original_track_length)
                print (Float(self.selected_search_result_post.original_track_length) / 1000)
                //print(self.audio_scrubber_ot.maximumValue)
                self.spotify_current_uri = self.selected_search_result_post.trackid
                self.Song_name_label.text = self.selected_search_result_post.songname
                self.Artist_name_label.text = ""
                //self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateScrubber), userInfo: nil, repeats: true)
                self.uploading = true
            } else if (self.upload_flag == "apple") {
                print ("asetup_selected_media pple")
                self.Now_playing_image.image = self.selected_search_result_post_image
                self.apple_player.setQueue(with: [self.selected_search_result_post.trackid])
                self.apple_player.play()
                self.apple_player.currentPlaybackTime = 30.0
                self.animate_color()
                //self.audio_scrubber_ot.maximumValue = Float(tappedCell.mediaItem.durationInMillis!)
                //self.test_slider.maximumValue = Float(tappedCell.mediaItem.durationInMillis!)
                print (self.selected_search_result_post.original_track_length)
                print (Float(self.selected_search_result_post.original_track_length) / 1000)
                self.duration = (self.selected_search_result_post.original_track_length) / 1000
                self.duration_for_number_of_cells = Int(ceil(Double(self.selected_search_result_post.original_track_length) / 1000))
                //print(self.audio_scrubber_ot.maximumValue)
                self.apple_id = self.selected_search_result_post.trackid
                self.Song_name_label.text = self.selected_search_result_post.songname
                self.Artist_name_label.text = ""
                self.uploading = true
            }
            
        } else  {
            print (" == youtube")
            self.Youtube_player.isHidden = false
            
            self.Youtube_player.load(withVideoId: self.selected_search_result_post.videoid ?? "" , playerVars: ["autoplay": 1, "playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 1, "rel": 0, "iv_load_policy": 3])
            self.Youtube_player.playVideo()
            self.Song_name_label.text = self.selected_search_result_post.songname
            self.Artist_name_label.text = ""
            
        }
//        print ("past the checks")
//        self.collection_view_for_scroll.reloadData()
//        print ("past the checks 2 - duration for number of cells \(self.duration_for_number_of_cells)")
//        self.slider_width.constant = (self.Custom_progress_bar_bar.frame.width * self.Selection_view.frame.width) / CGFloat((self.duration_for_number_of_cells * 5) - 3)
//        print ("slider width is \(self.slider_width.constant)")
//        print ("past the checks 3")
//        self.slider_leading_constraint.constant = 0
//        print ("past the checks 4")
//        self.color_animate_trailing.constant = 262.5
//        print ("past the checks 5")
//        self.collection_view_for_scroll.setContentOffset(CGPoint(x: -97.0, y: 0.0), animated: true)
//        print ("past the checks 6")
//        self.collection_view_for_scroll.reloadData()
        
    }
    
   
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func dismiss_chevron(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func back_button(_ sender: Any) {
        //toggle_hide_upload_selection(hide: true)
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
        } else if (self.upload_flag == "apple") {
            if (self.apple_player.playbackState == .playing) {
                self.apple_player.stop()
                
            }
        } else if (self.upload_flag == "youtube") {
            if (self.Youtube_player.playerState() == YTPlayerState.playing || self.Youtube_player.playerState() == YTPlayerState.paused) {
                self.Youtube_player.stopVideo()
            }
          
            self.Youtube_player.isHidden = true
        } else if (self.upload_flag == "now_playing") {
            
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
        print ("Invalidating scroller_timer 5")
        self.scroller_timer.invalidate()
        //self.timer.invalidate()
        //self.audio_scrubber_ot.value = 0.0
        print ("scroll enabled \(self.collection_view_for_scroll.isScrollEnabled)")
        print ("touch enabled \(self.collection_view_for_scroll.isUserInteractionEnabled)")
        
    }
    
    
    
    @IBAction func express_button_action(_ sender: Any) {
        
        
        
            
            
            self.is_selecting_animation = true
            self.is_selecting_audio_clip = false
            self.Express_button.isHidden = true
            self.Select_audio_clip_button.isHidden = false
            
            //show express_view
            self.Express_view.isHidden = false
            
            
            //Hide selection view
            self.Custom_progress_bar_container.isHidden = true
            self.Selection_view.isHidden = true
            self.collection_view_for_scroll.isHidden = true
            self.Color_animate_view.isHidden = true
            self.Time_label.isHidden = true
            self.Caption_text_view.isHidden = true
            self.GIFSearch_Bar.isHidden = false
            self.Text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-type-60"), for: .normal)
            
        
        
        
    }
    
    
    @IBAction func album_art_or_lyric_switch_action(_ sender: Any) {
        print ("album_art_or_lyric_switch_action")
        if self.Now_playing_image.isHidden &&  !self.Lyric_view.isHidden {
            self.Now_playing_image.isHidden = false
            self.Lyric_view.isHidden = true
            self.lyrics = false
            self.Album_art_or_lyric_switch.setBackgroundImage(UIImage(named: "icons8-l-filled-100"), for: .normal)
        } else if self.Lyric_view.isHidden  && !self.Now_playing_image.isHidden {
            self.Lyric_view.isHidden = false
            self.Now_playing_image.isHidden = true
            self.lyrics = true
            self.Album_art_or_lyric_switch.setBackgroundImage(UIImage(named: "icons8-xlarge-icons-filled-100"), for: .normal)
        }
        
        
    }
    
    @IBAction func text_or_animation_switch_action(_ sender: Any) {
        print("text_or_animation_switch_action")
        if self.GIF_Search_is_ON {
            self.GIFSearch_Bar.endEditing(true)
            self.express_view_to_search_bar_super_container.constant = 370
            self.GIF_SearchBar_top_to_express_view.constant = 4
            //self.Text_or_animation_switch_top_to_express_view.constant = 13
            self.GIF_Search_is_ON = false
            self.Text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-type-60"), for: .normal)
            
        } else {
            
            if self.is_selecting_animation {
                self.is_selecting_animation = false
                self.Caption_text_view.isHidden = false
                self.GIFSearch_Bar.isHidden = true
                self.Text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-typography-52"), for: .normal)
            } else {
                self.is_selecting_animation = true
                self.Caption_text_view.isHidden = true
                self.GIFSearch_Bar.isHidden = false
                self.Text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-type-60"), for: .normal)
            }
        }
        
    }
    
    @IBAction func select_audio_clip_show_hide(_ sender: Any) {
        
        
            
            self.is_selecting_animation = false
            self.is_selecting_audio_clip = true
            
            self.collection_view_for_scroll.reloadData()
            
            self.Express_button.isHidden = false
            self.Select_audio_clip_button.isHidden = true
            
            self.Express_view.isHidden = true
            self.Caption_text_view.isHidden = true
            self.Selection_view.isHidden = false
            self.collection_view_for_scroll.isHidden = false
            self.Color_animate_view.isHidden = false
            self.Custom_progress_bar_container.isHidden = false
            self.Time_label.isHidden = false
            
            
                
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("text view did begin editing")
        if textView.textColor ==  UIColor.lightGray {
            textView.text = nil
            if !self.Lyric_view.isHidden {
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
            self.Youtube_player.seek(toSeconds: Float(seek_to_time), allowSeekAhead: true)
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
                
              
                
                
                
                if self.presentingViewController is UploadViewController3 {
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
        print ("Invalidating scroller_timer 6")
        self.scroller_timer.invalidate()
    }
    
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
            if self.Youtube_player.playerState() == YTPlayerState.playing {
                self.Youtube_player.stopVideo()
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
    
    
  
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.search_result_count
    }
    
   
    @objc func tapEdit2(recognizer: UITapGestureRecognizer)  {
        print ("tapEdit2 called ")
        
        //the miniplayer should fade out and the final upload page should show up
        //we get the media item data from the now playing poller
        
        
        //toggle_hide_upload_selection(hide: false)
        
        //get the song id from the current_playing_context and play the song from the start in our own player - this should stop the system player
        
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
            self.Song_name_label.text = self.poller.spotify_currently_playing_object.item?.name
            self.Artist_name_label.text = self.poller.spotify_currently_playing_object.item?.artists?[0].name
            self.uploading = true
        } else if (self.userDefaults.string(forKey: "UserAccount") == "Apple") {
            
            print ("now playing tap edit - account Apple")
            if let mediaItem = self.apple_system_player.nowPlayingItem {
                print ("\(mediaItem.playbackDuration)")
                self.apple_system_player.pause()
                self.apple_player.setQueue(with: [mediaItem.playbackStoreID as! String])
                self.apple_player.play()
                self.apple_player.currentPlaybackTime = 0.0
                self.animate_color()
                print (mediaItem.playbackDuration)
                print (mediaItem.playbackStoreID)
                //self.audio_scrubber_ot.maximumValue = Float(mediaItem.playbackDuration)
                //self.test_slider.maximumValue = Float(mediaItem.playbackDuration)
                self.apple_id = mediaItem.playbackStoreID
                self.duration = Int(mediaItem.playbackDuration)
                self.duration_for_number_of_cells = Int(ceil(mediaItem.playbackDuration))
                self.Song_name_label.text = mediaItem.title
                self.Artist_name_label.text = mediaItem.artist
                self.uploading = true
            }
        }
        
        self.collection_view_for_scroll.reloadData()
        print (self.collection_view_for_scroll.contentSize.width)
        print (self.Custom_progress_bar_bar.frame.width)
        print (self.Selection_view.frame.width)
        self.slider_width.constant = (self.Custom_progress_bar_bar.frame.width * self.Selection_view.frame.width) / CGFloat((self.duration_for_number_of_cells * 5) - 3)
        self.slider_leading_constraint.constant = 0
        self.color_animate_trailing.constant = 262.5
        self.collection_view_for_scroll.setContentOffset(CGPoint(x: -97.0, y: 0.0), animated: true)
        
    }
   
    @objc func tapEdit_test_for_lyric_view(recognizer: UITapGestureRecognizer) {
        
        print ("tap gesture lyric")
        self.pane_view_for_keyboard_dismiss.isHidden = false
        if !self.Lyric_view.isHidden {
            self.Express_view.backgroundColor = UIColor.clear
            //self.search_bar_subview.layer.backgroundColor = UIColor.black.withAlphaComponent(0.7).cgColor
            
        }
        self.Lyric_view.becomeFirstResponder()
        self.tapGesture_test_lyric_view.isEnabled = false
        self.tapGesture_test_caption_view.isEnabled = false
        
        
        
    }
    
    @objc func tapEdit_test_for_caption_view(recognizer: UITapGestureRecognizer) {
        
        
        print("tap gesture caption")
        self.pane_view_for_keyboard_dismiss.isHidden = false
        
        if !self.Caption_text_view.isHidden {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.caption_view_bottom_constraint_to_express_view.constant = 273
            }, completion: nil)
            self.Express_view.backgroundColor = UIColor.clear
            //self.search_bar_subview.layer.backgroundColor = UIColor.black.withAlphaComponent(0.7).cgColor
           
            
        }
        self.Caption_text_view.becomeFirstResponder()
        self.tapGesture_test_caption_view.isEnabled = false
        self.tapGesture_test_lyric_view.isEnabled = false
        
    }
    
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
                                              caption: self.Caption_text_view.text,
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
                            lyrictext: self.Lyric_view.text,
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
                                              caption: self.Caption_text_view.text,
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
                            lyrictext: self.Lyric_view.text,
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
                                          caption: self.Caption_text_view.text,
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
                                          lyrictext: self.Lyric_view.text,
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
                                      caption: self.Caption_text_view.text,
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
                                                 caption: self.Caption_text_view.text,
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
                        lyrictext: self.Lyric_view.text,
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
                                                 caption: self.Caption_text_view.text,
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
                                                 lyrictext: self.Lyric_view.text,
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
    
   
    
    @objc func dismiss_keyboard () {
        
        if (self.uploading && (self.caption_view_bottom_constraint_to_express_view.constant == 4)) {
            self.Lyric_view.endEditing(true)
            self.pane_view_for_keyboard_dismiss.isHidden = true
            print ("lyric is not hidden")
            //self.search_bar_subview.layer.backgroundColor = UIColor.white.cgColor
            self.Express_view.backgroundColor = UIColor.white
            self.tapGesture_test_lyric_view.isEnabled = true
            self.tapGesture_test_caption_view.isEnabled = true
            
        } else if (self.uploading && (self.caption_view_bottom_constraint_to_express_view.constant == 273)) {
            self.Caption_text_view.endEditing(true)
            self.pane_view_for_keyboard_dismiss.isHidden = true
            print ("caption is not hidden")
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.caption_view_bottom_constraint_to_express_view.constant = 4
            }, completion: nil)
            self.Express_view.backgroundColor = UIColor.white
            //self.search_bar_subview.layer.backgroundColor = UIColor.white.cgColor
            self.tapGesture_test_caption_view.isEnabled = true
            self.tapGesture_test_lyric_view.isEnabled = true
        } else if upload_flag == "youtube" {
            self.searchController.searchBar.endEditing(true)
            self.pane_view_for_keyboard_dismiss.isHidden = true
           
        }
    }
    
    
    
    
}


extension UploadViewController3: UISearchResultsUpdating  {
    
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        print ("updateSearchResults")
        // TODO
        guard let searchString = searchController.searchBar.text else {
            return
        }
        
        if GIF_Search_is_ON {
            print ("GIF_Search_is_ON search string is \(searchController.searchBar.text)")
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
        
            if self.is_selecting_audio_clip {
                print ("scrollViewDidScroll")
                print ("Invalidating scroller_timer 7")
                self.scroller_timer.invalidate()
                self.color_animate_trailing.constant = 262.5
                print (" scroll view content offset x \(scrollView.contentOffset.x)")
                print ("collection view content size width \(self.collection_view_for_scroll.contentSize.width)")
                print ("progress bar width \(self.Custom_progress_bar_bar.frame.width)")
                
                if (self.collection_view_for_scroll.contentSize.width != 0) {
                    self.slider_leading_constraint.constant = ((scrollView.contentOffset.x + 96.5) * (self.Custom_progress_bar_bar.frame.width)) / (self.collection_view_for_scroll.contentSize.width)
                }
                
                var slider_constraint = Float(self.slider_leading_constraint.constant)
                var retranslate_value = round (((slider_constraint) * Float(self.duration_for_number_of_cells)) / 267)
                var minutes = Int (retranslate_value / 60)
                var seconds =  (Int(retranslate_value) - (minutes * 60))
                self.Time_label.text = "\(minutes):\(seconds)"
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
        
        self.Youtube_player?.playVideo()
        
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
        self.Color_animate_view.backgroundColor = UIColor.magenta
        //self.color_animate_trailing.constant = 138
        self.Color_animate_view.layer.cornerRadius = 5
        self.Custom_progress_bar_container.layer.borderColor = UIColor.clear.cgColor
        self.Custom_progress_bar_bar.layer.cornerRadius = 1
        self.Custom_progress_bar_slider.layer.cornerRadius = 2
        self.collection_view_for_scroll.contentInset.left = 96.5 //112.5 - 16
        self.collection_view_for_scroll.contentInset.right = 96.5
        self.slider_width.constant = 15
        print ("slider_width \(self.slider_width.constant)")
        
        print ("my_collection_view.contentOffset \(self.collection_view_for_scroll.contentOffset.x)")
        print ("my_collection_view.contentOffset \(self.collection_view_for_scroll.contentOffset.y)")
        print (" custom_progress_bar_bar.frame.width\(self.Custom_progress_bar_bar.frame.width)")
        self.slider_leading_constraint.constant = 0
        
    }
    
    func reset_custom_scroller () {
        
        self.slider_width.constant = 15
        self.slider_leading_constraint.constant = 0
        self.color_animate_trailing.constant = 262.5
        self.collection_view_for_scroll.setContentOffset(CGPoint(x: -97.0, y: 0.0), animated: true)
        self.Time_label.text = "0:00"
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
            print ("Invalidating scroller_timer 1")
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
            print ("Invalidating scroller_timer 2")
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
       
        //print("collection view dequeue ")
        print (self.is_selecting_audio_clip)
        if self.is_selecting_audio_clip && collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionview_cell_for_scroll_bar", for: indexPath) as! collectionview_cell_for_scroll_bar
            print (indexPath[1])
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
            
            if let collectionViewLayout = Mycollectionview2.collectionViewLayout as? SwiftyGiphyGridLayout {
                print("collection view layout is fine")
            } else {
                print ("collection view layout is not fine")
            }
            
            if let collectionViewLayout = Mycollectionview2.collectionViewLayout as? SwiftyGiphyGridLayout, let imageSet = currentGifs?[indexPath.row].imageSetClosestTo(width: self.mycollectionViewLayout!.columnWidth, animated: true)
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
            self.Youtube_player.seek(toSeconds: Float(seek_to_time), allowSeekAhead: true)
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

extension UploadViewController3: UISearchBarDelegate {
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print ("searchBarTextDidBeginEditing")
        if searchBar.tag == 1 {
            print("searchBar.tag == 1")
            self.searchController.searchBar.isHidden = false
            self.navigationItem.hidesBackButton = true
            self.navigationItem.titleView = self.searchController.searchBar
            self.searchController.searchBar.placeholder = "Search GIFs"
            self.searchController.searchBar.text = ""
            if (!self.searchController.isActive) {
                self.searchController.isActive = true
            }
            self.GIFSearch_Bar.endEditing(true)
            self.express_view_to_search_bar_super_container.constant = 5
            //self.GIF_SearchBar_top_to_express_view.constant = -60
            //self.Text_or_animation_switch_top_to_express_view.constant = -51
            self.GIFSearch_Bar.isHidden = true
            self.Text_or_animation_switch.isHidden = true
            self.SelectedGIF_view.isHidden = true
            self.GIF_Search_is_ON = true
            
            if #available(iOS 11, *)
            {
                print("collection view content insets ios 11")
                Mycollectionview2.contentInset = UIEdgeInsets.init(top: 24.0, left: 0.0, bottom: 5.0, right: 0.0)
                Mycollectionview2.scrollIndicatorInsets = UIEdgeInsets.init(top: 24.0, left: 0.0, bottom: 5.0, right: 0.0)
            }
            else
            {
                print("collection view content inset")
                Mycollectionview2.contentInset = UIEdgeInsets.init(top: self.topLayoutGuide.length + 24.0, left: 0.0, bottom: 10.0, right: 0.0)
                Mycollectionview2.scrollIndicatorInsets = UIEdgeInsets.init(top: self.topLayoutGuide.length + 24.0, left: 0.0, bottom: 10.0, right: 0.0)
            }
            
            if let mycollectionViewLayout = Mycollectionview2.collectionViewLayout as? SwiftyGiphyGridLayout
            {
                print ("GRID LAYOUT DELEGATE SET!!!!!!!!!!!!!!!!!!!!!!! ")
                self.mycollectionViewLayout!.delegate = self
            }
            
            Mycollectionview2.isHidden = false
            //self.text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-cancel-50"), for: .normal)
        } else {
            print("searchBar.tag != 1")
            if (!self.GIF_Search_is_ON) {
                self.pane_view_for_keyboard_dismiss.isHidden = false
                //self.view.bringSubview(toFront: self.pane_view_for_keyboard_dismiss)
               
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
        if searchBar.tag == 1 {
            self.express_view_to_search_bar_super_container.constant = 370
            self.GIF_SearchBar_top_to_express_view.constant = 4
            //self.Text_or_animation_switch_top_to_express_view.constant = 13
            self.GIF_Search_is_ON = false
            self.Text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-type-60"), for: .normal)
            
        } else {
            if (self.GIF_Search_is_ON) {
                print ("GIF_Search_is_ON")
                searchController.searchBar.isHidden = true
                self.navigationItem.hidesBackButton = false
                //self.searchController.searchBar.placeholder = "Search Apple Music"
                self.searchController.searchBar.text = ""
                self.searchController.searchBar.isHidden = true
                //self.searchController.isActive = false
                self.GIFSearch_Bar.endEditing(true)
                self.express_view_to_search_bar_super_container.constant = 370
                self.GIF_Search_is_ON = false
                self.GIFSearch_Bar.isHidden = false
                self.Text_or_animation_switch.isHidden = false
                self.SelectedGIF_view.isHidden = false
                self.Mycollectionview2.isHidden = true
            } else {
               print ("GIF_Search_is_OFF")
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
            
                // MARK: GIF Search
                
        }
        
    }
    
}

extension UploadViewController3 {
    
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        //print("heightForPhotoAtIndexPath")
        guard let imageSet = currentGifs?[indexPath.row].imageSetClosestTo(width: withWidth, animated: true) else {
            return 0.0
        }
        //print("\(AVMakeRect(aspectRatio: CGSize(width: imageSet.width, height: imageSet.height), insideRect: CGRect(x: 0.0, y: 0.0, width: withWidth, height: CGFloat.greatestFiniteMagnitude)).height)")
        //print ("collection view height \(self.Mycollectionview2.frame.height)")
        //print ("collection view width \(self.Mycollectionview2.frame.width)")
        //print ("collection contentSize height \(self.Mycollectionview2.contentSize.height)")
        //print ("collection contentSize width \(self.Mycollectionview2.contentSize.width)")
        //print ("collection X position \(self.Mycollectionview2.frame.minX)")
        //print ("collection Y position \(self.Mycollectionview2.frame.minY)")
        return AVMakeRect(aspectRatio: CGSize(width: imageSet.width, height: imageSet.height), insideRect: CGRect(x: 0.0, y: 0.0, width: withWidth, height: CGFloat.greatestFiniteMagnitude)).height
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let selectedimageSet = currentGifs![indexPath.row].imageSetClosestTo(width: self.SelectedGIF_view.frame.width, animated: true)
        let imageSetforNewsFeedPost = currentGifs![indexPath.row].imageSetClosestTo(width: 351.0, animated: true) // Set it for the width of the GIF image view in the Post cell.
        //let selectedGif = currentGifs![indexPath.row]
        //self.searchController.searchBar.placeholder = "Search Apple Music"
        self.navigationItem.hidesBackButton = false
        //self.navigationItem.titleView = nil
        self.searchController.searchBar.text = ""
        self.searchController.searchBar.isHidden = true
        self.Text_or_animation_switch.isHidden = false
        self.searchController.isActive = false
        self.searchController.searchBar.endEditing(true)
        self.Mycollectionview2.isHidden = true
        //DO STUFF HERE
        self.GIFSearch_Bar.endEditing(true)
        self.GIFSearch_Bar.isHidden = false
        self.express_view_to_search_bar_super_container.constant = 370
        self.GIF_SearchBar_top_to_express_view.constant = 4
        //self.Text_or_animation_switch_top_to_express_view.constant = 13
        self.GIF_Search_is_ON = false
        self.Text_or_animation_switch.setBackgroundImage(UIImage(named: "icons8-type-60"), for: .normal)
        self.SelectedGIF_view.sd_setShowActivityIndicatorView(true)
        self.SelectedGIF_view.sd_setIndicatorStyle(.gray)
        print ("selected GIF url is \(selectedimageSet?.url)")
        self.SelectedGIF_view.sd_setImage(with: selectedimageSet?.url)
        self.selected_GIF_url = imageSetforNewsFeedPost?.url
        self.SelectedGIF_view.isHidden = false
    }
    
    func fetchNextSearchPage()
    {
        Mycollectionview2.isHidden = false
        print ("collection view height \(self.Mycollectionview2.frame.height)")
        print ("collection view width \(self.Mycollectionview2.frame.width)")
        print ("collection contentSize height \(self.Mycollectionview2.contentSize.height)")
        print ("collection contentSize width \(self.Mycollectionview2.contentSize.width)")
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
            let width = max((self.Mycollectionview2.collectionViewLayout as? SwiftyGiphyGridLayout)?.columnWidth ?? 0.0, 0.0)
            print("fetchNextSearchPage 7")
            SwiftyGiphyAPI.shared.getSearch(searchTerm: searchText, limit: 100, rating: self.contentRating, offset: self.currentSearchPageOffset) { [weak self] (error, response) in
                
                self?.isSearchPageLoadInProgress = false
                
                guard currentCounter == self?.searchCounter else {
                    print ("currentCounter == self?.searchCounter")
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
                
                self?.Mycollectionview2.reloadData()
                
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
