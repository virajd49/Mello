//
//  PostViewController.swift
//  Project2
//
//  Created by virdeshp on 6/9/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation



class PostViewController: UIViewController {
    
    
    @IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var album_art: UIImageView!
    @IBOutlet weak var visual_aid_container: UIView!
    
    
    override func viewDidLoad() {
        self.profile_image.layer.cornerRadius = 50
        self.profile_image.clipsToBounds = true
    }
    
    @IBAction func go_to_profile_page_button(_ sender: Any) {
        
        if let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "profileviewcontroller") {
            self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: " BACK", style: .plain, target: nil, action: nil)
            //self.navigationController?.navigationItem.backBarButtonItem?.title = " "
            //self.navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    
    
    
    
    
    
}
