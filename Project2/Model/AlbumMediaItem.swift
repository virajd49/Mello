//
//  AlbumMediaItem.swift
//  Project2
//
//  Created by virdeshp on 8/17/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation

/*
 
 JSON keys struct file for apple album media item - taken pretty much straigh off from the apple music sample project.

 */


class AlbumMediaItem {
    
    // MARK: Types
    
    /// The type of resource.
    ///
    /// - songs: This indicates that the `MediaItem` is a song from the Apple Music Catalog.
    /// - albums: This indicates that the `MediaItem` is an album from the Apple Music Catalog.
    enum MediaType: String {
        case albums
    }
    
    /// The various keys needed for serializing an instance of `MediaItem` using a JSON response from the Apple Music Web Service.
    struct JSONKeys {
        static let identifier = "id"
        
        static let type = "type"
        
        static let attributes = "attributes"
        
        static let genreNames = "genreNames"
        
        static let name = "name"
        
        static let editorialNotes = "editorialNotes"
        
        static let url = "url"
        
        static let relationships = "relationships"
        
        //static let tracks = "tracks"
        
        static let artistName = "artistName"
        
        //static let tracks_data = "data"
        
    }
    
    // MARK: Properties
    
    /// The persistent identifier of the resource which is used to add the item to the playlist or trigger playback.
    let identifier: String?
    
    /// The localized name of the album or song.
    let name: String?
  
    /// The type of the `MediaItem` which in this application can be either `songs` or `albums`.
    let type: MediaType
 
    let genreNames: [String]
    
    let editorialNotes: String?
    
    let url: String?
    
    //let tracks_data: [MediaItem]
    
    let artistName: String?
    
    
    
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
        
        guard let relationships = json[JSONKeys.relationships] as? [String: Any] else {
            throw SerializationError.missing(JSONKeys.attributes)
        }
//
//        guard let tracks = relationships[JSONKeys.tracks] as? [String: Any] else {
//            throw SerializationError.missing(JSONKeys.name)
//        }
        
//        guard let tracks_data = tracks[JSONKeys.tracks_data] as? [MediaItem] else {
//
//            throw SerializationError.missing(JSONKeys.name)
//        }
        
        //
        //print (attributes)
        guard let name = attributes[JSONKeys.name] as? String else {
            throw SerializationError.missing(JSONKeys.name)
        }
        
        guard let artistName = attributes[JSONKeys.artistName] as? String else {
            throw SerializationError.missing(JSONKeys.name)
        }
        
        let editorialNotes = attributes[JSONKeys.editorialNotes] as? String ?? " "
        
        /* guard let artworkJSON = attributes[JSONKeys.artwork] as? [String: Any], let artwork = try? Artwork(json: artworkJSON) else {
         throw SerializationError.missing(JSONKeys.artwork)
         } */
        
        guard let genreNames = attributes[JSONKeys.genreNames] as? [String] else {
            throw SerializationError.missing(JSONKeys.genreNames)
        }
        
        let url = attributes[JSONKeys.url] as? String ?? " "
        
        self.identifier = identifier
        self.type = type
        self.name = name
        self.genreNames = genreNames
        self.url = url
        self.editorialNotes = editorialNotes
        //self.tracks_data = tracks_data
        self.artistName = artistName
        
        
    }
}
