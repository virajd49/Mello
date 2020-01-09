//
//  myTabBarContorller.swift
//  Project2
//
//  Created by virdeshp on 12/1/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation



class myTabBarController: UITabBarController, UITabBarControllerDelegate, NowPlayingViewDelegate {

   // var poller = now_playing_poller.shared
    var playingView = NowPlayingView()
    var fullmediaplayer = FullMediaPlayer.shared
    let window = UIApplication.shared.keyWindow
    var appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playingView.smallPlayer.frame = CGRect(origin: CGPoint(x:0, y:(self.window!.frame.height)), size: CGSize(width: 375, height: 50))
        self.fullmediaplayer.delegate = playingView
        self.playingView.delegate = self
        self.view.addSubview(playingView.smallPlayer)
        self.delegate = self
    }
    
    func hide_status_bar() {
        print("hide_status_bar")
        self.appdelegate.hide_status_bar = true
        setNeedsStatusBarAppearanceUpdate()
        
    }
    
    func show_status_bar() {
        print("show_status_bar")
        self.appdelegate.hide_status_bar = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    //I wanted the UploadViewController to pop up from the bottom, so here I detect when the upload tab is selected and present UploadViewController2 modally. I couldnt figure out how to present a tabbar child controller from the bottom up - so UploadViewController is just a dummy.
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("hey this worked MAN")
        
        //So if the selected viewcontroller is UploadViewController
        if viewController is UploadViewController {
        
            let UploadVC = viewController as! UploadViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyboard.instantiateViewController(withIdentifier: "UploadViewController2") as! UploadViewController2
            let navController = UINavigationController(rootViewController: newViewController) // Creating a navigation controller with newViewController at the root of the navigation stack.
            UploadVC.present(navController, animated: true, completion: {
                    print("complete")
                })
            return false
        } else if viewController is NewsFeedTableViewController {
            let NewsfeedVC = viewController as! NewsFeedTableViewController
            NewsfeedVC.fullmediaplayer.delegate = playingView
            
            return true
        } else {
            return true
        }
    }
    
}
