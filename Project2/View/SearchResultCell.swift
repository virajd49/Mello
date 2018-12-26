//
//  SearchResultCell.swift
//  Project2
//
//  Created by virdeshp on 12/2/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation
import UIKit

class SearchResultCell: UITableViewCell{
    
    static let identifier = "searchresultcell"
 
    
    @IBOutlet weak var media_image: UIImageView!
    
    @IBOutlet weak var media_name_label: UILabel!
    
    var artist_name: String?
    var media_apple_id: String?
    var isrc: String?
    
    
    var mediaItem: MediaItem! {
        didSet{
            media_image.image = nil
            media_name_label.text = mediaItem?.name ?? ""
            artist_name? = mediaItem?.artistName ?? ""
            media_apple_id = mediaItem?.identifier ?? ""
            isrc = mediaItem?.isrc ?? ""
            
        }
    }
    
    var spotify_mediaItem: SpotifyMediaObject.item! {
        didSet{
            media_image.image = nil
            media_name_label.text = spotify_mediaItem?.name ?? ""
            artist_name? = spotify_mediaItem?.artists![0].name ?? ""
            media_apple_id = spotify_mediaItem?.uri ?? ""
            isrc = spotify_mediaItem?.external_ids?.isrc ?? ""
            
        }
    }
    

}
