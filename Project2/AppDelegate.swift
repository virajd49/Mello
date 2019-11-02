//
//  AppDelegate.swift
//  Project2
//
//  Created by virdeshp on 3/11/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit
import Firebase
import SwiftyGiphy

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
 

   
    let user_defs = UserDefaults.standard
    var window: UIWindow?
    var viewController: UIViewController!
    //var poller = now_playing_poller.shared
    var authMaster = AuthenticationMaster()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        SwiftyGiphyAPI.shared.apiKey = "jXXFUup29spwxFlOwA2douoYMMhp4YvB"
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // 2- check if app can handle redirect URL
        print ("out here 8")

        if Auth.auth().currentUser != nil {
            // User is signed in.
            // ...
            let user = Auth.auth().currentUser
            if let user = user {
                // The user's ID, unique to the Firebase project.
                // Do NOT use this value to authenticate with your backend server,
                // if you have one. Use getTokenWithCompletion:completion: instead.
                let uid = user.uid
                let email = user.email
                print (uid)
                print (email)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "FireBaseloginSuccessfull"), object: nil)
                // ...
            }
        } else {
            // No user is signed in.
            // ...
            Auth.auth().signIn(withEmail: "virajdeshpande88@gmail.com", password: "password123") { (user, error) in
                // ...
                if error != nil {
                    print ("Sign in failure")
                    print (error)
                    return
                }

                print ("Sign in succesfull")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "FireBaseloginSuccessfull"), object: nil)
            }
        }
        
        //SPOTIFY auth flow - app comes back from spotify after authorizing
        //from the url parameter we grab all the session details and then post a notification for updateAfterFirstLogin back in SignInViewController
        //old_spotify_sdk
        return authMaster.handle_spotify_redirect_url(url: url)
        
        // MARK: Need a better place for the POLLER
    
//                    self.poller.grab_now_playing_item().done {
//                        print("Done checking for now playing")
//                    }

    }
    


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("application entered background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("application became active")
       // self.poller.grab_now_playing_item().done {
         //   print("Done checking for now playing")
        //}
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

