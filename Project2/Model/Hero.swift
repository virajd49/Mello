//
//  Hero.swift
//  Project2
//
//  Created by virdeshp on 6/8/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import PromiseKit
import Firebase



struct Hero {
    
    var artistName: String?
    var imageURL: String?
    var testimonialText: String?
    var contentList: [String:Post]?

   static func fetchHeroes() -> Promise<[Hero]> {
        return Promise { seal in
            var heroes = [Hero]()
            var helper = Post_helper()
            var worker = ISRC_worker()
            var dummy_posts = [String:Post]()
            print ("fetchHeroes")
            var ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
            ref.child("user_db").child("profile_db").child("hero_db").observeSingleEvent(of: .value, with: { snapshot in
                print (snapshot.childrenCount)
                
                let dummy_post = Post(albumArtImage: "" , sourceAppImage: "", typeImage: "" , profileImage: "" , username: "" ,timeAgo: "", numberoflikes: "" ,caption:"", offset: 0.0, startoffset: 0.0, audiolength: 0.0, paused: false, playing: true, trackid: "", helper_id: "", videoid: "", starttime: 0.0 , endtime: 0.0, flag: "", lyrictext: "", songname: "", sourceapp: "", preview_url: "", albumArtUrl: "", original_track_length: 0, GIF_url: "")
                dummy_posts.updateValue(dummy_post, forKey: "Post1")
                
                let dummy_hero = Hero(artistName: "" , imageURL: "" ,  testimonialText: "", contentList: dummy_posts)
    
                //heroes = Array<Hero>(repeating: dummy_hero, count: Int(snapshot.childrenCount))
                //print(heroes)
                
                for child in snapshot.children {
                    print ("fetch heroes child in snapshot")
                    let snap = child as! DataSnapshot
                    print (snap.key)
                    print(snap.value)
                    let index = snap.key as! String
                    let absolute_index = index.replacingOccurrences(of: "Hero", with: "")
                    let temp_dict = snap.value as! [String : Any]
                    //print(temp_dict)
                    var post_dict = [String:Post]()
                    if temp_dict.keys.contains("contentList") {
                        let hero_content = temp_dict["contentList"] as! [String:[String : Any]]
                        
                        
                        
                        for i in 0..<hero_content.count {
                            print("for i in hero content count")
                            
                            print(hero_content["Post\(i + 1)"]?["flag"] as! String)
                            print("Post\(i + 1)")
                            let post = Post(albumArtImage: (hero_content["Post\(i + 1)"]?["albumArtImage"] as! String) ,
                                            sourceAppImage: (hero_content["Post\(i + 1)"]?["sourceAppImage"] as! String),
                                            typeImage: (hero_content["Post\(i + 1)"]?["typeImage"] as! String) ,
                                            profileImage: (hero_content["Post\(i + 1)"]?["profileImage"] as! String) ,
                                            username: (hero_content["Post\(i + 1)"]?["username"] as! String) ,
                                            timeAgo: (hero_content["Post\(i + 1)"]?["timeAgo"] as! String),
                                            numberoflikes: (hero_content["Post\(i + 1)"]?["numberoflikes"] as! String) ,
                                            caption: (hero_content["Post\(i + 1)"]?["caption"] as! String),
                                            offset: (hero_content["Post\(i + 1)"]?["offset"] as! TimeInterval),
                                            startoffset: (hero_content["Post\(i + 1)"]?["startoffset"] as! TimeInterval),
                                            audiolength: (hero_content["Post\(i + 1)"]?["audiolength"] as! Float),
                                            paused: (hero_content["Post\(i + 1)"]?["paused"] as! Bool),
                                            playing: (hero_content["Post\(i + 1)"]?["playing"] as! Bool),
                                            trackid: (hero_content["Post\(i + 1)"]?["trackid"] as! String),
                                            helper_id: (hero_content["Post\(i + 1)"]?["helper_id"] as! String),
                                            videoid: (hero_content["Post\(i + 1)"]?["videoid"] as! String),
                                            starttime: (hero_content["Post\(i + 1)"]?["starttime"] as! Float) ,
                                            endtime: (hero_content["Post\(i + 1)"]?["endtime"] as! Float),
                                            flag: (hero_content["Post\(i + 1)"]?["flag"] as! String),
                                            lyrictext: (hero_content["Post\(i + 1)"]?["lyrictext"] as! String),
                                            songname: (hero_content["Post\(i + 1)"]?["songname"] as! String),
                                            sourceapp: (hero_content["Post\(i + 1)"]?["sourceapp"] as! String),
                                            preview_url: (hero_content["Post\(i + 1)"]?["preview_url"] as! String),
                                            albumArtUrl: (hero_content["Post\(i + 1)"]?["albumArtUrl"] as! String),
                                            original_track_length: 0,
                                            GIF_url: (hero_content["Post\(i + 1)"]?["GIF_url"] as! String))
                            print(post.flag)
                            print(post.flag as! String)
                            post_dict.updateValue(post, forKey: "Post\(i + 1)")
                            
                        }
                    }
                    let hero = Hero(artistName: (temp_dict["artistName"] as? String) ?? "" , imageURL: (temp_dict["imageURL"] as? String) ?? "",  testimonialText: (temp_dict["testimonialText"] as? String) ?? "", contentList: post_dict)
                    
                    heroes.append(hero)
                }
                print(heroes)
                seal.fulfill(heroes)
                
            })
            
            var post1 = Post(albumArtImage: "clapton" , sourceAppImage: "apple_logo", typeImage: "icons8-musical-notes-50" , profileImage: "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "20 mins ago"  , numberoflikes: "20 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0, audiolength: 30, paused: false, playing: false, trackid: "14268593", helper_id: "spotify:track:6zC0mpGYwbNTpk9SKwh08f", videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Wonderful Tonight", sourceapp: "apple", preview_url: "", albumArtUrl: "https://i.scdn.co/image/efe0ee0512fbaf28307158f871427ec6aec7181c", original_track_length: 219333, GIF_url: "")
            
            var post2 = Post(albumArtImage:"doesitfeellike" , sourceAppImage: "Spotify_cropped", typeImage:"icons8-musical-notes-50" , profileImage: "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "2 hours ago"  , numberoflikes: "28 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0,audiolength: 60, paused: false, playing: false, trackid: "spotify:track:3ZakaL0QEt5eeD3N7HbaN1", helper_id: "1311238254", videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Does it feel like falling", sourceapp: "spotify", preview_url: "", albumArtUrl: "https://i.scdn.co/image/13e4b7ca24993f21e80611fbacc7fcc5cdb7c00a", original_track_length: 234918, GIF_url: "")
            
            var post3 = Post(albumArtImage: "IMG_4387" , sourceAppImage:  "apple_logo", typeImage: "icons8-musical-notes-50" , profileImage: "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "3 hours ago"  , numberoflikes: "10 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0,audiolength: 60, paused: false, playing: false, trackid: "312319419", helper_id: "spotify:track:2So1k5N6x7iomF1T44gGkb",videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Wonderwall", sourceapp: "apple", preview_url: "", albumArtUrl: "https://i.scdn.co/image/3c4581eabc924b41527625b849f40864f43a5c7d", original_track_length: 286493, GIF_url: "")
            
            var post4 = Post(albumArtImage: "clapton", sourceAppImage:  "Youtube_cropped", typeImage: "video" , profileImage: "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "6 hours ago"  , numberoflikes: "13 likes" ,caption: "Caption...", offset: 0.0, startoffset: 0.0, audiolength: 60, paused: false, playing: false, trackid: "empty", helper_id: "default",videoid: "mQ055hHdxbE", starttime: 120, endtime: 180, flag: "video", lyrictext: "", songname: "John Mayer - New Light", sourceapp: "youtube", preview_url: "", albumArtUrl:  "https://i.ytimg.com/vi/mQ055hHdxbE/hqdefault.jpg", original_track_length: 229000, GIF_url: "")
            
            var post5 = Post(albumArtImage:  "inthearms" , sourceAppImage: "Spotify_cropped", typeImage: "icons8-musical-notes-50" , profileImage: "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "6 hours ago"  , numberoflikes: "13 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0,audiolength: 60, paused: false, playing: false, trackid: "spotify:track:48GBbQiTSlXX5i0cn3iIiJ", helper_id: "1204587476",videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "In the Arms of a Stranger", sourceapp: "spotify", preview_url: "", albumArtUrl: "https://i.scdn.co/image/37c5af43b274e8c7e0c98c63b602ef2174ae880d", original_track_length: 212626, GIF_url: "")
            
            var post6 = Post(albumArtImage: "clapton" , sourceAppImage: "apple_logo", typeImage: "icons8-sheet-music-50" , profileImage:  "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "1 day ago"  , numberoflikes: "17 likes" ,caption: "Caption...", offset: 10.0,startoffset: 0.0, audiolength: 60, paused: false, playing: false, trackid: "1224353521", helper_id: "spotify:track:0Zrug5Ry3x6x60lohpEU0C",videoid: "empty", starttime: 0 , endtime: 0, flag: "lyric", lyrictext:
                """
                One last drink to wishful thinkin'\nAnd then another again\nThe bar is getting brighter\nAnd the walls are closin' in\n

                Journey on the jukebox singin'\nDon't let the believin' end\nThe one that you had eyes for\nHad their eyes for your best friend\n

                Nobody's gonna love you right\nNobody's gonna take you in tonight\nFinish out the bottle or step into the light\nAnd roll it on home\n

                Roll it on home\nRoll it on home\nTomorrow's another chance you won't go it alone\n
                
                If you roll it on home
                """, songname: "Roll it on home", sourceapp: "apple", preview_url: "", albumArtUrl: "https://i.scdn.co/image/dfa9264c5427a0dfcfdf99a6592d608b42420e84", original_track_length: 204160, GIF_url: "")
            
            var post7 = Post(albumArtImage:  "queen2" , sourceAppImage:  "apple_logo", typeImage: "icons8-musical-notes-50" , profileImage:  "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "12 hours ago"  , numberoflikes: "22 likes" ,caption: "Caption...", offset: 10.0,startoffset: 0.0, audiolength: 60, paused: false, playing: false, trackid: "932648605", helper_id: "spotify:track:7hQJA50XrCWABAu5v6QZ4i", videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Dont stop me now", sourceapp: "apple", preview_url: "", albumArtUrl: "https://i.scdn.co/image/2e82bac8c64908ef1504e8391362c030b0fdad2e", original_track_length: 209391, GIF_url: "")
            
            var post8 = Post(albumArtImage:  "misbehaving1" , sourceAppImage:  "Spotify_cropped", typeImage: "icons8-musical-notes-50" , profileImage:  "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "22 hours ago"  , numberoflikes: "15 likes" ,caption: "Caption...", offset: 10.0,startoffset: 0.0, audiolength: 60,paused: false, playing: false, trackid: "spotify:track:04EDShdWyBr2aJPqjFjKAQ", helper_id: "1282343124",videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Misbehaving", sourceapp: "spotify", preview_url: "", albumArtUrl: "https://i.scdn.co/image/191682b2b8e9bd9a140bdaa1db15e4126808cf72", original_track_length: 228855, GIF_url: "")
            
            var post9 = Post(albumArtImage:  "clapton", sourceAppImage:  "Youtube_cropped", typeImage: "video" , profileImage:  "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "6 hours ago"  , numberoflikes: "13 likes" ,caption: "Caption...", offset: 0.0, startoffset: 0.0, audiolength: 110, paused: false, playing: false, trackid: "empty", helper_id: "default", videoid: "o1VvgO7RNXg", starttime: 210 , endtime: 320, flag: "video", lyrictext: "", songname: "Bewajah - Coke Studio", sourceapp: "youtube", preview_url: "", albumArtUrl: "https://i.ytimg.com/vi/o1VvgO7RNXg/hqdefault.jpg", original_track_length: 362000, GIF_url: "")
            
            var post10 = Post(albumArtImage:  "Screen Shot 2017-10-24 at 7.30.42 PM" , sourceAppImage:  "apple_logo", typeImage: "icons8-musical-notes-50" , profileImage:  "FullSizeRender 10-2" , username: "Viraj" ,timeAgo: "1 day ago"  , numberoflikes: "17 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0,audiolength: 40, paused: false, playing: false, trackid: "1224353520", helper_id: "spotify:track:5KsLlcmWDoHUoJFzRw14wD", videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Rosie", sourceapp: "apple", preview_url: "", albumArtUrl: "https://i.scdn.co/image/dfa9264c5427a0dfcfdf99a6592d608b42420e84", original_track_length: 242747, GIF_url: "")
            
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
    
    
    //FIXME This is an internal deubuging method. When we make changes to the Post structure we clear the database and pull posts from hardcoded values written above. When we want to push the values abck to the database we call this function by calling the bring up miniplayer view function on the newsfeed
    static func dict_heroes () {
        
        print ("In dict_posts")
        var hero_list: [Hero]?
        var hero_dict_array = [[String: Any]]()
        var hero_dict = [String: Any]()
        
        self.fetchHeroes().done { heroes in
            hero_list = heroes
            
            for i in 0..<hero_list!.count {
                
                hero_dict.updateValue(hero_list![i].artistName, forKey: "artistName")
                hero_dict.updateValue(hero_list![i].imageURL, forKey: "imageURL")
                hero_dict.updateValue(hero_list![i].testimonialText, forKey: "testimonialText")
                
                var post_dict_array = [String:[String: Any]]()
                
                for j in 0..<hero_list![i].contentList!.count {
                    var post_dict = [String: Any]()
                    
                    
                    
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.albumArtImage, forKey: "albumArtImage")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.audiolength, forKey: "audiolength")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.caption, forKey: "caption")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.endtime, forKey: "endtime")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.flag, forKey: "flag")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.trackid, forKey: "trackid")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.helper_id, forKey: "helper_id")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.lyrictext, forKey: "lyrictext")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.numberoflikes, forKey: "numberoflikes")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.offset, forKey: "offset")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.paused, forKey: "paused")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.playing, forKey: "playing")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.preview_url, forKey: "preview_url")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.profileImage, forKey: "profileImage")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.songname, forKey: "songname")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.sourceapp, forKey: "sourceapp")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.sourceAppImage, forKey: "sourceAppImage")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.startoffset, forKey: "startoffset")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.starttime, forKey: "starttime")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.timeAgo, forKey: "timeAgo")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.typeImage, forKey: "typeImage")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.username, forKey: "username")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.videoid, forKey: "videoid")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.albumArtUrl, forKey: "albumArtUrl")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.original_track_length, forKey: "original_track_length")
                    post_dict.updateValue(hero_list![i].contentList?["Post\(j+1)"]?.GIF_url, forKey: "GIF_url")
                    
                    post_dict_array.updateValue(post_dict, forKey: "Post\(j+1)")
                }
               
                hero_dict.updateValue(post_dict_array, forKey: "contentList")
                hero_dict_array.append(hero_dict)
                
                let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
                
                let final_hero = ["Hero\(i)" : hero_dict]
                
                ref.child("user_db").child("profile_db").child("heroes_db").updateChildValues(final_hero) { (err, ref) in
                    
                    if err != nil {
                        print ("ERROR saving hero value")
                        print (err)
                        return
                    }
                    print ("saved hero value to db")
                }
            }
        }
    }
    
    static func add_new_hero_to_firebase (new_hero: Hero, new_hero_number: Int) {
        
        var hero_dict = [String: Any]()
        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        
        hero_dict.updateValue(new_hero.artistName, forKey: "artistName")
        hero_dict.updateValue(new_hero.imageURL, forKey: "imageURL")
        hero_dict.updateValue(new_hero.testimonialText, forKey: "testimonialText")
        
        var post_dict_array = [String:[String: Any]]()
        
        for j in 0..<new_hero.contentList!.count {
            
            var post_dict = [String: Any]()
            
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.albumArtImage, forKey: "albumArtImage")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.audiolength, forKey: "audiolength")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.caption, forKey: "caption")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.endtime, forKey: "endtime")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.flag, forKey: "flag")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.trackid, forKey: "trackid")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.helper_id, forKey: "helper_id")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.lyrictext, forKey: "lyrictext")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.numberoflikes, forKey: "numberoflikes")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.offset, forKey: "offset")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.paused, forKey: "paused")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.playing, forKey: "playing")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.preview_url, forKey: "preview_url")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.profileImage, forKey: "profileImage")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.songname, forKey: "songname")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.sourceapp, forKey: "sourceapp")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.sourceAppImage, forKey: "sourceAppImage")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.startoffset, forKey: "startoffset")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.starttime, forKey: "starttime")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.timeAgo, forKey: "timeAgo")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.typeImage, forKey: "typeImage")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.username, forKey: "username")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.videoid, forKey: "videoid")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.albumArtUrl, forKey: "albumArtUrl")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.original_track_length, forKey: "original_track_length")
            post_dict.updateValue(new_hero.contentList?["Post\(j+1)"]?.GIF_url, forKey: "GIF_url")
            
            post_dict_array.updateValue(post_dict, forKey: "Post\(j+1)")
        }
        
        hero_dict.updateValue(post_dict_array, forKey: "contentList")

        let final_post = ["Hero\(new_hero_number)" : hero_dict]
        ref.child("user_db").child("profile_db").child("hero_db").updateChildValues(final_post) { (err, ref) in
            if err != nil {
                print ("ERROR saving hero value")
                print (err)
                return
            }
            print ("saved hero value to db")
        }
    }
    
    
    static func add_new_post_to_hero_firebase (hero_key: String, hero: Hero, new_post: Post) {
        
        var hero_dict = [String: Any]()
        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        var index = ""
        
        var post_dict = [String: Any]()
        
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
        post_dict.updateValue(new_post.GIF_url, forKey: "GIF_url")
        
        
        let final_post = ["Post\(hero.contentList!.count + 1)" : post_dict]
        
        ref.child("user_db").child("profile_db").child("hero_db").child(hero_key).child("contentList").updateChildValues(final_post) { (err, ref) in
            if err != nil {
                print ("ERROR saving hero post value")
                print (err)
                return
            }
            print ("saved hero value to db")
        }
        
    }
    
    static func add_new_testimonial_to_hero_firebase (hero_key: String, testimonial: String) {
        
        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        var index = ""
        
    
        ref.child("user_db").child("profile_db").child("hero_db").child(hero_key).child("caption").setValue(testimonial) { (err, ref) in
            if err != nil {
                print ("ERROR saving hero testimonial value")
                print (err)
                return
            }
            print ("saved hero value to db")
        }
        
    }
    
    
    static func remove_post_from_hero_firebase (hero_key: String, content_list: [String : Post]) {
        
        var hero_dict = [String: Any]()
        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        var index = ""
        
        var post_dict_array = [String:[String: Any]]()
        
        for j in 0..<content_list.count {
            
            var post_dict = [String: Any]()
            
            post_dict.updateValue(content_list["Post\(j+1)"]?.albumArtImage, forKey: "albumArtImage")
            post_dict.updateValue(content_list["Post\(j+1)"]?.audiolength, forKey: "audiolength")
            post_dict.updateValue(content_list["Post\(j+1)"]?.caption, forKey: "caption")
            post_dict.updateValue(content_list["Post\(j+1)"]?.endtime, forKey: "endtime")
            post_dict.updateValue(content_list["Post\(j+1)"]?.flag, forKey: "flag")
            post_dict.updateValue(content_list["Post\(j+1)"]?.trackid, forKey: "trackid")
            post_dict.updateValue(content_list["Post\(j+1)"]?.helper_id, forKey: "helper_id")
            post_dict.updateValue(content_list["Post\(j+1)"]?.lyrictext, forKey: "lyrictext")
            post_dict.updateValue(content_list["Post\(j+1)"]?.numberoflikes, forKey: "numberoflikes")
            post_dict.updateValue(content_list["Post\(j+1)"]?.offset, forKey: "offset")
            post_dict.updateValue(content_list["Post\(j+1)"]?.paused, forKey: "paused")
            post_dict.updateValue(content_list["Post\(j+1)"]?.playing, forKey: "playing")
            post_dict.updateValue(content_list["Post\(j+1)"]?.preview_url, forKey: "preview_url")
            post_dict.updateValue(content_list["Post\(j+1)"]?.profileImage, forKey: "profileImage")
            post_dict.updateValue(content_list["Post\(j+1)"]?.songname, forKey: "songname")
            post_dict.updateValue(content_list["Post\(j+1)"]?.sourceapp, forKey: "sourceapp")
            post_dict.updateValue(content_list["Post\(j+1)"]?.sourceAppImage, forKey: "sourceAppImage")
            post_dict.updateValue(content_list["Post\(j+1)"]?.startoffset, forKey: "startoffset")
            post_dict.updateValue(content_list["Post\(j+1)"]?.starttime, forKey: "starttime")
            post_dict.updateValue(content_list["Post\(j+1)"]?.timeAgo, forKey: "timeAgo")
            post_dict.updateValue(content_list["Post\(j+1)"]?.typeImage, forKey: "typeImage")
            post_dict.updateValue(content_list["Post\(j+1)"]?.username, forKey: "username")
            post_dict.updateValue(content_list["Post\(j+1)"]?.videoid, forKey: "videoid")
            post_dict.updateValue(content_list["Post\(j+1)"]?.albumArtUrl, forKey: "albumArtUrl")
            post_dict.updateValue(content_list["Post\(j+1)"]?.original_track_length, forKey: "original_track_length")
            post_dict.updateValue(content_list["Post\(j+1)"]?.GIF_url, forKey: "GIF_url")
            
            post_dict_array.updateValue(post_dict, forKey: "Post\(j+1)")
        }
        
        
        ref.child("user_db").child("profile_db").child("hero_db").child(hero_key).child("contentList").setValue(post_dict_array) { (err, ref) in
            if err != nil {
                print ("ERROR saving hero post value")
                print (err)
                return
            }
            print ("saved hero value to db")
        }
        
    }
 
    
}



