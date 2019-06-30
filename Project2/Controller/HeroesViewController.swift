//
//  HeroesViewController.swift
//  Project2
//
//  Created by virdeshp on 6/9/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation



class HeroesViewController: UIViewController {
    
    
    @IBOutlet weak var profile_image_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var heroes_1: UIImageView!
    
    @IBOutlet weak var heroes_2: UIImageView!
    
    @IBOutlet weak var heroes_3: UIImageView!
    @IBOutlet weak var heroes_4: UIImageView!
    @IBOutlet weak var heroes_5: UIImageView!
    
    @IBOutlet weak var testimonial_text: UITextView!
    
    
    override func viewWillAppear(_ animated: Bool) {
//        self.heroes_1.alpha = 0
//        self.heroes_2.alpha = 0
//        self.heroes_3.alpha = 0
//        self.heroes_4.alpha = 0
//        self.heroes_5.alpha = 0
    }
    
    override func viewDidLoad() {
        //self.profile_image_top_constraint.constant = -228
        self.profile_image.layer.cornerRadius = 50
        self.profile_image.clipsToBounds = true
        self.heroes_1.layer.cornerRadius = 21
        self.heroes_2.layer.cornerRadius = 21
        self.heroes_3.layer.cornerRadius = 21
        self.heroes_4.layer.cornerRadius = 21
        self.heroes_5.layer.cornerRadius = 21
//        self.heroes_1.alpha = 1
//        self.heroes_2.alpha = 1
//        self.heroes_3.alpha = 1
//        self.heroes_4.alpha = 1
//        self.heroes_5.alpha = 1
        
        UIView.animate(withDuration: 0.5, animations: {
            print("animating")
            self.profile_image_top_constraint.constant = -212
            self.heroes_1.alpha = 1
            self.heroes_2.alpha = 1
            self.heroes_3.alpha = 1
            self.heroes_4.alpha = 1
            self.heroes_5.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func got_to_profile_button(_ sender: Any) {
        

        if let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "profileviewcontroller") {
            self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: " BACK", style: .plain, target: nil, action: nil)
            //self.navigationController?.navigationItem.backBarButtonItem?.title = " "
            //self.navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    
    }
    
    
}
