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
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("hey this worked MAN")
        
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
