//
//  UploadViewControllerAlbumDisplay.swift
//  Project2
//
//  Created by virdeshp on 8/18/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation


class UploadViewControllerAlbumDisplay: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    @IBOutlet weak var my_table: UITableView!
     var flow = "default_upload"
    var album_header_view = UIView.init(frame: CGRect(x: 0, y: 0, width: 375, height: 180))
    var album_header_image_view = UIImageView.init(frame: CGRect(x: 10, y: 15, width: 150, height: 150))
    var album_name_label_view = UILabel.init(frame: CGRect(x: 165, y: 15, width: 200, height: 30))
    var album_artist_name_label_view = UILabel.init(frame: CGRect(x: 165, y: 50, width: 200, height: 30))
    var album_artist_release_date_label_view = UILabel.init(frame: CGRect(x: 165, y: 85, width: 200, height: 30))
    var search_result_count = 0
    let appleMusicManager = AppleMusicManager()
    let userDefaults = UserDefaults.standard
    var albumMediaItem: MediaItem!
    var setterQueue = DispatchQueue(label: "UploadViewControllerAlbumDisplay")
    let imageCacheManager = ImageCacheManager()
    var upload_flag = "now_playing"
    
    var duration: Int = 0
    var duration_for_number_of_cells: Int = 0
    var selected_search_result_post: Post!
    var selected_search_result_post_image: UIImage!
    var selected_search_result_song_db_struct = song_db_struct()
    var path_keeper = upload_path_keeper.shared
    
    var mediaItems = [[MediaItem]]() {
        didSet {
            DispatchQueue.main.async {
                print ("reloading")
                self.search_result_count = self.mediaItems.count ?? 0
                self.my_table?.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        my_table.delegate = self
        my_table.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        self.my_table?.addGestureRecognizer(tapGesture)
        
        setup_table()
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.mediaItems.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mediaItems.count != 0 {
            print("\(mediaItems[section].count) is the count")
            return mediaItems[section].count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.identifier,
                                                       for: indexPath) as? SearchResultCell else {
                                                        return UITableViewCell()
        }
        
        print ("we here")
        var imageURL: URL?
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
        
        return cell
    }
    
    func setup_table() {
        let country_code = userDefaults.string(forKey: "Country_code")
        
        self.album_header_view.addSubview(self.album_header_image_view)
        self.album_header_view.addSubview(self.album_name_label_view)
        self.album_header_view.addSubview(self.album_artist_name_label_view)
        self.album_header_view.addSubview(self.album_artist_release_date_label_view)
        
        self.my_table.tableHeaderView = self.album_header_view
        album_header_image_view.loadImageUsingCacheWithUrlString(imageurlstring: albumMediaItem.artwork.imageURL(size: CGSize(width: 150, height: 150)).absoluteString)
        album_name_label_view.text = albumMediaItem.name
        album_artist_name_label_view.text = albumMediaItem.artistName
        album_artist_release_date_label_view.text = albumMediaItem.releaseDate
        
        
        appleMusicManager.performAppleMusicCatalogSearch_album_relation_songs(with: albumMediaItem.identifier!, countryCode: country_code ?? "us").done { searchResults in
            
            
            
            self.setterQueue.sync {
                self.mediaItems = [searchResults]
                print(searchResults.count)
                self.search_result_count = searchResults.count ?? 0
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print ("prepare for segue")
            let destinationVC = segue.destination as! UploadViewController3
            destinationVC.flow = self.flow
            
            destinationVC.selected_search_result_post = self.selected_search_result_post
            destinationVC.selected_search_result_song_db_struct = self.selected_search_result_song_db_struct
            destinationVC.upload_flag = self.upload_flag
            destinationVC.duration = self.duration
            destinationVC.duration_for_number_of_cells = self.duration_for_number_of_cells
            destinationVC.selected_search_result_post_image = self.selected_search_result_post_image
            definesPresentationContext = false //If you keep it as true then, the search bar in the controller that you push on the navigation stack remains unresponsive.
            destinationVC.uploading = true

            
        }
    
    
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.my_table)
            if let tapIndexPath = self.my_table?.indexPathForRow(at: tapLocation) {
                
                let upload_cell = self.my_table?.cellForRow(at: tapIndexPath) as? SearchResultCell
            
                self.selected_search_result_post_image = upload_cell?.media_image.image
                self.selected_search_result_song_db_struct.album_name = upload_cell?.mediaItem.albumName
                self.selected_search_result_song_db_struct.artist_name = upload_cell?.mediaItem.artistName
                self.selected_search_result_song_db_struct.isrc_number = upload_cell?.mediaItem.isrc
                self.selected_search_result_song_db_struct.playable_id = upload_cell?.mediaItem.identifier
                self.selected_search_result_song_db_struct.preview_url = upload_cell?.mediaItem.previews[0]["url"] ?? ""
                self.selected_search_result_song_db_struct.release_date = upload_cell?.mediaItem.releaseDate
                self.selected_search_result_song_db_struct.song_name = upload_cell?.mediaItem.name
                
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
                    trackid: upload_cell?.mediaItem.identifier,
                    helper_id: "",
                    videoid: "empty",
                    starttime: 0 ,
                    endtime: 0,
                    flag: "audio",
                    lyrictext: "",
                    songname: upload_cell?.mediaItem.name,
                    sourceapp: self.upload_flag,
                    preview_url: upload_cell?.mediaItem.previews[0]["url"] ?? "",
                    albumArtUrl: upload_cell?.mediaItem.artwork.imageURL(size: CGSize(width: 375, height: 375)).absoluteString,
                    original_track_length: upload_cell?.mediaItem.durationInMillis!,
                    GIF_url: "" )
                
                self.performSegue(withIdentifier: "album_display_to_3", sender: self)
                
            }
        }
    }
                
    
    
    
    
}
