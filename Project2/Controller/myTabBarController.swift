//
//  myTabBarContorller.swift
//  Project2
//
//  Created by virdeshp on 12/1/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation



class myTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("hey this worked MAN")
        guard viewController is UploadViewController else { return true }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "UploadViewController2") as! UploadViewController2
        newViewController.modalPresentationStyle = .fullScreen
        tabBarController.present(newViewController, animated: true, completion: nil)
        return false
    }
    
}
