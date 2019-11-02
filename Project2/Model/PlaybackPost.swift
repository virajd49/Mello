//
//  PlaybackPost.swift
//  Project2
//
//  Created by virdeshp on 10/27/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation



struct PlaybackPost {
    var post: Post!
    var player: player_type!
    var trackid: String!
    var can_play_this_post: Bool = true
    var message_for_user: String! = ""
}
