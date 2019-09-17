//
//  SpotifyArtistMediaObject.swift
//  Project2
//
//  Created by virdeshp on 7/25/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation

/*
 
 JSON decodable for the artist search response from spotify
 
https://developer.spotify.com/documentation/web-api/reference/search/search/
 */

class SpotifyArtistMediaObject: Decodable {
    
    struct artists : Decodable {
        let artists: artist
    }
    
    struct artist: Decodable {
        let href : String?
        let items : [item]?
        //        let limit : Int?
        //        let next : String?
        //        let offset : Int?
        //        let previous : String?
        //        let total: Int?
        //
        //        enum CodingKeys: String, CodingKey {
        //            case href = "href"
        //            case items = "items"
        //            case limit = "limit"
        //            case next = "next"
        //            case offset = "Int"
        //            case previous = "previous"
        //            case total = "total"
        //        }
    }
    
    struct item: Decodable {
        
        
        let followers: followers?
        let genres: [String]?
        let images: [image]?
        //        let external_urls: [external_urls]?
        //        let href : String?
        let id : String?
        //        let is_local: Bool?
        let name :  String?
        //        let popularity : Int?
        let preview_url : String?
        //        let type : String?
        let uri : String?
        
    }
    
    struct followers: Decodable {
        let href: String?
        let total: Int?
    }
    
    
    struct album: Decodable {
        //        let album_type : String?
        //        let artists : [artists]?
        //        let available_markets : [String]?
        //        let external_urls : external_urls?
        //        let href : String?
        //        let id : String?
        let images : [image]?
        let name : String?
        let release_date : String?
        //        let release_date_precision : String?
        //        let total_tracks : Int?
        //        let type : String?
        //        let uri : String?
        
    }
    //
    //

    //
    //
    //    struct external_urls: Decodable {
    //
    //        let spotify : String?
    //    }
    //
    struct isrc_id: Decodable {
        let isrc: String?
    }
    
    struct image: Decodable {
        
        let height: Int?
        let url: String?
        let width: Int?
        
        
    }
    
    var items: [item]
    //    init(items: [item]) {
    //
    //        self.items = items
    //
    //    }
    
    
}
