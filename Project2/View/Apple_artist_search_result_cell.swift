//
//  apple_artist_search_result_cell.swift
//  Project2
//
//  Created by virdeshp on 7/27/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import GoogleAPIClientForREST

//Artist search results - Heroes page view controller

class Apple_artist_search_result_cell: UITableViewCell {
    
    static let identifier = "appleartistsearchresultcell"
    
    @IBOutlet weak var artist_name_label: UILabel!
    
    var artist_name: String?
    var media_id: String?
   
    var artistMediaItem: ArtistMediaItem! {
        didSet{
            artist_name_label.text = artistMediaItem?.name ?? ""
            artist_name? = artistMediaItem?.name ?? ""
            media_id = artistMediaItem?.identifier ?? ""
            
        }
    }
    
  
}
