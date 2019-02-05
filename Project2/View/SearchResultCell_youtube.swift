//
//  SearchResultCell_youtube.swift
//  Project2
//
//  Created by virdeshp on 1/31/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import UIKit
import GoogleAPIClientForREST

class SearchResultCell_youtube: UITableViewCell{
    
    static let identifier = "searchresultcell_youtube"
    
    
    @IBOutlet weak var media_image: UIImageView!
       
    @IBOutlet weak var media_name_label: UILabel!
    
    
    var artist_name: String?
    var media_id: String?
    var isrc: String?
    var yt_video_duration: Float?
    
    
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
