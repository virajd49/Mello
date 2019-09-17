//
//  SearchResultCell.swift
//  Project2
//
//  Created by virdeshp on 12/2/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation
import UIKit
import GoogleAPIClientForREST



//uploadviewcontroller2 and searchresults controller

class SearchResultCell: UITableViewCell {
    
    static let identifier = "searchresultcell"
 
    
    @IBOutlet weak var media_image: UIImageView!
    
    @IBOutlet weak var media_name_label: UILabel!
    
    var artist_name: String?
    var media_id: String?
    var isrc: String?
    var yt_video_duration: Float?
    
    
    var mediaItem: MediaItem! {
        didSet{
            media_image.image = nil
            media_name_label.text = mediaItem?.name ?? ""
            artist_name? = mediaItem?.artistName ?? ""
            media_id = mediaItem?.identifier ?? ""
            isrc = mediaItem?.isrc ?? ""
            yt_video_duration = 0.0
            
        }
    }
    
    var spotify_mediaItem: SpotifyMediaObject.item! {
        didSet{
            media_image.image = nil
            media_name_label.text = spotify_mediaItem?.name ?? ""
            artist_name? = spotify_mediaItem?.artists![0].name ?? ""
            media_id = spotify_mediaItem?.uri ?? ""
            isrc = spotify_mediaItem?.external_ids?.isrc ?? ""
            yt_video_duration = 0.0
            
        }
    }
    
    var spotify_recently_played_mediaItem: SpotifyRecentlyPlayedMediaObject.item! {
        didSet{
            media_image.image = nil
            media_name_label.text = spotify_recently_played_mediaItem.track?.name ?? ""
            artist_name? = spotify_recently_played_mediaItem.track?.artists![0].name ?? ""
            media_id = spotify_recently_played_mediaItem.track?.uri ?? ""
            isrc = spotify_recently_played_mediaItem.track?.external_ids?.isrc ?? ""
            yt_video_duration = 0.0
            
        }
    }
    
    var youtube_video_resource = GTLRYouTube_SearchResult() {
        didSet{
            media_image.image = nil
            media_name_label.text = youtube_video_resource.snippet?.title ?? ""
            artist_name = ""
            media_id = youtube_video_resource.identifier?.videoId ?? ""
            isrc = ""
            yt_video_duration = 0.0
        }
    }
}
