//
//  SpotifyTopTracksMediaObject.swift
//  Project2
//
//  Created by virdeshp on 10/5/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation

/*
 
 JSON decodable for the recently played items response from spotify
 
https://developer.spotify.com/documentation/web-api/reference/player/get-recently-played/
 */


class SpotifyTopTracksMediaObject: Decodable {
    
    struct items : Decodable {
        let items: [item]
    }

    struct item: Decodable {
        //this is a track
        let album: album?
        let artists: [artists]?
        //        let available_markets: [String]?
        //        let disc_number : Int?
        let duration_ms: Int?
        //        let explicit: Bool?
        let external_ids: isrc_id?
        //        let external_urls: [external_urls]?
        //        let href : String?
        let id : String?
        //        let is_local: Bool?
        let name :  String?
        //        let popularity : Int?
        let preview_url : String?
        //        let track_number : Int?
        //        let type : String?
        let uri : String?
        let context: context?
        //
        //        enum CodingKeys: String, CodingKey {
        //            case album = "album"
        //            case artists = "artists"
        //            case available_markets =  "available_markets"
        //            case disc_number = "disk_number"
        //            case duration_ms = "duration_ms"
        //            case explicit = "Bool"
        //            case external_ids =  "external_ids"
        //            case external_urls = "external_urls"
        //            case href  = "href"
        //            case id = "id"
        //            case is_local = "is_local"
        //            case name = "name"
        //            case popularity = "popularity"
        //            case preview_url = "preview_url"
        //            case track_number = "track_number"
        //            case type = "type"
        //            case uri  = "uri"
        //
        //        }
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
    struct artists: Decodable {
        //        let external_urls : [external_urls]?
        //        let href : String?
        //        let id : String?
        let name : String?
        //        let type : String?
        //        let uri : String?
        //
        
        
    }
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
    
    struct context: Decodable {
        let uri: String?
        //let external_urls: external_urls?
        let href: String?
        let type: String?
    }
    
    
}
