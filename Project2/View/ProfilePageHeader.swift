//
//  ProfilePageHeader.swift
//  Project2
//
//  Created by virdeshp on 3/20/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation

/*
 
 ProfilePageViewController is a collection view and the top part of the page is the collection view header, that is defined here.
 
 */


class ProfilePageHeader: UICollectionReusableView {
    
  
  
    @IBOutlet weak var heroes_button: UIButton!
    @IBOutlet weak var oom_button: UIButton!
    @IBOutlet weak var profile_image: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        init_heroes_view()
        init_oom_view()
        self.profile_image.layer.cornerRadius = 50
        self.profile_image.clipsToBounds = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var heroes_view = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: UIApplication.shared.keyWindow?.frame.width ?? 50.0 , height: UIApplication.shared.keyWindow?.frame.height ?? 50.0))
    
    var oom_view = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: UIApplication.shared.keyWindow?.frame.width ?? 50.0 , height: UIApplication.shared.keyWindow?.frame.height ?? 50.0))
    
    func init_heroes_view () {
        
        self.heroes_view.backgroundColor = UIColor.red
        
    }
    
    func init_oom_view() {
        
        self.oom_view.backgroundColor = UIColor.blue
        
    }
   
    
    
   
}
