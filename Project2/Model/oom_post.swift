//
//  oom_post.swift
//  Project2
//
//  Created by virdeshp on 7/16/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import PromiseKit
import Firebase



struct oom_post {
    
    
    var the_post: Post!
    
  
    static func fetch_oom_post() -> Promise<Post> {
        return Promise { seal in
         
            
            var ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
            ref.child("user_db").child("profile_db").child("oom").observeSingleEvent(of: .value, with: { snapshot in
                
                let temp_dict = snapshot.value as! [String : Any]
                let temp_post = Post(albumArtImage: (temp_dict["albumArtImage"] as! String) , sourceAppImage: (temp_dict["sourceAppImage"] as! String), typeImage: (temp_dict["typeImage"] as! String) , profileImage: (temp_dict["profileImage"] as! String) , username: (temp_dict["username"] as! String) ,timeAgo: (temp_dict["timeAgo"] as! String), numberoflikes: (temp_dict["numberoflikes"] as! String) ,caption: (temp_dict["caption"] as! String), offset: (temp_dict["offset"] as! TimeInterval), startoffset: (temp_dict["startoffset"] as! TimeInterval), audiolength: (temp_dict["audiolength"] as! Float), paused: (temp_dict["paused"] as! Bool), playing: (temp_dict["playing"] as! Bool), trackid: (temp_dict["trackid"] as! String), helper_id: (temp_dict["helper_id"] as! String), videoid: (temp_dict["videoid"] as! String), starttime: (temp_dict["starttime"] as! Float) , endtime: (temp_dict["endtime"] as! Float), flag: (temp_dict["flag"] as! String), lyrictext: (temp_dict["lyrictext"] as! String), songname: (temp_dict["songname"] as! String), sourceapp: (temp_dict["sourceapp"] as! String), preview_url: (temp_dict["preview_url"] as! String), albumArtUrl: (temp_dict["albumArtUrl"] as! String), original_track_length: 0, GIF_url: (temp_dict["GIF_url"] as! String))
                
                seal.fulfill(temp_post)
                
            })
        }
        
        
    }
    
    
    //FIXME This is an internal deubuging method. When we make changes to the Post structure we clear the database and pull posts from hardcoded values written above. When we want to push the values abck to the database we call this function by calling the bring up miniplayer view function on the newsfeed
    static func dict_oom_post () {
        
      
        self.fetch_oom_post().done { OOM in
            
        }
    }
    
    static func add_new_oom_post_to_firebase (new_oom_post: Post) {
        
        var post_dict = [String: Any]()
        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        
        post_dict.updateValue(new_oom_post.albumArtImage, forKey: "albumArtImage")
        post_dict.updateValue(new_oom_post.audiolength, forKey: "audiolength")
        post_dict.updateValue(new_oom_post.caption, forKey: "caption")
        post_dict.updateValue(new_oom_post.endtime, forKey: "endtime")
        post_dict.updateValue(new_oom_post.flag, forKey: "flag")
        post_dict.updateValue(new_oom_post.trackid, forKey: "trackid")
        post_dict.updateValue(new_oom_post.helper_id, forKey: "helper_id")
        post_dict.updateValue(new_oom_post.lyrictext, forKey: "lyrictext")
        post_dict.updateValue(new_oom_post.numberoflikes, forKey: "numberoflikes")
        post_dict.updateValue(new_oom_post.offset, forKey: "offset")
        post_dict.updateValue(new_oom_post.paused, forKey: "paused")
        post_dict.updateValue(new_oom_post.playing, forKey: "playing")
        post_dict.updateValue(new_oom_post.preview_url, forKey: "preview_url")
        post_dict.updateValue(new_oom_post.profileImage, forKey: "profileImage")
        post_dict.updateValue(new_oom_post.songname, forKey: "songname")
        post_dict.updateValue(new_oom_post.sourceapp, forKey: "sourceapp")
        post_dict.updateValue(new_oom_post.sourceAppImage, forKey: "sourceAppImage")
        post_dict.updateValue(new_oom_post.startoffset, forKey: "startoffset")
        post_dict.updateValue(new_oom_post.starttime, forKey: "starttime")
        post_dict.updateValue(new_oom_post.timeAgo, forKey: "timeAgo")
        post_dict.updateValue(new_oom_post.typeImage, forKey: "typeImage")
        post_dict.updateValue(new_oom_post.username, forKey: "username")
        post_dict.updateValue(new_oom_post.videoid, forKey: "videoid")
        post_dict.updateValue(new_oom_post.albumArtUrl, forKey: "albumArtUrl")
        post_dict.updateValue(new_oom_post.GIF_url, forKey: "GIF_url")
        

        ref.child("user_db").child("profile_db").child("oom_db").updateChildValues(post_dict) { (err, ref) in
                
                if err != nil {
                    print ("ERROR saving post value")
                    print (err)
                    return
                }
                print ("saved post value to db")
        }
        
        
        
    }

    
}
