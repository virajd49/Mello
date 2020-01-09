//
//  ISRC_worker.swift
//  Project2
//
//  Created by virdeshp on 10/1/18.
//  Copyright © 2018 Viraj. All rights reserved.
//


/*This class contains the song searching functions for apple and spotify. It also contains the parsing mechanisms for matching the song metadata when looking for a
  song in each catalog. It also contains the functions that convert the song metadata into the right formats and adds it to the Firebase Database.
 
 The top function in this file is get_this_song() - start from there, it will be easier to understand.


 THE SEARCHER NEEDS UPGRADES!!! SPECIFICALLY:
                      How many items do we ask for as search results? Right now only asking for 20 and going through the first 20 entries. If we dont find the match in those 20 entries we reject the Promise i.e dont return a match.
 THE PARSER NEEDS UPGRADES!!!!!!!!!!!!! SPECIFIC CASES:
              Wonderful Tonight - 20th Century Masters - The Millenium Collection does not match to the exact same song & album on spotify
    because the phrases in the album name a in a different order.
              Don't Stop Me Now - The Platinum Collection - Greatest Hits I II & III does not match to the exact same album on spotify because the album name only contains "The Platinum Collection"
              That's the Way - The complete BBC sessions - does not match because Spotify has the name as 'That's the Way - 1/4/71 Paris Theatre; 2016 Remaster' and Apple has the name as 'That's the Way (1/4/71 Paris Theatre)' - Possible solution - also include an album name match search - and then go through all the songs and see if we have an isrc match.
                Antisocial Ed Sheeran & Travis Scott

 THE ISRC DATABASE NEEDS AN UPGRADE!!!!!!!:
    Apple songs have different song id's in different regions: So what to do? Make a separate db for every region? Or change the apple metadata format to include all the song id's for a single song entry ?
 
 */
import Foundation
import UIKit
import MediaPlayer
import Firebase
import PromiseKit
import PostgresClientKit


class ISRC_worker {
    
    let userDefaults = UserDefaults.standard
    let appleMusicManager = AppleMusicManager()
    var spotify_mediaItems: [SpotifyMediaObject.item]!
    var apple_mediaItems: [MediaItem]!
    var apple_struct : song_db_struct?
    var spotify_struct : song_db_struct?
    var target_struct = song_db_struct()
    var isrc_num : String?
    var this_catalogue_doesnt_have_the_song_right_now = "none"  //values: none/spotify/apple
    typealias isrc_data_set = [String : [String: [String: Any]]]
    
    
    enum MyError: Error {
        case runtimeError(String)
    }
    
    
    //Find all the songs that match the given song name from the spotify catalogue
    func perform_search_for_spotify_new (name: String) ->Promise<Void> {
        return Promise { seal in
        appleMusicManager.performSpotifyCatalogSearchNew(with: name).done { searchItems in
            
            self.spotify_mediaItems = searchItems
            print ("YAAAAAAAAAAS!!!!!!!!!!!!!!! - perform_search_for_spotify_new - spotify_mediaItems.count is \(self.spotify_mediaItems.count)")
            seal.fulfill(())
        }
     }
    }
    
    
    //Find all the songs that match the given song name from the apple catalogue
    func perform_search_for_apple (name: String) -> Promise<Void> {
        return Promise { seal in
            let country_code = userDefaults.string(forKey: "Country_code")
            appleMusicManager.performAppleMusicCatalogSearchNew(with: name, countryCode: country_code ?? "us").done { searchItems in
                
                
                print ("we got'em bruh !!!!!!!!!!!!!!!!!!!!")
                self.apple_mediaItems = searchItems
                print ("YAAAAAAAAAAS!!!!!!!!!!!!!!! 2 - perform_search_for_apple")
                seal.fulfill(())
                
            }
        }
    }
    
    //We have apple metadata for a song and we need to find the same song in spotify
    func spotify_search_and_parse (appi_struct: song_db_struct) -> Promise<Void>{
        return Promise { seal in
        //get apple struct
        //search spotify catalog
        //return a spotify struct
    
        var variable = song_db_struct()
            
            //Song search by name in spotify - this will put the results in self.spotify_mediaItems
            perform_search_for_spotify_new(name: appi_struct.song_name ?? "nil").done { Void in
                                                        var count : Int!
                                                        if self.spotify_mediaItems.isEmpty {
                                                            count = 0
                                                        } else {
                                                            count = self.spotify_mediaItems.count
                                                        }
                                                        print ("Spotify media items count \(count)")
                                                        var i : Int!
                                                        i = count + 1
                
                //If we have results, go through them and find the best match
                if !self.spotify_mediaItems.isEmpty {
                                                        print(appi_struct.isrc_number)
                    
                                                        //Removing the word Remastered ##/##/### or just Remastered from the song name to help with better matching
                                                        var matcher_song_name =  String()
                                                        var custom_strip_text: String = self.remastered_matches(for: "Remastered \\d\\d\\d\\d", in: appi_struct.song_name! ?? "") ?? ""
                                                        if custom_strip_text == "nil" {
                                                            matcher_song_name = self.remove_remastered(full_name: appi_struct.song_name! ?? "") ?? ""
                                                        } else {
                                                            matcher_song_name = self.remove_custom_remastered(full_name: appi_struct.song_name! ?? "", custom_text: custom_strip_text) ?? ""
                                                            print (matcher_song_name)
                                                            print ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                                                            print (custom_strip_text)
                                                            print ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                                                        }
                                                        var matcher_album_name: String = self.remove_remastered(full_name: appi_struct.album_name!) ?? ""
                                                        print (matcher_album_name)
    
                
                                                        if i == count + 1 { //exact match
                                                            print ("exact match")
                                                            for l in 0..<count {
                                                                print ("-----------Spotify----------------")
                                                                print (self.spotify_mediaItems[l].artists?[0].name)
                                                                print (self.spotify_mediaItems[l].uri)
                                                                print (self.spotify_mediaItems[l].external_ids?.isrc)
                                                                print (self.spotify_mediaItems[l].name)
                                                                print (self.spotify_mediaItems[l].album?.name)
                                                                print (self.spotify_mediaItems[l].preview_url)
                                                                print (self.spotify_mediaItems[l].album?.release_date)
                                                                print (self.spotify_mediaItems.count)
                                                                print ("-----------------------------------")
                                                                /*Not including date matching for now because of cases like "All you need is love album: Magic Mystery tour" Apple has the wrong release date?? please check notes: it's a loose paper*/
                                                                //if spoti_struct.release_date?.count != self?.apple_mediaItems[l].releaseDate?.count {
                                                                //      if self?.apple_mediaItems[l].releaseDate?.count as Int! >spoti_struct.release_date?.count as Int!{
                                                                //        for n in 0...3 {
                                                                //            self?.apple_mediaItems[l].releaseDate?.dropLast()
                                                                //         }
                                                                //      } else {
                                                                //          for n in 0...3 {
                                                                //           spoti_struct.release_date?.dropLast()
                                                                //          }
                                                                //      }
                                                                //  }
                                                                var matchee_song_name =  String()
                                                                var custom_strip_text: String = self.remastered_matches(for: "Remastered \\d\\d\\d\\d", in: self.spotify_mediaItems[l].name! ?? "") ?? ""
                                                                if custom_strip_text == "nil" {
                                                                    matchee_song_name = self.remove_remastered(full_name: self.spotify_mediaItems[l].name! ?? "") ?? ""
                                                                } else {
                                                                    matchee_song_name = self.remove_custom_remastered(full_name: self.spotify_mediaItems[l].name! ?? "", custom_text: custom_strip_text) ?? ""
                                                                }
                                                                var matchee_album_name: String = self.remove_remastered(full_name: self.spotify_mediaItems[l].album?.name! ?? "") ?? ""
                                                                print (appi_struct.isrc_number)
                                                                print (appi_struct.artist_name)
                                                                print (matcher_album_name)
                                                                print (matcher_song_name)
                                                                print (matchee_album_name)
                                                                print (matchee_song_name)
                                                                
                                                                //EXACT MATCH
                                                                if self.spotify_mediaItems[l].external_ids?.isrc == appi_struct.isrc_number &&
                                                                    self.spotify_mediaItems[l].artists?[0].name == appi_struct.artist_name &&
                                                                    matchee_album_name == matcher_album_name &&
                                                                    matchee_song_name == matcher_song_name /*&&
                                                                     self?.apple_mediaItems[l].releaseDate == appi_struct.release_date*/ {
                                                                        print ("the apple one")
                                                                        print (self.spotify_mediaItems[l].external_ids?.isrc)
                                                                        i = l
                                                                        break
                                                                }
                                                            }
                                                        }
                    
                                                        if i == count + 1 {  //by album and song name only
                                                            print ("by album and song name only")
                                                            for l in 0..<count {
                                                                // if spoti_struct.release_date?.count != self?.apple_mediaItems[l].releaseDate?.count {
                                                                //      if self?.apple_mediaItems[l].releaseDate?.count as Int! > spoti_struct.release_date?.count as Int!{
                                                                //        for n in 0...3 {
                                                                //            self?.apple_mediaItems[l].releaseDate?.dropLast()
                                                                //        }
                                                                //     } else {
                                                                //        for n in 0...3 {
                                                                //           spoti_struct.release_date?.dropLast()
                                                                //       }
                                                                //     }
                                                                //
                                                                // }
                                                                var matchee_song_name =  String()
                                                                var custom_strip_text: String = self.remastered_matches(for: "Remastered \\d\\d\\d\\d", in: self.spotify_mediaItems[l].name! ?? "") ?? ""
                                                                if custom_strip_text == "nil" {
                                                                    matchee_song_name = self.remove_remastered(full_name: self.spotify_mediaItems[l].name! ?? "") ?? ""
                                                                } else {
                                                                    matchee_song_name = self.remove_custom_remastered(full_name: self.spotify_mediaItems[l].name! ?? "", custom_text: custom_strip_text) ?? ""
                                                                }
                                                                var matchee_album_name: String = self.remove_remastered(full_name: self.spotify_mediaItems[l].album?.name! ?? "") ?? ""
                                                                
                                                                //ARTIST NAME, ALBUM NAME, SONG NAME
                                                                if self.spotify_mediaItems[l].artists?[0].name == appi_struct.artist_name &&
                                                                    matchee_album_name == matcher_album_name &&
                                                                    matchee_song_name == matcher_song_name /*&&
                                                                     self?.apple_mediaItems[l].releaseDate == spoti_struct.release_date */ {
                                                                        print ("the apple one")
                                                                        print (self.spotify_mediaItems[l].external_ids?.isrc)
                                                                        i = l
                                                                        break
                                                                }
                                                            }
                                                        }
                    
                                                        //ISRC MATCH ONLY
                                                        if i == count + 1 { //by isrc only
                                                            print ("by isrc only")
                                                            for l in 0..<count {
    
                                                                if self.spotify_mediaItems[l].external_ids?.isrc == appi_struct.isrc_number {
                                                                    print ("the apple one")
                                                                    print (self.spotify_mediaItems[l].external_ids?.isrc)
                                                                    i = l
                                                                    break
                                                                }
                                                            }
                                                        }
                }
                                                        if i > count {
                                                            //this means we iterated through all items in the current search list and found nothing OR the items array was empty
                                                            //for now - leave the spotify values empty - will have to put in a mechanism in the future to check if the song has been made available on spotify or not and fill this up
                                                            //seal.reject(MyError.runtimeError("Song not found"))
                                                            variable.release_date = ""
                                                            variable.album_name = ""
                                                            variable.artist_name = ""
                                                            variable.playable_id = ""
                                                            variable.song_name = ""
                                                            variable.isrc_number = ""
                                                            variable.preview_url = ""
                                                            self.spotify_struct = variable
                                                            self.this_catalogue_doesnt_have_the_song_right_now = "spotify"
                                                            seal.fulfill(())
                                                        } else {
    
                                                            print ("\(self.spotify_mediaItems[i])")
                                                            variable.release_date = self.spotify_mediaItems[i].album?.release_date ?? ""
                                                            variable.album_name = self.spotify_mediaItems[i].album?.name ?? ""
                                                            variable.artist_name = self.spotify_mediaItems[i].artists?[0].name ?? ""
                                                            variable.playable_id = self.spotify_mediaItems[i].uri ?? ""
                                                            variable.song_name = self.spotify_mediaItems[i].name ?? ""
                                                            variable.isrc_number = self.spotify_mediaItems[i].external_ids?.isrc ?? ""
                                                            variable.preview_url =  self.spotify_mediaItems[i].preview_url ?? ""
                                                            self.spotify_struct = variable
                                                            print ("end of spotify_search_and_parse")
                                                            seal.fulfill(())
                                                            //self.apple_search_and_parse(spoti_struct: variable)
                                                        }
    
            }
        }
    
    }
    
    
    //We have spotify metadata for a song and we need to find the same song in apple
    func apple_search_and_parse (spoti_struct: song_db_struct) -> Promise<Void> {
        return Promise { seal in
        //get spotify struct
        //search apple catalog
        //return an apple struct
            
        var variable = song_db_struct()
        let country_code = userDefaults.string(forKey: "Country_code")
            //Song search by name in apple - this will put the results in self.apple_mediaItems
            perform_search_for_apple (name: spoti_struct.song_name ?? "nil").done { Void in
                
                                                        var count : Int!
                                                        if self.apple_mediaItems.isEmpty {
                                                            count = 0
                                                        } else {
                                                            count = self.apple_mediaItems.count
                                                        }
                                                        var i : Int!
                                                        i = count + 1
                                                        if !self.apple_mediaItems.isEmpty {
                                                            print(spoti_struct.isrc_number)
                                                            var matcher_song_name =  String()
                                                            var custom_strip_text: String = self.remastered_matches(for: "Remastered \\d\\d\\d\\d", in: spoti_struct.song_name! ?? "") ?? ""
                                                            if custom_strip_text == "nil" {
                                                                matcher_song_name = self.remove_remastered(full_name: spoti_struct.song_name! ?? "") ?? ""
                                                            } else {
                                                                matcher_song_name = self.remove_custom_remastered(full_name: spoti_struct.song_name! ?? "", custom_text: custom_strip_text) ?? ""
                                                                print (matcher_song_name)
                                                                print ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                                                                print (custom_strip_text)
                                                                print ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                                                            }
                                                            var matcher_album_name: String = self.remove_remastered(full_name: spoti_struct.album_name!) ?? ""
                                                            print (matcher_album_name)
                
                
                                                            if i == count + 1 { //exact match
                                                                print ("exact match")
                                                                for l in 0..<count {
                                                                    print ("-----------Apple----------------")
                                                                    print (self.apple_mediaItems[l].artistName)
                                                                    print (self.apple_mediaItems[l].identifier)
                                                                    print (self.apple_mediaItems[l].isrc)
                                                                    print (self.apple_mediaItems[l].name)
                                                                    print (self.apple_mediaItems[l].albumName)
                                                                    print (self.apple_mediaItems[l].url)
                                                                    print (self.apple_mediaItems[l].releaseDate)
                                                                    print (self.apple_mediaItems[l].previews[0])
                                                                    print (self.apple_mediaItems.count)
                                                                    print ("-----------------------------------")
                                                                    /*Not including date matching for now because of cases like "All you need is love album: Magic Mystery tour" Apple has the wrong release date?? please check notes: it's a loose paper
                                                                if spoti_struct.release_date?.count != self?.apple_mediaItems[0][l].releaseDate?.count {
                                                                    if self?.apple_mediaItems[0][l].releaseDate?.count as Int! > spoti_struct.release_date?.count                                 as Int!{
                                                                            for n in 0...3 {
                                                                                self?.apple_mediaItems[0][l].releaseDate?.dropLast()
                                                                            }
                                                                    } else {
                                                                        for n in 0...3 {
                                                                            spoti_struct.release_date?.dropLast()
                                                                        }
                                                                    }
                                                                }
                                                                    
                                                                    */
                                                                    var matchee_song_name =  String()
                                                                    var custom_strip_text: String = self.remastered_matches(for: "Remastered \\d\\d\\d\\d", in: self.apple_mediaItems[l].name! ?? "") ?? ""
                                                                    if custom_strip_text == "nil" {
                                                                        matchee_song_name = self.remove_remastered(full_name: self.apple_mediaItems[l].name! ?? "") ?? ""
                                                                    } else {
                                                                        matchee_song_name = self.remove_custom_remastered(full_name: self.apple_mediaItems[l].name! ?? "", custom_text: custom_strip_text) ?? ""
                                                                    }
                                                                    var matchee_album_name: String = self.remove_remastered(full_name: self.apple_mediaItems[l].albumName! ?? "") ?? ""
                                                                    
                                                                    
                                                                    //EXACT MATCH
                                                                    if self.apple_mediaItems[l].isrc == spoti_struct.isrc_number &&
                                                                        self.apple_mediaItems[l].artistName == spoti_struct.artist_name &&
                                                                        matchee_album_name == matcher_album_name &&
                                                                        matchee_song_name == matcher_song_name /*&&
                                                                         self?.apple_mediaItems[l].releaseDate == spoti_struct.release_date*/ {
                                                                            print ("the apple one")
                                                                            print (self.apple_mediaItems[l].isrc)
                                                                            i = l
                                                                            break
                                                                    }
                                                                }
                                                            }
                                                            if i == count + 1 {  //by album and song name only
                                                                print ("by album and song name only")
                                                                for l in 0..<count {
/*                                                         if spoti_struct.release_date?.count != self?.apple_mediaItems[0][l].releaseDate?.count {
                                                                    if self?.apple_mediaItems[l].releaseDate?.count as Int! > spoti_struct.release_date?.count as Int!{
                                                                             for n in 0...3 {
                                                                                self?.apple_mediaItems[l].releaseDate?.dropLast()
                                                                               }
                                                                     } else {
                                                                        for n in 0...3 {
                                                                           spoti_struct.release_date?.dropLast()
                                                                        }
                                                                    }

                                                                }
 */
                                                                    var matchee_song_name =  String()
                                                                    var custom_strip_text: String = self.remastered_matches(for: "Remastered \\d\\d\\d\\d", in: self.apple_mediaItems[l].name! ?? "") ?? ""
                                                                    if custom_strip_text == "nil" {
                                                                        matchee_song_name = self.remove_remastered(full_name: self.apple_mediaItems[l].name! ?? "") ?? ""
                                                                    } else {
                                                                        matchee_song_name = self.remove_custom_remastered(full_name: self.apple_mediaItems[l].name! ?? "", custom_text: custom_strip_text) ?? ""
                                                                    }
                                                                    var matchee_album_name: String = self.remove_remastered(full_name: self.apple_mediaItems[l].albumName! ?? "") ?? ""
                                                                    
                                                                    //ARTIST, ALBUM AND SONGNAME MATCH
                                                                    if self.apple_mediaItems[l].artistName == spoti_struct.artist_name &&
                                                                        matchee_album_name == matcher_album_name &&
                                                                        matchee_song_name == matcher_song_name /*&&
                                                                         self?.apple_mediaItems[0][l].releaseDate == spoti_struct.release_date */ {
                                                                            print ("the apple one")
                                                                            print (self.apple_mediaItems[l].isrc)
                                                                            i = l
                                                                            break
                                                                    }
                                                                }
                                                            }
                                                            if i == count + 1 { //by isrc only
                                                                print ("by isrc only")
                                                                for l in 0..<count {
                                                                    
                                                                    if self.apple_mediaItems[l].isrc == spoti_struct.isrc_number {
                                                                        print ("the apple one")
                                                                        print (self.apple_mediaItems[l].isrc)
                                                                        i = l
                                                                        break
                                                                    }
                                                                }
                                                            }
                
                
                                                    }
                                                            if i > count {
                                                                //this means we iterated through all items in the current search list and found nothing OR that the items array was empty
                                                                //for now - reject the promise
                                                                
                                                                //seal.reject(MyError.runtimeError("Song not found"))
                                                                variable.album_name = ""
                                                                variable.song_name = ""
                                                                variable.playable_id = ""
                                                                variable.artist_name = ""
                                                                variable.isrc_number = ""
                                                                variable.preview_url = ""
                                                                self.apple_struct = variable
                                                                self.this_catalogue_doesnt_have_the_song_right_now = "apple"
                                                                seal.fulfill(())
                                                            } else {
                                                                print ("\(self.apple_mediaItems[i])")
                                                                variable.album_name = self.apple_mediaItems[i].albumName ?? ""
                                                                variable.song_name = self.apple_mediaItems[i].name ?? ""
                                                                variable.playable_id = self.apple_mediaItems[i].identifier ?? ""
                                                                variable.artist_name = self.apple_mediaItems[i].artistName ?? ""
                                                                variable.isrc_number = self.apple_mediaItems[i].isrc ?? ""
                                                                print(self.apple_mediaItems[i].previews[0]["url"])
                                                                variable.preview_url =  (self.apple_mediaItems[i].previews[0]["url"]) ?? ""
                                                                self.apple_struct = variable
                                                                seal.fulfill(())
                                                            }
            }
        }
    }

    func new_db_entry (target: String, reference_struct: song_db_struct)  -> Promise<Void> {
        print ("new_db_entry")
        return Promise { seal in
        //if passed in struct is spotify call apple search
        
        //if passed in struct is apple call spotify search
        
        //make the entry in the database and return the newly found song struct
        self.target_struct = song_db_struct()
        
        if target == "apple" {
            apple_search_and_parse(spoti_struct: reference_struct).done { Void in
                self.spotify_struct = reference_struct
                self.target_struct = self.apple_struct!
                self.firebase_add()
                seal.fulfill(())
            }
        } else if target == "spotify" {
            spotify_search_and_parse(appi_struct: reference_struct).done { Void in
                self.apple_struct = reference_struct
                self.target_struct = self.spotify_struct!
                self.firebase_add()
                seal.fulfill(())
            }
        }
        
      
        }
    }
    
    func firebase_add () {
        print("firebase")
        if (self.apple_struct?.isrc_number == self.spotify_struct?.isrc_number) && (self.this_catalogue_doesnt_have_the_song_right_now == "none") {
            firebase_addition(isrc_no: self.apple_struct!.isrc_number!, spotify_data: self.spotify_struct!, apple_data: self.apple_struct!)
        } else if self.this_catalogue_doesnt_have_the_song_right_now == "spotify"{
            firebase_addition_apple_only(isrc_no: self.apple_struct!.isrc_number!, apple_data: self.apple_struct!)
        } else if self.this_catalogue_doesnt_have_the_song_right_now == "apple" {
            firebase_addition_spotify_only(isrc_no: self.spotify_struct!.isrc_number!, spotify_data: self.spotify_struct!)
        } else {
            firebase_addition(isrc_no: self.apple_struct!.isrc_number!, spotify_data: self.spotify_struct!, apple_data: self.apple_struct!)
            firebase_addition(isrc_no: self.spotify_struct!.isrc_number!, spotify_data: self.spotify_struct!, apple_data: self.apple_struct!)
        }
        
    }
    
    
    func get_this_song (target_catalog: String, song_data: song_db_struct) -> Promise<song_db_struct> {
        return Promise { seal in
        var found_song = song_db_struct()
        //Check if the database has this isrc entry
        //if yes call: get_from_db ()
        print("In get this song")
        //if no call new_db_entry ()
        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        ref.child("isrc_db").child(song_data.isrc_number ?? "nil").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                print ("Yes we got here")
                print (snapshot)
                //We want to see if this isrc entry contains both catalogue sets - if a certain set is missing (target_catalogue) this was because at the time that this entry was made, we could not find the song in that catalogue - so we treat it as a new entry - search through that catalogue again to see if the song has now been added  - if yes - when we add the entry again, it will contain the missing set
                let temp_diction = snapshot.value as! [String : [String : String]]
                //the dict should have 2 entries - spotify and apple, if it has less than 2 that means that one of them is missing (or both)
                if temp_diction.count < 2 {
                    if temp_diction.keys.contains("apple_set"){
                        print("get_this_song: spotify_set is Missing")
                    } else if temp_diction.keys.contains("spotify_set"){
                        print ("get_this_song: apple_set is Missing")
                    } else {
                        print ("get_this_song: Both sets are Missing??")
                    }
                    self.new_db_entry(target: target_catalog, reference_struct: song_data).done { Void in
                        found_song = self.target_struct
                        seal.fulfill(found_song)
                    }
                }
                
                //if there are 2 entries, that means we have the required song in our db, so grab it and return
                ref.child("isrc_db").child(song_data.isrc_number ?? "nil").child("\(target_catalog)_set").observeSingleEvent(of: .value) { (snapshot2) in
                    if snapshot2.exists() {
                        print ("song is there ")
                        //found_song = snapshot2.value as! song_db_struct
                        let temp_dict = snapshot2.value as! [String : String]
                        found_song.playable_id = temp_dict["playable_id"]
                        seal.fulfill(found_song)
                    } else {
                        seal.fulfill(found_song)
                        print("ERROR: get_this_song: \(target_catalog)_set in isrc_db is empty")
                    }
                 }
                } else {
                //We don't have an entry for this song/ISRC - so do a fresh search in the target catalogue.
                    print("song aint there")
                    self.new_db_entry(target: target_catalog, reference_struct: song_data).done { Void in
                    found_song = self.target_struct
                    seal.fulfill(found_song)
                }
            }
        }
        }
    }
    
    //Making new addition to isrc database - song found in apple and spotify
    func firebase_addition (isrc_no: String, spotify_data: song_db_struct, apple_data: song_db_struct) {
        print("firebase_addition")
        var ds = ISRC_ds(isrc_number: isrc_no, spotify_set: spotify_data, apple_set: apple_data)
        let isrc_ds = ds.create_isrc_ds()
        
        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        
        ref.child("isrc_db").updateChildValues(isrc_ds) { (err, ref) in
            
            if err != nil {
                print (err)
                return
            }
            print ("saved value to db")
        }
    }
    
    //Making new addition to isrc database - song found in apple only
    func firebase_addition_apple_only (isrc_no: String, apple_data: song_db_struct) {
        print("firebase_addition_apple_only")
        var ds = ISRC_ds(isrc_number: isrc_no, spotify_set: apple_data, apple_set: apple_data)
        let isrc_ds = ds.create_isrc_ds_apple_only()
        
        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        
        ref.child("isrc_db").updateChildValues(isrc_ds) { (err, ref) in
            
            if err != nil {
                print (err)
                return
            }
            print ("saved value to db")
        }
    }
    
    
    //Making new addition to isrc database - song found in spotify only
    func firebase_addition_spotify_only (isrc_no: String, spotify_data: song_db_struct) {
        print("firebase_addition_spotify_only")
        var ds = ISRC_ds(isrc_number: isrc_no, spotify_set: spotify_data, apple_set: spotify_data)
        let isrc_ds = ds.create_isrc_ds_spotify_only()
        
        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        
        ref.child("isrc_db").updateChildValues(isrc_ds) { (err, ref) in
            
            if err != nil {
                print (err)
                return
            }
            print ("saved value to db")
        }
    }
    

func remove_remastered(full_name: String) -> String {
    
    var changed_name = full_name
    changed_name = changed_name.replacingOccurrences(of: "Remastered", with: "")
    changed_name = changed_name.replacingOccurrences(of: "(", with: "")
    changed_name = changed_name.replacingOccurrences(of: ")", with: "")
    changed_name = changed_name.replacingOccurrences(of: "[", with: "")
    changed_name = changed_name.replacingOccurrences(of: "]", with: "")
    changed_name = changed_name.replacingOccurrences(of: " ", with: "")
    changed_name = changed_name.replacingOccurrences(of: "-", with: "")
    changed_name = changed_name.lowercased() //'Roll it on home' case
    
    return changed_name
    
}

func remove_custom_remastered(full_name: String, custom_text: String) -> String {
    
    var changed_name = full_name
    print ("******************")
    print (custom_text)
    print ("******************")
    changed_name = changed_name.replacingOccurrences(of: custom_text, with: "")
    changed_name = changed_name.replacingOccurrences(of: "(", with: "")
    changed_name = changed_name.replacingOccurrences(of: ")", with: "")
    changed_name = changed_name.replacingOccurrences(of: "[", with: "")
    changed_name = changed_name.replacingOccurrences(of: "]", with: "")
    changed_name = changed_name.replacingOccurrences(of: " ", with: "")
    changed_name = changed_name.replacingOccurrences(of: "-", with: "")
    changed_name = changed_name.lowercased() //'Roll it on home' case
    
    print ("******************")
    print (changed_name)
    print ("******************")
    return changed_name
    
}

func remastered_matches(for regex: String, in text: String) -> String {
    
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        let matched_string : [String] = results.map {
            String(text[Range($0.range, in: text)!])
        }
        if matched_string.count > 0 {
            return matched_string[0]
        } else {
            return "nil"
        }
        
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return "nil"
    }
}
    
    
    
    
}
    
    
    

