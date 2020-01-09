//
//  HeroesViewController.swift
//  Project2
//
//  Created by virdeshp on 6/9/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import Firebase
import PromiseKit
import MediaPlayer
import GoogleAPIClientForREST
import SwiftyGiphy
import UIKit
import AVFoundation
import FLAnimatedImage
import SDWebImage

/*
 
 This is the Heroes page that is accessible from the user's profile page. We display all the users top artists here:
 
    -Artist photo
    -Text testimonial
    -A list of content - audio, video, lyric, etc.
 
 At any point of time we are displaying all artist photos and a single artists testimonial and content list. When the user taps on an artist the testimonial and the content list sections change to display the selected artists testimonial and content.
 
 Long pressing on an artist will allow the user to edit/add an artist - and all the components for that artist:
 
    -We allow the user to search fro any artist from a search bar that's in this viewcontroller.
    -We allow them to enter the text testimonial from this viewcontroller.
    -To add a new content to the content list we take them through Uploadviewcontroller 2 and 3 and then back here.
 
 
 Long pressing on the testimonial will let them edit the testimonial for a particular artist:
 
 Long pressing on the content section will allow them to edit/add to the content section only.
 
 This one is a little cleaner coded than the others.
 
 
 */

class HeroesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SearchResultsProtocolDelegate  {
    
    @IBOutlet weak var super_container_view: UIView!
    @IBOutlet weak var upper_container_view: UIView!
    
    @IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var heroes_1: UIImageView!
    
    @IBOutlet weak var heroes_2: UIImageView!
    
    @IBOutlet weak var heroes_3: UIImageView!
    @IBOutlet weak var heroes_4: UIImageView!
    @IBOutlet weak var heroes_5: UIImageView!
    
    @IBOutlet weak var hero_add_content_button: UIButton!
    @IBOutlet weak var hero_name_label: UILabel!
    @IBOutlet weak var Hero_content_table: UITableView!
    @IBOutlet weak var done_editing: UIButton!
    @IBOutlet weak var cancel_editing: UIButton!
    @IBOutlet weak var delete_post: UIButton!
    
    let imageCacheManager = ImageCacheManager()
    var testimonial_leadConstraint : NSLayoutConstraint?
    var testimonial_trailConstraint : NSLayoutConstraint?
    var testimonial_topConstraint : NSLayoutConstraint?
    var testimonial_botConstraint : NSLayoutConstraint?
    var separator_botConstraint : NSLayoutConstraint?
    var selected_post: Post = Post(albumArtImage: "" , sourceAppImage: "", typeImage: "" , profileImage: "" , username: "" ,timeAgo: "", numberoflikes: "" ,caption:"", offset: 0.0, startoffset: 0.0, audiolength: 0.0, paused: false, playing: true, trackid: "", helper_id: "", helper_preview_url: "", videoid: "", starttime: 0.0 , endtime: 0.0, flag: "", lyrictext: "", songname: "", sourceapp: "", preview_url: "", albumArtUrl: "", original_track_length: 0, GIF_url: "")
    
    var heroes = [Hero]()
    var selected_hero_number = 1
    var upload_flag = ""  //artist / track / GIF
    var resultsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsController") as! SearchResultsController
    var searchController: UISearchController!
    let testimonial: UITextView = UITextView.init(frame: CGRect(x: 0, y: 0, width: 375, height: 75))
    var empty_table_image_view = UIImageView(frame: CGRect(x: 162.5, y: 225, width: 50, height: 50))
    var empty_table_message_view = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 375))
    var path_keeper = upload_path_keeper.shared
    var post_from_uploadVC: Post = Post(albumArtImage: "" , sourceAppImage: "", typeImage: "" , profileImage: "" , username: "" ,timeAgo: "", numberoflikes: "" ,caption:"", offset: 0.0, startoffset: 0.0, audiolength: 0.0, paused: false, playing: true, trackid: "", helper_id: "", helper_preview_url: "", videoid: "", starttime: 0.0 , endtime: 0.0, flag: "", lyrictext: "", songname: "", sourceapp: "", preview_url: "", albumArtUrl: "", original_track_length: 0, GIF_url: "")
    
    
    var edit_mode_is_on = false
    var editing_hero = false
    var editing_testimonial_only = false
    var editing_content_only = false
    
    //temp variables for edit mode - when the user is editing a hero or any section of a hero - we switch to edit mode and move the data into temporary variables - so as long as we are in edit mode - we use the data in the temp variables - once we are done editing - we swicth edit mode to off and then use data from the regular heroes array. We do this because what if the user switches to edit mode - makes a bunch of changes and then cancels all of them. We don't want to lose the original data. See UI_for_edit_mode()
    var temp_testimonial_text: String!
    var temp_artist_name: String!
    var temp_artist_image_url: String!
    var temp_content_array = [Post]()
    
    
    var selected_content_cell: Int!
    var app_mus_mgr = AppleMusicManager()
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewwillappear")
        //self.tabBarController?.tabBar.layer.zPosition = -1
        self.resultsController.delegate = self
        self.searchController.searchBar.delegate = self
        
        //this code is for when we instantiate UploadVC - select content and then come back - it triggers viewwillAppear
        if self.path_keeper.new_post_selected && self.edit_mode_is_on {
            post_from_uploadVC = self.path_keeper.grab_keeper_post()
                if self.editing_hero || self.editing_content_only {
                    self.temp_content_array.append(post_from_uploadVC)
                    self.Hero_content_table.reloadData()
                }
        } else {
            //this is regular path when we navigate to Heroes page
            setup_hero_UI(hero_number: 1)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      
    }
    
    override func viewDidLoad() {
        //self.profile_image_top_constraint.constant = -228
        //nav bar settings
        var back_button = UIButton(type: .custom)
        back_button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        back_button.translatesAutoresizingMaskIntoConstraints = false
        back_button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 5)
        back_button.setImage(UIImage(named: "icons8-back-30"), for: .normal)
        back_button.tintColor = UIColor.black
        back_button.setTitle("", for: .normal)
        back_button.setTitleColor(back_button.tintColor, for: .normal)
        back_button.addTarget(self, action: "backAction", for: .touchUpInside)
        back_button.layer.borderColor = UIColor.black.cgColor
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back_button)
        
        
        self.navigationController?.navigationBar.layer.borderColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        
        self.profile_image.layer.cornerRadius = 27.25
        self.profile_image.clipsToBounds = true
        self.heroes_1.layer.cornerRadius = 21
        self.heroes_1.layer.borderColor = UIColor.black.cgColor
        self.heroes_1.layer.borderWidth = 2.0
        self.heroes_2.layer.cornerRadius = 21
        self.heroes_2.layer.borderColor = UIColor.black.cgColor
        self.heroes_2.layer.borderWidth = 2.0
        self.heroes_3.layer.cornerRadius = 21
        self.heroes_3.layer.borderColor = UIColor.black.cgColor
        self.heroes_3.layer.borderWidth = 2.0
        self.heroes_4.layer.cornerRadius = 21
        self.heroes_4.layer.borderColor = UIColor.black.cgColor
        self.heroes_4.layer.borderWidth = 2.0
        self.heroes_5.layer.cornerRadius = 21
        self.heroes_5.layer.borderColor = UIColor.black.cgColor
        self.heroes_5.layer.borderWidth = 2.0
        
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(tapEdit1(recognizer:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(tapEdit2(recognizer:)))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(tapEdit3(recognizer:)))
        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(tapEdit4(recognizer:)))
        let tapGesture5 = UITapGestureRecognizer(target: self, action: #selector(tapEdit5(recognizer:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        
        self.heroes_1.addGestureRecognizer(tapGesture1)
        self.heroes_2.addGestureRecognizer(tapGesture2)
        self.heroes_3.addGestureRecognizer(tapGesture3)
        self.heroes_4.addGestureRecognizer(tapGesture4)
        self.heroes_5.addGestureRecognizer(tapGesture5)
        
        let longPressGesture1 = UILongPressGestureRecognizer(target: self, action: #selector(longPressEdit1(recognizer:)))
        let longPressGesture2 = UILongPressGestureRecognizer(target: self, action: #selector(longPressEdit2(recognizer:)))
        let longPressGesture3 = UILongPressGestureRecognizer(target: self, action: #selector(longPressEdit3(recognizer:)))
        let longPressGesture4 = UILongPressGestureRecognizer(target: self, action: #selector(longPressEdit4(recognizer:)))
        let longPressGesture5 = UILongPressGestureRecognizer(target: self, action: #selector(longPressEdit5(recognizer:)))
        let longPressGesture6 = UILongPressGestureRecognizer(target: self, action: #selector(longPressEdit6(recognizer:)))
        let longPressGesture7 = UILongPressGestureRecognizer(target: self, action: #selector(longPressEdit7(recognizer:)))
        
        self.heroes_1.addGestureRecognizer(longPressGesture1)
        self.heroes_2.addGestureRecognizer(longPressGesture2)
        self.heroes_3.addGestureRecognizer(longPressGesture3)
        self.heroes_4.addGestureRecognizer(longPressGesture4)
        self.heroes_5.addGestureRecognizer(longPressGesture5)
        
        self.testimonial.addGestureRecognizer(longPressGesture6)
        self.Hero_content_table.addGestureRecognizer(longPressGesture7)
        self.Hero_content_table.addGestureRecognizer(tapGesture)
        
        self.done_editing.isHidden = true
        self.cancel_editing.isHidden = true
        self.delete_post.isHidden = true
        self.hero_add_content_button.isHidden = true
        
        
        /*
 
         The testimonial view is the tableview header - this is where we set that up.
 
        */
        
        var view1: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 375, height: 103));
        testimonial.textContainerInset = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
        
        //this is just a grey separator line to separate the testimonial view from the content list.
        var separator_view = UIView(frame: CGRect(x: 15, y: 100, width: 345, height: 1))
        separator_view.backgroundColor = UIColor.lightGray
        view1.addSubview(testimonial);
        view1.addSubview(separator_view)
        
        let view1_widthConstraint = NSLayoutConstraint(item: view1, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 375)
        let testimonial_widthConstraint = NSLayoutConstraint(item: testimonial, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 375)
        let separator_heightConstraint = NSLayoutConstraint(item: separator_view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 1)
        NSLayoutConstraint.activate([view1_widthConstraint, testimonial_widthConstraint, separator_heightConstraint])
        
        view1.addConstraintWithFormat(format: "V:|-0-[v0]-10-[v1]-1-|", views: testimonial, separator_view)
        view1.addConstraintWithFormat(format: "H:|-15-[v0]-15-|", views: separator_view)
        view1.addConstraintWithFormat(format: "H:|-0-[v0]-0-|", views: testimonial)
        
        testimonial.sizeToFit()
        testimonial.isScrollEnabled = false
        testimonial.translatesAutoresizingMaskIntoConstraints = false
       
        view1.sizeToFit()
        view1.translatesAutoresizingMaskIntoConstraints = false
      
        
        self.Hero_content_table.tableHeaderView = view1;
        testimonial.text = "Add Testimonial..."
        testimonial.font = UIFont(name: testimonial.font!.fontName, size: 16)
        testimonial.layer.borderColor = UIColor.black.cgColor
        
        testimonial.isUserInteractionEnabled = true
        view1.isUserInteractionEnabled = true
        self.Hero_content_table.tableHeaderView?.isUserInteractionEnabled = true
        self.Hero_content_table.delegate = self
        self.Hero_content_table.dataSource = self
        
        /* Testimonial view setup done */
        
        var profile_pic_view = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        profile_pic_view.image = UIImage(named: "StringFullSizeRender 10-3")
        profile_pic_view.clipsToBounds = true
        profile_pic_view.contentMode = .scaleToFill
        var heroes_label_view = UILabel.init(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        var container_view = UIView.init(frame: CGRect(x: 0, y: 0, width: 130, height: 45))
        container_view.addSubview(profile_pic_view)
        //container_view.addSubview(heroes_label_view)
        self.navigationItem.titleView = heroes_label_view
        
        
        
        UIView.animate(withDuration: 0.5, animations: {
            print("animating")
            
            self.heroes_1.alpha = 1
            self.heroes_2.alpha = 0.4
            self.heroes_3.alpha = 0.4
            self.heroes_4.alpha = 0.4
            self.heroes_5.alpha = 0.4
            self.view.layoutIfNeeded()
        })
        

        if !self.heroes.isEmpty {
            setup_hero_UI(hero_number: 1)
        }
        
        
        //Hero_content_table.separatorStyle = .none
        
        
        
        //searchcontroller stuff
        searchController =  UISearchController(searchResultsController: self.resultsController)
        searchController.searchResultsUpdater = self.resultsController
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Artists"
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchController.searchBar.isHidden = true
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        resultsController.delegate = self
        
        self.fetch_heroes()
        
        
        //podcast test
        
        //self.app_mus_mgr.performSpotifyCatalogSearch_test_podcasts(with: "why'd you ")
        
    }
    
    @IBAction func hero_add_content_action(_ sender: Any) {
        self.edit_mode_is_on = true
        self.path_keeper.set_upload_path(as: "hero")
        performSegue(withIdentifier: "to_upload", sender: self)
    
    }
    
    //this button is only visible when editing_mode_is_on
    @IBAction func done_editing_action(_ sender: Any) {
        
        
        if self.editing_testimonial_only {
            
            //local Hero array update
            self.heroes[selected_hero_number - 1].testimonialText = self.temp_testimonial_text
            
            
            //DB update
            Hero.add_new_testimonial_to_hero_firebase(hero_key: "Hero\(self.selected_hero_number)", testimonial: self.temp_testimonial_text)
        } else if self.editing_content_only {
            
             //local Hero array update
            for i in 0..<self.temp_content_array.count {
                self.heroes[selected_hero_number - 1].contentList!.updateValue(self.temp_content_array[i], forKey: "Post\(i+1)")
            }
            
            //DB update
            //Hero.add_new_post_to_hero_firebase(hero_key: "Hero\(self.selected_hero_number)", hero: self.heroes[self.selected_hero_number - 1], new_post:)
            
            Hero.push_new_content_list_to_firebase(hero_key: "Hero\(self.selected_hero_number)", content_list:  self.heroes[selected_hero_number - 1].contentList!)
        } else if self.editing_hero {
            
             //local  Hero array update
            var temp_content_dict = [String : Post] ()
            var temp_hero = Hero()
            for i in 0..<self.temp_content_array.count {
                temp_content_dict.updateValue(self.temp_content_array[i], forKey: "Post\(i+1)")
                
            }
            temp_hero.artistName = self.temp_artist_name
            temp_hero.imageURL = self.temp_artist_image_url
            temp_hero.testimonialText = self.temp_testimonial_text
            temp_hero.contentList = temp_content_dict
            
            //local update
            self.heroes.append(temp_hero)
            
             //DB update
            Hero.add_new_hero_to_firebase(new_hero: temp_hero, new_hero_number: selected_hero_number)
        }
        
        self.temp_artist_image_url = ""
        self.temp_artist_name = ""
        self.temp_testimonial_text = ""
        self.temp_content_array.removeAll()
        self.touch_for_other_heroes_toggle(on: true)

        self.edit_mode_is_on = false
        self.editing_hero = false
        self.editing_content_only = false
        self.editing_testimonial_only = false
        //reset editing mode UI
        UI_for_edit_mode(is_on: false)
    }
    
    
    @IBAction func cancel_editing_action(_ sender: Any) {
        
       
        UI_for_edit_mode(is_on: false)
        //empty out all the temp variables
        self.temp_artist_image_url = ""
        self.temp_artist_name = ""
        self.temp_testimonial_text = ""
        self.temp_content_array.removeAll()
        //set all editing flags to false
        self.editing_hero = false
        self.edit_mode_is_on = false
        self.editing_content_only = false
        self.editing_testimonial_only = false
        //reload content to what it was before
        self.Hero_content_table.reloadData()
        self.setup_hero_UI(hero_number: self.selected_hero_number)
        self.touch_for_other_heroes_toggle(on: true)
        
        //reload hero image, hero name and hero testimonial to what it was before
    }
    
    
    @IBAction func delete_post_action(_ sender: Any) {
        print("delete_post_action - post value = Post\(self.selected_content_cell + 1)")
        self.heroes[self.selected_hero_number - 1].contentList!.removeValue(forKey: "Post\(self.selected_content_cell + 1)")
        self.temp_content_array.remove(at: self.selected_content_cell)
        self.Hero_content_table.reloadData()
        print("---------content_list----------")
        print(self.heroes[self.selected_hero_number - 1].contentList!)
        UI_for_edit_mode(is_on: true)
        
    }
    
    //Turn off user interaction for all hero images other than the selected one.
    func touch_for_other_heroes_toggle(on: Bool) {
        
        if self.selected_hero_number != 1 {
            self.heroes_1.isUserInteractionEnabled = on
        }
        
        if self.selected_hero_number != 2 {
            self.heroes_2.isUserInteractionEnabled = on
        }
        
        if self.selected_hero_number != 3 {
            self.heroes_3.isUserInteractionEnabled = on
        }
        
        if self.selected_hero_number != 4 {
            self.heroes_4.isUserInteractionEnabled = on
        }
        
        if self.selected_hero_number != 5 {
            self.heroes_5.isUserInteractionEnabled = on
        }
    }
    
    
    func get_type_of_search() -> String {
        return self.upload_flag
    }
    
    func end_search_controller() {
        self.searchController.setEditing(false, animated: true)
        self.searchController.isActive = false
        self.searchController.searchBar.isHidden = true
        if self.edit_mode_is_on {
            UI_for_edit_mode(is_on: true)
        }
    }
    
    func take_and_update_selected_apple_artist_info (with_this artist: ArtistMediaItem, name: String) {
    
        self.hero_name_label.text = name
        switch self.selected_hero_number {
        case 1:
            break
        case 2:
            break
        case 3:
            break
        case 4:
            break
        case 5:
            break
        default:
            break
            
        }
    }
    
    //should only be called when edit mode is on and changing hero - so no edit_mode_is_on checks
    func take_and_update_selected_spotify_artist_info (with_this artist: SpotifyArtistMediaObject.item, image: UIImage, name: String) {
        print("take_and_update_selected_spotify_artist_info \(name)")
        
        //temp variables to pass on to DB
        self.temp_artist_name = name
        self.temp_artist_image_url = artist.images![0].url
        
        //immediate UI updates
        self.hero_name_label.text = name
        switch self.selected_hero_number {
        case 1:
            self.heroes_1.image = image
            break
        case 2:
            self.heroes_2.image = image
            break
        case 3:
            self.heroes_3.image = image
            break
        case 4:
            self.heroes_4.image = image
            break
        case 5:
            self.heroes_5.image = image
            break
        default:
            break
            
        }
     
    }
    
    //testing - go to a user's profile from a tag.
    @IBAction func got_to_profile_button(_ sender: Any) {
        

        if let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "profileviewcontroller") {
            self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: " BACK", style: .plain, target: nil, action: nil)
            //self.navigationController?.navigationItem.backBarButtonItem?.title = " "
            //self.navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    
    }
    
    
    @objc func backAction () {
        if self.edit_mode_is_on {
            self.UI_for_edit_mode(is_on: false)
        }
        self.navigationController?.popViewController(animated: true)
    }

     //fetch all the hero data and store it in a struct
    func fetch_heroes () {
        print("fetch_heroes")
        Hero.fetchHeroes().done { heroes in
            self.heroes = heroes
            print("just fetched")
            print(self.heroes)
            self.setup_hero_UI(hero_number: 1)
            
            print("inner reload")
        }
        self.setup_hero_UI(hero_number: 1)
        print("outer reload")
    }
    
    
    //tap function for each hero  - this will reload the table view with the respective hero content
    
    @objc func tapEdit1(recognizer: UITapGestureRecognizer)  {
        print("tapEdit1")
        self.selected_hero_number = 1
        self.heroes_1.alpha = 1
        change_hero_alpha()
        
        //Update hero name and testimonial
        if self.selected_hero_number <= self.heroes.count {
            self.testimonial.text = self.heroes[selected_hero_number - 1].testimonialText ?? ""
            self.hero_name_label.text = self.heroes[selected_hero_number - 1].artistName ?? ""
        } else {
            self.testimonial.text =  ""
            self.hero_name_label.text = ""
        }
        self.Hero_content_table.reloadData()
        
    }
    
    @objc func tapEdit2(recognizer: UITapGestureRecognizer)  {
        print("tapEdit2")
        self.selected_hero_number = 2
        self.heroes_2.alpha = 1
        change_hero_alpha()
        
        //Update hero name and testimonial
        if self.selected_hero_number <= self.heroes.count {
            self.testimonial.text = self.heroes[selected_hero_number - 1].testimonialText ?? ""
            self.hero_name_label.text = self.heroes[selected_hero_number - 1].artistName ?? ""
        } else {
            self.testimonial.text =  ""
            self.hero_name_label.text = ""
        }
        self.Hero_content_table.reloadData()
    }
    
    @objc func tapEdit3(recognizer: UITapGestureRecognizer)  {
        print("tapEdit3")
        self.selected_hero_number = 3
        self.heroes_3.alpha = 1
        change_hero_alpha()
        
        //Update hero name and testimonial
        if self.selected_hero_number <= self.heroes.count {
            self.testimonial.text = self.heroes[selected_hero_number - 1].testimonialText ?? ""
            self.hero_name_label.text = self.heroes[selected_hero_number - 1].artistName ?? ""
        } else {
            self.testimonial.text =  ""
            self.hero_name_label.text = ""
        }
        self.Hero_content_table.reloadData()
    }
    
    @objc func tapEdit4(recognizer: UITapGestureRecognizer)  {
        print("tapEdit4")
        self.selected_hero_number = 4
        self.heroes_4.alpha = 1
        change_hero_alpha()
        
        //Update hero name and testimonial
        if self.selected_hero_number <= self.heroes.count {
            self.testimonial.text = self.heroes[selected_hero_number - 1].testimonialText ?? ""
            self.hero_name_label.text = self.heroes[selected_hero_number - 1].artistName ?? ""
        } else {
            self.testimonial.text =  ""
            self.hero_name_label.text = ""
        }
        self.Hero_content_table.reloadData()
    }
    
    @objc func tapEdit5(recognizer: UITapGestureRecognizer)  {
        print("tapEdit5")
        self.selected_hero_number = 5
        self.heroes_5.alpha = 1
        change_hero_alpha()
        
        //Update hero name and testimonial
        if self.selected_hero_number <= self.heroes.count {
            self.testimonial.text = self.heroes[selected_hero_number - 1].testimonialText ?? ""
            self.hero_name_label.text = self.heroes[selected_hero_number - 1].artistName ?? ""
        } else {
            self.testimonial.text =  ""
            self.hero_name_label.text = ""
        }
        self.Hero_content_table.reloadData()
    }
    
    @objc func tapEdit6(recognizer: UITapGestureRecognizer)  {
        print("tapEdit6")
        if let uploadVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadViewController2") {
            self.path_keeper.set_upload_path(as: "hero")
            self.navigationController?.navigationBar.layer.borderColor = UIColor.black.cgColor
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.pushViewController(uploadVC, animated: true)
        }
        
        
    }
    
    func change_hero_alpha () {
        
        if self.selected_hero_number != 1 {
            self.heroes_1.alpha = 0.4
        }
        
        if self.selected_hero_number != 2 {
            self.heroes_2.alpha = 0.4
        }
        
        if self.selected_hero_number != 3 {
            self.heroes_3.alpha = 0.4
        }
        
        if self.selected_hero_number != 4 {
            self.heroes_4.alpha = 0.4
        }
        
        if self.selected_hero_number != 5 {
            self.heroes_5.alpha = 0.4
        }
 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches began")
        if self.testimonial.isFirstResponder {
            self.testimonial.endEditing(true)
            if self.edit_mode_is_on {
                if self.editing_testimonial_only || self.editing_hero {
                    self.temp_testimonial_text = self.testimonial.text
                }
            }
        }
    }
    
    func set_up_search_controller() {
        self.searchController.searchBar.isHidden = false
        self.upload_flag = "artist"
        self.searchController.isActive = true
        //self.searchController.searchBar.becomeFirstResponder()
    }
    
    @objc func longPressEdit1(recognizer: UILongPressGestureRecognizer)  {
        print("longPressEdit1")
        self.selected_hero_number = 1
        self.heroes_1.alpha = 1
        self.empty_table_image_view.alpha = 1
        self.empty_table_image_view.isUserInteractionEnabled = true
        self.Hero_content_table.backgroundView?.isUserInteractionEnabled = true
        self.empty_table_message_view.isUserInteractionEnabled = true
        self.UI_for_edit_mode(is_on: true)
        self.set_up_search_controller()
        self.UI_for_edit_mode(is_on: true)
        
        //Update hero name and testimonial
        if self.selected_hero_number <= self.heroes.count {
            self.testimonial.text = self.heroes[selected_hero_number - 1].testimonialText ?? ""
            self.hero_name_label.text = self.heroes[selected_hero_number - 1].artistName ?? ""
        } else {
            self.testimonial.text =  ""
            self.hero_name_label.text = ""
        }
        self.Hero_content_table.reloadData()
        
        self.edit_mode_is_on = true
        self.editing_hero = true
        self.editing_content_only = false
        self.editing_testimonial_only = false
        self.touch_for_other_heroes_toggle(on: false)

        //set testimonial view to be editing
        
    }
    
    @objc func longPressEdit2(recognizer: UILongPressGestureRecognizer)  {
        self.selected_hero_number = 2
        self.heroes_2.alpha = 1
        self.empty_table_image_view.alpha = 1
        self.empty_table_image_view.isUserInteractionEnabled = true
        self.Hero_content_table.backgroundView?.isUserInteractionEnabled = true
        self.empty_table_message_view.isUserInteractionEnabled = true
        self.UI_for_edit_mode(is_on: true)
        self.set_up_search_controller()
        
        //Update hero name and testimonial
        if self.selected_hero_number <= self.heroes.count {
            self.testimonial.text = self.heroes[selected_hero_number - 1].testimonialText ?? ""
            self.hero_name_label.text = self.heroes[selected_hero_number - 1].artistName ?? ""
        } else {
            self.testimonial.text =  ""
            self.hero_name_label.text = ""
        }
        self.Hero_content_table.reloadData()
        
        self.edit_mode_is_on = true
        self.editing_hero = true
        self.editing_content_only = false
        self.editing_testimonial_only = false
        self.touch_for_other_heroes_toggle(on: false)
       print("longPressEdit2")
    }
    
    @objc func longPressEdit3(recognizer: UILongPressGestureRecognizer)  {
        self.selected_hero_number = 3
        self.heroes_3.alpha = 1
        self.empty_table_image_view.alpha = 1
        self.empty_table_image_view.isUserInteractionEnabled = true
        self.Hero_content_table.backgroundView?.isUserInteractionEnabled = true
        self.empty_table_message_view.isUserInteractionEnabled = true
        self.UI_for_edit_mode(is_on: true)
        self.set_up_search_controller()
        
        //Update hero name and testimonial
        if self.selected_hero_number <= self.heroes.count {
            self.testimonial.text = self.heroes[selected_hero_number - 1].testimonialText ?? ""
            self.hero_name_label.text = self.heroes[selected_hero_number - 1].artistName ?? ""
        } else {
            self.testimonial.text =  ""
            self.hero_name_label.text = ""
        }
        self.Hero_content_table.reloadData()
        self.edit_mode_is_on = true
        self.editing_hero = true
        self.editing_content_only = false
        self.editing_testimonial_only = false
        self.touch_for_other_heroes_toggle(on: false)
        print("longPressEdit3")
    }
    
    @objc func longPressEdit4(recognizer: UILongPressGestureRecognizer)  {
         self.selected_hero_number = 4
        self.heroes_4.alpha = 1
        self.empty_table_image_view.alpha = 1
        self.empty_table_image_view.isUserInteractionEnabled = true
        self.Hero_content_table.backgroundView?.isUserInteractionEnabled = true
        self.empty_table_message_view.isUserInteractionEnabled = true
        self.UI_for_edit_mode(is_on: true)
        self.set_up_search_controller()
        
        //Update hero name and testimonial
        if self.selected_hero_number <= self.heroes.count {
            self.testimonial.text = self.heroes[selected_hero_number - 1].testimonialText ?? ""
            self.hero_name_label.text = self.heroes[selected_hero_number - 1].artistName ?? ""
        } else {
            self.testimonial.text =  ""
            self.hero_name_label.text = ""
        }
        self.Hero_content_table.reloadData()
        self.edit_mode_is_on = true
        self.editing_hero = true
        self.editing_content_only = false
        self.editing_testimonial_only = false
        self.touch_for_other_heroes_toggle(on: false)
        print("longPressEdit4")
    }
    
    @objc func longPressEdit5(recognizer: UILongPressGestureRecognizer)  {
        self.selected_hero_number = 5
        self.heroes_5.alpha = 1
        self.empty_table_image_view.alpha = 1
        self.empty_table_image_view.isUserInteractionEnabled = true
        self.Hero_content_table.backgroundView?.isUserInteractionEnabled = true
        self.empty_table_message_view.isUserInteractionEnabled = true
        self.UI_for_edit_mode(is_on: true)
        self.set_up_search_controller()
        
        //Update hero name and testimonial
        if self.selected_hero_number <= self.heroes.count {
            self.testimonial.text = self.heroes[selected_hero_number - 1].testimonialText ?? ""
            self.hero_name_label.text = self.heroes[selected_hero_number - 1].artistName ?? ""
        } else {
            self.testimonial.text =  ""
            self.hero_name_label.text = ""
        }
        self.Hero_content_table.reloadData()
        self.edit_mode_is_on = true
        self.editing_hero = true
        self.editing_content_only = false
        self.editing_testimonial_only = false
        self.touch_for_other_heroes_toggle(on: false)
        print("longPressEdit5")
    }
    
    @objc func longPressEdit6(recognizer: UILongPressGestureRecognizer) {
        //for testimonial edit
        
        //if no heroes have been added OR if new hero is being added don't go to editing_testimonial_only mode
        if self.heroes.isEmpty || self.selected_hero_number > self.heroes.count {
            return
        }
        
        self.edit_mode_is_on = true
        self.editing_hero = false
        self.editing_content_only = false
        self.editing_testimonial_only = true
        self.UI_for_edit_mode(is_on: true)
        
    }
    
    @objc func longPressEdit7(recognizer: UILongPressGestureRecognizer)  {       //for content edit
        self.edit_mode_is_on = true
        self.editing_hero = false
        self.editing_content_only = true
        self.editing_testimonial_only = false
         UI_for_edit_mode(is_on: true)
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.Hero_content_table)
            if let tapIndexPath = self.Hero_content_table?.indexPathForRow(at: tapLocation) {
                
                self.selected_content_cell = tapIndexPath[1]
                print("\(self.selected_content_cell)")
                
                let flag = self.heroes[self.selected_hero_number - 1].contentList!["Post\(tapIndexPath[1] + 1)"]?.flag
                
                if flag == "lyric" {
                    let cell  = self.Hero_content_table.cellForRow(at: tapIndexPath) as? my_content_lyric_cell
                } else if flag == "video" {
                    let cell  = self.Hero_content_table.cellForRow(at: tapIndexPath) as? my_content_video_cell
                } else if flag == "audio" {
                    let cell  = self.Hero_content_table.cellForRow(at: tapIndexPath) as? my_content_audio_cell
                }
                
                
             }
        }
    }
    
    func UI_for_edit_mode(is_on: Bool) {
        if is_on {
           print("UI_for_edit_mode is on")
            self.done_editing.isHidden = false
            self.cancel_editing.isHidden = false
            self.delete_post.isHidden = false
            self.hero_add_content_button.isHidden = false
            change_hero_alpha()
            //profile picture
            self.profile_image.alpha = 0.3
            //background view
            //self.super_container_view.backgroundColor = UIColor.lightGray
            self.upper_container_view.backgroundColor = UIColor(white: 1, alpha: 0.2)
            //table view back ground view
            
            if !self.temp_content_array.isEmpty {
                self.temp_content_array.removeAll()
            }
            
            if self.heroes.count >= self.selected_hero_number {
                if !self.heroes[self.selected_hero_number - 1].contentList!.isEmpty {
                    for i in 1...self.heroes[self.selected_hero_number - 1].contentList!.count {
                        self.temp_content_array.append(self.heroes[self.selected_hero_number - 1].contentList!["Post\(i)"]!)
                    }
                }
            }
        } else {
            
            //Done editing button - hide this
            self.done_editing.isHidden = true
            self.cancel_editing.isHidden = true
            self.delete_post.isHidden = true
            self.hero_add_content_button.isHidden = true
            self.profile_image.alpha = 1
            //self.super_container_view.backgroundColor = UIColor.white
            self.upper_container_view.backgroundColor = UIColor.white
            
            if !self.temp_content_array.isEmpty {
                self.temp_content_array.removeAll()
            }
            
        }
    }
    
    //Loads artist photos into all the hero image views, and loads the content table and testimonial with the first hero data.
    func setup_hero_UI (hero_number: Int) {
        
        if !heroes.isEmpty {
            if hero_number > 0 {
                self.selected_hero_number = hero_number
                self.testimonial.text = self.heroes[hero_number - 1].testimonialText
                self.hero_name_label.text = self.heroes[hero_number - 1].artistName
                self.Hero_content_table.reloadData()
            }
            
            if self.heroes.count > 0 {
                self.heroes_1.loadImageUsingCacheWithUrlString(imageurlstring: self.heroes[0].imageURL!)
            }
            if self.heroes.count > 1 {
                self.heroes_2.loadImageUsingCacheWithUrlString(imageurlstring: self.heroes[1].imageURL!)
            }
            if self.heroes.count > 2 {
                self.heroes_3.loadImageUsingCacheWithUrlString(imageurlstring: self.heroes[2].imageURL!)
            }
            if self.heroes.count > 3 {
                self.heroes_4.loadImageUsingCacheWithUrlString(imageurlstring: self.heroes[3].imageURL!)
            }
            if self.heroes.count > 4 {
                self.heroes_5.loadImageUsingCacheWithUrlString(imageurlstring: self.heroes[4].imageURL!)
            }
        }
        
        
    }
    
    
    
    //:MARK Table view functions:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection")
        
        if self.edit_mode_is_on {
            if self.editing_hero || self.editing_content_only {
                return self.temp_content_array.count
            } else {
                return 0
            }
        } else {
            if !self.heroes.isEmpty && self.selected_hero_number <= self.heroes.count {
                print (!self.heroes.isEmpty)
                print (self.heroes[self.selected_hero_number - 1].contentList!.count)
                return self.heroes[self.selected_hero_number - 1].contentList!.count
            } else {
                print (self.heroes.isEmpty)
                return 0
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSections")
        
        if self.edit_mode_is_on {
            print("edit_mode_is_on")
            if self.editing_hero || self.editing_content_only {
                return self.temp_content_array.count
            } else {
                return 0
            }
        } else {
            if !self.heroes.isEmpty {
                print ("!self.heroes.isEmpty")
                return 1
            } else {
                print ("self.heroes.isEmpty")
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print ("cellForRowAt")
        print (self.selected_hero_number)
        
        print(indexPath)
        print(indexPath[0])
        print("Post\(indexPath[1] + 1)")
        print()
        var post = Post(albumArtImage: "" , sourceAppImage: "", typeImage: "" , profileImage: "" , username: "" ,timeAgo: "", numberoflikes: "" ,caption:"", offset: 0.0, startoffset: 0.0, audiolength: 0.0, paused: false, playing: true, trackid: "", helper_id: "", helper_preview_url: "", videoid: "", starttime: 0.0 , endtime: 0.0, flag: "", lyrictext: "", songname: "", sourceapp: "", preview_url: "", albumArtUrl: "", original_track_length: 0, GIF_url: "")
        
        if self.edit_mode_is_on {
            if self.editing_hero || self.editing_content_only {
                post = self.temp_content_array[indexPath[1]]
            }
        } else {
            post = (self.heroes[self.selected_hero_number - 1].contentList?["Post\(indexPath[1] + 1)"])!
        }
        
        print("post flag is \(post.flag)")
        if post.flag == "audio" {
            print("audio")
            let cell = tableView.dequeueReusableCell(withIdentifier: "audio_content_cell", for: indexPath) as! my_content_audio_cell
            cell.selectionStyle = .none
            print ("post!.albumArtUrl")
            print ("post?.songname")
            cell.album_art_image.loadImageUsingCacheWithUrlString(imageurlstring: post.albumArtUrl)
            cell.song_name_label.text = post.songname
            //cell.artist_name_label.text = post?.artist_name
            
            
            return cell
            
        } else if post.flag == "video" {
            print("video")
            let cell = tableView.dequeueReusableCell(withIdentifier: "video_content_cell", for: indexPath) as! my_content_video_cell
            cell.selectionStyle = .none
            cell.media_image.loadImageUsingCacheWithUrlString(imageurlstring: post.albumArtUrl)
            cell.song_name_text_view.text = post.songname
            return cell
            
        } else if post.flag == "lyric" {
            print("lyric")
            print(post.lyrictext)
            let cell = tableView.dequeueReusableCell(withIdentifier: "lyric_content_cell", for: indexPath) as! my_content_lyric_cell
            cell.selectionStyle = .none

            cell.lyric_text_view.text = post.lyrictext
            cell.lyric_view_2.text = post.lyrictext
            cell.lyric_text_view.translatesAutoresizingMaskIntoConstraints = false
            cell.lyric_text_view.sizeToFit()
            cell.lyric_text_view.isScrollEnabled = false
            //cell.lyric_text_view.isHidden = true
            
            cell.lyric_view_2.translatesAutoresizingMaskIntoConstraints = false
            cell.lyric_view_2.sizeToFit()
            cell.lyric_view_2.isScrollEnabled = false
           
            
            cell.black_n_white_animation()
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "audio_content_cell", for: indexPath) as! my_content_audio_cell
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    
    //tap function for each table view cell
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        print ("tapedit here 1")
        if recognizer.state == UIGestureRecognizer.State.ended {
            print ("tap edit here 2")
            let tapLocation = recognizer.location(in: self.Hero_content_table)
            if let tapIndexPath = self.Hero_content_table.indexPathForRow(at: tapLocation) {
                print ("tap edit here 3")
                
                var post = Post(albumArtImage: "" , sourceAppImage: "", typeImage: "" , profileImage: "" , username: "" ,timeAgo: "", numberoflikes: "" ,caption:"", offset: 0.0, startoffset: 0.0, audiolength: 0.0, paused: false, playing: true, trackid: "", helper_id: "", helper_preview_url: "", videoid: "", starttime: 0.0 , endtime: 0.0, flag: "", lyrictext: "", songname: "", sourceapp: "", preview_url: "", albumArtUrl: "", original_track_length: 0, GIF_url: "")
                
                if self.edit_mode_is_on {
                    if self.editing_hero || self.editing_content_only {
                        post = self.temp_content_array[tapIndexPath[1]]
                    }
                } else {
                    post = (self.heroes[self.selected_hero_number - 1].contentList?["Post\(tapIndexPath[1] + 1)"])!
                }
                
                self.selected_post = post
                performSegue(withIdentifier: "heroes_to_show_update", sender: self)
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print ("searchBarTextDidBeginEditing")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print ("searchBarCancelButtonClicked")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print ("searchBarSearchButtonClicked")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "heroes_to_show_update" {
            if let destination = segue.destination as? ShowUpdateController {
                print("prepare")
                
                
                
                if self.selected_post.flag == "audio" {
                    print ("audio")
                    imageCacheManager.fetchImage(url: URL(string: self.selected_post.albumArtUrl)!, completion: { (image) in
                        destination.albumArt.image = image
                    })
                    destination.song_ID = self.selected_post.trackid
                    //destination.song_ID = "spotify:show:4xEBxMawkpToKdcnSTI7Ze"   //podcast test for spotify
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
                
                //destination.youtubeplayer?.load(withVideoId: "U_xI_vKkkmg" , playerVars: ["playsinline": 1, "showinfo": 0, "modestbranding" : 1, "controls": 1, "start": 26, "end": 84, "rel": 0])
            }
        }
    }
    
    
}

class TagLabel: UILabel {
    
    override func draw(_ rect: CGRect) {
        let inset = UIEdgeInsets(top: 2, left: 5, bottom: 0, right: 5)
        super.drawText(in: rect.inset(by: inset))
    }
}
