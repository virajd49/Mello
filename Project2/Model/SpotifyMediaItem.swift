//
//  SpotifyMediaItem.swift
//  Project2
//
//  Created by virdeshp on 9/12/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation


class SpotifyMediaItem {
    
    // MARK: Types
    
    /// The type of resource.
    ///
    /// - songs: This indicates that the `MediaItem` is a song from the Apple Music Catalog.
    /// - albums: This indicates that the `MediaItem` is an album from the Apple Music Catalog.
    enum MediaType: String {
        case track, album, playlist
    }
    
    /// The various keys needed for serializing an instance of `MediaItem` using a JSON response from the Apple Music Web Service.
    struct JSONKeys {
        /*
        static let album = "album"
        
        static let external_ids = "external_ids"
        
        static let artists = "artists"
        
        static let identifier = "id"
        
        static let type = "type"
        
        static let href = "href"
        
        static let preview_url = "preview_url"
        
        static let isrc = "isrc"
        */
        static let tracks = "tracks"
    }
    
    // MARK: Properties
    
    /// The persistent identifier of the resource which is used to add the item to the playlist or trigger playback.
     let tracks: [String]
    /*
    let identifier: String
    
    /// The localized name of the album or song.
    let external_ids: [String: String]
    
    /// The artist’s name.
    let artists: [String: String]
    
    /// The album artwork associated with the song or album.
 
    let tracks: [String]
    /// The type of the `MediaItem` which in this application can be either `songs` or `albums`.
    let type: MediaType
    
    let href: String
    
    let preview_url: String
    
    //let composerName: String
    
    //let genreNames: String
    
    
    let isrc: String
    var ISRC: String
    
    */
  
    
    // MARK: Initialization
    
    init(json: [String: Any]) throws {
        
        guard let tracks = json[JSONKeys.tracks] as? [String] else {
            throw SerializationError.missing(JSONKeys.tracks)
        }
         /*
        guard let identifier = json[JSONKeys.identifier] as? String else {
            throw SerializationError.missing(JSONKeys.identifier)
        }
        
        guard let href = json[JSONKeys.href] as? String else {
            throw SerializationError.missing(JSONKeys.href)
        }
        
        guard let preview_url = json[JSONKeys.preview_url] as? String else {
            throw SerializationError.missing(JSONKeys.preview_url)
        }
        
        guard let typeString = json[JSONKeys.type] as? String, let type = MediaType(rawValue: typeString) else {
            throw SerializationError.missing(JSONKeys.type)
        }
        
        guard let external_ids = json[JSONKeys.external_ids] as? [String: String] else {
            throw SerializationError.missing(JSONKeys.external_ids)
        }
        
        
        guard let artists = json[JSONKeys.artists] as? [String: String] else {
            throw SerializationError.missing(JSONKeys.artists)
        }
        
        /*
        //let artistName = attributes[JSONKeys.artistName] as? String ?? " "
        
        //guard let artworkJSON = attributes[JSONKeys.artwork] as? [String: Any], let artwork = try? Artwork(json: artworkJSON) else {
          //  throw SerializationError.missing(JSONKeys.artwork)
        //}
        */
        
        
        if (external_ids[JSONKeys.isrc] as? String) != nil {
            ISRC = (external_ids[JSONKeys.isrc] as? String)!
        }else {
            ISRC = "none"
        }
        */
        
        /*
         guard let isrc = attributes[JSONKeys.isrc] as? String else {
         print("yeah this was thrown")
         throw SerializationError.missing(JSONKeys.isrc)
         }
         
         
         guard let composerName = attributes[JSONKeys.composerName] as? String else {
         throw SerializationError.missing(JSONKeys.composerName)
         }
         
         guard let genreNames = attributes[JSONKeys.genreNames] as? String else {
         throw SerializationError.missing(JSONKeys.genreNames)
         }
         
 
         guard let isrc = attributes[JSONKeys.isrc] as? String else {
         print("yeah this was thrown")
         let isrc = "none"
         return
         //throw SerializationError.missing(JSONKeys.isrc)
         }
         */
        
        /*
        self.identifier = identifier
        self.type = type
        self.preview_url = preview_url
        self.artists = artists
        self.external_ids = external_ids
        self.href = href
        self.isrc = ISRC
        */
        self.tracks = tracks
        /*
         self.composerName = composerName
         
         self.genreNames = genreNames
         */
        //self.isrc = isrc
        
        
    }
}
