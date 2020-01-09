//
//  UploadViewController4.swift
//  Project2
//
//  Created by virdeshp on 6/30/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import PromiseKit
import Firebase


/*
 
 This controller is used to give the user options of where he/she wants to add the post:
 
    -Newsfeed
    -OMM
    -Hero
 
 And also:
 
    -Add location
    -Tag a friend
 
 There's nothing too complicated or messy going on in this one.
 
 */

class UploadViewController4: UIViewController {
    
    @IBOutlet weak var add_to_news_feed: UIButton!
    @IBOutlet weak var add_to_OMM: UIButton!
    @IBOutlet weak var add_location: UIButton!
    @IBOutlet weak var pin_to_profile: UIButton!
    @IBOutlet weak var tag_friends: UIButton!
    
    @IBOutlet weak var add_to_news_feed_checkbox: UIButton!
    @IBOutlet weak var add_to_OMM_checkbox: UIButton!
    @IBOutlet weak var pin_to_profile_checkbox: UIButton!
    
    @IBOutlet weak var add_to_hero_drop_down_box: UIButton!
    
    @IBOutlet weak var hero_list_view: UIView!
    @IBOutlet weak var hero_1_label_button: UIButton!
    @IBOutlet weak var hero_2_label_button: UIButton!
    @IBOutlet weak var hero_3_label_button: UIButton!
    @IBOutlet weak var hero_4_label_button: UIButton!
    @IBOutlet weak var hero_5_label_button: UIButton!
    
    var OMM_selected = false
    var pin_to_profile_selected = false
    var add_to_newsfeed_selected = false
    var add_to_hero_selected = false
    var hero_list_showing = false
    var selected_hero_name = ""
    
    let searchController = UISearchController(searchResultsController: nil)
    var selected_search_result_post: Post!
    var selected_search_result_song_db_struct = song_db_struct()
    var hero_name_list: [String]?
    var path_keeper = upload_path_keeper.shared
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let height: CGFloat = 50 //whatever height you want to add to the existing height
        let bounds = self.navigationController!.navigationBar.bounds
        print ("nav bar height is \(bounds.height)")
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
        
        
        
        searchController.searchBar.isHidden = true
        navigationItem.titleView = searchController.searchBar //the SearchBar here is redundant - only used so that the Navigation Bar stays at the correct height.
        print ("nav bar height is \(bounds.height)")
        
        
        self.hero_list_view.isHidden = true
        
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(done_button))
        
        list_hero_names()
    }
    
    @IBAction func pin_to_profile_action(_ sender: Any) {
        
    }
    
    //we check the box and set the news_feed selected flag to true
    @IBAction func add_to_newsfeed_action(_ sender: UIButton) {
        
        sender.setBackgroundImage(UIImage.init(named: "icons8-checked-checkbox-50"), for: .normal)
        add_to_newsfeed_selected = true
        
    }
    
    
    //If the user wants to add the post to a particular hero, we display all the heroes they have, so they can select one
    @IBAction func hero_drop_down(_ sender: Any) {
        
        if hero_list_showing {
            self.hero_list_view.isHidden = true
            self.add_to_hero_drop_down_box.setBackgroundImage(UIImage.init(named: "icons8-drop-down-50"), for: .normal)
        } else {
            
            if !self.hero_name_list!.isEmpty {
                self.hero_1_label_button.titleLabel?.text = hero_name_list?[0]
                self.hero_2_label_button.titleLabel?.text = hero_name_list?[1]
                self.hero_3_label_button.titleLabel?.text = hero_name_list?[2]
                self.hero_4_label_button.titleLabel?.text = hero_name_list?[3]
                self.hero_5_label_button.titleLabel?.text = hero_name_list?[4]
            }
            self.hero_list_view.isHidden = false
            self.add_to_hero_drop_down_box.setBackgroundImage(UIImage.init(named: "icons8-drop-down-checked-50"), for: .normal)
        }
    }
    
    //we check the box and set the OOM_selected selected flag to true
    @IBAction func add_to_OMM_action(_ sender: UIButton) {
        
        sender.setBackgroundImage(UIImage.init(named: "icons8-checked-checkbox-50"), for: .normal)
        OMM_selected = true
        
    }
    
    @IBAction func tag_friends_action(_ sender: Any) {
        //to be implemented
    }
    
    @IBAction func add_location_option(_ sender: Any) {
        //to be implemented
    }
    
    //we check the box and set the add_to_hero_selected flag to true and set the selected_hero_name
    @IBAction func hero_check_box(_ sender: UIButton) {
        
        sender.setBackgroundImage(UIImage.init(named: "icons8-checked-checkbox-50"), for: .normal)
        add_to_hero_selected = true
        selected_hero_name = hero_name_list?[sender.tag - 1] ?? ""

    }
    
    
    //Add it to local newsfeed and add it to the database newsfeed posts list
    func upload_to_newsfeed () {
        if let check_post = self.selected_search_result_post {
        if let presenter = self.presentingViewController as? myTabBarController {
            print("we got tabbar as presenter")
            if let newsfeed = presenter.viewControllers?[0].children[0] as? NewsFeedTableViewController {
                print ("we got newsfeed")
                print ("\(newsfeed.posts?.count)")
                let new_post_number = newsfeed.posts?.count
                self.add_new_post_to_firebase(new_post: self.selected_search_result_post, new_post_number: new_post_number!, destination_type: "newsfeed")
                newsfeed.fetchPosts()
            }
        }
        }
        
    }
    
    func upload_to_heroes () {
        //to be implemented
    }
    
    func upload_to_OMM () {
        self.add_new_post_to_firebase(new_post: self.selected_search_result_post, new_post_number: 0, destination_type: "oom")
    }
    
    func upload_to_profile () {
        //to be implemented
    }
    
    @objc func done_button (sender: UIBarButtonItem) {
        print("done_button")
        
        //Was trying to figure out some stuff about the controller stack here, retaining it in case needed in future
        /*
        if let presenter = self.presentingViewController as? myTabBarController {
            print ("presenter is myTabBarController")
        } else if let presenter = self.presentingViewController as? PostViewController {
            print ("presenter is PostViewController")
        } else if let presenter = self.presentingViewController as? ProfilePageViewController {
            print ("presenter is ProfilePageViewController")
        } else if let presenter = self.presentingViewController as? UINavigationController {
            print ("top_view_controller is UINavigationController")
        }
        
        
        if let top_view_controller = self.navigationController?.topViewController as? myTabBarController {
            print ("top_view_controller is myTabBarController")
        } else if let top_view_controller = self.navigationController?.topViewController as? PostViewController {
            print ("top_view_controller is PostViewController")
        } else if let top_view_controller = self.navigationController?.topViewController as? ProfilePageViewController {
            print ("top_view_controller is ProfilePageViewController")
        } else if let top_view_controller = self.navigationController?.topViewController as? UploadViewController {
            print ("top_view_controller is UploadViewController")
        } else if let top_view_controller = self.navigationController?.topViewController as? UploadViewController2 {
            print ("top_view_controller is UploadViewController2")
        } else if let top_view_controller = self.navigationController?.topViewController as? UINavigationController {
            print ("top_view_controller is UINavigationController")
            if let secondary_top_view_controller = top_view_controller.topViewController as? UINavigationController {
                print ("top_view_controller is UINavigationController")
            } else if let secondary_top_view_controller = top_view_controller.topViewController as? PostViewController {
                print ("top_view_controller is PostViewController")
            } else if let secondary_top_view_controller = top_view_controller.topViewController as? ProfilePageViewController {
                print ("top_view_controller is ProfilePageViewController")
            } else if let secondary_top_view_controller = top_view_controller.topViewController as? UploadViewController {
                print ("top_view_controller is UploadViewController")
            } else if let secondary_top_view_controller = top_view_controller.topViewController as? UploadViewController2 {
                print ("top_view_controller is UploadViewController2")
            } else if let secondary_top_view_controller = top_view_controller.topViewController as? myTabBarController {
                print ("top_view_controller is myTabBarController")
            }
            
            if let secondary_top_view_controller = top_view_controller.children[0] as? UINavigationController {
                print ("childViewControllers[0]  is UINavigationController")
            } else if let secondary_top_view_controller = top_view_controller.children[0]  as? PostViewController {
                print ("childViewControllers[0]  is PostViewController")
            } else if let secondary_top_view_controller = top_view_controller.children[0]  as? ProfilePageViewController {
                print ("childViewControllers[0]  is ProfilePageViewController")
            } else if let secondary_top_view_controller = top_view_controller.children[0]  as? UploadViewController {
                print ("childViewControllers[0]  is UploadViewController")
            } else if let secondary_top_view_controller = top_view_controller.children[0]  as? UploadViewController2 {
                print ("childViewControllers[0]  is UploadViewController2")
            } else if let secondary_top_view_controller = top_view_controller.children[0]  as? myTabBarController {
                print ("childViewControllers[0]  is myTabBarController")
            }
        }
 */
        
        //if add to newsfeed flag is set - upload it to newsfeed
        if add_to_newsfeed_selected {
            self.upload_to_newsfeed()
        }
        
        
        //if add to profile flag is set - upload it to profile
        if pin_to_profile_selected {
            //function to be implemented
        }
        
        //if add to hero flag is set - add to hero
        if add_to_hero_selected {
            //function to be implemented
        }
        
        
        //if add to omm flag is set - add to omm
        if OMM_selected {
            self.upload_to_OMM()
        }
        
        //then dismiss yourself
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func add_new_post_to_firebase (new_post: Post, new_post_number: Int, destination_type: String) {
        
        var post_dict = [String: Any]()
        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        
        post_dict.updateValue(new_post.albumArtImage, forKey: "albumArtImage")
        post_dict.updateValue(new_post.audiolength, forKey: "audiolength")
        post_dict.updateValue(new_post.caption, forKey: "caption")
        post_dict.updateValue(new_post.endtime, forKey: "endtime")
        post_dict.updateValue(new_post.flag, forKey: "flag")
        post_dict.updateValue(new_post.trackid, forKey: "trackid")
        post_dict.updateValue(new_post.helper_id, forKey: "helper_id")
        post_dict.updateValue(new_post.helper_preview_url, forKey: "helper_preview_url")
        post_dict.updateValue(new_post.lyrictext, forKey: "lyrictext")
        post_dict.updateValue(new_post.numberoflikes, forKey: "numberoflikes")
        post_dict.updateValue(new_post.offset, forKey: "offset")
        post_dict.updateValue(new_post.paused, forKey: "paused")
        post_dict.updateValue(new_post.playing, forKey: "playing")
        post_dict.updateValue(new_post.preview_url, forKey: "preview_url")
        post_dict.updateValue(new_post.profileImage, forKey: "profileImage")
        post_dict.updateValue(new_post.songname, forKey: "songname")
        post_dict.updateValue(new_post.sourceapp, forKey: "sourceapp")
        post_dict.updateValue(new_post.sourceAppImage, forKey: "sourceAppImage")
        post_dict.updateValue(new_post.startoffset, forKey: "startoffset")
        post_dict.updateValue(new_post.starttime, forKey: "starttime")
        post_dict.updateValue(new_post.timeAgo, forKey: "timeAgo")
        post_dict.updateValue(new_post.typeImage, forKey: "typeImage")
        post_dict.updateValue(new_post.username, forKey: "username")
        post_dict.updateValue(new_post.videoid, forKey: "videoid")
        post_dict.updateValue(new_post.albumArtUrl, forKey: "albumArtUrl")
        post_dict.updateValue(new_post.GIF_url, forKey: "GIF_url")
        
        let final_post = ["Post\(new_post_number)" : post_dict]
        
        
        //add the post to the right database depending on what the destination type is.
        switch destination_type {
            case "newsfeed":
                ref.child("user_db").child("post_db").updateChildValues(final_post) { (err, ref) in
                    
                    if err != nil {
                        print ("ERROR saving post value")
                        print (err)
                        return
                    }
                    print ("saved post value to db")
                }
                break
            case "profile":
                
                ref.child("user_db").child("profile_db").child("pinned_posts_db").updateChildValues(final_post) { (err, ref) in
                    
                    if err != nil {
                        print ("ERROR saving post value")
                        print (err)
                        return
                    }
                    print ("saved post value to db")
                }
                
                break
            case "oom":
                ref.child("user_db").child("profile_db").child("oom").updateChildValues(post_dict) { (err, ref) in
                    
                    if err != nil {
                        print ("ERROR saving post value")
                        print (err)
                        return
                    }
                    print ("saved post value to db")
                }
                break
            default:
                print("default case")
            
        }
       
        
    }
    
    //We grab the list of heroes that user has in their profile, for if the user wants to add the post to any one of the heroes.
    func list_hero_names () {
        
        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        
        ref.child("user_db").child("profile_db").child("heroes_db").observeSingleEvent(of: .value, with: { snapshot in
            print (snapshot.childrenCount)
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let temp_dict = snap.value as! [String : Any]
                
                for name in temp_dict.keys {
                    self.hero_name_list?.append(name)
                }
            }
        })
    }
    
    
    //add the post to the selected hero in the database
    static func add_new_post_to_hero_firebase (hero: Hero, new_post: Post) {
        
        var hero_dict = [String: Any]()
        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        var index = ""
        var hero_content = [String:[String : Any]]()
        
        ref.child("user_db").child("profile_db").child("heroes_db").observeSingleEvent(of: .value, with: { snapshot in
            print (snapshot.childrenCount)
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                index = snap.key 
                let temp_dict = snap.value as! [String : Any]
                
                guard let artist_name = temp_dict["artistName"] as? String, artist_name == hero.artistName else {
                    continue
                }
                
                hero_content = temp_dict["contentList"] as! [String:[String : Any]]
                break
            }
            var post_dict = [String: Any]()
            
            post_dict.updateValue(new_post.albumArtImage, forKey: "albumArtImage")
            post_dict.updateValue(new_post.audiolength, forKey: "audiolength")
            post_dict.updateValue(new_post.caption, forKey: "caption")
            post_dict.updateValue(new_post.endtime, forKey: "endtime")
            post_dict.updateValue(new_post.flag, forKey: "flag")
            post_dict.updateValue(new_post.trackid, forKey: "trackid")
            post_dict.updateValue(new_post.helper_id, forKey: "helper_id")
            post_dict.updateValue(new_post.helper_preview_url, forKey: "helper_preview_url")
            post_dict.updateValue(new_post.lyrictext, forKey: "lyrictext")
            post_dict.updateValue(new_post.numberoflikes, forKey: "numberoflikes")
            post_dict.updateValue(new_post.offset, forKey: "offset")
            post_dict.updateValue(new_post.paused, forKey: "paused")
            post_dict.updateValue(new_post.playing, forKey: "playing")
            post_dict.updateValue(new_post.preview_url, forKey: "preview_url")
            post_dict.updateValue(new_post.profileImage, forKey: "profileImage")
            post_dict.updateValue(new_post.songname, forKey: "songname")
            post_dict.updateValue(new_post.sourceapp, forKey: "sourceapp")
            post_dict.updateValue(new_post.sourceAppImage, forKey: "sourceAppImage")
            post_dict.updateValue(new_post.startoffset, forKey: "startoffset")
            post_dict.updateValue(new_post.starttime, forKey: "starttime")
            post_dict.updateValue(new_post.timeAgo, forKey: "timeAgo")
            post_dict.updateValue(new_post.typeImage, forKey: "typeImage")
            post_dict.updateValue(new_post.username, forKey: "username")
            post_dict.updateValue(new_post.videoid, forKey: "videoid")
            post_dict.updateValue(new_post.albumArtUrl, forKey: "albumArtUrl")
            post_dict.updateValue(new_post.original_track_length, forKey: "original_track_length")
            post_dict.updateValue(new_post.GIF_url, forKey: "GIF_url")
            
            hero_content.updateValue(post_dict, forKey: "Post\(hero_content.count + 1)")
            
            ref.child("user_db").child("profile_db").child("hero_db").child("\(index)").child("contentList").updateChildValues(hero_content) { (err, ref) in
                if err != nil {
                    print ("ERROR saving hero value")
                    print (err)
                    return
                    
                }
                print ("saved hero value to db")
            }
        })
    }
    

}
