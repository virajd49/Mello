//
//  MusicPlayerMaster.swift
//  Project2
//
//  Created by virdeshp on 10/26/19.
//  Copyright © 2019 Viraj. All rights reserved.
//import UIKit





import AVFoundation
import Firebase
import Foundation
import YoutubeKit
import PromiseKit

enum player_type: String {
    case appleplayer = "appleplayer"
    case spotifyplayer = "spotifyplayer"
    case youtubeplayer = "youtubeplayer"
    case avplayer = "avplayer"
}

class MusicPlayerMaster: NSObject {
    
    
    
    
    var current_user = UserAccount()
    var user_services = [Service]()
    var newsfeed_posts = [Post]()
    var playback_ready_posts = [PlaybackPost]()
    var user_has_apple: Bool = false
    var user_has_spotify: Bool = false
    var user_has_both: Bool = false
    var user_has_youtube: Bool = false
    var apple_service = Service()
    var spotify_service = Service()
    var youtube_service = Service()
    
    
    
    override init () {
        print("------------------------- MusicPlayerMaster init -----------------------------")
        /*get user info
            -username
            -services
         */
//        current_user.get_current_user()
//        current_user.get_user_subscriptions().done { services_array in
//            self.user_services = services_array
//        }
        
    }
    
    
    
    
    func fetch_posts () -> Promise<Void>{
        return Promise { seal in
            Post.fetchPosts().done { posts in
                self.newsfeed_posts = posts
                seal.fulfill_()
            }
        }
    }
    
    
    func make_posts_newfeed_ready () -> Promise<Void> {
        return Promise { seal in
            
            current_user.get_current_user()
            current_user.get_user_subscriptions().done { services_array in
                self.user_services = services_array
            
        self.fetch_posts().done {
            self.recognize_services()
            for post in self.newsfeed_posts {
                var temp_playback_post = PlaybackPost()
                temp_playback_post.post = post
                switch post.sourceapp {
                case service_name.apple.rawValue:
                    if self.user_has_apple {
                        switch self.apple_service.subscription! {
                        case subscription.free:
                            //playable id should be sample URL - apple
                            temp_playback_post.trackid = post.preview_url
                            //player should be AV player
                            temp_playback_post.player = player_type.avplayer
                            break
                        case subscription.paid:
                            //playable id should be apple trackid
                            temp_playback_post.trackid = post.trackid
                            //player should be appleplayer
                            temp_playback_post.player = player_type.appleplayer
                            break
                        default:
                            break
                        }
                    } else if self.user_has_spotify {
                        switch self.spotify_service.subscription! {
                        case subscription.free:
                            //playable id should be sample URL - spotify/apple
                            temp_playback_post.trackid = post.preview_url
                            //player should be AV player
                            temp_playback_post.player = player_type.avplayer
                            break
                        case subscription.premium:
                            //playable id should be spotify trackid (helper)
                            temp_playback_post.trackid = post.helper_id
                            //player should be spotifyplayer
                            temp_playback_post.player = player_type.spotifyplayer
                            break
                        default:
                            break
                        }
                    } else {
                        //can't play this post
                        temp_playback_post.can_play_this_post = false
                        temp_playback_post.message_for_user = "Sign up with Apple to listen to this song"
                    }
                    
                    
                    break
                case service_name.spotify.rawValue:
                    if self.user_has_spotify {
                        switch self.spotify_service.subscription! {
                        case subscription.free:
                            //playable id should be sample URL - spotify
                            temp_playback_post.trackid = post.preview_url
                            //player should be AV player
                            temp_playback_post.player = player_type.avplayer
                            break
                        case subscription.premium:
                            //playable id should be spotify trackid
                            temp_playback_post.trackid = post.trackid
                            //player should be spotifyplayer
                            temp_playback_post.player = player_type.spotifyplayer
                            break
                        default:
                            break
                        }
                    } else if self.user_has_apple {
                        switch self.apple_service.subscription! {
                        case subscription.free:
                            //playable id should be sample URL - spotify/apple
                            temp_playback_post.trackid = post.preview_url
                            
                            //player should be AV player
                            temp_playback_post.player = player_type.avplayer
                            break
                        case subscription.paid:
                            //playable id should be apple trackid (helper)
                            temp_playback_post.trackid = post.helper_id
                            //player should be appleplayer
                            temp_playback_post.player = player_type.appleplayer
                            break
                        default:
                            break
                        }
                        
                    } else {
                        //can't play this post!
                        temp_playback_post.can_play_this_post = false
                        temp_playback_post.message_for_user = "Sign up with Spotify to listen to this song"
                    }
                    break
                case service_name.youtube.rawValue:
                    if self.user_has_youtube {
                        //playable id should be video id
                        temp_playback_post.trackid = post.videoid
                        //player should be youtube player
                        temp_playback_post.player = player_type.youtubeplayer
                    }
                    break
                default:
                    break
                }
                
                self.playback_ready_posts.append(temp_playback_post)
            }
            seal.fulfill_()
        }
            }
            
        }
    }
    
    func recognize_services() {
        print("---------recognize_services ------------------------")
        for service in user_services {
            print("---------for service in user_services------------------------")
            switch service.name! {
            case service_name.apple:
                user_has_apple = true
                apple_service = service
                print("---------User has apple service ------------------------")
                break
            case service_name.spotify:
                user_has_spotify = true
                spotify_service = service
                print("---------User has spotify service ------------------------")
                break
            case service_name.youtube:
                user_has_youtube = true
                youtube_service = service
                print("---------User has Youtube service ------------------------")
                break
            default:
                break
            }
        }
        
        if user_has_spotify && user_has_apple {
            user_has_both = true
        }
    }
   
    /* User can have
        only Apple
        only Spotify
        both
     
     
     depending on what the user registers with we will always have
        apple_player as primary - with spotify helper id's or AV player urls from apple
        spotify player as primary - with apple helper id's or AV player urls from spotify
        apple and spotify both as primary - should not need AV player urls
     
     
     Post should have -
        source app - id 100%
        source app url - if found
        helper app id - if found
        helper app url - if found
     
                When we get the posts we go through them and sort out the id's based on what we can use -
                        can only use the preview clips for non premium spotify members and non itunes subscribers
     
            so figure out target player based on what data we have and what user account we are using. -> do this evertime we do a new load and give the newsfeed a list of posts that are ready for this
                        - target player
                        - player id/url string
     
     
     
     
     User flow:
        what primary player do I have ?
            -> Does any id match my primary player/s ?
                ->yes  - grab the id and play using that player
                ->no - is there a sample url ?
                        -> yes, grab that and play using AV player
                        -> no, (rare case) - display UI saying sorry sign up to this service to listen to this song.
     
     */
    
    
    
    
    
    
}
