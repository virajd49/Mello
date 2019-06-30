//
//  SpotifyCurrentPlayingMediaObject.swift
//  Project2
//
//  Created by virdeshp on 2/17/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation


class SpotifyCurrentPlayingMediaObject: Decodable {
    
    struct currently_playing_context: Decodable {
        let timestamp: Int?
        //let device: device?
        let progress_ms: Int
        let is_playing: Bool?
        let currently_playing_type: String?
        let item: item?
        //let shuffle_state: Bool?
        //let repeat_state: String?
        let context: context?
        
        
    }
    
    struct context: Decodable {
        let external_urls: external_urls?
        let href: String?
        let type: String?
        let uri: String?
        
    }
    
    struct device: Decodable {
        let id: String?
        let is_active: Bool?
        let is_restricted: Bool?
        let name: String?
        let type: String?
        let volume_percent: Int?
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
    
    
    struct external_urls: Decodable {
        
        let spotify : String?
        
    }
    
    struct isrc_id: Decodable {
        let isrc: String?
    }
    
    struct image: Decodable {
        
        let height: Int?
        let url: String?
        let width: Int?
        
        
    }
    
    
}
