//
//  ProfilePageViewController.swift
//  Project2
//
//  Created by virdeshp on 3/19/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer


//This global youtube player is used for the benefit of OOM. This youtube player is instantiated and loaded when the Profile page loads, and when the OOM page is displayed we hand this off to the OOM VC's youtube player.
    // global_yt_player_init - this is called when ProfilePageViewController appears
    // youtube_player_setup_from_global_player - this is called when we prepare for segue from Profile page to OOM - this hands off the player.
    //the player is then played from 4 different places -
    //                                                    - view will appear - everytime view appears - required
    //                                                    - youtube_player_setup_from_global_player - this is only triggered when we segue
    //                                                    - player did become ready - this is only triggered if player is loaded/reloaded

var global_yt_player: YTPlayerView!

func global_yt_player_init (with oom_post: Post) {
    print("global_yt_player_init called")
    global_yt_player = YTPlayerView.init(frame: CGRect(origin: CGPoint(x:0, y:109), size: CGSize(width: 375, height: 240)))
    //self.youtubeplayer?.delegate = self
    global_yt_player?.contentMode = UIViewContentMode.scaleAspectFill
    //self.view.addSubview(youtubeplayer!)
    global_yt_player?.backgroundColor = UIColor.white
    global_yt_player?.clipsToBounds = true
    //global_yt_player?.layer.cornerRadius = 10
    global_yt_player?.load(withVideoId: oom_post.videoid, playerVars: ["autoplay": 1
        , "playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 0, "start": oom_post.starttime, "end": oom_post.endtime, "rel": 0, "iv_load_policy": 3])
    print ("global youtube_player_setup done")
 
}

class ProfilePageViewController: UIViewController, UIGestureRecognizerDelegate , UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
   
    
    
    @IBOutlet weak var my_collection_view: UICollectionView!
    @IBOutlet weak var test_view_profile_image: UIImageView!
    
    @IBOutlet weak var profile_image_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var heroes_1: UIImageView!
    @IBOutlet weak var heroes_2: UIImageView!
    @IBOutlet weak var heroes_3: UIImageView!
    @IBOutlet weak var heroes_4: UIImageView!
    @IBOutlet weak var heroes_5: UIImageView!
    
    @IBOutlet weak var oom_album_art_container: UIView!
    @IBOutlet weak var oom_album_art: UIImageView!
    
    @IBOutlet weak var separation_bar_view: UIView!
    @IBOutlet weak var testimonial_view: UITextView!
    
    @IBOutlet weak var backButton: UIButton!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "my_content_cell", for: indexPath) as! my_content_cell
        
        return cell
    }
    
    var tapGesture1 = UITapGestureRecognizer()
    var tapGesture2 = UITapGestureRecognizer()
    var tapGesture3 = UITapGestureRecognizer()
    var main_profile_image = UIImageView()
    var grab_oom = grab_and_store_oom.shared
    var oom_post: Post!
    
    @IBOutlet weak var test_view: UIView!
    
    override func viewDidLoad() {
        
        self.test_view.isHidden = true
        tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(present_oom_view(recognizer:)))
        tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(hide_oom_view(recognizer:)))
        tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(present_heroes_view(recognizer:)))
        tapGesture2.delegate = self.test_view_profile_image as? UIGestureRecognizerDelegate
        self.test_view_profile_image.addGestureRecognizer(tapGesture2)
        self.my_collection_view.delegate = self
        self.my_collection_view.dataSource = self
        self.test_view_profile_image.layer.cornerRadius = 50
        self.test_view_profile_image.clipsToBounds = true
        self.heroes_1.layer.cornerRadius = 21
        self.heroes_2.layer.cornerRadius = 21
        self.heroes_3.layer.cornerRadius = 21
        self.heroes_4.layer.cornerRadius = 21
        self.heroes_5.layer.cornerRadius = 21
        self.heroes_1.isHidden = true
        self.heroes_2.isHidden = true
        self.heroes_3.isHidden = true
        self.heroes_4.isHidden = true
        self.heroes_5.isHidden = true
        self.heroes_1.alpha = 0
        self.heroes_2.alpha = 0
        self.heroes_3.alpha = 0
        self.heroes_4.alpha = 0
        self.heroes_5.alpha = 0
        self.backButton.alpha = 0
        self.separation_bar_view.alpha = 0
        self.testimonial_view.alpha = 0
        self.oom_album_art.isHidden = true
        self.backButton.isHidden = true
        self.oom_album_art_container.isHidden = true
        self.separation_bar_view.isHidden = true
        self.testimonial_view.isHidden = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
         self.tabBarController?.tabBar.layer.zPosition = 0
        grab_oom.grab_oom().done { oom in
            print("grabbed oom post \n")
            self.oom_post = oom
            global_yt_player_init(with: self.oom_post)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // 1
        switch kind {
        // 2
        case UICollectionElementKindSectionHeader:
            // 3
            guard
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "\(ProfilePageHeader.self)",
                    for: indexPath) as? ProfilePageHeader
                else {
                    fatalError("Invalid view type")
            }
            
            tapGesture1.delegate = headerView.oom_button as! UIGestureRecognizerDelegate
            headerView.oom_button.addGestureRecognizer(tapGesture1)
            
            tapGesture3.delegate = headerView.heroes_button as! UIGestureRecognizerDelegate
            headerView.heroes_button.addGestureRecognizer(tapGesture3)
            self.main_profile_image = headerView.profile_image
            self.main_profile_image.layer.cornerRadius = 50
            self.main_profile_image.clipsToBounds = true
            return headerView
        default:
            // 4
            assert(false, "Invalid element type")
        }
    }
    
    
    @objc func present_oom_view (recognizer: UITapGestureRecognizer) {
        print("preset_test_view")
//        if self.test_view.isHidden {
//            self.test_view.backgroundColor = UIColor.clear
//            self.oom_album_art_container.alpha = 0
//            self.oom_album_art.alpha = 0
//            self.backButton.alpha = 0
//            self.oom_album_art_container.isHidden = false
//            self.oom_album_art.isHidden = false
//            self.backButton.isHidden = false
//            self.test_view.isHidden = false
//            self.main_profile_image.isHidden = true
//        }
//        
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseIn], animations: {
//            self.test_view.backgroundColor = UIColor.white
//            self.oom_album_art_container.alpha = 1
//            self.oom_album_art.alpha = 1
//            self.backButton.alpha = 1
//            self.profile_image_top_constraint.constant = 500
//            self.view.layoutIfNeeded()
//        })
        
//        if let postVC = self.storyboard?.instantiateViewController(withIdentifier: "postviewcontroller") {
//            let navController = UINavigationController(rootViewController: postVC)
//            navController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//            self.present(navController, animated: true, completion: nil)
//        }
        
        performSegue(withIdentifier: "to_oom", sender: self)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to_oom" {
            let destinationVC = segue.destination as! UINavigationController
            let postVC = destinationVC.childViewControllers[0] as! PostViewController
            postVC.OOM_post = self.oom_post
            postVC.setup_media()
            postVC.youtube_player_setup_from_global_player()
        } else if segue.identifier == "to_hero" {
            
        }
    }
    
    @objc func hide_oom_view (recognizer: UITapGestureRecognizer) {
        print("preset_test_view")
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseIn], animations: {
            self.test_view.backgroundColor = UIColor.clear
            self.oom_album_art_container.alpha = 0
            self.oom_album_art.alpha = 0
            self.backButton.alpha = 0
            self.profile_image_top_constraint.constant = 47
            self.view.layoutIfNeeded()
            
        }, completion : {
            (value: Bool) in
            self.main_profile_image.isHidden = false
            self.test_view.isHidden = true
            self.oom_album_art_container.isHidden = true
            self.oom_album_art.isHidden = true
            self.backButton.isHidden = true
        })
 
    }
    
    @objc func present_heroes_view (recognizer: UITapGestureRecognizer) {
        print("preset_test_view")
//        if self.test_view.isHidden {
//            self.test_view.backgroundColor = UIColor.clear
//            self.heroes_1.isHidden = false
//            self.heroes_2.isHidden = false
//            self.heroes_3.isHidden = false
//            self.heroes_4.isHidden = false
//            self.heroes_5.isHidden = false
//            self.test_view.isHidden = false
//            self.backButton.isHidden = false
//            self.main_profile_image.isHidden = true
//        }
//        
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseIn], animations: {
//            self.test_view.backgroundColor = UIColor.white
//            self.profile_image_top_constraint.constant = 147
//            self.heroes_1.alpha = 1
//            self.heroes_2.alpha = 1
//            self.heroes_3.alpha = 1
//            self.heroes_4.alpha = 1
//            self.heroes_5.alpha = 1
//            self.backButton.alpha = 1
//            self.separation_bar_view.alpha = 1
//            self.testimonial_view.alpha = 1
//            self.separation_bar_view.isHidden = false
//            self.testimonial_view.isHidden = false
//            self.view.layoutIfNeeded()
//        })
        
        if let heroesVC = self.storyboard?.instantiateViewController(withIdentifier: "heroesviewcontroller") {
            self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: " BACK", style: .plain, target: nil, action: nil)
            //self.navigationController?.navigationItem.backBarButtonItem?.title = " "
            //self.navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.pushViewController(heroesVC, animated: true)
        }
        
        //performSegue(withIdentifier: "to_hero", sender: self)
        
    }
    

    @IBAction func back_button(_ sender: Any) {
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseIn], animations: {
            self.test_view.backgroundColor = UIColor.clear
            self.heroes_1.alpha = 0
            self.heroes_2.alpha = 0
            self.heroes_3.alpha = 0
            self.heroes_4.alpha = 0
            self.heroes_5.alpha = 0
            self.backButton.alpha = 0
            self.separation_bar_view.alpha = 0
            self.testimonial_view.alpha = 0
            self.profile_image_top_constraint.constant = 47
            
            
            //for oom view
            self.oom_album_art_container.alpha = 0
            self.oom_album_art.alpha = 0
            
            
            self.view.layoutIfNeeded()
            
        }, completion : {
            (value: Bool) in
            
            self.main_profile_image.isHidden = false
            self.test_view.isHidden = true
            self.oom_album_art_container.isHidden = true
            self.oom_album_art.isHidden = true
            self.heroes_1.isHidden = true
            self.heroes_2.isHidden = true
            self.heroes_3.isHidden = true
            self.heroes_4.isHidden = true
            self.heroes_5.isHidden = true
            self.backButton.isHidden = true
            self.separation_bar_view.isHidden = true
            self.testimonial_view.isHidden = true
            
        })
        
        
    }
}
