//
//  AppDelegate.swift
//  Project2
//
//  Created by virdeshp on 3/11/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var auth = SPTAuth()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        auth.redirectURL     = URL(string: "viraj-project2://callback")
        auth.sessionUserDefaultsKey = "current session"
        FirebaseApp.configure()
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // 2- check if app can handle redirect URL
        print ("oit here 8")
        
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
        
        /*
         Auth.auth().createUser(withEmail: "virajdeshpande89@gmail.com", password: "password123", completion: { (user, error) in
         
         if error != nil {
         print(error)
         return
         }
         
         print("Succesfully authenticated user")
         NotificationCenter.default.post(name: Notification.Name(rawValue: "FireBaseloginSuccessfull"), object: nil)
         
         })
         */
        
        if auth.canHandle(auth.redirectURL) {
            print ("oit here 9")
            
            // 3 - handle callback in closure
            print (url)
            print (url.query)
            print (url)
            auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
                // 4- handle error
                if error != nil {
                    print(error)
                    print("error!")
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: "loggedinperformsegue"), object: nil)
                // 5- Add session to User Defaults
                let userDefaults = UserDefaults.standard
                let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
                userDefaults.set(sessionData, forKey: "SpotifySession")
                userDefaults.set("Apple", forKey: "UserAccount")
                userDefaults.synchronize()
                // 6 - Tell notification center login is successful
                NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
                print ("oit here 7")
            })
            return true
        }
        return false
    }
    


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

