//
//  MediaItem.swift
//  Project2
//
//  Created by virdeshp on 5/10/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation

/*
 
  JSON keys struct file for apple mediat items - taken pretty much straigh off from the apple music sample project
 
 */

class MediaItem {
    
    // MARK: Types
    
    /// The type of resource.
    ///
    /// - songs: This indicates that the `MediaItem` is a song from the Apple Music Catalog.
    /// - albums: This indicates that the `MediaItem` is an album from the Apple Music Catalog.
    enum MediaType: String {
        case songs, albums, stations, playlists
    }
    
    /// The various keys needed for serializing an instance of `MediaItem` using a JSON response from the Apple Music Web Service.
    struct JSONKeys {
        static let identifier = "id"
        
        static let type = "type"
        
        static let attributes = "attributes"
        
        static let name = "name"
        
        static let artistName = "artistName"
        
        static let artwork = "artwork"
        
        //static let composerName = "composerName"
        
        //static let genreNames = "genreNames"
        
        static let isrc = "isrc"
        
        static let url = "url"
        
        static let albumName = "albumName"
        
        static let releaseDate = "releaseDate"
        
        static let previews = "previews"
        
        static let durationInMillis = "durationInMillis"
    }
    
    // MARK: Properties
    
    /// The persistent identifier of the resource which is used to add the item to the playlist or trigger playback.
    let identifier: String?
    
    /// The localized name of the album or song.
    let name: String?
    
    /// The artist’s name.
    let artistName: String?
    
    /// The album artwork associated with the song or album.
    let artwork: Artwork
    
    /// The type of the `MediaItem` which in this application can be either `songs` or `albums`.
    let type: MediaType
    
    let albumName: String?
    
    //let composerName: String
    
    //let genreNames: [String]
    
    
    let isrc: String?
    //var ISRC: String
   
    let previews: [[String: String]]
    
    let url: String?
    
    let releaseDate: String?
    
    let durationInMillis: Int?
 
    // MARK: Initialization
    
    init(json: [String: Any]) throws {
        guard let identifier = json[JSONKeys.identifier] as? String else {
            throw SerializationError.missing(JSONKeys.identifier)
        }
        
        guard let typeString = json[JSONKeys.type] as? String, let type = MediaType(rawValue: typeString) else {
            throw SerializationError.missing(JSONKeys.type)
        }
        
        guard let attributes = json[JSONKeys.attributes] as? [String: Any] else {
            throw SerializationError.missing(JSONKeys.attributes)
        }
        
        //
        //print (attributes)
        guard let name = attributes[JSONKeys.name] as? String else {
            throw SerializationError.missing(JSONKeys.name)
        }
        
        let artistName = attributes[JSONKeys.artistName] as? String ?? " "
        
        
        /*
        guard let artworkJSON = attributes[JSONKeys.artwork] as? [String: Any], let artwork = try? Artwork(json: artworkJSON) else {
            throw SerializationError.missing(JSONKeys.artwork)
            //artwork = Artwork(json: ["height": 438, "width":440, "url": "https://upload.wikimedia.org/wikipedia/commons/d/df/ITunes_logo.svg"])
        }
         */
        
        if attributes.keys.contains(JSONKeys.artwork) {
            print ("contains artwork")
            guard let artworkJSON = attributes[JSONKeys.artwork] as? [String: Any], let artwork = try? Artwork(json: artworkJSON) else {
                print("throwing error from here 1")
                throw SerializationError.missing(JSONKeys.artwork)
            }
            self.artwork = artwork
        } else {
            print("does not contain artwork")
            guard let artwork = try? Artwork(json: ["height": 438, "width": 440, "url": "https://upload.wikimedia.org/wikipedia/commons/d/df/ITunes_logo.svg"]) else {
                print("throwing error from here 2")
                throw SerializationError.missing(JSONKeys.artwork)
            }
            self.artwork = artwork
            
        }
        
        let duration = attributes[JSONKeys.durationInMillis] as? Int ?? 0
        
        let isrc = attributes[JSONKeys.isrc] as? String ?? " "
        
        let previews = attributes[JSONKeys.previews] as? [[String: String]] ?? [["": ""]]
        
        let url = attributes[JSONKeys.url] as? String ?? " "
        
        let albumName = attributes[JSONKeys.albumName] as? String ?? " "
        
        let releaseDate = attributes[JSONKeys.releaseDate] as? String ?? " "
        
//        guard let isrc = (attributes[JSONKeys.isrc] as? String) else {
//            throw SerializationError.missing(JSONKeys.name)
//        }
        
        /*
        guard let composerName = attributes[JSONKeys.composerName] as? String else {
            throw SerializationError.missing(JSONKeys.composerName)
        }
       */
        
//        guard let genreNames = attributes[JSONKeys.genreNames] as? [String] else {
//            throw SerializationError.missing(JSONKeys.genreNames)
//        }
 
       
//        guard let url = (attributes[JSONKeys.url] as? String) else {
//            throw SerializationError.missing(JSONKeys.url)
//        }
 
        
        self.identifier = identifier
        self.type = type
        self.name = name
        self.artistName = artistName
        //self.artwork = artwork
        self.isrc = isrc
        self.previews = previews
        self.durationInMillis = duration
        //self.composerName = composerName
        //self.genreNames = genreNames
        self.url = url
        self.albumName = albumName
        self.releaseDate = releaseDate
        
    }
}
