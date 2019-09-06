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
class AppDelegate: UIResponder, UIApplicationDelegate, SPTAudioStreamingDelegate {
 

    let SpotifyClientID = "5b5198fe415746c0a9410281d041a4f9"
    let SpotifyRedirectURL = URL(string: "viraj-project2://spotify-login-callback")!
    //let requestedScopes: SPTScope = [.appRemoteControl, .userReadCurrentlyPlaying]
    let user_defs = UserDefaults.standard
    var window: UIWindow?
    var auth = SPTAuth.defaultInstance()
    var viewController: UIViewController!
    var poller = now_playing_poller.shared
    
//    lazy var configuration = SPTConfiguration(
//        clientID: SpotifyClientID,
//        redirectURL: SpotifyRedirectURL
//    )
//    
//    //Setup session manager for authentication
//    lazy var sessionManager: SPTSessionManager = {
//        if let tokenSwapURL = URL(string: "https://viraj-project2.herokuapp.com/api/token"),
//            let tokenRefreshURL = URL(string: "https://viraj-project2.herokuapp.com/api/refresh_token") {
//            self.configuration.tokenSwapURL = tokenSwapURL
//            self.configuration.tokenRefreshURL = tokenRefreshURL
//            self.configuration.playURI = ""  //if empty - will play last played song, if given specific URI will play that song
//        }
//        let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
//        return manager
//    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        //old spotify sdk
        auth.redirectURL  = URL(string: "viraj-project2://spotify-login-callback")
        auth.sessionUserDefaultsKey = "current session"
        FirebaseApp.configure()
        SwiftyGiphyAPI.shared.apiKey = "jXXFUup29spwxFlOwA2douoYMMhp4YvB"
        
//        if Auth.auth().currentUser != nil {
//            // User is signed in.
//            // ...
//            let user = Auth.auth().currentUser
//            if let user = user {
//                // The user's ID, unique to the Firebase project.
//                // Do NOT use this value to authenticate with your backend server,
//                // if you have one. Use getTokenWithCompletion:completion: instead.
//                let uid = user.uid
//                let email = user.email
//                print (uid)
//                print (email)
//                NotificationCenter.default.post(name: Notification.Name(rawValue: "FireBaseloginSuccessfull"), object: nil)
//                // ...
//            }
//        } else {
//            // No user is signed in.
//            // ...
//            Auth.auth().signIn(withEmail: "virajdeshpande88@gmail.com", password: "password123") { (user, error) in
//                // ...
//                if error != nil {
//                    print ("Sign in failure")
//                    print (error)
//                    return
//                }
//
//                print ("Sign in succesfull")
//                NotificationCenter.default.post(name: Notification.Name(rawValue: "FireBaseloginSuccessfull"), object: nil)
//            }
//        }
//        // Override point for customization after application launch.
        
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // 2- check if app can handle redirect URL
        print ("oit here 8")
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
        if (auth.canHandle(auth.redirectURL!)) {
            print ("oit here 9")

            // 3 - handle callback in closure
            print (url)
            print (url.query)
            print (auth.hasTokenSwapService)
            print (auth.hasTokenRefreshService)
            print (auth.redirectURL)
            print (auth.tokenRefreshURL)
            print (auth.tokenSwapURL)
            
            
            //we get 'session' from url
            auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
                // 4- handle error
                if error != nil {
                    print(error)
                    print("error!")
                    if session != nil {
                        print (session?.accessToken)
                    }
                } else {
                    print (url)
                    print ("\(session)")
                    //NotificationCenter.default.post(name: Notification.Name(rawValue: "loggedinperformsegue"), object: nil)
                    // 5- Add session to User Defaults
                    
                    let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
                    self.user_defs.set(sessionData, forKey: "SpotifySession")
                    self.user_defs.set("Apple", forKey: "UserAccount") //<- this value is independent of any auth flow, it is used as a flag throughout the app to simulate if the user uses apple music or spotify - see top of this file for full
                    self.user_defs.set(session?.accessToken, forKey: "spotify_access_token")
                    self.user_defs.set(session?.encryptedRefreshToken, forKey: "spotify_refresh_token")
                    self.user_defs.synchronize()
                    print ("\(session?.accessToken)")
                    print ("\(session?.expirationDate)")
                    if session?.encryptedRefreshToken != nil {
                        print ("refresh token present")
                    } else {
                        print ("refresh token is nil")
                    }
                    
                    //As soon as we are done authenticating, we want to get the currently playing item from apple/spotify
                    //I'm not sure if this is blocking anything, but it can probably go on a background thread - Look at now_playing_poller.swift under Model
                    self.poller.grab_now_playing_item().done {
                        print("Done checking for now playing")
                    }
                    // 6 - Tell notification center login is successful - this will run updateAfterFirstLogin in SigninViewController
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
                    print ("oit here 7")
                }
            })
            return true
        }
        return false
        
        //new spotify_sdk - shouldn't there be a if can open URL here of some sort ??
        //self.sessionManager.application(application, open: url, options: options)
        
        //return true
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

    
//    func spotify_sign_in_session_check_new_sdk () {
//        
//        if let sessionObj: AnyObject = user_defs.object(forKey: "SpotifySession") as AnyObject {
//            print("why are we here if obj is NSNull")
//            if let sessionDataObj = sessionObj as? NSData {
//                
//                let session =  NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj as Data) as! SPTSession
//                
//                //if the session has expired renew it
//                if session.isExpired {
//                    print ("session is expired")
//                    sessionManager.session = session
//                    sessionManager.renewSession()
//                    
//                } else {
//                    //if not directly connect to the remoteApp
//                    print ("session is valid")
//                    let access_token = self.user_defs.value(forKey: "spotify_access_token") as! String
//                    print(access_token)
//                    NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
//                 
//                }
//            }
//            
//        } else {
//            
//            //Initiates session for authentication - takes user to sign in page - if token is valid - returns immmediately
//            self.sessionManager.initiateSession(with: requestedScopes, options: .default)
//        }
//    }
    
//    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
//        print("success", session)
//        print("We authenticated succesfully !!")
//        //We come here once the user succesfully authenticates
//        //Once the user succesfully authenticates we can remote connect to the spotify app.
//        self.user_defs.set(session.accessToken, forKey: "spotify_access_token")
//        self.user_defs.set(session.refreshToken, forKey: "spotify_refresh_token")
//        let sessionData =  try? NSKeyedArchiver.archivedData(withRootObject: session, requiringSecureCoding: false)
//        print (self.sessionManager.session.debugDescription)
//        self.user_defs.set(sessionData, forKey: "SpotifySession")
//
//        user_defs.set("Spotify", forKey: "UserAccount")
//        user_defs.synchronize()
//        // 6 - Tell notification center login is successful
//        print ("oit here 7")
//        self.poller.grab_now_playing_item()
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
//
//    }
//
//    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
//        print("fail", error)
//    }

//    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
//        print("renewed", session)
//        self.user_defs.set(session.accessToken, forKey: "spotify_access_token")
//        self.user_defs.set(session.refreshToken, forKey: "spotify_refresh_token")
//        let sessionData =  try? NSKeyedArchiver.archivedData(withRootObject: session, requiringSecureCoding: false)
//        print (self.sessionManager.session.debugDescription)
//        self.user_defs.set(sessionData, forKey: "SpotifySession")
//
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "loggedinperformsegue"), object: nil)
//        user_defs.set("Apple", forKey: "UserAccount")
//        user_defs.synchronize()
//        // 6 - Tell notification center login is successful
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
//        print ("oit here 7")
//        self.poller.grab_now_playing_item()
//    }

//    func spotify_sign_button_new_sdk () {
//
//        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
//    }

}

