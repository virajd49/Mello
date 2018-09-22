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


class AppleMusicManager {
    
    
    let userDefaults = UserDefaults.standard
    /// The completion handler that is called when an Apple Music Catalog Search API call completes.
    typealias CatalogSearchCompletionHandler = (_ mediaItems: [[MediaItem]], _ error: Error?) -> Void
    
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
        let developerAuthenticationToken: String? = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Iko3VDc3WjQ0V1oifQ.eyJpc3MiOiIyODJIMlU4VkZUIiwiaWF0IjoxNTM2NTEzNzM1LCJleHAiOjE1NDA4MzM3MzV9.ER-u0V7vTvM3V-5j0v7cJIe5JxhAekWHpz_Hzmg2r4XPTJHqFti9k6mBgmZVabv7qjE7dB8TfZMapo35JG201g"
        return developerAuthenticationToken
    }
    
    func performAppleMusicCatalogSearch(with term: String, countryCode: String, completion: @escaping CatalogSearchCompletionHandler) {
        
        //print("search got to here as well")
        print(term)
        print(countryCode)
        
        guard let developerToken = fetchDeveloperToken() else {
            fatalError("Developer Token not configured. See README for more details.")
        }
        
        let urlRequest = AppleMusicRequestFactory.createSearchRequest(with: term, countryCode: countryCode, developerToken: developerToken)
        
        //print(urlRequest)
        //print (developerToken)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            //print(error)
            print(response)
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion([], error)
                //print("error response")
                //print(error)
                return
            }
            //print(urlResponse)
            //print("response should be above this guy")
            do {
                let mediaItems = try self.processMediaItemSections(from: data!)
                completion(mediaItems, nil)
                print(mediaItems)
                
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    
    func performSpotifyCatalogSearch(with term: String, completion: @escaping SpotifyCatalogSearchCompletionHandler) {
        
        //print("search got to here as well")
        print(term)
        //print(countryCode)
        
        let developerToken = (self.userDefaults.object(forKey: "Spotify_access_token")) as! String
        
        let urlRequest = AppleMusicRequestFactory.createSpotifySearchRequest(with: term, developerToken: developerToken)
        
        //print(urlRequest)
        //print (developerToken)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            //print(error)
            print(response)
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion([], error)
                //print("error response")
                //print(error)
                
                return
            }
            
            guard let data = data else {return}
            
            let dataAsString = String(data: data, encoding: .utf8)
            print(dataAsString)
            print(urlResponse)
            //print("response should be above this guy")
 
            
            
            
//            do {
//                let tracks = try JSONDecoder().decode(SpotifyMediaObject.tracks.self, from: data)
////                let isrc_id = try JSONDecoder().decode(SpotifyMediaObject.isrc_id.self, from: data)
//                print("\n-------------------------------------")
//                //print(tracks.tracks.items)
//                print(tracks.tracks.items![0].external_ids?.isrc)
//                print(tracks.tracks.items![0].album?.name)
//                print(tracks.tracks.items![0].name)
//                print(tracks.tracks.items![0].artists![0].name)
//                print(tracks.tracks.items![0].preview_url)
//                print(tracks.tracks.items![0].uri)
//                print("-------------------------------------\n")
//            } catch let jsonErr{
//                print ("Error Serializing JSON: ", jsonErr)
//            }
//
//            do{
//
//                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
//                print (json)
//
//            } catch let jsonErr{
//                print ("Error Serializing JSON: ", jsonErr)
//            }
            
            do {
                let spotifyMediaObjects = try self.processSpotifyMediaItemSections(from: data)
                completion(spotifyMediaObjects, nil)
                print(spotifyMediaObjects)
                
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
        //print ("did this too")
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
    
    func processMediaItemSections(from json: Data) throws -> [[MediaItem]] {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let results = jsonDictionary[ResponseRootJSONKeys.results] as? [String: [String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.results)
        }
        
        var mediaItems = [[MediaItem]]()
        
        if let songsDictionary = results[ResourceTypeJSONKeys.songs] {
            
            if let dataArray = songsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let songMediaItems = try processMediaItems(from: dataArray)
                mediaItems.append(songMediaItems)
            }
        }
        
        if let albumsDictionary = results[ResourceTypeJSONKeys.albums] {
            
            if let dataArray = albumsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let albumMediaItems = try processMediaItems(from: dataArray)
                mediaItems.append(albumMediaItems)
            }
        }
        
        return mediaItems
    }
    
    
    func processSpotifyMediaItemSections(from json: Data) throws -> [SpotifyMediaObject.item] {
        
        var tracks_1 = [SpotifyMediaObject.item]()
        
        
        do {
            let tracks = try JSONDecoder().decode(SpotifyMediaObject.tracks.self, from: json)
            //                let isrc_id = try JSONDecoder().decode(SpotifyMediaObject.isrc_id.self, from: data)
            print("\n-------------------------------------")
            //print(tracks.tracks.items)
            print(tracks.tracks.items![0].external_ids?.isrc)
            print(tracks.tracks.items![0].album?.name)
            print(tracks.tracks.items![0].name)
            print(tracks.tracks.items![0].artists![0].name)
            print(tracks.tracks.items![0].preview_url)
            print(tracks.tracks.items![0].uri)
            print("-------------------------------------\n")
            tracks_1 = tracks.tracks.items!
        } catch let jsonErr{
            print ("Error Serializing JSON: ", jsonErr)
        }
        
        
        
//        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
//            let results = jsonDictionary[ResponseRootJSONKeys.results] as? [String: [String: Any]] else {
//                throw SerializationError.missing(ResponseRootJSONKeys.results)
//        }
//
//        var mediaItems = [[SpotifyMediaItem]]()
//
//        if let songsDictionary = results[ResourceTypeJSONKeys.tracks] {
//
//            if let dataArray = songsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
//                let songMediaItems = try processSpotifyMediaItems(from: dataArray)
//                mediaItems.append(songMediaItems)
//            }
//        }
        /*
        if let albumsDictionary = results[ResourceTypeJSONKeys.albums] {
            
            if let dataArray = albumsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let albumMediaItems = try processSpotifyMediaItems(from: dataArray)
                mediaItems.append(albumMediaItems)
            }
        }
        */
        return tracks_1
    }
    
    
    func processMediaItems(from json: [[String: Any]]) throws -> [MediaItem] {
        let songMediaItems = try json.map { try MediaItem(json: $0) }
        return songMediaItems
    }
    
    func processSpotifyMediaItems(from json: [[String: Any]]) throws -> [SpotifyMediaItem] {
        let songMediaItems = try json.map { try SpotifyMediaItem(json: $0) }
        return songMediaItems
    }
    
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
    
    
    
}
