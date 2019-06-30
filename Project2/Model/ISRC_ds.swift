//
//  ISRC_ds.swift
//  Project2
//
//  Created by virdeshp on 9/25/18.
//  Copyright © 2018 Viraj. All rights reserved.
//


//This class is used for fitting song metadata into teh fomrat required for our ISRC db.
import UIKit

//not being used
struct spotify_data_struct {
    
    
    var playable_id: String?
    var song_name: String?
    var album_name: String?
    var artist_name: String?
    var isrc_number: String?
    var release_date: String?
}

//not being used
struct apple_data_struct {
    
    
    var playable_id: String?
    var song_name: String?
    var album_name: String?
    var artist_name: String?
    var isrc_number: String?
    var release_date: String?
}

struct song_db_struct {
    
    var playable_id: String?
    var song_name: String?
    var album_name: String?
    var artist_name: String?
    var isrc_number: String?
    var release_date: String?
    var preview_url: String?
    
    
}

class ISRC_ds {
    
    typealias isrc_data_set = [String : [String: [String: Any]]]
    var spotify_data: song_db_struct
    var apple_data: song_db_struct
    var isrc_number: String
    
    init (isrc_number: String, spotify_set: song_db_struct, apple_set: song_db_struct) {
        self.spotify_data = spotify_set
        self.apple_data = apple_set
        self.isrc_number = isrc_number
    }
    
   func create_spotify_set() -> [String: Any] {
        
    var spotify_set = ["playable_id": self.spotify_data.playable_id, "song_name" : self.spotify_data.song_name, "album_name": self.spotify_data.album_name, "artist_name": self.spotify_data.artist_name, "preview_url": self.spotify_data.preview_url ?? "nil"] as [String: Any]
        
        return spotify_set
        
    }
    
    func create_apple_set() -> [String: Any] {
        
        let apple_set = ["playable_id": self.apple_data.playable_id, "song_name" : self.apple_data.song_name, "album_name": self.apple_data.album_name, "artist_name": self.apple_data.artist_name, "preview_url": self.apple_data.preview_url ?? "nil"] as [String: Any]
        
        return apple_set
        
    }
    
    func create_isrc_ds() -> isrc_data_set {
        
        let isrc_ds = [ isrc_number : ["apple_set" : self.create_apple_set(), "spotify_set" : self.create_spotify_set()]]
        
        return isrc_ds
    }
    
    func create_isrc_ds_apple_only() -> isrc_data_set {
        
        let isrc_ds = [ isrc_number : ["apple_set" : self.create_apple_set()]]
        
        return isrc_ds
    }
    
    func create_isrc_ds_spotify_only() -> isrc_data_set {
        
        let isrc_ds = [ isrc_number : ["spotify_set" : self.create_spotify_set()]]
        
        return isrc_ds
    }
    
    
}
