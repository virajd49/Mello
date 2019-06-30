//
//  SpotifyMediaObject.swift
//  Project2
//
//  Created by virdeshp on 9/15/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation


class SpotifyMediaObject: Decodable {
    
    struct tracks : Decodable {
        let tracks: track
    }
    
    struct track: Decodable {
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
    
    
}
