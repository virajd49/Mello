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
    
    static func fetch_update() -> [Update] {
        
        var updates = [Update]()
        
        
        let update1 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "Vincent - Don Mclean", post_type: UIImage(named: "icons8-musical-notes-50"), albumArt: "clapton", SongID: "spotify:track:3ZakaL0QEt5eeD3N7HbaN1", playerType: "Apple")
        let update2 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "Next to me - Imagine Dragons", post_type: UIImage(named: "video"), albumArt: "clapton", SongID: "spotify:track:3ZakaL0QEt5eeD3N7HbaN1", playerType: "Spotify")
        let update3 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "Down in Mexico - The Coasters", post_type: UIImage(named: "icons8-musical-notes-50"), albumArt: "clapton", SongID: "spotify:track:3ZakaL0QEt5eeD3N7HbaN1", playerType: "Apple")
        let update4 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "It's so easy, but I can't...", post_type: UIImage(named: "icons8-sheet-music-50"), albumArt: "clapton", SongID: "spotify:track:3ZakaL0QEt5eeD3N7HbaN1", playerType: "Apple")
        let update5 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "All you need is Love - The Beatles", post_type: UIImage(named: "icons8-musical-notes-50"), albumArt: "clapton", SongID: "spotify:track:3ZakaL0QEt5eeD3N7HbaN1", playerType: "Spotify")
        let update6 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "Let it be, let it be...", post_type: UIImage(named: "icons8-sheet-music-50"), albumArt: "clapton", SongID: "spotify:track:3ZakaL0QEt5eeD3N7HbaN1", playerType: "Apple")
        let update7 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "Weekend Luv - Quinn Lewis", post_type: UIImage(named: "icons8-musical-notes-50"), albumArt: "clapton", SongID: "spotify:track:3ZakaL0QEt5eeD3N7HbaN1", playerType: "Spotify")
        let update8 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "Another one bites the dust (Live Version)", post_type: UIImage(named: "video"), albumArt: "clapton", SongID: "spotify:track:3ZakaL0QEt5eeD3N7HbaN1", playerType: "Apple")
        let update9 = Update(profile_image: UIImage(named: "FullSizeRender 10-2"), song_name: "All out of Love - Air Supply", post_type: UIImage(named: "icons8-musical-notes-50"), albumArt: "clapton", SongID: "spotify:track:3ZakaL0QEt5eeD3N7HbaN1", playerType: "Spotify")
        
        
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
