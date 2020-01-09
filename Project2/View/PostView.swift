//
//  PostView.swift
//  Project2
//
//  Created by virdeshp on 12/17/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation



class PostView: UIView {
    
     let PostView_CONTENT_XIB_NAME = "PostView"
    
    @IBOutlet weak var Visual_container_view: UIView!
    @IBOutlet weak var username_label: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var wkwebviewContainer: UIView!
    @IBOutlet weak var gifView: UIImageView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var albumArtView: UIImageView!
    @IBOutlet weak var stack_content_view: UIStackView!
    @IBOutlet weak var albumArtContainerView: UIView!
    @IBOutlet weak var captionLabelView: UILabel!
    var label_is_expanded: Bool = false
    @IBOutlet weak var caption_label_height: NSLayoutConstraint!
    var caption_og_text: String = ""
    
    
    override init(frame: CGRect) { //for using the view programmatically
          super.init(frame: frame)
        commonInit(frame: frame)
          
          
      }
      
      required init?(coder aDecoder: NSCoder) { // used for view in IB
          super.init(coder: aDecoder)
          
      }
      
    func commonInit(frame: CGRect) {
          print("commonInit ran---------------------------------")
        Bundle.main.loadNibNamed(PostView_CONTENT_XIB_NAME, owner: self, options: nil)
        addSubview(stack_content_view)
        
        stack_content_view.frame = frame
        self.albumArtShadow()
          
      }
    
    
    func albumArtShadow () {
        print("albumArtShadow")
        albumArtContainerView.layer.cornerRadius = 10
        albumArtContainerView.clipsToBounds = false
        albumArtContainerView.layer.shadowColor = UIColor.black.cgColor
        albumArtContainerView.layer.shadowOpacity = 0.5
        albumArtContainerView.layer.shadowOffset = CGSize.zero
        albumArtContainerView.layer.shadowRadius = 10
        albumArtContainerView.layer.shadowPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: 0, y: 0) , size: CGSize(width: albumArtContainerView.frame.width, height: albumArtContainerView.frame.height)), cornerRadius: 10).cgPath
         albumArtView.clipsToBounds = true
         albumArtView.layer.cornerRadius = 10
    }
}
