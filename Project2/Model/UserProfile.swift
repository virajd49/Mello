//
//  UserProfile.swift
//  Project2
//
//  Created by virdeshp on 6/8/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import PromiseKit
import Firebase


class UserProfile {

    var profileImageURL: String!
    var heroes: [Hero]!
    var omm: Post!
    var pinnedPosts: [Post]!
    var followers: Int!
    var follows: Int!
    
    static func fetch_pinnedPosts () -> Promise<[Post]> {
        return Promise { seal in
            var posts = [Post]()
            var helper = Post_helper()
            var worker = ISRC_worker()
            
            var ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
            ref.child("user_db").child("profile_db").child("pinned_posts_db").observeSingleEvent(of: .value, with: { snapshot in
                print (snapshot.childrenCount)
                let dummy_post = Post(albumArtImage: "" , sourceAppImage: "", typeImage: "" , profileImage: "" , username: "" ,timeAgo: "", numberoflikes: "" ,caption:"", offset: 0.0, startoffset: 0.0, audiolength: 0.0, paused: false, playing: true, trackid: "", helper_id: "", videoid: "", starttime: 0.0 , endtime: 0.0, flag: "", lyrictext: "", songname: "", sourceapp: "", preview_url: "", albumArtUrl: "", original_track_length: 0, GIF_url: "")
                posts = Array<Post>(repeating: dummy_post, count: Int(snapshot.childrenCount))
                
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    print (snap.key)
                    let index = snap.key as! String
                    let absolute_index = index.replacingOccurrences(of: "Post", with: "")
                    let temp_dict = snap.value as! [String : Any]
                    //                print(temp_dict)
                    //                print (temp_dict["albumArtImage"] as! String)
                    //                print (temp_dict["sourceAppImage"] as! String)
                    //                print (temp_dict["typeImage"] as! String)
                    //                print (temp_dict["profileImage"] as! String)
                    //                print (temp_dict["username"] as! String)
                    //                print (temp_dict["timeAgo"] as! String)
                    //                print (temp_dict["numberoflikes"] as! String)
                    //                print (temp_dict["caption"] as! String)
                    //                print (temp_dict["offset"] as! TimeInterval)
                    //                print (temp_dict["startoffset"] as! TimeInterval)
                    //                print (temp_dict["audiolength"] as! Float)
                    //                print (temp_dict["paused"] as! Bool)
                    //                print (temp_dict["playing"] as! Bool)
                    //                print (temp_dict["trackid"] as! String)
                    //                print (temp_dict["helper_id"] as! String)
                    //                print (temp_dict["videoid"] as! String)
                    //                print (temp_dict["starttime"] as! Float)
                    //                print (temp_dict["endtime"] as! Float)
                    //                print (temp_dict["flag"] as! String)
                    //                print (temp_dict["lyrictext"] as! String)
                    //                print (temp_dict["songname"] as! String)
                    //                print (temp_dict["sourceapp"] as! String)
                    //                print (temp_dict["preview_url"] as! String)
                    //                print (temp_dict["original_track_length"] as! String)
                    let post = Post(albumArtImage: (temp_dict["albumArtImage"] as! String) , sourceAppImage: (temp_dict["sourceAppImage"] as! String), typeImage: (temp_dict["typeImage"] as! String) , profileImage: (temp_dict["profileImage"] as! String) , username: (temp_dict["username"] as! String) ,timeAgo: (temp_dict["timeAgo"] as! String), numberoflikes: (temp_dict["numberoflikes"] as! String) ,caption: (temp_dict["caption"] as! String), offset: (temp_dict["offset"] as! TimeInterval), startoffset: (temp_dict["startoffset"] as! TimeInterval), audiolength: (temp_dict["audiolength"] as! Float), paused: (temp_dict["paused"] as! Bool), playing: (temp_dict["playing"] as! Bool), trackid: (temp_dict["trackid"] as! String), helper_id: (temp_dict["helper_id"] as! String), videoid: (temp_dict["videoid"] as! String), starttime: (temp_dict["starttime"] as! Float) , endtime: (temp_dict["endtime"] as! Float), flag: (temp_dict["flag"] as! String), lyrictext: (temp_dict["lyrictext"] as! String), songname: (temp_dict["songname"] as! String), sourceapp: (temp_dict["sourceapp"] as! String), preview_url: (temp_dict["preview_url"] as! String), albumArtUrl: (temp_dict["albumArtUrl"] as! String), original_track_length: 0, GIF_url: (temp_dict["GIF_url"] as! String))
                    posts[Int(absolute_index)!] = post
                }
                seal.fulfill(posts)
            })
            
        }
 
    }
    
    static func fetch_heroes () {
        
        
    }
    
    
    static func fetch_omm () {
        
        
        
    }

   
}

