//
//  AppleMusicRequestFactory.swift
//  Project2
//
//  Created by virdeshp on 5/10/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation
import StoreKit
import UIKit
import MediaPlayer

struct AppleMusicRequestFactory {
    
    
    static let userDefaults = UserDefaults.standard
    // MARK: Types
    
    /// The base URL for all Apple Music API network calls.
    static let appleMusicAPIBaseURLString = "api.music.apple.com"
    
    /// The Apple Music API endpoint for requesting a list of recently played items.
    static let recentlyPlayedPathURLString = "/v1/me/recent/played"
    
    /// The Apple Music API endpoint for requesting a the storefront of the currently logged in iTunes Store account.
    static let userStorefrontPathURLString = "/v1/me/storefront"
    
    static func createSearchRequest(with term: String, countryCode: String, developerToken: String) -> URLRequest {
        
        // Create the URL components for the network call.
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
        urlComponents.path = "/v1/catalog/\(countryCode)/search"
        //print(urlComponents.host)
        let expectedTerms = term.replacingOccurrences(of: " ", with: "+")
        let urlParameters = ["term": expectedTerms,
                             "limit": "15",
                             "offset": "0",
                             "types": "songs,albums"]
        
        var queryItems = [URLQueryItem]()
        for (key, value) in urlParameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        urlComponents.queryItems = queryItems
        
        // Create and configure the `URLRequest`.
        print("in creation")
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        print(urlRequest)
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        //urlRequest.addValue("Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Iko3VDc3WjQ0V1oifQ.eyJpc3MiOiIyODJIMlU4VkZUIiwiaWF0IjoxNTM2NTEzNzM1LCJleHAiOjE1NDA4MzM3MzV9.ER-u0V7vTvM3V-5j0v7cJIe5JxhAekWHpz_Hzmg2r4XPTJHqFti9k6mBgmZVabv7qjE7dB8TfZMapo35JG201g", forHTTPHeaderField: "Authorization")
        //print(urlRequest)
        //print (urlRequest.allHTTPHeaderFields)
        print("exiting creation")
        return urlRequest
    }
    
    static func createArtistSearchRequest(with term: String, countryCode: String, developerToken: String) -> URLRequest {
        
        // Create the URL components for the network call.
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
        urlComponents.path = "/v1/catalog/\(countryCode)/search"
        //print(urlComponents.host)
        let expectedTerms = term.replacingOccurrences(of: " ", with: "+")
        let urlParameters = ["term": expectedTerms,
                             "limit": "15",
                             "offset": "0",
                             "types": "artists"]
        
        var queryItems = [URLQueryItem]()
        for (key, value) in urlParameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        urlComponents.queryItems = queryItems
        
        // Create and configure the `URLRequest`.
        print("in creation")
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        print(urlRequest)
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        //urlRequest.addValue("Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Iko3VDc3WjQ0V1oifQ.eyJpc3MiOiIyODJIMlU4VkZUIiwiaWF0IjoxNTM2NTEzNzM1LCJleHAiOjE1NDA4MzM3MzV9.ER-u0V7vTvM3V-5j0v7cJIe5JxhAekWHpz_Hzmg2r4XPTJHqFti9k6mBgmZVabv7qjE7dB8TfZMapo35JG201g", forHTTPHeaderField: "Authorization")
        //print(urlRequest)
        //print (urlRequest.allHTTPHeaderFields)
        print("exiting creation")
        return urlRequest
    }
    
    static func createSearchRequest_for_song_id (with term: String, countryCode: String, developerToken: String) -> URLRequest {
        
        // Create the URL components for the network call.
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
        urlComponents.path = "/v1/catalog/\(countryCode)/songs"
        //print(urlComponents.host)
        
        let urlParameters = ["ids": term]
        
        var queryItems = [URLQueryItem]()
        for (key, value) in urlParameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        urlComponents.queryItems = queryItems
        
        // Create and configure the `URLRequest`.
        print("in creation")
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        print(urlRequest)
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        //urlRequest.addValue("Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Iko3VDc3WjQ0V1oifQ.eyJpc3MiOiIyODJIMlU4VkZUIiwiaWF0IjoxNTM2NTEzNzM1LCJleHAiOjE1NDA4MzM3MzV9.ER-u0V7vTvM3V-5j0v7cJIe5JxhAekWHpz_Hzmg2r4XPTJHqFti9k6mBgmZVabv7qjE7dB8TfZMapo35JG201g", forHTTPHeaderField: "Authorization")
        //print(urlRequest)
        //print (urlRequest.allHTTPHeaderFields)
        print("exiting creation")
        return urlRequest
    }
    
    
    static func createSpotifySearchRequest(with term: String, developerToken: String) -> URLRequest {
        
        // Create the URL components for the network call.
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.spotify.com"
        urlComponents.path = "/v1/search"
        //print(urlComponents.host)
        let expectedTerms = term.replacingOccurrences(of: " ", with: "+")
        let urlParameters = ["offset": "0",
                             "limit": "15",
                             "market": "US",
                             "type": "track",
                             "q": expectedTerms]
        
        var queryItems = [URLQueryItem]()
        for (key, value) in urlParameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        //print(queryItems)
        
        urlComponents.queryItems = [URLQueryItem(name: "q", value: expectedTerms), URLQueryItem(name: "type", value: "track"), URLQueryItem(name: "market", value: "US"), URLQueryItem(name: "limit", value: "20"), URLQueryItem(name: "offset", value: "0")]
        
        
        // Create and configure the `URLRequest`.
        print("in creation spotify")
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        print(urlRequest)
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        
        //print(urlRequest)
        //print (urlRequest.allHTTPHeaderFields)
        print("exiting creation spotify")
        return urlRequest
    }
    
    static func createSpotifyArtistSearchRequest(with term: String, developerToken: String) -> URLRequest {
        
        // Create the URL components for the network call.
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.spotify.com"
        urlComponents.path = "/v1/search"
        //print(urlComponents.host)
        let expectedTerms = term.replacingOccurrences(of: " ", with: "+")
        let urlParameters = ["offset": "0",
                             "limit": "15",
                             "market": "US",
                             "type": "artist",
                             "q": expectedTerms]
        
        var queryItems = [URLQueryItem]()
        for (key, value) in urlParameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        //print(queryItems)
        
        urlComponents.queryItems = [URLQueryItem(name: "q", value: expectedTerms), URLQueryItem(name: "type", value: "artist"), URLQueryItem(name: "market", value: "US"), URLQueryItem(name: "limit", value: "20"), URLQueryItem(name: "offset", value: "0")]
        
        
        // Create and configure the `URLRequest`.
        print("in creation spotify")
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        print(urlRequest)
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        
        //print(urlRequest)
        //print (urlRequest.allHTTPHeaderFields)
        print("exiting creation spotify")
        return urlRequest
    }
    
    static func createStorefrontsRequest(regionCode: String, developerToken: String) -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
        urlComponents.path = "/v1/storefronts/\(regionCode)"
        
        // Create and configure the `URLRequest`.
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
    
    static func createRecentlyPlayedRequest(developerToken: String, userToken: String) -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
        urlComponents.path = AppleMusicRequestFactory.recentlyPlayedPathURLString
        
        // Create and configure the `URLRequest`.
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        return urlRequest
    }
    
    static func createGetUserStorefrontRequest(developerToken: String, userToken: String) -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequestFactory.appleMusicAPIBaseURLString
        urlComponents.path = AppleMusicRequestFactory.userStorefrontPathURLString
        
        // Create and configure the `URLRequest`.
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        return urlRequest
    }
    
    static func createSpotifySearchRequest_current_playing_item(with term: String, accesstoken: String) -> URLRequest {
        
        // Create the URL components for the network call.
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.spotify.com"
        urlComponents.path = "/v1/me/player/currently-playing"
        //print(urlComponents.host)
        //        let expectedTerms = term.replacingOccurrences(of: " ", with: "+")
        //        let urlParameters = ["offset": "0",
        //                             "limit": "15",
        //                             "market": "US",
        //                             "type": "track",
        //                             "q": expectedTerms]
        //
        //        var queryItems = [URLQueryItem]()
        //        for (key, value) in urlParameters {
        //            queryItems.append(URLQueryItem(name: key, value: value))
        //        }
        //
        //        //print(queryItems)
        //
        //        urlComponents.queryItems = [URLQueryItem(name: "q", value: expectedTerms), URLQueryItem(name: "type", value: "track"), URLQueryItem(name: "market", value: "US"), URLQueryItem(name: "limit", value: "20"), URLQueryItem(name: "offset", value: "0")]
        //
        
        // Create and configure the `URLRequest`.
        print("in creation spotify")
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        print(urlRequest)
        urlRequest.addValue("Bearer \(accesstoken)", forHTTPHeaderField: "Authorization")
        
        //print(urlRequest)
        //print (urlRequest.allHTTPHeaderFields)
        print("exiting creation spotify")
        return urlRequest
    }
    
    static func createSpotifySearchRequest_songURI(with term: String, accesstoken: String) -> URLRequest {
        
        // Create the URL components for the network call.
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.spotify.com"
        urlComponents.path = "/v1/tracks/\(term)"
        //print(urlComponents.host)
        //        let expectedTerms = term.replacingOccurrences(of: " ", with: "+")
        //        let urlParameters = ["offset": "0",
        //                             "limit": "15",
        //                             "market": "US",
        //                             "type": "track",
        //                             "q": expectedTerms]
        //
        //        var queryItems = [URLQueryItem]()
        //        for (key, value) in urlParameters {
        //            queryItems.append(URLQueryItem(name: key, value: value))
        //        }
        //
        //        //print(queryItems)
        //
        //        urlComponents.queryItems = [URLQueryItem(name: "q", value: expectedTerms), URLQueryItem(name: "type", value: "track"), URLQueryItem(name: "market", value: "US"), URLQueryItem(name: "limit", value: "20"), URLQueryItem(name: "offset", value: "0")]
        //
        
        // Create and configure the `URLRequest`.
        print("in creation spotify")
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        print(urlRequest)
        urlRequest.addValue("Bearer \(accesstoken)", forHTTPHeaderField: "Authorization")
        
        //print(urlRequest)
        //print (urlRequest.allHTTPHeaderFields)
        print("exiting creation spotify")
        return urlRequest
        
    }
}
