//
//  Post_helper.swift
//  Project2
//
//  Created by virdeshp on 10/2/18.
//  Copyright © 2018 Viraj. All rights reserved.
//


//This class is to be used at upload time along with ISRC_worker. It gets all the required song metadata for the post and makes the necessary updates to the ISRC database.

import Foundation
import UIKit
import MediaPlayer
import Firebase
import PromiseKit



class Post_helper {
    
    
    let userDefaults = UserDefaults.standard
    let appleMusicManager = AppleMusicManager()
    var spotify_mediaItems: [SpotifyMediaObject.item]!
    var apple_mediaItems: [[MediaItem]]!
    var apple_struct : song_db_struct?
    var spotify_struct : song_db_struct?
    
    func perform_search_for_spotify (name: String)  {
        
        appleMusicManager.performSpotifyCatalogSearch(with: name,
                                                      completion: { [weak self] (searchResults, error) in
                                                        guard error == nil else {
                                                            let alertController: UIAlertController
                                                            
                                                            guard let error = error as NSError?, let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? Error else {
                                                                print ("Encountered unexpected error")
                                                                return
                                                            }
                                                            print ("Encountered error: \(underlyingError.localizedDescription)")
                                                            return
                                                        }
                                                        self?.spotify_mediaItems = searchResults
                                                        
        })
        print ("YAAAAAAAAAAS!!!!!!!!!!!!!!!")
    }
    
    func perform_search_for_spotify_new (name: String) -> Promise<Void> {
        return Promise { seal in
        appleMusicManager.performSpotifyCatalogSearchNew(with: name).done { searchItems in
            
            self.spotify_mediaItems = searchItems
            seal.fulfill(())
        }
        print ("YAAAAAAAAAAS!!!!!!!!!!!!!!!")
        }
    }
    
    func perform_search_for_apple (name: String) -> Promise<Void> {
        return Promise { seal in
        let country_code = userDefaults.string(forKey: "Country_code")
        appleMusicManager.performAppleMusicCatalogSearchNew(with: name, countryCode: country_code ?? "us").done { searchItems in
            
            
            print ("we got'em bruh !!!!!!!!!!!!!!!!!!!!")
            self.apple_mediaItems = searchItems
            seal.fulfill(())
            
        }
        print ("YAAAAAAAAAAS!!!!!!!!!!!!!!! 2")
        }
    }

    func spotify_search (song_name: String, song_id: String) -> Promise<song_db_struct> {
        return Promise { seal in
        print("in spotify search")
        var variable = song_db_struct()
        perform_search_for_spotify_new(name: song_name).done { Void in
                                                        print (self.spotify_mediaItems)
                                                        var count,i : Int!
                                                        count = self.spotify_mediaItems.count
                                                        print(count)
                                                            for l in 0..<count {
                                                               
                                                                if song_id == self.spotify_mediaItems[l].uri {
                                                                    i = l
                                                                    break
                                                                }
                                                               
                                                        }
                                                        
                                                        //print (self?.mediaItems[0][0].genreNames)
                                                        variable.release_date = self.spotify_mediaItems[i].album?.release_date
                                                        variable.album_name = self.spotify_mediaItems[i].album?.name
                                                        variable.artist_name = self.spotify_mediaItems[i].artists?[0].name
                                                        variable.playable_id = self.spotify_mediaItems[i].uri
                                                        variable.song_name = self.spotify_mediaItems[i].name
                                                        variable.isrc_number = self.spotify_mediaItems[i].external_ids?.isrc
                                                        variable.preview_url = self.spotify_mediaItems[i].preview_url
                                                        self.spotify_struct = variable
                                                        
                                                        
      //  })
        
             seal.fulfill(self.spotify_struct ?? variable)
            }
        }
    }
    
    func apple_search (song_name: String, song_id: String) -> Promise<song_db_struct>{
        return Promise { seal in
        print ("in apple search")
        var variable = song_db_struct()
            perform_search_for_apple(name: song_name).done { Void in

                                                            var count : Int!
                                                            count = self.apple_mediaItems[0].count
                                                            var i : Int!
                                                            i = 0
                                                                for l in 0..<count {
                                                                    print ("-----------Apple Search----------------")
                                                                    print (self.apple_mediaItems[0][l].artistName)
                                                                    print (self.apple_mediaItems[0][l].identifier)
                                                                    print (self.apple_mediaItems[0][l].isrc)
                                                                    print (self.apple_mediaItems[0][l].name)
                                                                    print (self.apple_mediaItems[0][l].albumName)
                                                                    print (self.apple_mediaItems[0][l].url)
                                                                    print (self.apple_mediaItems[0][l].releaseDate)
                                                                    print (self.apple_mediaItems[0][l].previews)
                                                                    print (self.apple_mediaItems[0].count)
                                                                    print ("-----------------------------------")
                                                                    if song_id == self.apple_mediaItems[0][l].identifier {
                                                                        i = l
                                                                        break
                                                                    }
                                                                    
                                                            }
                
                                                            variable.release_date = self.apple_mediaItems[0][i].releaseDate
                                                            variable.album_name = self.apple_mediaItems[0][i].albumName
                                                            variable.song_name = self.apple_mediaItems[0][i].name
                                                            variable.playable_id = self.apple_mediaItems[0][i].identifier
                                                            variable.artist_name = self.apple_mediaItems[0][i].artistName
                                                            variable.isrc_number = self.apple_mediaItems[0][i].isrc
                                                            variable.preview_url = (((self.apple_mediaItems[0][i].previews as! NSArray)[0] as! [String:String])["url"])
                                                            self.apple_struct = variable
                                                            print (variable.song_name)
        
                    seal.fulfill(self.apple_struct ?? variable)
            }
    }
  }
}
