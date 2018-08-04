//
//  Post.swift
//  Project2
//
//  Created by virdeshp on 3/12/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit


struct Post {
    
    var albumArtImage : UIImage?
    var sourceAppImage : UIImage?
    var typeImage : UIImage?
    var profileImage: UIImage?
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
    var videoid: String!
    var starttime: Float!
    var endtime: Float!
    var flag: String!  //can be audio, video or lyric
    var lyrictext: String!
    var songname: String!
    var sourceapp: String!
    
    static func fetchPosts() -> [Post] {
        
        var posts = [Post]()
        
        let post1 = Post(albumArtImage: UIImage(named: "clapton") , sourceAppImage: UIImage(named: "apple_logo"), typeImage:UIImage(named: "icons8-musical-notes-50") , profileImage: UIImage(named: "FullSizeRender 10-2") , username: "Viraj" ,timeAgo: "20 mins ago"  , numberoflikes: "20 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0, audiolength: 30, paused: false, playing: false, trackid: "14268593", videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Wonderful tonight", sourceapp: "apple")
        
        let post2 = Post(albumArtImage: UIImage(named: "doesitfeellike") , sourceAppImage: UIImage(named: "Spotify_cropped"), typeImage:UIImage(named: "icons8-musical-notes-50") , profileImage: UIImage(named: "FullSizeRender 10-2") , username: "Viraj" ,timeAgo: "2 hours ago"  , numberoflikes: "28 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0,audiolength: 60, paused: false, playing: false, trackid: "spotify:track:3ZakaL0QEt5eeD3N7HbaN1", videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Does it feel like falling", sourceapp: "spotify")
        
        let post3 = Post(albumArtImage: UIImage(named: "IMG_4387") , sourceAppImage: UIImage(named: "apple_logo"), typeImage:UIImage(named: "icons8-musical-notes-50") , profileImage: UIImage(named: "FullSizeRender 10-2") , username: "Viraj" ,timeAgo: "3 hours ago"  , numberoflikes: "10 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0,audiolength: 60, paused: false, playing: false, trackid: "312319419",videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Wonderwall", sourceapp: "apple")
        
        let post4 = Post(albumArtImage: UIImage(named: "clapton"), sourceAppImage: UIImage(named: "Youtube_cropped"), typeImage:UIImage(named: "video") , profileImage: UIImage(named: "FullSizeRender 10-2") , username: "Viraj" ,timeAgo: "6 hours ago"  , numberoflikes: "13 likes" ,caption: "Caption...", offset: 0.0, startoffset: 0.0,audiolength: 58, paused: false, playing: false, trackid: "empty",videoid: "U_xI_vKkkmg", starttime: 26, endtime: 84, flag: "video", lyrictext: "", songname: "John Mayer - Live at the Masonic", sourceapp: "youtube")
        
        let post5 = Post(albumArtImage: UIImage(named: "inthearms") , sourceAppImage: UIImage(named: "Spotify_cropped"), typeImage:UIImage(named: "icons8-musical-notes-50") , profileImage: UIImage(named: "FullSizeRender 10-2") , username: "Viraj" ,timeAgo: "6 hours ago"  , numberoflikes: "13 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0,audiolength: 60, paused: false, playing: false, trackid: "spotify:track:48GBbQiTSlXX5i0cn3iIiJ",videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "In the Arms of a Stranger", sourceapp: "spotify")
        
        let post6 = Post(albumArtImage: nil , sourceAppImage: UIImage(named: "apple_logo"), typeImage:UIImage(named: "icons8-sheet-music-50") , profileImage: UIImage(named: "FullSizeRender 10-2") , username: "Viraj" ,timeAgo: "1 day ago"  , numberoflikes: "17 likes" ,caption: "Caption...", offset: 10.0,startoffset: 0.0, audiolength: 60, paused: false, playing: false, trackid: "1224353521",videoid: "empty", starttime: 0 , endtime: 0, flag: "lyric", lyrictext:
            """
            One last drink to wishful thinkin'\nAnd then another again\nThe bar is getting brighter\nAnd the walls are closin' in\n

            Journey on the jukebox singin'\nDon't let the believin' end\nThe one that you had eyes for\nHad their eyes for your best friend\n

            Nobody's gonna love you right\nNobody's gonna take you in tonight\nFinish out the bottle or step into the light\nAnd roll it on home\n

            Roll it on home\nRoll it on home\nTomorrow's another chance you won't go it alone\n
            
            If you roll it on home
            """, songname: "Roll it on home", sourceapp: "apple")
        
        let post7 = Post(albumArtImage: UIImage(named: "queen2") , sourceAppImage: UIImage(named: "apple_logo"), typeImage:UIImage(named: "icons8-musical-notes-50") , profileImage: UIImage(named: "FullSizeRender 10-2") , username: "Viraj" ,timeAgo: "12 hours ago"  , numberoflikes: "22 likes" ,caption: "Caption...", offset: 10.0,startoffset: 0.0, audiolength: 60, paused: false, playing: false, trackid: "932648605",videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Dont stop me now", sourceapp: "apple")
        
        let post8 = Post(albumArtImage: UIImage(named: "misbehaving1") , sourceAppImage: UIImage(named: "Spotify_cropped"), typeImage:UIImage(named: "icons8-musical-notes-50") , profileImage: UIImage(named: "FullSizeRender 10-2") , username: "Viraj" ,timeAgo: "22 hours ago"  , numberoflikes: "15 likes" ,caption: "Caption...", offset: 10.0,startoffset: 0.0, audiolength: 60,paused: false, playing: false, trackid: "spotify:track:04EDShdWyBr2aJPqjFjKAQ",videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Misbehaving", sourceapp: "spotify")
        
        let post9 = Post(albumArtImage: UIImage(named: "clapton"), sourceAppImage: UIImage(named: "Youtube_cropped"), typeImage:UIImage(named: "video") , profileImage: UIImage(named: "FullSizeRender 10-2") , username: "Viraj" ,timeAgo: "6 hours ago"  , numberoflikes: "13 likes" ,caption: "Caption...", offset: 0.0,startoffset: 0.0, audiolength: 110, paused: false, playing: false, trackid: "empty", videoid: "o1VvgO7RNXg", starttime: 210 , endtime: 320, flag: "video", lyrictext: "", songname: "Bewajah - Coke Studio", sourceapp: "youtube")
        
        let post10 = Post(albumArtImage: UIImage(named: "Screen Shot 2017-10-24 at 7.30.42 PM") , sourceAppImage: UIImage(named: "apple_logo"), typeImage:UIImage(named: "icons8-musical-notes-50") , profileImage: UIImage(named: "FullSizeRender 10-2") , username: "Viraj" ,timeAgo: "1 day ago"  , numberoflikes: "17 likes" ,caption: "Caption...", offset: 10.0, startoffset: 0.0,audiolength: 40, paused: false, playing: false, trackid: "1224353520",videoid: "empty", starttime: 0 , endtime: 0, flag: "audio", lyrictext: "", songname: "Rosie", sourceapp: "apple")
        
        posts.append(post1)
        posts.append(post2)
        posts.append(post3)
        posts.append(post4)
        posts.append(post5)
        posts.append(post6)
        posts.append(post7)
        posts.append(post8)
        posts.append(post9)
        posts.append(post10)

        return posts
        
        
        
        
        
    }
    
}
