//
//  Post.swift
//  Project2
//
//  Created by virdeshp on 3/12/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit
import Firebase
import PromiseKit



struct Post {
    
    
    let userDefaults = UserDefaults.standard
    var albumArtImage : String?
    var sourceAppImage : String?
    var typeImage : String?
    var profileImage: String?
    var username: String?
    var timeAgo: String?
    var numberoflikes: String?
    var caption: String?
    var offset: TimeInterval!
    var startoffset: TimeInterval!
    var audiolength: Float
    var paused: Bool!
    var playing: Bool!
    var trackid: String!
    var helper_id: String!
    var videoid: String!
    var starttime: Float!
    var endtime: Float!
    var flag: String!  //can be audio, video or lyric
    var lyrictext: String!
    var songname: String!
    var sourceapp: String!
    var preview_url: String!
    var albumArtUrl: String!
    var original_track_length: Int!
    
    static func fetchPosts() -> Promise<[Post]> {
        return Promise { seal in
        var posts = [Post]()
        var helper = Post_helper()
        var worker = ISRC_worker()
        
        
            var ref = FIRDatabase.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        ref.child("user_db").child("post_db").observeSingleEvent(of: .value, with: { snapshot in
            print (snapshot.childrenCount)
            let dummy_post = Post(albumArtImage: "" , sourceAppImage: "", typeImage: "" , profileImage: "" , username: "" ,timeAgo: "", numberoflikes: "" ,caption:"", offset: 0.0, startoffset: 0.0, audiolength: 0.0, paused: false, playing: true, trackid: "", helper_id: "", videoid: "", starttime: 0.0 , endtime: 0.0, flag: "", lyrictext: "", songname: "", sourceapp: "", preview_url: "", albumArtUrl: "", original_track_length: 0)
            posts = Array<Post>(repeating: dummy_post, count: Int(snapshot.childrenCount))

            for child in snapshot.children {
                let snap = child as! FIRDataSnapshot
                print (snap.key)
                let index = snap.key as! String
                let absolute_index = index.replacingOccurrences(of: "Post", with: "")
                let temp_dict = snap.value as! [String : Any]
                //print(temp_dict)
                print (temp_dict["albumArtImage"] as! String)
                print (temp_dict["sourceAppImage"] as! String)
                print (temp_dict["typeImage"] as! String)
                print (temp_dict["profileImage"] as! String)
                print (temp_dict["username"] as! String)
                print (temp_dict["timeAgo"] as! String)
                print (temp_dict["numberoflikes"] as! String)
                print (temp_dict["caption"] as! String)
                print (temp_dict["offset"] as! TimeInterval)
                print (temp_dict["startoffset"] as! TimeInterval)
                print (temp_dict["audiolength"] as! Float)
                print (temp_dict["paused"] as! Bool)
                print (temp_dict["playing"] as! Bool)
                print (temp_dict["trackid"] as! String)
                print (temp_dict["helper_id"] as! String)
                print (temp_dict["videoid"] as! String)
                print (temp_dict["starttime"] as! Float)
                print (temp_dict["endtime"] as! Float)
                print (temp_dict["flag"] as! String)
                print (temp_dict["lyrictext"] as! String)
                print (temp_dict["songname"] as! String)
                print (temp_dict["sourceapp"] as! String)
                print (temp_dict["preview_url"] as! String)
                //print (temp_dict["original_track_length"] as! String)
                let post = Post(albumArtImage: (temp_dict["albumArtImage"] as! String) , sourceAppImage: (temp_dict["sourceAppImage"] as! String), typeImage: (temp_dict["typeImage"] as! String) , profileImage: (temp_dict["profileImage"] as! String) , username: (temp_dict["username"] as! String) ,timeAgo: (temp_dict["timeAgo"] as! String), numberoflikes: (temp_dict["numberoflikes"] as! String) ,caption: (temp_dict["caption"] as! String), offset: (temp_dict["offset"] as! TimeInterval), startoffset: (temp_dict["startoffset"] as! TimeInterval), audiolength: (temp_dict["audiolength"] as! Float), paused: (temp_dict["paused"] as! Bool), playing: (temp_dict["playing"] as! Bool), trackid: (temp_dict["trackid"] as! String), helper_id: (temp_dict["helper_id"] as! String), videoid: (temp_dict["videoid"] as! String), starttime: (temp_dict["starttime"] as! Float) , endtime: (temp_dict["endtime"] as! Float), flag: (temp_dict["flag"] as! String), lyrictext: (temp_dict["lyrictext"] as! String), songname: (temp_dict["songname"] as! String), sourceapp: (temp_dict["sourceapp"] as! String), preview_url: (temp_dict["preview_url"] as! String), albumArtUrl: (temp_dict["albumArtUrl"] as! String), original_track_length: 0)
                //print(post)

                posts[Int(absolute_index)!] = post
                //posts.append(post)
                print ("appending")
                //print (posts)


            }

            seal.fulfill(posts)
        })
//
            var post1 = Post(albumArtImage: "clapton" , sourceAppImage: "apple_logo", typeImage: "icons8-musical-notes-50" , profileImage: "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "20 mins ago"  , numberoflikes: "20 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0, audiolength: 30, paused: false, playing: false, trackid: "14268593", helper_id: "spotify:track:6zC0mpGYwbNTpk9SKwh08f", videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Wonderful Tonight", sourceapp: "apple", preview_url: "", albumArtUrl: "https://i.scdn.co/image/efe0ee0512fbaf28307158f871427ec6aec7181c", original_track_length: 219333)
//        let p1_struct = helper.apple_search (song_name: post1.songname, song_id: post1.trackid)
//        print (p1_struct)
//        let p1_found_struct = worker.get_this_song(target_catalog: "spotify", song_data: p1_struct)
//        post1.helper_id = p1_found_struct
        
        
            var post2 = Post(albumArtImage:"doesitfeellike" , sourceAppImage: "Spotify_cropped", typeImage:"icons8-musical-notes-50" , profileImage: "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "2 hours ago"  , numberoflikes: "28 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0,audiolength: 60, paused: false, playing: false, trackid: "spotify:track:3ZakaL0QEt5eeD3N7HbaN1", helper_id: "1311238254", videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Does it feel like falling", sourceapp: "spotify", preview_url: "", albumArtUrl: "https://i.scdn.co/image/13e4b7ca24993f21e80611fbacc7fcc5cdb7c00a", original_track_length: 234918)
//        let p2_struct = helper.spotify_search (song_name: post2.songname, song_id: post2.trackid)
//        let p2_found_struct = worker.get_this_song(target_catalog: "apple", song_data: p2_struct)
//        post2.helper_id = p2_found_struct
        
        var post3 = Post(albumArtImage: "IMG_4387" , sourceAppImage:  "apple_logo", typeImage: "icons8-musical-notes-50" , profileImage: "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "3 hours ago"  , numberoflikes: "10 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0,audiolength: 60, paused: false, playing: false, trackid: "312319419", helper_id: "spotify:track:2So1k5N6x7iomF1T44gGkb",videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Wonderwall", sourceapp: "apple", preview_url: "", albumArtUrl: "https://i.scdn.co/image/3c4581eabc924b41527625b849f40864f43a5c7d", original_track_length: 286493)
//        let p3_struct = helper.apple_search (song_name: post3.songname, song_id: post3.trackid)
//        let p3_found_struct = worker.get_this_song(target_catalog: "spotify", song_data: p3_struct)
//        post1.helper_id = p3_found_struct
        
        var post4 = Post(albumArtImage: "clapton", sourceAppImage:  "Youtube_cropped", typeImage: "video" , profileImage: "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "6 hours ago"  , numberoflikes: "13 likes" ,caption: "Caption...", offset: 0.0, startoffset: 0.0, audiolength: 60, paused: false, playing: false, trackid: "empty", helper_id: "default",videoid: "mQ055hHdxbE", starttime: 120, endtime: 180, flag: "video", lyrictext: "", songname: "John Mayer - New Light", sourceapp: "youtube", preview_url: "", albumArtUrl:  "https://i.ytimg.com/vi/mQ055hHdxbE/hqdefault.jpg", original_track_length: 229000)
        
        var post5 = Post(albumArtImage:  "inthearms" , sourceAppImage: "Spotify_cropped", typeImage: "icons8-musical-notes-50" , profileImage: "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "6 hours ago"  , numberoflikes: "13 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0,audiolength: 60, paused: false, playing: false, trackid: "spotify:track:48GBbQiTSlXX5i0cn3iIiJ", helper_id: "1204587476",videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "In the Arms of a Stranger", sourceapp: "spotify", preview_url: "", albumArtUrl: "https://i.scdn.co/image/37c5af43b274e8c7e0c98c63b602ef2174ae880d", original_track_length: 212626)
//        let p5_struct = helper.spotify_search (song_name: post5.songname, song_id: post5.trackid)
//        let p5_found_struct = worker.get_this_song(target_catalog: "apple", song_data: p5_struct)
//        post2.helper_id = p5_found_struct
        
        var post6 = Post(albumArtImage: "clapton" , sourceAppImage: "apple_logo", typeImage: "icons8-sheet-music-50" , profileImage:  "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "1 day ago"  , numberoflikes: "17 likes" ,caption: "Caption...", offset: 10.0,startoffset: 0.0, audiolength: 60, paused: false, playing: false, trackid: "1224353521", helper_id: "spotify:track:0Zrug5Ry3x6x60lohpEU0C",videoid: "empty", starttime: 0 , endtime: 0, flag: "lyric", lyrictext:
            """
            One last drink to wishful thinkin'\nAnd then another again\nThe bar is getting brighter\nAnd the walls are closin' in\n

            Journey on the jukebox singin'\nDon't let the believin' end\nThe one that you had eyes for\nHad their eyes for your best friend\n

            Nobody's gonna love you right\nNobody's gonna take you in tonight\nFinish out the bottle or step into the light\nAnd roll it on home\n

            Roll it on home\nRoll it on home\nTomorrow's another chance you won't go it alone\n
            
            If you roll it on home
            """, songname: "Roll it on home", sourceapp: "apple", preview_url: "", albumArtUrl: "https://i.scdn.co/image/dfa9264c5427a0dfcfdf99a6592d608b42420e84", original_track_length: 204160)
//        let p6_struct = helper.apple_search (song_name: post6.songname, song_id: post6.trackid)
//        let p6_found_struct = worker.get_this_song(target_catalog: "spotify", song_data: p6_struct)
//        post1.helper_id = p6_found_struct
        
        var post7 = Post(albumArtImage:  "queen2" , sourceAppImage:  "apple_logo", typeImage: "icons8-musical-notes-50" , profileImage:  "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "12 hours ago"  , numberoflikes: "22 likes" ,caption: "Caption...", offset: 10.0,startoffset: 0.0, audiolength: 60, paused: false, playing: false, trackid: "932648605", helper_id: "spotify:track:7hQJA50XrCWABAu5v6QZ4i",videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Dont stop me now", sourceapp: "apple", preview_url: "", albumArtUrl: "https://i.scdn.co/image/2e82bac8c64908ef1504e8391362c030b0fdad2e", original_track_length: 209391)
//        let p7_struct = helper.apple_search (song_name: post7.songname, song_id: post7.trackid)
//        let p7_found_struct = worker.get_this_song(target_catalog: "spotify", song_data: p7_struct)
//        post1.helper_id = p7_found_struct
        
        
        var post8 = Post(albumArtImage:  "misbehaving1" , sourceAppImage:  "Spotify_cropped", typeImage: "icons8-musical-notes-50" , profileImage:  "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "22 hours ago"  , numberoflikes: "15 likes" ,caption: "Caption...", offset: 10.0,startoffset: 0.0, audiolength: 60,paused: false, playing: false, trackid: "spotify:track:04EDShdWyBr2aJPqjFjKAQ", helper_id: "1282343124",videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Misbehaving", sourceapp: "spotify", preview_url: "", albumArtUrl: "https://i.scdn.co/image/191682b2b8e9bd9a140bdaa1db15e4126808cf72", original_track_length: 228855)
//        let p8_struct = helper.spotify_search (song_name: post8.songname, song_id: post8.trackid)
//        let p8_found_struct = worker.get_this_song(target_catalog: "apple", song_data: p8_struct)
//        post2.helper_id = p8_found_struct
        
        var post9 = Post(albumArtImage:  "clapton", sourceAppImage:  "Youtube_cropped", typeImage: "video" , profileImage:  "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "6 hours ago"  , numberoflikes: "13 likes" ,caption: "Caption...", offset: 0.0,startoffset: 0.0, audiolength: 110, paused: false, playing: false, trackid: "empty", helper_id: "default", videoid: "o1VvgO7RNXg", starttime: 210 , endtime: 320, flag: "video", lyrictext: "", songname: "Bewajah - Coke Studio", sourceapp: "youtube", preview_url: "", albumArtUrl: "https://i.ytimg.com/vi/o1VvgO7RNXg/hqdefault.jpg", original_track_length: 362000)
        
        var post10 = Post(albumArtImage:  "Screen Shot 2017-10-24 at 7.30.42 PM" , sourceAppImage:  "apple_logo", typeImage: "icons8-musical-notes-50" , profileImage:  "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "1 day ago"  , numberoflikes: "17 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0,audiolength: 40, paused: false, playing: false, trackid: "1224353520", helper_id: "spotify:track:5KsLlcmWDoHUoJFzRw14wD", videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Rosie", sourceapp: "apple", preview_url: "", albumArtUrl: "https://i.scdn.co/image/dfa9264c5427a0dfcfdf99a6592d608b42420e84", original_track_length: 242747)
//        let p10_struct = helper.apple_search (song_name: post10.songname, song_id: post10.trackid)
//        let p10_found_struct = worker.get_this_song(target_catalog: "spotify", song_data: p10_struct)
//        post1.helper_id = p10_found_struct
        
//        posts.append(post1)
//        posts.append(post2)
//        posts.append(post3)
//        posts.append(post4)
//        posts.append(post5)
//        posts.append(post6)
//        posts.append(post7)
//        posts.append(post8)
//        posts.append(post9)
//        posts.append(post10)
//
//        print ("after appending")
//        //print (posts)
//        seal.fulfill(posts)
        }
        
        
    }
    
    static func dict_posts () {
        
        
        print ("In dict_posts")
        var post_list: [Post]?
        var dict_array = [[String: Any]]()
        var post_dict = [String: Any]()
        
       
        self.fetchPosts().done { posts in
             post_list = posts
        
            
            for i in 0..<post_list!.count {
                
                post_dict.updateValue(post_list![i].albumArtImage, forKey: "albumArtImage")
                post_dict.updateValue(post_list![i].audiolength, forKey: "audiolength")
                post_dict.updateValue(post_list![i].caption, forKey: "caption")
                post_dict.updateValue(post_list![i].endtime, forKey: "endtime")
                post_dict.updateValue(post_list![i].flag, forKey: "flag")
                post_dict.updateValue(post_list![i].trackid, forKey: "trackid")
                post_dict.updateValue(post_list![i].helper_id, forKey: "helper_id")
                post_dict.updateValue(post_list![i].lyrictext, forKey: "lyrictext")
                post_dict.updateValue(post_list![i].numberoflikes, forKey: "numberoflikes")
                post_dict.updateValue(post_list![i].offset, forKey: "offset")
                post_dict.updateValue(post_list![i].paused, forKey: "paused")
                post_dict.updateValue(post_list![i].playing, forKey: "playing")
                post_dict.updateValue(post_list![i].preview_url, forKey: "preview_url")
                post_dict.updateValue(post_list![i].profileImage, forKey: "profileImage")
                post_dict.updateValue(post_list![i].songname, forKey: "songname")
                post_dict.updateValue(post_list![i].sourceapp, forKey: "sourceapp")
                post_dict.updateValue(post_list![i].sourceAppImage, forKey: "sourceAppImage")
                post_dict.updateValue(post_list![i].startoffset, forKey: "startoffset")
                post_dict.updateValue(post_list![i].starttime, forKey: "starttime")
                post_dict.updateValue(post_list![i].timeAgo, forKey: "timeAgo")
                post_dict.updateValue(post_list![i].typeImage, forKey: "typeImage")
                post_dict.updateValue(post_list![i].username, forKey: "username")
                post_dict.updateValue(post_list![i].videoid, forKey: "videoid")
                post_dict.updateValue(post_list![i].albumArtUrl, forKey: "albumArtUrl")
                post_dict.updateValue(post_list![i].original_track_length, forKey: "original_track_length")
                
                dict_array.append(post_dict)
                
                let ref = FIRDatabase.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
                
                let final_post = ["Post\(i)" : post_dict]
                
                ref.child("user_db").child("post_db").updateChildValues(final_post) { (err, ref) in
                    
                    if err != nil {
                        print ("ERROR saving post value")
                        print (err)
                        return
                    }
                    print ("saved post value to db")
                }
            }
            
        }
        
        
    }
    
    static func add_new_post_to_firebase (new_post: Post, new_post_number: Int) {
        
        var post_dict = [String: Any]()
        let ref = FIRDatabase.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        
        post_dict.updateValue(new_post.albumArtImage, forKey: "albumArtImage")
        post_dict.updateValue(new_post.audiolength, forKey: "audiolength")
        post_dict.updateValue(new_post.caption, forKey: "caption")
        post_dict.updateValue(new_post.endtime, forKey: "endtime")
        post_dict.updateValue(new_post.flag, forKey: "flag")
        post_dict.updateValue(new_post.trackid, forKey: "trackid")
        post_dict.updateValue(new_post.helper_id, forKey: "helper_id")
        post_dict.updateValue(new_post.lyrictext, forKey: "lyrictext")
        post_dict.updateValue(new_post.numberoflikes, forKey: "numberoflikes")
        post_dict.updateValue(new_post.offset, forKey: "offset")
        post_dict.updateValue(new_post.paused, forKey: "paused")
        post_dict.updateValue(new_post.playing, forKey: "playing")
        post_dict.updateValue(new_post.preview_url, forKey: "preview_url")
        post_dict.updateValue(new_post.profileImage, forKey: "profileImage")
        post_dict.updateValue(new_post.songname, forKey: "songname")
        post_dict.updateValue(new_post.sourceapp, forKey: "sourceapp")
        post_dict.updateValue(new_post.sourceAppImage, forKey: "sourceAppImage")
        post_dict.updateValue(new_post.startoffset, forKey: "startoffset")
        post_dict.updateValue(new_post.starttime, forKey: "starttime")
        post_dict.updateValue(new_post.timeAgo, forKey: "timeAgo")
        post_dict.updateValue(new_post.typeImage, forKey: "typeImage")
        post_dict.updateValue(new_post.username, forKey: "username")
        post_dict.updateValue(new_post.videoid, forKey: "videoid")
        post_dict.updateValue(new_post.albumArtUrl, forKey: "albumArtUrl")
        post_dict.updateValue(new_post.original_track_length, forKey: "original_track_length")
        
        let final_post = ["Post\(new_post_number)" : post_dict]
        
        ref.child("user_db").child("post_db").updateChildValues(final_post) { (err, ref) in
            
            if err != nil {
                print ("ERROR saving post value")
                print (err)
                return
            }
            print ("saved post value to db")
        }
        
        
        
    }
    
 
}
