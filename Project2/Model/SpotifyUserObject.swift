//
//  SpotifyUserObject.swift
//  Project2
//
//  Created by virdeshp on 10/28/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation

/*
 
 JSON decodable for the artist search response from spotify
 
https://developer.spotify.com/documentation/web-api/reference/search/search/
 */

/*
 
 Spotify web api example
 {"country":"SE","display_name":"JM Wizzler","email":"email@example.com","external_urls":{"spotify":"https://open.spotify.com/user/wizzler"},"followers":{"href":null,"total":3829},"href":"https://api.spotify.com/v1/users/wizzler","id":"wizzler","images":[{"height":null,"url":"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-frc3/t1.0-1/1970403_10152215092574354_1798272330_n.jpg","width":null}],"product":"premium","type":"user","uri":"spotify:user:wizzler"}
 */

class SpotifyUserObject: Decodable {
    
    struct user: Decodable {
        let country: String?
        let display_name: String?
        let email: String?
        let external_urls: external_urls?
        let followers: followers?
        let id: String?
        let images: [image]?
        let product: String?
        let type: String?
        let uri: String?
    }
   
   
    
    struct followers: Decodable {
        let href: String?
        let total: Int?
    }

    struct external_urls: Decodable {
        let spotify : String?
    }
    
   
    struct image: Decodable {
        
        let height: Int?
        let url: String?
        let width: Int?
        
        
    }
  
    
    
}

