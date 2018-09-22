//
//  SongPlayControlViewController.swift
//  Project2
//
//  Created by virdeshp on 8/22/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit

class SongPlayControlViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var songDuration: UILabel!
    @IBOutlet weak var play_bar: UIProgressView!
    var playbar_progress: Float!
    var timer : Timer!
    var song_name: String!
    
    // MARK: - Properties
    var currentSong: Post? {
        didSet {
            configureFields()
        }
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFields()
        self.timer = Timer.scheduledTimer(timeInterval: 0.00005, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
        self.play_bar.progress = playbar_progress
        
    }
    
    @objc func updateProgress() {
        // increase progress value
        //print("updating")
        self.play_bar.progress += 0.00005/(self.currentSong?.audiolength)!
        //self.progressBar.setProgress(0.01, animated: true)
        //self.progressBar.animate(duration: 10)
        
        // invalidate timer if progress reach to 1
        if self.play_bar.progress >= 1 {
            // invalidate timer
            print ("invalidate timer happened")
            self.timer?.invalidate()
            self.play_bar.progress = 0.0
        }
     }
}
// MARK: - Internal
extension SongPlayControlViewController {
    
    func configureFields() {
        guard songTitle != nil else {
            return
        }
        
        songTitle.text = song_name
        //songArtist.text = currentSong?.
        //songDuration.text = "Duration \(currentSong?.presentationTime ?? "")"
    }
}

/* MARK: - Song Extension
extension Song {
    
    var presentationTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        let date = Date(timeIntervalSince1970: duration)
        return formatter.string(from: date)
    }
}
*/
