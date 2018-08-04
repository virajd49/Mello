//
//  FriendUpdateCell.swift
//  Project2
//
//  Created by virdeshp on 6/30/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation
import UIKit

class FriendUpdateCell: UITableViewCell{
    
    
    @IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var song_name: UITextView!
    @IBOutlet weak var update_type: UIImageView!
    
    
    var update: Update! {
        didSet{
            self.updateUI()
        }
    }
    
    func updateUI() {
        
        self.profile_image.image = update.profile_image
        self.song_name.text = update.song_name
        self.update_type.image = update.post_type
        
        
    }
}
