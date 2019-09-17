//
//  my_content_lyric_cell.swift
//  Project2
//
//  Created by virdeshp on 7/13/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation

//Profile page

class my_content_lyric_cell: UITableViewCell {
    
    
    
    @IBOutlet weak var lyric_text_view: UITextView!
    @IBOutlet weak var lyric_view_2: UITextView!
    @IBOutlet weak var glass_pane: UIView! //just a transparent UIview that covers the entire cell because, if the view underneath are animating as per black_n_white_animation the cell doesnt respond to touch.
    
    
    func black_n_white_animation() {
        self.lyric_view_2.isUserInteractionEnabled = true
        self.lyric_text_view.isUserInteractionEnabled = true
        self.lyric_text_view.backgroundColor = UIColor(white: 1.0, alpha: 0)
        self.lyric_view_2.backgroundColor = UIColor.black
        self.lyric_text_view.alpha = 1
        print("black_n_white_animation")
        UIView.animate(withDuration: 1, delay: 0,  options: [.repeat, .autoreverse], animations: {
            self.lyric_text_view.alpha = 0
        }, completion: nil)
    }
    
    
    
    
}
