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
        let developerAuthenticationToken: String? = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Iko3VDc3WjQ0V1oifQ.eyJpc3MiOiIyODJIMlU4VkZUIiwiaWF0IjoxNTYwMDQwMTA5LCJleHAiOjE1NjE3NjgxMDl9.05l-lAqtCTW6YlshWRhMz_uS-sJp8mc_hHbVxkFd9CWWHvs1thl7mWmxRGcTWvWRRTuapZzYhvwSfUcr_VwsvQ"
        
//        "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Iko3VDc3WjQ0V1oifQ.eyJpc3MiOiIyODJIMlU4VkZUIiwiaWF0IjoxNTUyNTMyMzIwLCJleHAiOjE1NTY4NTIzMjB9.omYV_K9GTUgO8zYjMe7ySp-3p6xOO5WR6JkPeSJPtaePcaKIyGzLHnAlOkj_cOfJxuStUP8U1bh3c2ZWrAU97A"
        return developerAuthenticationToken
    }
    
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
            //print(dataAsString)
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
    
    func performAppleMusicGetRecentlyPlayed(userToken: String, completion: @escaping GetRecentlyPlayedCompletionHandler) {
        guard let developerToken = fetchDeveloperToken() else {
            fatalError("Developer Token not configured.  See README for more details.")
        }
        
        let urlRequest = AppleMusicRequestFactory.createRecentlyPlayedRequest(developerToken: developerToken, userToken: userToken)
        
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
                
                let mediaItems = try self.processMediaItems(from: results)
                
                completion(mediaItems, nil)
                
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    
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
    
    //Used for regular song searches by name
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
    
    
    func processMediaItems(from json: [[String: Any]]) throws -> [MediaItem] {
        let songMediaItems = try json.map { try MediaItem(json: $0) }
        return songMediaItems
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
    
    func performSpotifyCurrentPlayingSearch(with term: String) ->Promise<[SpotifyCurrentPlayingMediaObject.currently_playing_context]> {
        return Promise { seal in
            print("JUST in performSpotifyCurrentPlayingSearch")
            //print(term)
            //print(countryCode)
            var empty_currently_playing_object_array = [SpotifyCurrentPlayingMediaObject.currently_playing_context]()
            let urlRequest = AppleMusicRequestFactory.createSpotifySearchRequest_current_playing_item(with: term, accesstoken: self.userDefaults.value(forKey: "spotify_access_token") as! String)
            
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
    
    
}
