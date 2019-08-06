//
//  grab_and_store_oom.swift
//  Project2
//
//  Created by virdeshp on 7/20/19.
//  Copyright © 2019 Viraj. All rights reserved.
//




import Foundation
import MediaPlayer
import PromiseKit

//For now used by ProfileVC to grab and store oom for quick initialization of PostVC (oom view)
class grab_and_store_oom {
    
    static let shared = grab_and_store_oom()
    var stored_oom: Post!
    
    
    func grab_oom () ->Promise<Post> {
         return Promise { seal in
            print("setup media")
            oom_post.fetch_oom_post().done { fetched_post in
                self.stored_oom = fetched_post
                seal.fulfill(self.stored_oom)
            }
        }
        
    }
    
    
    


}
