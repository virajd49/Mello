//
//  UploadViewController2.swift
//  Project2
//
//  Created by virdeshp on 12/1/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation


class UploadViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource, CALayerDelegate, UIScrollViewDelegate, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    @IBOutlet weak var selector_stack: UIStackView!
    @IBOutlet weak var stack_trailing: NSLayoutConstraint!
    @IBOutlet weak var stack_leading: NSLayoutConstraint!
    @IBOutlet weak var now_playing_button_outlet: UIButton!
    @IBOutlet weak var apple_button_outlet: UIButton!
    @IBOutlet weak var spotify_button_outlet: UIButton!
    @IBOutlet weak var youtube_button_outlet: UIButton!
    
    @IBOutlet weak var now_playing_image: UIImageView!
    @IBOutlet weak var now_playing_progress_bar: UIProgressView!
    @IBOutlet weak var now_playing_scrubber: UIButton!
    
    @IBOutlet weak var search_bar_container: UIView!
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var back_button: UIButton!
    
    @IBOutlet weak var test_slider: UISlider!
    @IBOutlet weak var audio_scrubber_ot: UISlider!
    var spotifyplayer =  SPTAudioStreamingController.sharedInstance()
    var spotify_current_uri: String?
    var timer : Timer!
    
    var my_table: UITableView?
    var search_result_count: Int = 0
    @IBOutlet weak var table_view: UITableView!
    var button_array: [UIButton]?
    
    let userDefaults = UserDefaults.standard
    
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
    var search_flag = ""
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
        self.search_bar_container.addSubview(searchController.searchBar)
        searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchController.searchBar.isHidden = true
        now_playing_image.layer.cornerRadius = 10
        
        gradient.frame = (self.my_table?.bounds)!
        self.my_table?.layer.mask = gradient
        gradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.7, 1]
        gradient.delegate = self
        let cancelButtonAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
        
        self.spotifyplayer?.playbackDelegate = self as SPTAudioStreamingPlaybackDelegate
        self.spotifyplayer?.delegate = self as SPTAudioStreamingDelegate
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
        toggle_hide_now_playing(hide: false)
        searchController.searchBar.isHidden = true
        self.my_table?.isHidden = true
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
        self.search_flag = "apple"
        self.my_table?.isHidden = false
        
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
        self.search_flag = "spotify"
        self.my_table?.isHidden = false
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
        searchController.searchBar.placeholder = "Search Youtube"
        searchController.searchBar.isHidden = false
        self.my_table?.isHidden = false
    }
    
    @IBAction func back_button(_ sender: Any) {
        toggle_hide_now_playing(hide: true)
        searchController.searchBar.isHidden = false
        self.my_table?.isHidden = false
        self.back_button?.isHidden = true
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
        //self.timer.invalidate()
        //self.audio_scrubber_ot.value = 0.0
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
        
        
        if ((self.spotifyplayer?.playbackState.isPlaying)!) {
            self.spotifyplayer?.seek(to: TimeInterval(self.audio_scrubber_ot.value), callback: nil)
        } else {
            self.spotifyplayer?.playSpotifyURI(spotify_current_uri, startingWith: 0, startingWithPosition: TimeInterval(self.audio_scrubber_ot.value), callback: { (error) in
                if (error == nil) {
                    print("playing!")
                }
                
            })
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
        
        
        if ((self.spotifyplayer?.playbackState.isPlaying)!) {
             self.spotifyplayer?.seek(to: TimeInterval(self.audio_scrubber_ot.value), callback: nil)
        } else {
                self.spotifyplayer?.playSpotifyURI(spotify_current_uri, startingWith: 0, startingWithPosition: TimeInterval(self.audio_scrubber_ot.value), callback: { (error) in
                    if (error == nil) {
                        print("playing!")
                    }

                })
        }
    }
    
    func toggle_hide_now_playing (hide: Bool) {
        if hide {
            self.now_playing_image.isHidden = true
            self.now_playing_scrubber.isHidden = true
            self.now_playing_progress_bar.isHidden = true
            self.audio_scrubber_ot.isHidden = true
            self.test_slider.isHidden = true
        } else {
            self.now_playing_image.isHidden = false
            self.now_playing_scrubber.isHidden = false
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
        if search_flag == "apple" {
            print ("section \(section)")
            if mediaItems.count != 0 {
                return mediaItems[section].count
            } else {
                return 0
            }
        } else if search_flag == "spotify" {
            print ("section \(section)")
            if spotify_mediaItems.count != 0 {
                return spotify_mediaItems[section].count
            } else {
                return 0
            }
            
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("Songs", comment: "Songs")
        } else {
            return NSLocalizedString("Albums", comment: "Albums")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.identifier,
                                                       for: indexPath) as? SearchResultCell else {
                                                        return UITableViewCell()
        }
        print ("we here")
        var imageURL: URL?
        
        if self.search_flag == "apple" {
            print ("dequeue was called")
            let mediaItem = mediaItems[indexPath.section][indexPath.row]
        
            cell.mediaItem = mediaItem
        
        
            // Image loading.
            imageURL = mediaItem.artwork.imageURL(size: CGSize(width: 90, height: 90))
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
        } else if self.search_flag == "spotify" {
            print ("dequeue was called")
            print(indexPath.section) 
            print(indexPath.row)
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
        return cell
    }
    
    
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizerState.ended {
            let tapLocation = recognizer.location(in: self.my_table)
            if let tapIndexPath = self.my_table?.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.my_table?.cellForRow(at: tapIndexPath) as? SearchResultCell {
                    
                    print ("gesture recognized")
                    self.now_playing_image.image = tappedCell.media_image.image
                    toggle_hide_now_playing(hide: false)
                    searchController.searchBar.isHidden = true
                    self.my_table?.isHidden = true
                    self.back_button?.isHidden = false
                    self.searchController.view.endEditing(true)
                    self.spotifyplayer?.playSpotifyURI(tappedCell.spotify_mediaItem.uri, startingWith: 0, startingWithPosition: 0.0, callback: { (error) in
                        if (error == nil) {
                            print("playing!")
                        }
                        
                    })
                    self.audio_scrubber_ot.maximumValue = Float(tappedCell.spotify_mediaItem.duration_ms! / 1000)
                    self.test_slider.maximumValue =
                        Float(tappedCell.spotify_mediaItem.duration_ms! / 1000)
                    print (tappedCell.spotify_mediaItem.duration_ms)
                    print (tappedCell.spotify_mediaItem.duration_ms! * 1000)
                    print(self.audio_scrubber_ot.maximumValue)
                     //self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateScrubber), userInfo: nil, repeats: true)
                    self.spotify_current_uri = tappedCell.spotify_mediaItem.uri
    
                }
            }
        }
    }
    
    @objc func updateScrubber () {
        self.audio_scrubber_ot.value = Float((self.spotifyplayer?.playbackState.position)!)
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
            }
        } else if (self.search_flag == "apple") {
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
        } else if (self.search_flag == "spotify") {
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
}

extension UploadViewController2: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        setterQueue.sync {
            self.mediaItems = []
            self.spotify_mediaItems = []
        }
    }

}
