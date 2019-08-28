//
//  UserMusicAccess.swift
//  Project2
//
//  Created by virdeshp on 5/20/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation
import StoreKit
import UIKit
import MediaPlayer
import PromiseKit
//This class is used to pull resources from the Users own library - Not the entire catalogue


class UserAccess {
    
    
    //let userdefaults = UserDefaults.standard
    //var musicPlayerController = MPMusicPlayerController.applicationMusicPlayer
    var myPlaylistQuery = MPMediaQuery.playlists()
    var myLibrarySongsQuery = MPMediaQuery.songs()
    var session: SPTSession!
    let userDefaults = UserDefaults.standard
    lazy var full_library_spotifytrackIDs = [""]
    var all_playlist_URIs = ["":""]
    lazy var all_spotify_playlist_dict = ["":[""]]
    var username: String
    var access_token: String
    var ErrorPointer: ErrorPointer = nil
    
    
    init(myPlaylistQuery: MPMediaQuery, myLibrarySongsQuery: MPMediaQuery) {
        //self.musicPlayerController = musicPlayerController
        self.myPlaylistQuery = myPlaylistQuery
        self.myLibrarySongsQuery = myLibrarySongsQuery
        self.access_token = (self.userDefaults.object(forKey: "spotify_access_token") as! String)
        //self.access_token = "BQChhry-k4ofBoCQqMFiEPTMXwWE5lPcHQt7b05pnOJhdA5dibaZpbEiiKCQZKuwF3ASJs3bm4VxNfzGcsiPSYSTHAEgGBSi5ItLKaEhPFFfOKguD5yuKsrohGkG23keL74nOhaZXQs3MzNWgRxEdFiEvw"
        
        self.username = (self.userDefaults.object(forKey: "current_spotify_username") as! String)
        //self.username = "virajdeshpande88@gmail.com"
    }
    
    //this function fills up full_library_spotifytrackIDs, all_playlist_URIs and all_spotify_playlist_names
    func getYourSpotifyLibrary() { }
        
        /*
        if let sessionObj: AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            self.session = firstTimeSession
        }
        let accessToken = self.session.accessToken
        self.access_token = accessToken!
        */
        
        
        
        //this request is to get the current logged in users username, we use it for the next request
        /*
        let request1: URLRequest = try! SPTUser.createRequestForCurrentUser(withAccessToken: self.access_token)
        SPTRequest.sharedHandler().perform(request1, callback: { (error,response, data) in
            if error == nil {
               var user = try! SPTUser(from: data, with: response)
                print("\(user.canonicalUserName) and this guy")
                self.username = user.canonicalUserName
            }else {
                print ("error")
                print (error)
            }
        })
        */
    func get_spotify_playlists (){
        print ("get_spotify_playlists")
        //print("\(self.username) yeah this guy")
        //print ("hey 1")
        
        //this request is to get all the playlist names: make a list of those, so that we can  get the tracks for each of them
        //let request2: URLRequest = try! SPTPlaylistList.createRequestForGettingPlaylists(forUser: self.username, withAccessToken: self.access_token)
        //print(request2)
        //SPTRequest.sharedHandler().perform(request2) { (error, response, data) in
            //if error == nil {
                //print(response)
                //let playlists = try? SPTPlaylistList(from: data, with: response)
                //print (playlists?.items)
                print ("hey 2")
                //print(self.access_token)
                SPTPlaylistList.playlists(forUser: self.username, withAccessToken: self.access_token, callback: {(error, playlist_list)  in
                    if error == nil {
                        var list = playlist_list as! SPTPlaylistList
                        //print ("hey 3")
                        //this while loop goes through all the pages and appends the playlist URIs to all_the_playlists
                        repeat{
                            for i in 0...(list.items.count-1) {
                                let playlist = list.items[i] as! SPTPartialPlaylist
                                print(playlist)
                                print(playlist.name)
                                print(playlist.uri)
                                print(playlist.playableUri)
                                //self.all_playlist_URIs.append("\(playlist.uri)")
                                //self.all_playlist_URIs.append("\(playlist.uri!)")
                                if !(self.all_playlist_URIs.keys.contains(playlist.name)){
                                    self.all_playlist_URIs[playlist.name] = "\(playlist.uri)"
                                }
                                //self.all_spotify_playlist_dict.append(playlist.name)
                                //print("\(self.all_playlist_URIs) at the append")
                                //print((track as! SPTSavedTrack).uri)
                                SPTPlaylistSnapshot.playlist(withURI: playlist.uri, accessToken: self.access_token, callback: {(error, play_snap)  in
                                    if error == nil {
                                        let snapshot = play_snap as! SPTPlaylistSnapshot //get the sanpshot
                                        //print(new_string)
                                        //print (snapshot.firstTrackPage.items)
                                        let snapshot_tracks = snapshot.firstTrackPage.items as! [SPTPlaylistTrack]
                                        for i in 0...snapshot_tracks.count-1 { //for each track in the snapshot list
                                            let track_play = snapshot_tracks[i] 
                                            //print("at the append \(snapshot.name) \(track_play.playableUri)")
                                            if self.all_spotify_playlist_dict.keys.contains(snapshot.name){
                                             self.all_spotify_playlist_dict[snapshot.name]?.append("\(track_play.playableUri)")
                                            }else{
                                                self.all_spotify_playlist_dict[snapshot.name] = ["\(track_play.playableUri)"]
                                            }
                                        }
                                        //print("at the set \(self.all_spotify_playlist_dict)")
                                        
                                        self.userDefaults.set(self.all_spotify_playlist_dict, forKey: "Spotify_playlist_dict")
                                    }else {
                                        print("error in snap checking playlists")
                                        print(error)
                                    }
                                })
                            
                            }
                            //print ("hey 4")
                            if list.hasNextPage{
                                list.requestNextPage(withAccessToken: self.access_token, callback: { (error, ListPage)  in
                                    if (error == nil) {
                                        list = ListPage as! SPTPlaylistList
                                    }else {
                                        print ("error: could not get nextPage")
                                    }
                                })
                            }
                        }while list.hasNextPage
                        
                        self.userDefaults.set(self.all_playlist_URIs, forKey: "Spotify_playlist_URIs")
                        //print("at the set \(self.all_spotify_playlist_dict)")
                        //self.userDefaults.set(self.all_spotify_playlist_dict, forKey: "Spotify_playlist_dict")
                    }else{
                        print("latest error")
                        print(error)
                    }
                })
            //}else{
              //  print(error)
                //print ("error")
            //}
        //}
        //print("\(self.all_playlist_URIs) at the return")
        //self.userDefaults.set(self.all_playlist_URIs, forKey: "Spotify_playlist_URIs")
       
    }
    
    func get_spotify_all_tracks() {
        print ("get_spotify_all_tracks")
        //this request is to get all the tracks in the users library
        let request3: URLRequest = try! SPTYourMusic.createRequestForCurrentUsersSavedTracks(withAccessToken: self.access_token, error: ErrorPointer)
        //print (request3)
        SPTRequest.sharedHandler().perform(request3) { (error, response, data) in
            print("Just completed the request")
            if error == nil {
                print ("error != nil")
                //print (self.access_token)
                var listPage = try! SPTListPage(from: data!, with: response, expectingPartialChildren: false, rootObjectKey: nil)
                print("printing listpage.items")
                print (listPage.items)
                //this while loop goes through all the pages and appends the tracks to full_library_spotifytrackIDs
                // the while loop had to changed to a recursive function becuase the SPTListPage.requestNextPage was taking too long and the while loop would just skip to the next iteration without letting the request complete. So we replaced it with s combination of recursion + Promises in the spotify_get_page_after_function - we call the function with the first page - if it has a next page - we request for it - when we get it we call the function with the new page - when that funciton call returns - we fulfill the promise - We run this asynchronously to not block the main thread.
                DispatchQueue.global(qos: .userInitiated).async {
                    self.spotify_get_page_after(this_page: listPage).done {
                        print("Done appending the songs")
                        print (self.full_library_spotifytrackIDs)
                        self.userDefaults.set(self.full_library_spotifytrackIDs, forKey: "Spotify_library_tracks")
                        print("set spotify track id list")
                    }
                }
            } else {
                print ("error getting all tracks")
                print (error)
            }
            
        }
        //print("\(self.full_library_spotifytrackIDs) at the return")
        print("Returning from get_spotify_all_tracks")
        return
    }
    
    func spotify_get_page_after (this_page: SPTListPage) ->Promise<Void> {
        return Promise { seal in
            print("spotify_get_page_after")
            var page = this_page
            
            for track in page.items {
                var stringID = "\((track as! SPTSavedTrack).uri)"
                self.full_library_spotifytrackIDs.append(stringID)
                print((track as! SPTSavedTrack).uri)
                print(page.hasNextPage)
            }
            
            if page.hasNextPage {
                page.requestNextPage(withAccessToken: self.access_token, callback: { (error, ListPage)  in
                    print(error)
                    print(ListPage)
                    if (error == nil) {
                        print("error == nil")
                        var NewPage = ListPage as! SPTListPage
                        self.spotify_get_page_after(this_page: NewPage).done {
                            seal.fulfill(())
                        }
                    } else {
                        print ("error: could not get nextPage")
                        seal.fulfill(())
                    }
                })
            } else {
                print ("Got all pages")
                seal.fulfill(())
            }
        }
        
    }
    
    func spotify_check_in_library(trackid: String) -> String {
        
        var ret = "none"
        let library_tracks = userDefaults.object(forKey: "Spotify_library_tracks") as? [String]
        for song in library_tracks! {
            if trackid == song {
                ret = "Library"
            }
        }
        return ret
    }
    
    
    
    func spotify_check_in_a_playlist(trackURI: String) -> [String] {
        var containing_playlists = [""]
        //print("Here bruh")
        //Request the list of playlists
                //this while loop goes through all the pages
        
        let library_tracks = userDefaults.object(forKey: "Spotify_library_tracks") as? [String]
        
        for song in library_tracks! {
            
            if "\(String(describing: URL(string: trackURI)))" == ("\(song)") {
                print("library matched")
                containing_playlists.append("Library")
            }
        }
        //print (library_tracks)
        let playlist_URIs = self.userDefaults.object(forKey: "Spotify_playlist_URIs") as! [String: String]
        let playlist_dict = self.userDefaults.object(forKey: "Spotify_playlist_dict") as! [String: [String]]
                    //print (playlist_URIs)
                    //print (playlist_names)
        //print(playlist_dict)
        for (playlist,tracks) in playlist_dict {
            for track in tracks {
                if "\(String(describing: URL(string: trackURI)))" == track{
                    containing_playlists.append(playlist)
                    break
                }
            }
        }
        //print("containing playlists \(containing_playlists)")
        return containing_playlists
    }
            

    
    func getplaylist_title() -> [String]{
        let playlists = myPlaylistQuery.collections
        var playlistarray: [String] = []
        for playlist in playlists! {
            //print(playlist.value(forProperty: MPMediaPlaylistPropertyName)!)
            playlistarray.append(playlist.value(forProperty: MPMediaPlaylistPropertyName)! as! String)
        }
        return playlistarray
    }
    
    
    func getplaylists () -> [String : [String]] {
        let playlists = myPlaylistQuery.collections
        var playlistdict: [String : [String]] = [:]
        for playlist in playlists! {
            //print(playlist.value(forProperty: MPMediaPlaylistPropertyName)!)
            let songs = playlist.items
            for song in songs {
                let songTitle = song.value(forProperty: MPMediaItemPropertyTitle)
                playlistdict[playlist.value(forProperty: MPMediaPlaylistPropertyName)!as! String]?.append(songTitle as! String)
                //print("\t\t", songTitle!)
            }
        }
        
        return playlistdict
        
    }
        
        
    func add_to_mediaItem (mediacollection: String, mediaItem: String) {
        print("Reached add item function")
        print(mediacollection)
        print(mediaItem as String)
        let my_library = MPMediaLibrary()
        
        if mediacollection == "Library"{
            print ("entered here")
            my_library.addItem(withProductID: mediaItem, completionHandler: nil)
        }
             let playlists = myPlaylistQuery.collections
             var selected_playlist: MPMediaPlaylist
             for playlist in playlists! {
                if (playlist.value(forProperty: MPMediaPlaylistPropertyName)! as! String) == mediacollection {
                    selected_playlist = playlist as! MPMediaPlaylist
                    selected_playlist.addItem(withProductID: mediaItem, completionHandler: nil)
                    
                }
                
            }
    }
    
    func add_spotify_media_item(mediacollection: String, mediaItem: String)
    {
       
        var library_tracks = userDefaults.object(forKey: "Spotify_library_tracks") as? [String] //pulling from userdefaults
        print(library_tracks)
        if mediacollection == "Library"{
            let request: URLRequest = try! SPTYourMusic.createRequest(forSavingTracks: [URL(string: "\(mediaItem)") as Any], forUserWithAccessToken: self.access_token, error: ErrorPointer)
            SPTRequest.sharedHandler().perform(request) { (error, response, data) in
                if error == nil {
                    print (response)
                    library_tracks?.append("\(URL(string: mediaItem))")
                    self.userDefaults.set(library_tracks, forKey: "Spotify_library_tracks") //updating to userdefaults
                    
                }else{
                    print(error)
                }
            }
            SPTYourMusic.saveTracks(["\(mediaItem)"], forUserWithAccessToken: self.access_token, callback: {(error, Result) in
                if error != nil {
                    print ("Save tracks returned error")
                    print (error)
                }
            })
            
        }else{
            let playlist_name = self.userDefaults.object(forKey: "Spotify_playlist_URIs") as! [String: String] //pulling from userdefaults
            var playlist_dict = self.userDefaults.object(forKey: "Spotify_playlist_dict") as! [String: [String]] //pulling from userdefaults
            let playlist_URI = playlist_name[mediacollection] as! String
            let request: URLRequest = try! SPTPlaylistSnapshot.createRequest(forAddingTracks: [URL(string: "\(mediaItem)") as Any], toPlaylist: URL(string: "\(playlist_URI)")!, withAccessToken: self.access_token, error: ErrorPointer )
            SPTRequest.sharedHandler().perform(request) { (error, response, data) in
                if error == nil {
                    print(response)
                    let playist = try? SPTPlaylistSnapshot(from: data!, error: self.ErrorPointer)
                    //playist?.addTracks(toPlaylist: [URL(string: "\(String(describing: playlist_name[mediacollection]))")], withAccessToken: self.access_token, callback: nil)
                    playlist_dict[mediacollection]?.append("\(URL(string: mediaItem))")
                    print(playlist_dict)
                    self.userDefaults.set(playlist_dict, forKey: "Spotify_playlist_dict") //updating to userdefaults
                    
                }else{
                    print(error)
                    print(response)
                    print("error adding a song")
                }
            }
        }
    }
   
    
    func check_in_library (trackid: String) -> [String] {
        print ("in check in library function")
        let library = myLibrarySongsQuery.items
        
        var return_array = [""]
        var playbackIDcollection = [""]
        for song in library! {
            
            
            
            //print(song.value(forProperty: MPMediaItemPropertyTitle) as! String)
            if (song.value(forProperty: MPMediaItemPropertyPlaybackStoreID)) != nil {
            //print(song.value(forProperty: MPMediaItemPropertyPlaybackStoreID) as! String)
            playbackIDcollection.append((song.value(forProperty: MPMediaItemPropertyPlaybackStoreID) as! String))
                if (song.value(forProperty: MPMediaItemPropertyPlaybackStoreID) as! String) == trackid{
                    return_array.append("Library")
                    let playlists = myPlaylistQuery.collections
                     for playlist in playlists! {
                        let songs = playlist.items
                        for song in songs {
                            if (song.value(forProperty: MPMediaItemPropertyPlaybackStoreID) as! String) == trackid{
                                return_array.append(playlist.value(forProperty: MPMediaPlaylistPropertyName)!as! String)
                                break
                            }
                    }
                    print ("yes the song is there")
                    print (trackid)
                    break
                }
            }
        }
    }
        print (return_array)
        return return_array
    }
    
    
    
    
}
