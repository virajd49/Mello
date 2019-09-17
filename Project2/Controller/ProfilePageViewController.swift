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


//This global_yt_player is used for the benefit of OOM. This youtube player is instantiated and loaded when the Profile page loads, and when the OOM page is displayed we hand this off to the OOM VC's youtube player.
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
    global_yt_player?.contentMode = UIView.ContentMode.scaleAspectFill
    //self.view.addSubview(youtubeplayer!)
    global_yt_player?.backgroundColor = UIColor.white
    global_yt_player?.clipsToBounds = true
    //global_yt_player?.layer.cornerRadius = 10
    global_yt_player?.load(withVideoId: oom_post.videoid, playerVars: ["autoplay": 1
        , "playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 0, "start": oom_post.starttime, "end": oom_post.endtime, "rel": 0, "iv_load_policy": 3])
    print ("global youtube_player_setup done")
 
}


/*
 
 The user's profile page:
 
    -Collection view grid of all posted/pinned posts. If you tap on a post - it goes to ShowUpdateController to display the post
    -Button for Heroes view - tap on it and we go to HeroesViewController
    -Button for OMM section - tap on it and we go to PostViewController
 
 
 Other than that we also assist the OMM viewcontroller by grabbing the omm post from the database when this page loads, so if it is a youtube video
 we load it early using the global yt player
 
 Nothing too messy going on here.
 
 
 
 
 */

class ProfilePageViewController: UIViewController, UIGestureRecognizerDelegate , UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
   
    
    
    @IBOutlet weak var my_collection_view: UICollectionView!

    
  
    
    var tapGesture1 = UITapGestureRecognizer()
    var tapGesture2 = UITapGestureRecognizer()
    var tapGesture3 = UITapGestureRecognizer()
    var main_profile_image = UIImageView()
    var grab_oom = grab_and_store_oom.shared
    var oom_post: Post!
    var selected_post: Post!
    var posts: [Post]!
    var imageCacheManager = ImageCacheManager()
    
    @IBOutlet weak var test_view: UIView!
    
    override func viewDidLoad() {
        
        tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(present_oom_view(recognizer:)))
        tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(present_heroes_view(recognizer:)))
        self.my_collection_view.delegate = self
        self.my_collection_view.dataSource = self
        self.fetchPosts()
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        my_collection_view.addGestureRecognizer(tapGesture)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
         self.tabBarController?.tabBar.layer.zPosition = 0
        grab_oom.grab_oom().done { oom in
            print("grabbed oom post \n")
            self.oom_post = oom
            if self.oom_post.flag == "video" {
                global_yt_player_init(with: self.oom_post)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let posts = posts {  //because it is optional
            return posts.count   //number of sections = number of posts
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "my_content_cell", for: indexPath) as! my_content_cell
        
        
        cell.post = self.posts?.reversed()[indexPath[1]]
        
        return cell
    }
    
    func fetchPosts() {
        Post.fetch_profile_posts().done { posts in
            self.posts = posts
            self.my_collection_view.reloadData()
        }
        self.my_collection_view.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // 1
        switch kind {
        // 2
        case UICollectionView.elementKindSectionHeader:
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

        performSegue(withIdentifier: "to_oom", sender: self)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to_oom" {
            let destinationVC = segue.destination as! UINavigationController
            let postVC = destinationVC.children[0] as! PostViewController
            postVC.OOM_post = self.oom_post
            postVC.setup_media()
            if self.oom_post.flag == "video" {
                postVC.youtube_player_setup_from_global_player()
            }
        } else if segue.identifier == "to_hero" {
            
        } else if segue.identifier == "profile_to_show_update" {
            if let destination = segue.destination as? ShowUpdateController {
                print("prepare")
                
                if (self.selected_post != nil) {
                    
                    if self.selected_post.flag == "audio" {
                        print ("audio")
                        imageCacheManager.fetchImage(url: URL(string: self.selected_post.albumArtUrl)!, completion: { (image) in
                            destination.albumArt.image = image
                        })
                        destination.song_ID = self.selected_post.trackid
                        destination.player  = "Spotify"
                        destination.update_start = self.selected_post.starttime
                        destination.update_end = self.selected_post.endtime
                        destination.lyric_text = ""
                    } else if self.selected_post.flag == "video" {
                        print("video")
                        destination.song_ID = self.selected_post.videoid
                        destination.player  = "Youtube"
                        destination.update_start = self.selected_post.starttime
                        destination.update_end = self.selected_post.endtime
                        destination.lyric_text = ""
                    } else if self.selected_post.flag == "lyric" {
                        print("lyric")
                        destination.song_ID = self.selected_post.trackid
                        destination.player  = "Spotify"
                        destination.update_start = self.selected_post.starttime
                        destination.update_end = self.selected_post.endtime
                        destination.lyric_text = self.selected_post.lyrictext
                    } else {
                        return
                    }
                    
                    
                    if destination.player == "Youtube"{
                        destination.youtube_player_setup()
                    }else if destination.player == "Spotify"{
                        destination.Spotifyplayer.queueSpotifyURI(destination.song_ID, callback: { (error) in
                            if (error == nil) {
                                print("queued!")
                            }
                            
                        })
                    }else {
                        destination.apple_music_player.setQueue(with: [destination.song_ID])
                    }
                    
                }
                
                //destination.youtubeplayer?.load(withVideoId: "U_xI_vKkkmg" , playerVars: ["playsinline": 1, "showinfo": 0, "modestbranding" : 1, "controls": 1, "start": 26, "end": 84, "rel": 0])
            }
        }
    }
    
   
    
    @objc func present_heroes_view (recognizer: UITapGestureRecognizer) {
        print("preset_test_view")
        
        if let heroesVC = self.storyboard?.instantiateViewController(withIdentifier: "heroesviewcontroller") {
            self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: " BACK", style: .plain, target: nil, action: nil)
            //self.navigationController?.navigationItem.backBarButtonItem?.title = " "
            //self.navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.pushViewController(heroesVC, animated: true)
        }
        
        //performSegue(withIdentifier: "to_hero", sender: self)
        
    }
    
    
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        print ("tapedit here 1")
        if recognizer.state == UIGestureRecognizer.State.ended {
            print ("tap edit here 2")
            let tapLocation = recognizer.location(in: self.my_collection_view)
            if let tapIndexPath = self.my_collection_view.indexPathForItem(at: tapLocation) {
                print ("tap edit here 3")
                
                var post = Post(albumArtImage: "" , sourceAppImage: "", typeImage: "" , profileImage: "" , username: "" ,timeAgo: "", numberoflikes: "" ,caption:"", offset: 0.0, startoffset: 0.0, audiolength: 0.0, paused: false, playing: true, trackid: "", helper_id: "", videoid: "", starttime: 0.0 , endtime: 0.0, flag: "", lyrictext: "", songname: "", sourceapp: "", preview_url: "", albumArtUrl: "", original_track_length: 0, GIF_url: "")
                
                
                self.selected_post = self.posts.reversed()[tapIndexPath[1]]
                performSegue(withIdentifier: "profile_to_show_update", sender: self)
            }
        }
    }
    
    

    @IBAction func back_button(_ sender: Any) {
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseIn], animations: {
            self.test_view.backgroundColor = UIColor.clear

            self.view.layoutIfNeeded()
            
        }, completion : {
            (value: Bool) in
            
          
         
          
            
        })
        
        
    }
}
