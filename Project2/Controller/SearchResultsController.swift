//
//  SearchResultsController.swift
//  Project2
//
//  Created by virdeshp on 7/26/19.
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


protocol SearchResultsProtocolDelegate: UIViewController {
    
    func get_type_of_search() -> String
    
    func take_and_update_selected_apple_artist_info(with_this artist: ArtistMediaItem, name: String)
    
    func take_and_update_selected_spotify_artist_info(with_this artist: SpotifyArtistMediaObject.item, image: UIImage, name: String)
    
    func end_search_controller()
    
}

class SearchResultsController: UITableViewController, UISearchResultsUpdating, SwiftyGiphyGridLayoutDelegate {
    
    
    
    var delegate: SearchResultsProtocolDelegate?
    let kSwiftyGiphyCollectionViewCell = "SwiftyGiphyCollectionViewCell"
    var allowResultPaging: Bool = true
   
    
    //var currently_active_collection_view: UICollectionView
    var is_selecting_animation: Bool = false
    var GIF_Search_is_ON: Bool = false
    var artist_search_is_on: Bool = false
    var track_search_is_on: Bool = false
    var spotify_current_uri: String?
    var apple_id: String?
    var yt_id: String?
    
    var search_result_count: Int = 0
   
    var selected_cell: IndexPath?
    let userDefaults = UserDefaults.standard
    
    var temp_spotify_media_context_uri: String?
    var temp_spotify_media_context_duration: Int?
   
    var uploading = false
    var search_result_video = GTLRYouTube_Video()
    var selected_GIF_url: URL!
    var selected_search_result_post: Post!
    var selected_search_result_post_image: UIImage!
    var selected_search_result_song_db_struct = song_db_struct()
    var mycollectionview2: UICollectionView!
    var setterQueue = DispatchQueue(label: "SearchResultsController")
    var video_search_results = [GTLRYouTube_SearchResult]() {
        didSet {
            DispatchQueue.main.async {
                //print ("reloading")
                
                self.tableView.reloadData()
            }
        }
    }
    private let service = GTLRYouTubeService()
    
    
    
    var artistMediaItems = [[ArtistMediaItem]]() {
        didSet {
            DispatchQueue.main.async {
                //print ("reloading")
                self.tableView?.reloadData()
            }
        }
    }
    
    var spotify_artistMediaItems = [[SpotifyArtistMediaObject.item]]() {
        didSet {
            DispatchQueue.main.async {
                //print ("reloading")
                self.tableView?.reloadData()
            }
        }
    }
    
    var mediaItems = [[MediaItem]]() {
        didSet {
            DispatchQueue.main.async {
                //print ("reloading")
                self.tableView?.reloadData()
            }
        }
    }
    
    var spotify_mediaItems = [[SpotifyMediaObject.item]]() {
        didSet {
            DispatchQueue.main.async {
                //print ("reloading")
                self.tableView?.reloadData()
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
    var upload_flag = "default"
    let gradient = CAGradientLayer()
    var post_help = Post_helper()             //This is required because sometimes in spotify if the song is part of a compilation - made by a user
    var secondary_image_url: URL?             //- then it picks up the album art for that compilation instead of the actual album art. So we
    var secondary_image: UIImage?             // do a search by URI to get the album art of the actual song - store it in secondary_image_url and give the user an option.
  

    
    override func viewDidLoad() {
        print ("viewdidload")
        self.set_flag()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        self.tableView?.addGestureRecognizer(tapGesture)
        tapGesture.delegate = tableView as? UIGestureRecognizerDelegate
    }
    
    
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        guard let imageSet = currentGifs?[indexPath.row].imageSetClosestTo(width: withWidth, animated: true) else {
            return 0.0
        }
       
        return AVMakeRect(aspectRatio: CGSize(width: imageSet.width, height: imageSet.height), insideRect: CGRect(x: 0.0, y: 0.0, width: withWidth, height: CGFloat.greatestFiniteMagnitude)).height
        
    }
    
    func set_flag() {
        
        if let flag = delegate?.get_type_of_search() {
            if flag == "artist" {
                print ("flag == artist")
                self.artist_search_is_on = true
                self.track_search_is_on = false
                self.GIF_Search_is_ON = false
            } else if flag == "track" {
                print ("flag == track")
                self.artist_search_is_on = false
                self.track_search_is_on = true
                self.GIF_Search_is_ON = false
            } else if flag == "GIF" {
                print ("flag == GIF")
                self.artist_search_is_on = false
                self.track_search_is_on = false
                self.GIF_Search_is_ON = true
            }
            
        }
        

    }
    

        // MARK: - UISearchResultsUpdating Delegate
        func updateSearchResults(for searchController: UISearchController) {
            // TODO
            print ("updateSearchResults")
            guard let searchString = searchController.searchBar.text else {
                print("returning")
                return
            }
            
            print (searchString)
            if !GIF_Search_is_ON {
                print ("!GIF_Search_is_ON")
                if searchString == "" {
                    self.setterQueue.sync {
                        self.mediaItems = []
                        self.spotify_mediaItems = []
                        self.video_search_results = []
                    }
                } else if self.track_search_is_on {
                    if (self.upload_flag == "apple") {
                        get_apple_search_results(for: searchString)
                     
                    } else if (self.upload_flag == "spotify") {
                        print ("spotify search flag recognized")
                        get_spotify_search_results(for: searchString)
                       
                    }
                } else if artist_search_is_on {
                    
                    if (userDefaults.string(forKey: "UserAccount") == "Apple") {
                        let country_code = userDefaults.string(forKey: "Country_code")
                        get_apple_artist_search_results(for: searchString)
                       
                    } else if (userDefaults.string(forKey: "UserAccount") == "Spotify") {
                        print ("spotify search flag recognized")
                        get_spotify_artist_search_results(for: searchString)
                }
            } else {
                // Destroy current results
                    print("GIF_search_is_on")
                searchCounter += 1
                latestSearchResponse = nil
                currentSearchPageOffset = 0
                combinedSearchGifs = [GiphyItem]()
                currentGifs = [GiphyItem]()
                fetchNextSearchPage(with: searchString)
            }
        }
            
    }
    
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            print("searchBarTextDidBeginEditing")
            if  self.GIF_Search_is_ON {
               
                //self.GIF_SearchBar_top_to_express_view.constant = -60
                //self.Text_or_animation_switch_top_to_express_view.constant = -51
             
                
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
                    print ("GRID LAYOUT DELEGATE SET !!!!!!!!!!!!!!!!!!!!!!! ")
                    self.mycollectionViewLayout!.delegate = self
                }
                
                mycollectionview2.isHidden = false
            } else {
               
            }
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            print("searchBarCancelButtonClicked")
            if searchBar.tag == 1 {
               
                self.GIF_Search_is_ON = false
                
            } else {
                if (self.GIF_Search_is_ON) {
                   
                    
                    self.GIF_Search_is_ON = false
                   
                    self.mycollectionview2.isHidden = true
                } else {
                    setterQueue.sync {
                        self.mediaItems = []
                        self.spotify_mediaItems = []
                        self.video_search_results = []
                    }
                    
                    //self.view.sendSubview(toBack: self.pane_view_for_keyboard_dismiss)
                    if self.upload_flag == "youtube" {
                      
                    }
                }
            }
            
        }
        
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
            if self.GIF_Search_is_ON {
                searchCounter += 1
                latestSearchResponse = nil
                currentSearchPageOffset = 0
                combinedSearchGifs = [GiphyItem]()
                currentGifs = [GiphyItem]()
                fetchNextSearchPage(with: searchBar.text!)
            } else {
            
                    print("searchBarSearchButtonClicked")
                    guard let searchString = searchBar.text else {
                        print ("searchString != searchController.searchBar.text")
                        return
                    }
                    
                    if self.track_search_is_on {
                        if searchString == "" {
                            self.setterQueue.sync {
                                self.mediaItems = []
                                self.spotify_mediaItems = []
                            }
                        } else if (userDefaults.string(forKey: "UserAccount") == "Apple") {
                            get_apple_search_results(for: searchString)

                        } else if (userDefaults.string(forKey: "UserAccount") == "Spotify") {
                            print ("spotify search flag recognized")
                            get_spotify_search_results(for: searchString)
                           
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
                    } else if self.artist_search_is_on {
                        
                        if (userDefaults.string(forKey: "UserAccount") == "Apple") {
                            get_apple_artist_search_results(for: searchString)
                            
                        } else if (userDefaults.string(forKey: "UserAccount") == "Spotify") {
                            print ("spotify search flag recognized")
                            get_spotify_artist_search_results(for: searchString)
                        }
                        
                    }
             
            }
            
    }
    
    
    
    func get_spotify_artist_search_results(for search_string: String) {
        
        appleMusicManager.performSpotifyCatalogSearchNew_for_artist(with: search_string).done { searchResults in
            self.setterQueue.sync {
                self.spotify_mediaItems = []
            }
            let alertController: UIAlertController
            self.setterQueue.sync {
                self.spotify_artistMediaItems = [searchResults]
                print(searchResults.count)
                self.search_result_count = self.spotify_artistMediaItems.count ?? 0
            }
        }
    }
    
    func get_spotify_search_results(for search_string: String) {
        appleMusicManager.performSpotifyCatalogSearch(with: search_string,
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
    
    func get_apple_artist_search_results(for search_string: String) {
        let country_code = userDefaults.string(forKey: "Country_code")
        appleMusicManager.performAppleMusicCatalogSearchNew_for_artist(with: search_string,
                                                                       countryCode: country_code ?? "us").done { searchResults in
                                                                        // Your application should handle these errors appropriately depending on the kind of error.
                                                                        self.setterQueue.sync {
                                                                            self.artistMediaItems = []
                                                                        }
                                                                        self.setterQueue.sync {
                                                                            self.artistMediaItems = [searchResults]
                                                                            print(searchResults.count)
                                                                            self.search_result_count = self.artistMediaItems.count ?? 0
                                                                        }
        }
        
    }
    
    func get_apple_search_results(for search_string: String) {
        let country_code = userDefaults.string(forKey: "Country_code")
        appleMusicManager.performAppleMusicCatalogSearch(with: search_string,
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
        
    }
    
    
    func fetchNextSearchPage(with search_string: String)
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
        guard search_string != "" else {
            
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
            SwiftyGiphyAPI.shared.getSearch(searchTerm: search_string, limit: 100, rating: self.contentRating, offset: self.currentSearchPageOffset) { [weak self] (error, response) in
                
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
    
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView?.indexPathForRow(at: tapLocation) {
                
                if self.artist_search_is_on {
                    if (self.userDefaults.string(forKey: "UserAccount") == "Spotify") {
                        let selected_cell = self.tableView?.cellForRow(at: tapIndexPath) as? Spotify_artist_search_result_cell
                        print ("selected_cell?.artist_name \(selected_cell?.artist_name)")
                        
                        if let selected_artist = selected_cell?.spotify_artist_mediaItem {
                            print("selected_artist.name \(selected_artist.name)")
                            delegate?.take_and_update_selected_spotify_artist_info(with_this: selected_artist, image: (selected_cell?.artist_media_image.image)! , name: selected_artist.name ?? "")
                        }
                    } else if (self.userDefaults.string(forKey: "UserAccount") == "Apple") {
                        let selected_cell = self.tableView?.cellForRow(at: tapIndexPath) as? Apple_artist_search_result_cell
                        if let selected_artist = selected_cell?.artistMediaItem {
                            delegate?.take_and_update_selected_apple_artist_info(with_this: selected_artist, name: selected_cell?.artist_name ?? "")
                        }
                    }
                } else if self.track_search_is_on {
                    
                } else if self.GIF_Search_is_ON {
                    
                }
                
                delegate?.end_search_controller()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.search_result_count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.artist_search_is_on {
            if userDefaults.string(forKey: "UserAccount") == "Apple" {
                print ("section \(section)")
                if artistMediaItems.count != 0 {
                    return artistMediaItems[section].count
                } else {
                    return 0
                }
            } else if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                print ("section \(section)")
                if spotify_artistMediaItems.count != 0 {
                    return spotify_artistMediaItems[section].count
                } else {
                    return 0
                }
            } else {
                return 0
            }
        } else if self.track_search_is_on {
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
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.track_search_is_on {
            if self.upload_flag != "youtube" {
                if section == 0 {
                    if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                        return NSLocalizedString("Songs", comment: "Songs")
                    }
                } else {
                    if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                        return NSLocalizedString("Albums", comment: "Albums")
                    }
                }
            } else {
                return nil
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(" cellForRowAt")
        if self.track_search_is_on {
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
        } else if artist_search_is_on {
            print("artist_search_is_on")
            if userDefaults.string(forKey: "UserAccount") == "Apple" {
                print ("Apple")
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Apple_artist_search_result_cell.identifier,for: indexPath) as? Apple_artist_search_result_cell else {
                    return UITableViewCell()
                }
                
                print ("dequeue was called")
                let mediaItem = artistMediaItems[indexPath.section][indexPath.row]
                let isIndexValid1 = artistMediaItems.indices.contains(indexPath.section)
                let isIndexValid2 = artistMediaItems[indexPath.section].indices.contains(indexPath.row)
                if (isIndexValid1 && isIndexValid2) {
                    
                    cell.artistMediaItem = mediaItem
                    
                }
               
                return cell
                
            } else if userDefaults.string(forKey: "UserAccount") == "Spotify" {
                print("Spotify")
                var imageURL: URL?
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Spotify_artist_search_result_cell.identifier,for: indexPath) as? Spotify_artist_search_result_cell else {
                        return UITableViewCell()
                    }
                let isIndexValid1 = spotify_artistMediaItems.indices.contains(indexPath.section)
                let isIndexValid2 = spotify_artistMediaItems[indexPath.section].indices.contains(indexPath.row)
                if (isIndexValid1 && isIndexValid2) {
                    let spotify_artistMediaItem = spotify_artistMediaItems[indexPath.section][indexPath.row]
                    
                    cell.spotify_artist_mediaItem = spotify_artistMediaItems[indexPath.section][indexPath.row]
                    
                    
                    // Image loading.
                    if spotify_artistMediaItem.images?.count != 0 {
                        print ("hurdle one")
                        imageURL = URL(string: "\(spotify_artistMediaItem.images?[0].url ?? "" )")
                        print (spotify_artistMediaItem.images?[0].url)
                        print (imageURL)
                    }
                    
                    
                    if (imageURL != nil) {
                        print ("hurdle two")
                        if let image = imageCacheManager.cachedImage(url: imageURL!) {
                            // Cached: set immediately.
                            //®print ("Cached")
                            cell.artist_media_image.image = image
                            cell.artist_media_image.alpha = 1
                        } else {
                            // Not cached, so load then fade it in.
                            cell.artist_media_image.alpha = 0
                            //print ("Not cached")
                            imageCacheManager.fetchImage(url: imageURL!, completion: { (image) in
                                // Check the cell hasn't recycled while loading.
                                if (cell.spotify_artist_mediaItem?.uri ?? "") == spotify_artistMediaItem.uri {
                                    //print ("yes we load it too")
                                    cell.artist_media_image.image = image
                                    UIView.animate(withDuration: 0.3) {
                                        cell.artist_media_image.alpha = 1
                                    }
                                }
                                //print ("fetched")
                            })
                        }
                    }
                }
                return cell
            } else {
                 return UITableViewCell()
            }
            
            
        } else {
            
            return UITableViewCell()
        }
    }
        
        
    }

        
    

