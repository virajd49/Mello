//
//  MessageViewController.swift
//  Project2
//
//  Created by virdeshp on 5/7/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation
import UIKit

class MessageViewController: UIViewController, YTPlayerViewDelegate {
    
    let bottomView = BottomView()
    var youtube: YTPlayerView!
    var mini_youtube: YTPlayerView!
    let alertController = UIAlertController(title: nil, message: "Takes the appearance of the bottom bar if specified; otherwise, same as UIActionSheetStyleDefault.", preferredStyle: .actionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        // ...
    }
    
    let OKAction = UIAlertAction(title: "OK", style: .default) { action in
        // ...
    }
    
    let destroyAction = UIAlertAction(title: "Destroy", style: .destructive) { action in
        print (action)
    }
    
    @IBAction func switch_players(_ sender: Any) {
        
        let time: Float = youtube.currentTime() + 2.00
        print (time)
        mini_youtube.cueVideo(byId: "_N2xvUhqPEA", startSeconds: time, endSeconds: 120, suggestedQuality: YTPlaybackQuality.default)
        //mini_youtube.load(withVideoId: "_N2xvUhqPEA" , playerVars: ["playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 0, "controls": 1, "start": time, "end": 120, "rel": 0])
        mini_youtube.playVideo()
        
    }
    
    
    @IBAction func alertbutton(_ sender: Any) {
        
        /*self.present(alertController, animated: true) {
            // ...
        }
        */
        //bottomView.bringupview(id: "")
        let time2: Float = mini_youtube.currentTime() + 2.00
        print (time2)
        youtube.cueVideo(byId: "_N2xvUhqPEA", startSeconds: time2, endSeconds: 120, suggestedQuality: YTPlaybackQuality.default)
        youtube.playVideo()
        
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        youtube = YTPlayerView.init(frame: CGRect(x: 67, y: 431, width: 240, height: 128))
        mini_youtube = YTPlayerView.init(frame: CGRect(x: 67, y: 260, width: 240, height: 128))
        self.view.addSubview(youtube!)
        self.view.addSubview(mini_youtube!)
        mini_youtube.backgroundColor = UIColor.black
        youtube.backgroundColor = UIColor.black
        youtube.delegate = self
        mini_youtube.delegate = self
        
        youtube.load(withVideoId: "_N2xvUhqPEA" , playerVars: ["playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 0, "controls": 1, "start": 20, "end": 120, "rel": 0])
        mini_youtube.load(withVideoId: "_N2xvUhqPEA" , playerVars: ["playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 0, "controls": 1, "start": 20, "end": 120, "rel": 0])
        
        youtube.currentTime()
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        alertController.addAction(destroyAction)
        
       
    }
    
    
}
