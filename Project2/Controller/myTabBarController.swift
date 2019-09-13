//
//  myTabBarContorller.swift
//  Project2
//
//  Created by virdeshp on 12/1/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation



class myTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var poller = now_playing_poller.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    
    //I wanted the UploadViewController to pop up from the bottom, so here I detect when the upload tab is selected and present UploadViewController2 modally. I couldnt figure out how to present a tabbar child controller from the bottom up - so UploadViewController is just a dummy.
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("hey this worked MAN")
        
        //So if the selected viewcontroller is UploadViewController
        guard viewController is UploadViewController else { return true }
        
        let UploadVC = viewController as! UploadViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "UploadViewController2") as! UploadViewController2
        let navController = UINavigationController(rootViewController: newViewController) // Creating a navigation controller with newViewController at the root of the navigation stack.
        UploadVC.present(navController, animated: true, completion: {
                print("complete")
            })
        return false
    }
    
}
