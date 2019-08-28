//
//  my_content_cell.swift
//  Project2
//
//  Created by virdeshp on 7/13/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation





class my_content_cell: UICollectionViewCell {
    
    
    @IBOutlet weak var album_art_image: UIImageView!
    
    @IBOutlet weak var source_app_image: UIImageView!
    @IBOutlet weak var media_type_image: UIImageView!
    
    @IBOutlet weak var lyric_view: UITextView!
    
    var post: Post!{
        didSet {
            self.updateUI()
        }
    }
    
    func updateUI () {
        if self.post.flag != "lyric" {
            self.album_art_image.loadImageUsingCacheWithUrlString(imageurlstring: self.post.albumArtUrl)
            self.lyric_view.isHidden = true
        } else {
            self.lyric_view.text = self.post.lyrictext
            self.lyric_view.isScrollEnabled = false
            self.lyric_view.isEditable = false
            //self.bringSubviewToFront(lyric_view)
            self.album_art_image.alpha = 0
           // self.album_art_image.isHidden = true
        }
        self.source_app_image.image = UIImage(named: post.sourceAppImage!)
        self.media_type_image.image = UIImage(named: post.typeImage!)
    }
    
    
}
