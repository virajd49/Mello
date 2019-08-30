//
//  AppleMusicManager.swift
//  Project2
//
//  Created by virdeshp on 5/10/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation
import StoreKit
import UIKit
import PromiseKit


/* This file is a direct copy from apple's music kit example project and includes a lot of additions by me.
 
 This file contains functions to do all of the following:
 
 Apple/Spotify catalog search for : a song(using song name or song id)
                                    an artist (using artist name)
                                    all the songs in an album (using album id)
                                    recently played items by the user
                                    podcasts (by name) - most recent addition
 
 It also has functions to process the items returned by these requests: These process functions use the all the following models to map the JSON responses:
 
    The apple MediaItem is taken from the apple example project - I wrote ArtistMediaItem and AlbumMediatItem based off that
        MediaItem.swift - Apple - songs, albums - https://developer.apple.com/documentation/applemusicapi/search_for_catalog_resources
        ArtistMediaItem.swift - Apple - artists - https://developer.apple.com/documentation/applemusicapi/search_for_catalog_resources
        AlbumMediatItem.swift - Apple - Album - https://developer.apple.com/documentation/applemusicapi/get_a_catalog_album
 
    I wanted a simple way to map JSON and didn're really like the way MediaItem was done so I used Decodables for the spotify items
        SpotifyMediaObject.swift - Spotify - tracks, albums - https://developer.spotify.com/documentation/web-api/reference/tracks/get-track/
        SpotifyArtistMediaObject - Spotify - Artist - https://developer.spotify.com/documentation/web-api/reference/artists/get-artist/
        SpotifyRecentlyPlayedMediaObject - https://developer.spotify.com/documentation/web-api/reference/player/get-recently-played/
        SpotifyCurrentlyPlayingMediaObject - https://developer.spotify.com/documentation/web-api/reference/player/get-information-about-the-users-current-playback/
 
 All searches are done using a search URL - these search URLs are created in AppleMusicRequestFactory.swift (need to change this name to something more platform agnostic - it includes spotify and apple URLs ). The URLs is where we can decide what type of items do we want in the response for certain searches  - only songs, only albums, songs and albums both, etc.
 */

class AppleMusicManager {
    
    enum MyError: Error {
        case runtimeError(String)
    }
    
    
    let userDefaults = UserDefaults.standard
    /// The completion handler that is called when an Apple Music Catalog Search API call completes.
    typealias CatalogSearchCompletionHandler = (_ mediaItems: [MediaItem], _ error: Error?) -> Void
    
    typealias SpotifyCatalogSearchCompletionHandler = (_ mediaItems: [SpotifyMediaObject.item], _ error: Error?) -> Void
    /// The completion handler that is called when an Apple Music Get User Storefront API call completes.
    typealias GetUserStorefrontCompletionHandler = (_ storefront: String?, _ error: Error?) -> Void
    
    /// The completion handler that is called when an Apple Music Get Recently Played API call completes.
    typealias GetRecentlyPlayedCompletionHandler = (_ mediaItems: [MediaItem], _ error: Error?) -> Void
    
    
    /// The instance of `URLSession` that is going to be used for making network calls.
    lazy var urlSession: URLSession = {
        // Configure the `URLSession` instance that is going to be used for making network calls.
        let urlSessionConfiguration = URLSessionConfiguration.default
        
        return URLSession(configuration: urlSessionConfiguration)
    }()
    
    
    /// The storefront id that is used when making Apple Music API calls.
    var storefrontID: String?
    
    
    
    func fetchDeveloperToken() -> String? {
        
        // MARK: ADAPT: YOU MUST IMPLEMENT THIS METHOD
        let developerAuthenticationToken: String? = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Iko3VDc3WjQ0V1oifQ.eyJpc3MiOiIyODJIMlU4VkZUIiwiaWF0IjoxNTY0NTM5ODI0LCJleHAiOjE1NjYyNjc4MjR9.uFqA8yEGny6DkgMuYyHqFb_AZb90mWvBUIHZqRUNcwdze_mLunM79fs_msFl8RiO3JNh_tHuhugcdGzmzrUk6Q"
        
//        "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Iko3VDc3WjQ0V1oifQ.eyJpc3MiOiIyODJIMlU4VkZUIiwiaWF0IjoxNTUyNTMyMzIwLCJleHAiOjE1NTY4NTIzMjB9.omYV_K9GTUgO8zYjMe7ySp-3p6xOO5WR6JkPeSJPtaePcaKIyGzLHnAlOkj_cOfJxuStUP8U1bh3c2ZWrAU97A"
        return developerAuthenticationToken
    }
    
    //Original catalog search function that came with the apple musickit example project. This returns songs and albums in the response.
    func performAppleMusicCatalogSearch(with term: String, countryCode: String, completion: @escaping CatalogSearchCompletionHandler) {
        
        print("search got to here as well")
        print(term)
        //print(countryCode)
        
        guard let developerToken = fetchDeveloperToken() else {
            fatalError("Developer Token not configured. See README for more details.")
        }
        
        let urlRequest = AppleMusicRequestFactory.createSearchRequest(with: term, countryCode: countryCode, developerToken: developerToken)
        
        //print(urlRequest)
        //print (developerToken)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            print(error)
            print(response)
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion([], error)
                print("error response")
                //print(error)
                return
            }
            print(urlResponse)
            //print("response should be above this guy")
            let dataAsString = String(data: data!, encoding: .utf8)
            print(dataAsString)
            do {
                let mediaItems = try self.processMediaItemSections(from: data!)
                completion(mediaItems, nil)
                //print(mediaItems)
                
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    //Searches for songs in the Spotify catalog using song name as input string
    func performSpotifyCatalogSearch(with term: String, completion: @escaping SpotifyCatalogSearchCompletionHandler) {
        
        //print("search got to here as well")
        //print(term)
        //print(countryCode)
        
        let developerToken = (self.userDefaults.object(forKey: "spotify_access_token")) as! String
        
        let urlRequest = AppleMusicRequestFactory.createSpotifySearchRequest(with: term, developerToken: developerToken)
        
        //print(urlRequest)
        //print (developerToken)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            //print(error)
            //print(response)
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion([], error)
                //print("error response")
                //print(error)
                
                return
            }
            
            guard let data = data else {return}
            
            let dataAsString = String(data: data, encoding: .utf8)
            //print(dataAsString)
            //print(urlResponse)
            //print("response should be above this guy")

            do {
                let spotifyMediaObjects = try self.processSpotifyMediaItemSections(from: data)
                completion(spotifyMediaObjects, nil)
                //print(spotifyMediaObjects)
                
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
           
        }
        
        task.resume()
    }
    
    
    /*original function that came with the apple musickit example project. Returns all recently played items by the suwer, problem here is that it only returns them as albums - not individual tracks - I don't know why - so to get all the tracks you have to use performAppleMusicCatalogSearch_album_relation_songs with the ID of the album you get from this function.
 
        https://developer.apple.com/documentation/applemusicapi/get_recently_played_resources
 
    */
    
    
    func performAppleMusicGetRecentlyPlayed(userToken: String, completion: @escaping GetRecentlyPlayedCompletionHandler) {
        print ("performAppleMusicGetRecentlyPlayed")
        guard let developerToken = fetchDeveloperToken() else {
            fatalError("Developer Token not configured.  See README for more details.")
        }
        
        let urlRequest = AppleMusicRequestFactory.createRecentlyPlayedRequest(developerToken: developerToken, userToken: userToken)
        print(urlRequest)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion([], error)
                
                return
            }
            
            do {
                guard let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                    let results = jsonDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] else {
                        throw SerializationError.missing(ResponseRootJSONKeys.data)
                }
                
                let dataAsString = String(data: data!, encoding: .utf8)
                print(dataAsString)
                //print(urlResponse)
                //print("response should be above this guy")
                
                let mediaItems = try self.processMediaItems(from: results)
                
                completion(mediaItems, nil)
                
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    /*The apple catalog varies as per you region, this function looks up the storefront for the region you are in. This is called during user token retrieval in AppleMusicControl
        https://developer.apple.com/documentation/applemusicapi/storefronts_and_localization
    */
    func performAppleMusicStorefrontsLookup(regionCode: String, completion: @escaping GetUserStorefrontCompletionHandler) {
        guard let developerToken = fetchDeveloperToken() else {
            fatalError("Developer Token not configured. See README for more details.")
        }
        
        let urlRequest = AppleMusicRequestFactory.createStorefrontsRequest(regionCode: regionCode, developerToken: developerToken)
        
        let task = urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion(nil, error)
                return
            }
            
            do {
                let identifier = try self?.processStorefront(from: data!)
                completion(identifier, nil)
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    /*This function looks up the users storefront based on what country the users account is based in.
        https://developer.apple.com/documentation/applemusicapi/storefronts_and_localization
    */
    func performAppleMusicGetUserStorefront(userToken: String, completion: @escaping GetUserStorefrontCompletionHandler) {
        guard let developerToken = fetchDeveloperToken() else {
            fatalError("Developer Token not configured.  See README for more details.")
        }
        let urlRequest = AppleMusicRequestFactory.createGetUserStorefrontRequest(developerToken: developerToken, userToken: userToken)
        
        let task = urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                let error = NSError(domain: "AppleMusicManagerErrorDomain", code: -9000, userInfo: [NSUnderlyingErrorKey: error!])
                
                completion(nil, error)
                
                return
            }
            
            do {
                
                let identifier = try self?.processStorefront(from: data!)
                
                completion(identifier, nil)
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    
    func processMediaItemSections(from json: Data) throws -> [MediaItem] {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let results = jsonDictionary[ResponseRootJSONKeys.results] as? [String: [String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.results)
        }
        
        var mediaItems = [MediaItem]()
        
        if let songsDictionary = results[ResourceTypeJSONKeys.songs] {
            
            if let dataArray = songsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let songMediaItems = try processMediaItems(from: dataArray)
                mediaItems = songMediaItems
            }
        }
        
//        if let albumsDictionary = results[ResourceTypeJSONKeys.albums] {
//
//            if let dataArray = albumsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
//                let albumMediaItems = try processMediaItems(from: dataArray)
//                mediaItems.append(albumMediaItems)
//            }
//        }
        
        return mediaItems
    }
    
    //Used for artist searches
    func processArtistMediaItemSections(from json: Data) throws -> [ArtistMediaItem] {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let results = jsonDictionary[ResponseRootJSONKeys.results] as? [String: [String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.results)
        }
        
        var mediaItems = [ArtistMediaItem]()
        
        if let songsDictionary = results[ResourceTypeJSONKeys.songs] {
            
            if let dataArray = songsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let songMediaItems = try processArtistMediaItems(from: dataArray)
                mediaItems = songMediaItems
            }
        }
        
        //        if let albumsDictionary = results[ResourceTypeJSONKeys.albums] {
        //
        //            if let dataArray = albumsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
        //                let albumMediaItems = try processMediaItems(from: dataArray)
        //                mediaItems.append(albumMediaItems)
        //            }
        //        }
        
        return mediaItems
    }
    
    //Used only for song searches by song id - done for grabbing the now playing album art for UploadViewcontroller
    func processMediaItemSections_songID(from json: Data) throws -> [[MediaItem]] {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let data = jsonDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] else {
                print ("this error processMediaItemSections")
                throw SerializationError.missing(ResponseRootJSONKeys.data)
        }
        print ("processMediaItemSections 1 ")
        var mediaItems = [[MediaItem]]()
        let songMediaItem = try processMediaItems(from: data)
        mediaItems.append(songMediaItem)
        
        return mediaItems
    }
    
    //Used only for album searches by album id - done to get all the tracks in an album - because apple music returns only albums for recently played
    func processMediaItemSections_album_relations_songs(from json: Data) throws -> [MediaItem] {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let data = jsonDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] else {
                print ("this error processMediaItemSections")
                throw SerializationError.missing(ResponseRootJSONKeys.data)
        }
        print ("processMediaItemSections 1 ")
        var mediaItems = [MediaItem]()
        let mediaItem = try processMediaItems(from: data)
        mediaItems = mediaItem
        
        return mediaItems
    }
    
    //Used to process song search results from the spotify catalog
    func processSpotifyMediaItemSections(from json: Data) throws -> [SpotifyMediaObject.item] {
        
        var tracks_1 = [SpotifyMediaObject.item]()
        
        
        do {
            let tracks = try JSONDecoder().decode(SpotifyMediaObject.tracks.self, from: json)
            //                let isrc_id = try JSONDecoder().decode(SpotifyMediaObject.isrc_id.self, from: data)
//            print("\n----------------processSpotifyMediaItemSections---------------------")
//            //print(tracks.tracks.items)
//            print(tracks.tracks.items![0].external_ids?.isrc)
//            print(tracks.tracks.items![0].album?.name)
//            print(tracks.tracks.items![0].name)
//            print(tracks.tracks.items![0].artists![0].name)
//            print(tracks.tracks.items![0].preview_url)
//            print(tracks.tracks.items![0].uri)
//            print("-----------------processSpotifyMediaItemSections--------------------\n")
            tracks_1 = tracks.tracks.items!
        } catch let jsonErr{
            print ("Error Serializing JSON: ", jsonErr)
        }
        return tracks_1
    }
    
    
    //Used to process artist search results from the spotify catalog
    func processSpotifyMediaArtistItemSections(from json: Data) throws -> [SpotifyArtistMediaObject.item] {
        
        var artists_1 = [SpotifyArtistMediaObject.item]()
        
        
        do {
            let artists = try JSONDecoder().decode(SpotifyArtistMediaObject.artists.self, from: json)
            //                let isrc_id = try JSONDecoder().decode(SpotifyMediaObject.isrc_id.self, from: data)
            //            print("\n----------------processSpotifyMediaItemSections---------------------")
            //            //print(tracks.tracks.items)
            //            print(tracks.tracks.items![0].external_ids?.isrc)
            //            print(tracks.tracks.items![0].album?.name)
            //            print(tracks.tracks.items![0].name)
            //            print(tracks.tracks.items![0].artists![0].name)
            //            print(tracks.tracks.items![0].preview_url)
            //            print(tracks.tracks.items![0].uri)
            //            print("-----------------processSpotifyMediaItemSections--------------------\n")
            artists_1 = artists.artists.items!
        } catch let jsonErr{
            print ("Error Serializing JSON: ", jsonErr)
        }
        return artists_1
    }
    
    
    func processMediaItems(from json: [[String: Any]]) throws -> [MediaItem] {
        let songMediaItems = try json.map { try MediaItem(json: $0) }
        return songMediaItems
    }
    
    func processArtistMediaItems(from json: [[String: Any]]) throws -> [ArtistMediaItem] {
        let artistMediaItems = try json.map { try ArtistMediaItem(json: $0) }
        return artistMediaItems
    }
    
    func processAlbumMediaItems(from json: [[String: Any]]) throws -> [AlbumMediaItem] {
        let albumMediaItems = try json.map { try AlbumMediaItem(json: $0) }
        return albumMediaItems
    }
    
    
    
//    func processSpotifyMediaItems(from json: [[String: Any]]) throws -> [SpotifyMediaItem] {
//        let songMediaItems = try json.map { try SpotifyMediaItem(json: $0) }
//        return songMediaItems
//    }
    
    func processStorefront(from json: Data) throws -> String {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let data = jsonDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.data)
        }
        
        guard let identifier = data.first?[ResourceJSONKeys.identifier] as? String else {
            throw SerializationError.missing(ResourceJSONKeys.identifier)
        }
        
        return identifier
    }
    
   
    
    //Does the same as the original performAppleMusicCatalogSearch except that this one is implemented using Promises, I needed the code to be synchronous.
    func performAppleMusicCatalogSearchNew(with term: String, countryCode: String ) -> Promise<[MediaItem]> {
        return Promise { seal in
        print("performAppleMusicCatalogSearchNew")
        //print(term)
        //print(countryCode)
        
        guard let developerToken = fetchDeveloperToken() else {
            seal.reject("Error fetching developer token: performAppleMusicCatalogSearchNew" as! Error)
            fatalError("Developer Token not configured. See README for more details.")
        }
        
        let urlRequest = AppleMusicRequestFactory.createSearchRequest(with: term, countryCode: countryCode, developerToken: developerToken)
        
        print(urlRequest)
        print (developerToken)
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            print(error)
            print(response)
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                if error != nil {
                print(error)
                seal.reject (error!)
                } else {
                    seal.reject("Http error response performAppleMusicCatalogSearchNew" as! Error)
                }
                print("error response")
                return
            }
            //print(urlResponse)
            //print("response should be above this guy")
            let dataAsString = String(data: data!, encoding: .utf8)
            print(dataAsString)
            do {
                let mediaItems = try self.processMediaItemSections(from: data!)
                seal.fulfill(mediaItems)
                //print(mediaItems)
                
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
                seal.reject(MyError.runtimeError("JSON processing error - performAppleMusicCatalogSearch"))
            }
        }.resume()
        
        //task.resume()
    }
  }
    
    
    //Does the same as the original performSpotifyCatalogSearch except that this one is implemented using Promises, I needed the code to be synchronous.
    func performSpotifyCatalogSearchNew(with term: String) -> Promise<[SpotifyMediaObject.item]>{
        return Promise { seal in
        //print("search got to here as well")
        //print(term)
        //print(countryCode)
        
        let developerToken = (self.userDefaults.object(forKey: "spotify_access_token")) as! String
        
        let urlRequest = AppleMusicRequestFactory.createSpotifySearchRequest(with: term, developerToken: developerToken)
        
        //print(urlRequest)
        //print (developerToken)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            //print(error)
            //print(response)
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                if error != nil {
                    print(error)
                    seal.reject (error!)
                } else {
                    seal.reject("Http error response performSpotifyCatalogSearchNew" as! Error)
                }
                print("error response")
                return
            }
            
            guard let data = data else {return}
            
            let dataAsString = String(data: data, encoding: .utf8)
            print(dataAsString)
            //print(urlResponse)
            //print("response should be above this guy")
            
            do {
                let spotifyMediaObjects = try self.processSpotifyMediaItemSections(from: data)
                seal.fulfill(spotifyMediaObjects)
                //print(spotifyMediaObjects)
                
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
            
        }
        
         task.resume()
       }
    }
    
    
    //Searches for a song in the spotify catalog using a song ID (called URI in spotify API nomenclature)
    func performSpotifyCatalogSearchNew_songURI(with term: String) -> Promise<[SpotifyMediaObject.item]>{
        return Promise { seal in
            //print("search got to here as well")
            //print(term)
            //print(countryCode)
            
            let developerToken = (self.userDefaults.object(forKey: "spotify_access_token")) as! String
            
            let urlRequest = AppleMusicRequestFactory.createSpotifySearchRequest_songURI(with: term, accesstoken: developerToken)
            
            //print(urlRequest)
            //print (developerToken)
            let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
                print(error)
                print(response)
                guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                    if error != nil {
                        print(error)
                        seal.reject (error!)
                    } else {
                        seal.reject("Http error response performSpotifyCatalogSearchNew" as! Error)
                    }
                    print("error response")
                    return
                }
                
                guard let data = data else {return}
                
                let dataAsString = String(data: data, encoding: .utf8)
                //print(dataAsString)
                //print(urlResponse)
                //print("response should be above this guy")
                
                do {
                    let spotifyMediaObject = try self.processSpotifyMediaItemSections_songURI(from: data)
                    seal.fulfill(spotifyMediaObject)
                    //print(spotifyMediaObjects)
                    
                } catch {
                    fatalError("An error occurred: \(error.localizedDescription)")
                }
                
            }
            
            task.resume()
        }
    }
    
    //Saerches for a song in the apple catalog using a song ID.
    func performAppleMusicCatalogSearch_songID (with term: String, countryCode: String ) -> Promise<[[MediaItem]]> {
        return Promise { seal in
            //print("search got to here as well")
            //print(term)
            //print(countryCode)
            
            guard let developerToken = fetchDeveloperToken() else {
                seal.reject("Error fetching developer token: performAppleMusicCatalogSearchNew" as! Error)
                fatalError("Developer Token not configured. See README for more details.")
            }
            
            let urlRequest = AppleMusicRequestFactory.createSearchRequest_for_song_id(with: term, countryCode: countryCode, developerToken: developerToken)
            
            print(urlRequest)
            print (developerToken)
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                print(error)
                print(response)
                guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                    if error != nil {
                        print(error)
                        seal.reject (error!)
                    } else {
                        seal.reject("Http error response performAppleMusicCatalogSearchNew_songID" as! Error)
                    }
                    print("error response")
                    return
                }
                //print(urlResponse)
                //print("response should be above this guy")
                let dataAsString = String(data: data!, encoding: .utf8)
                print(dataAsString)
                do {
                    let mediaItems = try self.processMediaItemSections_songID(from: data!)
                    seal.fulfill(mediaItems)
                    //print(mediaItems)
                    
                } catch {
                    fatalError("An error occurred: \(error.localizedDescription)")
                    seal.reject(MyError.runtimeError("JSON processing error - performAppleMusicCatalogSearch"))
                }
                }.resume()
            
            //task.resume()
        }
    }
    
    
    //Returns a list of all the songs in an album - takes album ID as the input.
    func performAppleMusicCatalogSearch_album_relation_songs (with term: String, countryCode: String ) -> Promise<[MediaItem]> {
        return Promise { seal in
            //print("search got to here as well")
            //print(term)
            //print(countryCode)
            
            guard let developerToken = fetchDeveloperToken() else {
                seal.reject("Error fetching developer token: performAppleMusicCatalogSearchNew" as! Error)
                fatalError("Developer Token not configured. See README for more details.")
            }
            
            let urlRequest = AppleMusicRequestFactory.createSearchRequest_for_album_relations_songs(with: term, countryCode: countryCode, developerToken: developerToken)
            
            print(urlRequest)
            print (developerToken)
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                print(error)
                print(response)
                guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                    if error != nil {
                        print(error)
                        seal.reject (error!)
                    } else {
                        seal.reject("Http error response performAppleMusicCatalogSearchNew_songID" as! Error)
                    }
                    print("error response")
                    return
                }
                //print(urlResponse)
                //print("response should be above this guy")
                let dataAsString = String(data: data!, encoding: .utf8)
                print(dataAsString)
                do {
                    let MediaItems = try self.processMediaItemSections_album_relations_songs(from: data!)
                    seal.fulfill(MediaItems)
                    //print(mediaItems)
                    
                } catch {
                    fatalError("An error occurred: \(error.localizedDescription)")
                    seal.reject(MyError.runtimeError("JSON processing error - performAppleMusicCatalogSearch"))
                }
                }.resume()
            
            //task.resume()
        }
    }
    
    
    //Used by the now playing poller to grab the currently playing item in spotify.
    func performSpotifyCurrentPlayingSearch() ->Promise<[SpotifyCurrentPlayingMediaObject.currently_playing_context]> {
        return Promise { seal in
            print("JUST in performSpotifyCurrentPlayingSearch")
            //print(term)
            //print(countryCode)
            var empty_currently_playing_object_array = [SpotifyCurrentPlayingMediaObject.currently_playing_context]()
            let urlRequest = AppleMusicRequestFactory.createSpotifySearchRequest_current_playing_item(accesstoken: self.userDefaults.value(forKey: "spotify_access_token") as! String)
            
            print("The created url request \(urlRequest)")
            //print (developerToken)
            let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
                print(error)
                print(response)
                guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200  else {
                    let urlResponse = response as? HTTPURLResponse
                    print ("URL RESPONSE STATUS CODE IS \(urlResponse!.statusCode)")
                    guard let url_response = response as? HTTPURLResponse, url_response.statusCode == 204 else {
                        if error != nil {
                            print("error != nil")
                            print(error)
                            seal.fulfill(empty_currently_playing_object_array)
                        } else {
                            seal.fulfill(empty_currently_playing_object_array)
                        }
                        print("error response")
                        return
                    }
                    print ("ATTENTION: HTTP RESPONSE CODE 204 retunred - no content playing for spotify right now")
                    print("We bypassed the guard statement")
                    
                    seal.fulfill(empty_currently_playing_object_array)
                    return
                }
                
                guard let data = data else {
                    seal.fulfill(empty_currently_playing_object_array)
                    return}
                
                let dataAsString = String(data: data, encoding: .utf8)
                //print(dataAsString)
                //print(urlResponse)
                //print("response should be above this guy")
                
                do {
                    let spotifyCurrentlyPlayingMediaObject_single_value_array = try self.processSpotifyCurrentlyPlayingMediaItemSections(from: data)
                    print(spotifyCurrentlyPlayingMediaObject_single_value_array)
                    seal.fulfill(spotifyCurrentlyPlayingMediaObject_single_value_array)
                    
                } catch {
                    seal.fulfill(empty_currently_playing_object_array)
                    fatalError("An error occurred: \(error.localizedDescription)")
                }
                
            }
            
            task.resume()
            
        }
        
    }
    
    //Grabs all the recently played items by the user from spotify - returns tracks.
    func performSpotifyRecentlyPlayedSearch() -> Promise<[SpotifyRecentlyPlayedMediaObject.item]>{
        return Promise { seal in
            //print("search got to here as well")
            //print(term)
            //print(countryCode)
            
            let developerToken = (self.userDefaults.object(forKey: "spotify_access_token")) as! String
            
            let urlRequest = AppleMusicRequestFactory.createSpotifySearchRequest_recently_played(accesstoken: developerToken)
            
            //print(urlRequest)
            //print (developerToken)
            let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
                //print(error)
                //print(response)
                guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                    if error != nil {
                        print(error)
                        seal.reject (error!)
                    } else {
                        seal.reject("Http error response performSpotifyCatalogSearchNew" as! Error)
                    }
                    print("error response")
                    return
                }
                
                guard let data = data else {return}
                
                let dataAsString = String(data: data, encoding: .utf8)
                print(dataAsString)
                //print(urlResponse)
                //print("response should be above this guy")
                
                do {
                    let spotifyMediaObjects = try self.processSpotifyRecentlyPlayedMediaItemSections(from: data)
                    seal.fulfill(spotifyMediaObjects)
                    //print(spotifyMediaObjects)
                    
                } catch {
                    fatalError("An error occurred: \(error.localizedDescription)")
                }
                
            }
            
            task.resume()
        }
    }
    
    
    //Used to process all the recently played items for spotify
    func processSpotifyRecentlyPlayedMediaItemSections(from json: Data) throws -> [SpotifyRecentlyPlayedMediaObject.item] {
        
        var tracks_1 = [SpotifyRecentlyPlayedMediaObject.item]()
        
        
        do {
            let tracks = try JSONDecoder().decode(SpotifyRecentlyPlayedMediaObject.items.self, from: json)
            //                let isrc_id = try JSONDecoder().decode(SpotifyMediaObject.isrc_id.self, from: data)
            //            print("\n----------------processSpotifyMediaItemSections---------------------")
            //            //print(tracks.tracks.items)
            //            print(tracks.tracks.items![0].external_ids?.isrc)
            //            print(tracks.tracks.items![0].album?.name)
            //            print(tracks.tracks.items![0].name)
            //            print(tracks.tracks.items![0].artists![0].name)
            //            print(tracks.tracks.items![0].preview_url)
            //            print(tracks.tracks.items![0].uri)
            //            print("-----------------processSpotifyMediaItemSections--------------------\n")
            tracks_1 = tracks.items
        } catch let jsonErr{
            print ("Error Serializing JSON: ", jsonErr)
        }
        return tracks_1
    }
    
   
    
    //Used to process the currently playing item returned by spotify
    func processSpotifyCurrentlyPlayingMediaItemSections(from json: Data) throws -> [SpotifyCurrentPlayingMediaObject.currently_playing_context] {
        
        var currently_playing_object = [SpotifyCurrentPlayingMediaObject.currently_playing_context]()
        
        
        do {
            let track_info = try JSONDecoder().decode(SpotifyCurrentPlayingMediaObject.currently_playing_context.self, from: json)
            currently_playing_object.append(track_info)
        } catch let jsonErr{
            print ("Error Serializing JSON: ", jsonErr)
        }
        return currently_playing_object
    }
    
    func processSpotifyMediaItemSections_songURI(from json: Data) throws -> [SpotifyMediaObject.item] {
        
        var track_1 = [SpotifyMediaObject.item]()
        
        
        do {
            let track = try JSONDecoder().decode(SpotifyMediaObject.item.self, from: json)
            //                let isrc_id = try JSONDecoder().decode(SpotifyMediaObject.isrc_id.self, from: data)
            //            print("\n----------------processSpotifyMediaItemSections---------------------")
            //            //print(tracks.tracks.items)
            //            print(tracks.tracks.items![0].external_ids?.isrc)
            //            print(tracks.tracks.items![0].album?.name)
            //            print(tracks.tracks.items![0].name)
            //            print(tracks.tracks.items![0].artists![0].name)
            //            print(tracks.tracks.items![0].preview_url)
            //            print(tracks.tracks.items![0].uri)
            //            print("-----------------processSpotifyMediaItemSections--------------------\n")
            track_1.append(track)
        } catch let jsonErr{
            print ("Error Serializing JSON: ", jsonErr)
        }
        return track_1
    }
    
    
    
    //Searches for an artist in the apple music catalog by artist name
    func performAppleMusicCatalogSearchNew_for_artist(with term: String, countryCode: String ) -> Promise<[ArtistMediaItem]> {
        return Promise { seal in
            print("performAppleMusicCatalogSearchNew_for_artist")
            //print(term)
            //print(countryCode)
            
            guard let developerToken = fetchDeveloperToken() else {
                seal.reject("Error fetching developer token: performAppleMusicCatalogSearchNew_for_artist" as! Error)
                fatalError("Developer Token not configured. See README for more details.")
            }
            
            let urlRequest = AppleMusicRequestFactory.createArtistSearchRequest(with: term, countryCode: countryCode, developerToken: developerToken)
            
            print(urlRequest)
            print (developerToken)
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                print(error)
                print(response)
                guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                    if error != nil {
                        print(error)
                        seal.reject (error!)
                    } else {
                        seal.reject("Http error response performAppleMusicCatalogSearchNew_for_artist" as! Error)
                    }
                    print("error response")
                    return
                }
                //print(urlResponse)
                //print("response should be above this guy")
                let dataAsString = String(data: data!, encoding: .utf8)
                print(dataAsString)
                do {
                    let mediaItems = try self.processArtistMediaItemSections(from: data!)
                    seal.fulfill(mediaItems)
                    //print(mediaItems)
                    
                } catch {
                    fatalError("An error occurred: \(error.localizedDescription)")
                    seal.reject(MyError.runtimeError("JSON processing error - performAppleMusicCatalogSearchNew_for_artist"))
                }
                }.resume()
            
            //task.resume()
        }
    }
    
    //Searches for artist in the spotify catalog by artist name
    func performSpotifyCatalogSearchNew_for_artist(with term: String) -> Promise<[SpotifyArtistMediaObject.item]>{
        return Promise { seal in
            print("search got to here as well: performSpotifyCatalogSearchNew_for_artist")
            //print(term)
            //print(countryCode)
            
            let developerToken = (self.userDefaults.object(forKey: "spotify_access_token")) as! String
            
            let urlRequest = AppleMusicRequestFactory.createSpotifyArtistSearchRequest(with: term, developerToken: developerToken)
            
            //print(urlRequest)
            //print (developerToken)
            let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
                //print(error)
                //print(response)
                guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                    if error != nil {
                        print(error)
                        seal.reject (error!)
                    } else {
                        seal.reject("Http error response performSpotifyCatalogSearchNew_for_artist" as! Error)
                    }
                    print("error response")
                    return
                }
                
                guard let data = data else {return}
                
                let dataAsString = String(data: data, encoding: .utf8)
                print(dataAsString)
                //print(urlResponse)
                //print("response should be above this guy")
                
                do {
                    let spotifyMediaObjects = try self.processSpotifyMediaArtistItemSections(from: data)
                    seal.fulfill(spotifyMediaObjects)
                    //print(spotifyMediaObjects)
                    
                } catch {
                    fatalError("An error occurred: \(error.localizedDescription)")
                }
                
            }
            
            task.resume()
        }
    }
    
    
    //Latest search request that I added - searches for podcasts in the spotify catalog by podcast name
    func performSpotifyCatalogSearch_test_podcasts(with term: String) {
            //print("search got to here as well")
            //print(term)
            //print(countryCode)
            
            let developerToken = (self.userDefaults.object(forKey: "spotify_access_token")) as! String
            
            let urlRequest = AppleMusicRequestFactory.createSpotifySearchRequest_for_podcast(with: term, developerToken: developerToken)
            
            //print(urlRequest)
            //print (developerToken)
            let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
                //print(error)
                //print(response)
                guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                    if error != nil {
                        print(error)
                        
                    } else {
                        
                    }
                    print("error response")
                    return
                }
                
                guard let data = data else {return}
                
                let dataAsString = String(data: data, encoding: .utf8)
                print(dataAsString)
                //print(urlResponse)
                //print("response should be above this guy")
                
                
            }
            
            task.resume()
        
    }
    
    
}
