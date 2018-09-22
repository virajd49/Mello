//
//  Update.swift
//  Project2
//
//  Created by virdeshp on 6/30/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation



struct Update {
    
    var profile_image: UIImage?
    var song_name: String?
    var post_type: UIImage?
    var albumArt: String?
    var SongID: String?
    var playerType: String?
    var start_time: Float?
    var end_time: Float?
    var lyric: String?
    
    static func fetch_update() -> [Update] {
        
        var updates = [Update]()
        
        
        let update1 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "Vincent - Don Mclean", post_type: UIImage(named: "icons8-musical-notes-50"), albumArt: "Starry_Night", SongID: "spotify:track:0VNzEY1G4GLqcNx5qaaTl6", playerType: "Spotify", start_time: 0, end_time: 0, lyric: "")
        let update2 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "Next to me - Imagine Dragons", post_type: UIImage(named: "video"), albumArt: "Imagine_dragons", SongID: "-C_rvt0SwLE", playerType: "Youtube", start_time: 26, end_time: 84, lyric: "")
        let update3 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "Down in Mexico - The Coasters", post_type: UIImage(named: "icons8-musical-notes-50"), albumArt: "Down_in_Mexico", SongID: "220149676", playerType: "Apple", start_time: 0.0, end_time: 0.0, lyric: "")
        let update4 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "It's so easy, but I can't...", post_type: UIImage(named: "icons8-sheet-music-50"), albumArt: "Queen_live", SongID: "1410128669", playerType: "Apple", start_time: 0.0, end_time: 0.0, lyric:
            """
            It's so easy, but I can't do it\n
            So risky, but I gotta chance it\n
            It's so funny, there's nothing to laugh about\n
            My money, that's all you want to talk about\n
            I can see what you want me to be\n
            But I'm no fool\n
            It's in the lap of the Gods\n
            """)
        let update5 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "All you need is Love - The Beatles", post_type: UIImage(named: "icons8-musical-notes-50"), albumArt: "Beatles", SongID: "spotify:track:6KqiVlOLfDzJViJVAPym1p", playerType: "Spotify", start_time: 0.0, end_time: 0.0, lyric: "")
        let update6 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "Let it be, let it be...", post_type: UIImage(named: "icons8-sheet-music-50"), albumArt: "Beatles", SongID: "401151904", playerType: "Apple", start_time: 0.0, end_time: 0.0, lyric:
            """
            And when the broken hearted people living in the world agree\n
            There will be an answer, let it be\n
            For though they may be parted, there is still a chance that they will see\n
            There will be an answer, let it be\n
            Let it be, let it be, let it be, let it be\n
            There will be an answer, let it be\n
            Let it be, let it be, let it be, let it be\n
            Whisper words of wisdom, let it be
            """)
        let update7 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "Weekend Luv - Quinn Lewis", post_type: UIImage(named: "icons8-musical-notes-50"), albumArt: "Weekend_Luv", SongID: "spotify:track:4cyU7rrxR7HzC3SVNaix59", playerType: "Spotify", start_time: 0.0, end_time: 0.0, lyric: "")
        let update8 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "Another one bites the dust (Live Version)", post_type: UIImage(named: "video"), albumArt: "Queen_live", SongID: "933294760", playerType: "Apple", start_time: 0.0, end_time: 0.0, lyric: "")
        let update9 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "All out of Love - Air Supply", post_type: UIImage(named: "icons8-musical-notes-50"), albumArt: "All_out_of_love", SongID: "spotify:track:7dQC53NiYOY9gKg3Qsu2Bs", playerType: "Spotify", start_time: 0.0, end_time: 0.0, lyric: "")
        
        
        updates.append(update1)
        updates.append(update2)
        updates.append(update3)
        updates.append(update4)
        updates.append(update5)
        updates.append(update6)
        updates.append(update7)
        updates.append(update8)
        updates.append(update9)
        
        return updates
        
    }
}
