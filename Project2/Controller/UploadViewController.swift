//
//  UploadController.swift
//  Project2
//
//  Created by virdeshp on 11/23/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import AVFoundation
import Firebase
import Foundation


/* Just a dummy view controller */

class UploadViewController: UIViewController {

//
//    @IBOutlet weak var selector_stack: UIStackView!
//    @IBOutlet weak var stack_trailing: NSLayoutConstraint!
//    @IBOutlet weak var stack_leading: NSLayoutConstraint!
//    @IBOutlet weak var now_playing_button_outlet: UIButton!
//    @IBOutlet weak var apple_button_outlet: UIButton!
//    @IBOutlet weak var spotify_button_outlet: UIButton!
    
//    @IBOutlet weak var youtube_button_outlet: UIButton!
//
//    @IBOutlet weak var now_playing_image: UIImageView!
//    @IBOutlet weak var now_playing_progress_bar: UIProgressView!
//    @IBOutlet weak var now_playing_scrubber: UIButton!
//
//    @IBOutlet weak var search_bar_container: UIView!
//    let searchController = UISearchController(searchResultsController: nil)
//
//    var button_array: [UIButton]?
    
    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
//        stack_leading.constant = 167.5
//        stack_trailing.constant = -72.5
//        button_array = [self.now_playing_button_outlet, self.apple_button_outlet, self.spotify_button_outlet, self.youtube_button_outlet]
//        self.change_alpha(center_button: 0)
//        toggle_hide_now_playing(hide: false)
//        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
//        searchController.obscuresBackgroundDuringPresentation = true
//
//        searchController.searchBar.placeholder = "Search Posts"
//        self.search_bar_container.addSubview(searchController.searchBar)
//        searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
//        self.tabBarController?.tabBar.isHidden = true
//        searchController.searchBar.isHidden = true
//        let cancelButtonAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
//        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        self.tabBarController?.tabBar.isHidden = false
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func dismiss_chevron(_ sender: Any) {
        
//        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func now_playing_button(_ sender: Any) {
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
//                       options: [.curveEaseIn], animations: {
//        self.stack_leading.constant = 167.5
//        self.stack_trailing.constant = -72.5
//        self.change_alpha(center_button: 0)
//        self.view.layoutIfNeeded()
//        }, completion: nil)
//        toggle_hide_now_playing(hide: false)
//        searchController.searchBar.isHidden = true
    }
    
    @IBAction func apple_upload_button(_ sender: Any) {
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
//                       options: [.curveEaseIn], animations: {
//        self.stack_leading.constant = 87.5
//        self.stack_trailing.constant = 7.5
//        self.change_alpha(center_button: 1)
//        self.view.layoutIfNeeded()
//        }, completion: nil)
//        toggle_hide_now_playing(hide: true)
//        searchController.searchBar.placeholder = "Search Apple Music"
//        searchController.searchBar.isHidden = false
    }
    
    @IBAction func spotify_button(_ sender: Any) {
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
//                       options: [.curveEaseIn], animations: {
//        self.stack_leading.constant = 7.5
//        self.stack_trailing.constant = 87.5
//        self.change_alpha(center_button: 2)
//        self.view.layoutIfNeeded()
//        }, completion: nil )
//        toggle_hide_now_playing(hide: true)
//        searchController.searchBar.placeholder = "Search Spotify"
//        searchController.searchBar.isHidden = false
    }
    
    @IBAction func youtube_button(_ sender: Any) {
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
//                       options: [.curveEaseIn], animations: {
//        self.stack_leading.constant = -72.5
//        self.stack_trailing.constant = 167.5
//        self.change_alpha(center_button: 3)
//        self.view.layoutIfNeeded()
//        }, completion: nil )
//        toggle_hide_now_playing(hide: true)
//        searchController.searchBar.placeholder = "Search Youtube"
//        searchController.searchBar.isHidden = false
    }
    
    func change_alpha (center_button: Int) {
//
//        for i in 0...3 {
//            if i == center_button {
//                self.button_array![i].alpha = 1
//            } else {
//                self.button_array![i].alpha = 0.2
//            }
//        }
//
    }
    
    func toggle_hide_now_playing (hide: Bool) {
//        if hide {
//            self.now_playing_image.isHidden = true
//            self.now_playing_scrubber.isHidden = true
//            self.now_playing_progress_bar.isHidden = true
//        } else {
//            self.now_playing_image.isHidden = false
//            self.now_playing_scrubber.isHidden = false
//            self.now_playing_progress_bar.isHidden = false
//        }
    }
    
}
