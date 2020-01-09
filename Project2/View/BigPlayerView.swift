//
//  BigPlayerView.swift
//  Project2
//
//  Created by virdeshp on 12/11/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation



class BigPlayerView: UIView {
    
     let PlayerView_CONTENT_XIB_NAME = "PlayerView"
    @IBOutlet weak var scroll_view: UIScrollView!
    @IBOutlet weak var scroll_content_view: UIView!
    @IBOutlet weak var player_stack_view: UIStackView!
    @IBOutlet weak var player_top_spacer: UIView!
    @IBOutlet weak var AlbumArt_stack_view_segment: UIView!
    @IBOutlet weak var player_mid_spacer: UIView!
    @IBOutlet weak var player_controls_stack_segment: UIView!
    @IBOutlet weak var player_controls_stack_view: UIStackView!
    @IBOutlet weak var player_controls_top_spacer: UIView!
    @IBOutlet weak var progress_bar_container: UIView!
    @IBOutlet weak var player_controls_mid_spacer_2: UIView!
    @IBOutlet weak var controls_container: UIView!
    @IBOutlet weak var player_controls_bottom_spacer: UIView!
    @IBOutlet weak var player_bottom_spacer: UIView!
    
    @IBOutlet weak var albumArtLeading: NSLayoutConstraint!
    @IBOutlet weak var albumArtTrailing: NSLayoutConstraint!
    @IBOutlet weak var albumArtTop: NSLayoutConstraint!
  
    @IBOutlet weak var albumArtContainerView: UIView!
    @IBOutlet weak var albumArtView: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var dismissChevron: UIButton!
    @IBOutlet weak var playingFromLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var timeCompleted: UILabel!
    @IBOutlet weak var timeLeft: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var previousSong: UIButton!
    @IBOutlet weak var nextSong: UIButton!
    @IBOutlet weak var loopButton: UIButton!
    @IBOutlet weak var separatorLineView: UIView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var getSongButton: UIButton!
    @IBOutlet weak var seePost: UIButton!
    var content_view_leadConstraint : NSLayoutConstraint?
    var content_view_trailConstraint : NSLayoutConstraint?
    var content_view_topConstraint : NSLayoutConstraint?
    var content_view_botConstraint : NSLayoutConstraint?
    var mainWindow = UIApplication.shared.keyWindow
    var loopOne = false
    var loopPlaylist = false
    
    override init(frame: CGRect) { //for using the view programmatically
        super.init(frame: frame)
        commonInit()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) { // used for view in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        print("commonInit ran ---------------------------------")
        Bundle.main.loadNibNamed(PlayerView_CONTENT_XIB_NAME, owner: self, options: nil)
        addSubview(contentView)
        
        contentView.frame = self.bounds
              contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.seePost.titleLabel?.textAlignment = .right
        self.seePost.titleLabel?.textRect(forBounds: self.seePost.bounds, limitedToNumberOfLines: 1)
        
        
        self.progressSlider.minimumTrackTintColor = .systemRed
        self.progressSlider.maximumTrackTintColor = .systemGray
        self.progressSlider.setThumbImage(UIImage(named: "icons8-filled-circle-16"), for: .normal)
        albumArtShadow()
        
    }
    
    func albumArtShadow () {
        print("albumArtShadow")
        albumArtContainerView.layer.cornerRadius = 10
        albumArtContainerView.clipsToBounds = false
        albumArtContainerView.layer.shadowColor = UIColor.black.cgColor
        albumArtContainerView.layer.shadowOpacity = 0.5
        albumArtContainerView.layer.shadowOffset = CGSize.zero
        albumArtContainerView.layer.shadowRadius = 10
        var width = (self.mainWindow?.frame.width)! - (2 * albumArtTrailing.constant)
        albumArtContainerView.layer.shadowPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: 0, y: 0) , size: CGSize(width: width, height: width)), cornerRadius: 10).cgPath
         albumArtView.clipsToBounds = true
         albumArtView.layer.cornerRadius = 10
        //albumArtContainerView.layoutIfNeeded()
         albumArtContainerView.autoresizesSubviews = true
        
    }
          
    
    @IBAction func loopButtonAction(_ sender: Any) {
        print("loopButtonAction")
        if self.loopButton.currentBackgroundImage == UIImage(named: "icons8-repeat-grey-90") {
            print("IF 1")
            self.loopButton.setBackgroundImage(UIImage(named: "icons8-repeat-90"), for: .normal)
            self.loopPlaylist = true
            self.loopOne = false
            
        } else if self.loopButton.currentBackgroundImage == UIImage(named: "icons8-repeat-90") {
            print("ELSE IF 1")
            self.loopButton.setBackgroundImage(UIImage(named: "icons8-repeat-one-90"), for: .normal)
            self.loopOne = true
            self.loopPlaylist = false
            
        } else if self.loopButton.currentBackgroundImage == UIImage(named: "icons8-repeat-one-90") {
            print("ELSE IF 2")
            self.loopButton.setBackgroundImage(UIImage(named: "icons8-repeat-grey-90"), for: .normal)
            self.loopOne = false
            self.loopPlaylist = false
            
        }
    }
    
    
    
    
    
    
}
