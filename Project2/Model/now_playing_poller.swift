//
//  now_playing_poller.swift
//  Project2
//
//  Created by virdeshp on 2/10/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import MediaPlayer
import PromiseKit


class now_playing_poller {
    
    static let shared = now_playing_poller()
    let apple_system_player = MPMusicPlayerController.systemMusicPlayer
    var timer = Timer()
    var trackDuration = TimeInterval()
    var internal_keep_time = TimeInterval() //if there is ever a timing issue and we miss the time period from 0.0 - 2.0 seconds to catch the new song
    //we use this internal time keep - this is incremented ever second - so theoretically if the current playback time of the system player is less than this time - it means that it has switched over to a new song - thats the only way that it can be less than the internal time keep value.
            //--CAN'T USE IT -- ONLY ACCURATE UPTO 100th of a second -- we still update it for some future use maybe -- BUT DONT CHECK IT
    let appleMusicManager = AppleMusicManager()
    let userDefaults = UserDefaults.standard
    var apple_mediaItems: [[MediaItem]]!
    var spotify_currently_playing_object: SpotifyCurrentPlayingMediaObject.currently_playing_context!
    let imageCacheManager = ImageCacheManager()
    var the_image = UIImage()
    var current_playback_id = String()
    var something_is_playing: Bool = false
    private init () {
        
        print ("!!!!!!!!!!!!!!!!!!! now_playing_poller private init called !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSystemMusicPlayerControllerPlaybackStateDidChange),
                                               name: .MPMusicPlayerControllerPlaybackStateDidChange ,
                                               object: self.apple_system_player)
        self.apple_system_player.beginGeneratingPlaybackNotifications()
        
    }
    
    
    func grab_now_playing_item () ->Promise< Void > {
        return Promise{ seal in
        
        let user_player_flag = self.userDefaults.string(forKey: "UserAccount")
        
        switch (user_player_flag) {
            
        case "Apple" :
            if let mediaItem = self.apple_system_player.nowPlayingItem {
                let title: String = mediaItem.value(forProperty: MPMediaItemPropertyTitle) as! String
                let albumTitle: String = mediaItem.value(forProperty: MPMediaItemPropertyAlbumTitle) as! String
                let artist: String = mediaItem.value(forProperty: MPMediaItemPropertyArtist) as! String
                let now_playing_time: TimeInterval = self.apple_system_player.currentPlaybackTime
                let now_playing_id : Int = Int(mediaItem.persistentID)
                if let now_playing_id_2: String = mediaItem.playbackStoreID {
                    self.current_playback_id = now_playing_id_2
                    self.get_image(songid: now_playing_id_2)
                    print("playback id is \(now_playing_id_2)")
                } else {
                    print ("There is no song ID !!!!!!!")
                }
                trackDuration = mediaItem.playbackDuration
                print("now playing item playback duration is \(trackDuration)")
                //get media item using playbackstoreID
                
                if self.apple_system_player.playbackState == .playing {
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
                    internal_keep_time = self.apple_system_player.currentPlaybackTime
                }
                
                //mediaItem.artwork?.image(at: (self.now_playing_image?.bounds.size)!)
                if mediaItem.artwork == nil {
                    print ("image is nil")
                } else {
                    print ("image is not nil")
                    print ("\(mediaItem.artwork)")
                }
                
                print("\(title) on \(albumTitle) by \(artist) with a duration of \(trackDuration) playing at \(now_playing_time) with id \(now_playing_id)")
                self.something_is_playing = true
                seal.fulfill(())
            } else {
                print ("Nothing is playing")
                self.something_is_playing = false
                seal.fulfill(())
            }
            break;
        case "Spotify" :
            print("poller case Spotify")
            let access_token = self.userDefaults.value(forKey: "spotify_access_token")
            print("\(access_token)")
            appleMusicManager.performSpotifyCurrentPlayingSearch(with: access_token as! String).done { spotify_current_playing_context in
               
                guard !spotify_current_playing_context.isEmpty else {
                    print ("Spotify: Nothing is playing - spotify_current_playing_context is nil")
                    self.something_is_playing = false
                    return
                }
                
                self.something_is_playing = true
                
                self.spotify_currently_playing_object = spotify_current_playing_context[0]
                var imageURL: URL?
                if spotify_current_playing_context[0].item?.album?.images?.count != 0 {
                    print ("hurdle one")
                    print("\(self.spotify_currently_playing_object.item?.name)")
                    print("\(self.spotify_currently_playing_object.item?.artists![0].name)")
                    print ("\(self.spotify_currently_playing_object.progress_ms)")
                    print ("\(self.spotify_currently_playing_object.timestamp)")
                    imageURL = URL(string: "\(self.spotify_currently_playing_object.item?.album?.images?[0].url ?? "" )")
                    print (self.spotify_currently_playing_object.item?.album?.images?[0].url)
                    print (imageURL)
                    
                    if (imageURL != nil) {
                        print ("hurdle two")
                        if let image = self.imageCacheManager.cachedImage(url: imageURL!) {
                            // Cached: set immediately.
                            //®print ("Cached")
                            self.the_image = image
                            seal.fulfill(())
                        } else {
                            // Not cached, so load then fade it in.
                            
                            //print ("Not cached")
                            self.imageCacheManager.fetchImage(url: imageURL!, completion: { (image) in
                                self.the_image = image!
                                 seal.fulfill(())
                                
                                //print ("fetched")
                            })
                        }
                        
                    }
                    //self.upload_flag = "now_playing"
                }
            }
            break
        default:
            seal.fulfill(())
            break
            
        }
        }
    }
    
     @objc func handleSystemMusicPlayerControllerPlaybackStateDidChange (notification: NSNotification) {
        
        if self.apple_system_player.playbackState == .playing {
            print ("apple player was played - poller - handleSystemMusicPlayerControllerPlaybackStateDidChange")
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
            internal_keep_time = self.apple_system_player.currentPlaybackTime
        } else if self.apple_system_player.playbackState == .interrupted {
            print ("apple player was interrupted - poller - handleSystemMusicPlayerControllerPlaybackStateDidChange")
            self.timer.invalidate()
            internal_keep_time = 0.0
        } else if self.apple_system_player.playbackState == .paused {
            print ("apple player was paused - poller - handleSystemMusicPlayerControllerPlaybackStateDidChange")
            self.timer.invalidate()
            internal_keep_time = 0.0
        } else if self.apple_system_player.playbackState == .stopped {
            print ("apple player was stopped - poller - handleSystemMusicPlayerControllerPlaybackStateDidChange")
            self.timer.invalidate()
            internal_keep_time = 0.0
        }
    }
    
    @objc func updateTimer () {
        
        internal_keep_time += 1 //internal time keeping ; this is reset when we switch over to a new song.
        print("current time is \(self.apple_system_player.currentPlaybackTime) internal time is \(internal_keep_time)")
        if self.apple_system_player.currentPlaybackTime < 2 || (self.apple_system_player.nowPlayingItem?.playbackStoreID != self.current_playback_id) {
            print("current time is \(self.apple_system_player.currentPlaybackTime) internal time is \(internal_keep_time) , guess a new song started ?")
            self.timer.invalidate()
            self.grab_now_playing_item()
        }
        
        
    }
    
    func perform_search_for_apple_with_songID (song_id: String) -> Promise<Void> {
        return Promise { seal in
            let country_code = userDefaults.string(forKey: "Country_code")
            appleMusicManager.performAppleMusicCatalogSearch_songID(with: song_id, countryCode: country_code ?? "us").done { searchItems in
                
                
                print ("we got'em bruh !!!!!!!!!!!!!!!!!!!!")
                self.apple_mediaItems = searchItems
                seal.fulfill(())
                
            }
            print ("YAAAAAAAAAAS!!!!!!!!!!!!!!! 2")
        }
    }

    func get_image (songid: String) {
        
        self.perform_search_for_apple_with_songID(song_id: songid).done {
            if let image = self.imageCacheManager.cachedImage(url: self.apple_mediaItems[0][0].artwork.imageURL(size: CGSize(width: 275, height: 275))) {
                // Cached: set immediately.
                self.the_image = image
            } else {
                // Not cached, so load then fade it in.
                self.imageCacheManager.fetchImage(url: self.apple_mediaItems[0][0].artwork.imageURL(size: CGSize(width: 275, height: 275)), completion: { (image) in
                    self.the_image = image ?? UIImage.init(named: "Beatles")!
                })
            }
            
        }
        
    }
    
    func grab_and_store_image () {
        
        
        self.grab_now_playing_item().done {
            
            
        }
        
        
        return
    }
    
    
    func return_image () -> UIImage {
        
        return self.the_image
    }
}
