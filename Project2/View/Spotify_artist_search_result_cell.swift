//
//  spotify_artist_result_cell.swift
//  Project2
//
//  Created by virdeshp on 7/27/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import GoogleAPIClientForREST

class Spotify_artist_search_result_cell: UITableViewCell {
    
    static let identifier = "spotifyartistsearchresultcell"
    
    
    @IBOutlet weak var artist_media_image: UIImageView!
    
    @IBOutlet weak var artist_name_label: UILabel!
    
    var artist_name: String?
    var media_id: String?
    var isrc: String?
  
    var spotify_artist_mediaItem: SpotifyArtistMediaObject.item! {
        didSet{
            artist_media_image.image = nil
            artist_name_label.text = spotify_artist_mediaItem?.name ?? ""
            artist_name? = spotify_artist_mediaItem?.name ?? ""
            media_id = spotify_artist_mediaItem?.uri ?? ""
           
            
        }
    }
}
