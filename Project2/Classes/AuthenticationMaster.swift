//
//  AuthenticationMaster.swift
//  Project2
//
//  Created by virdeshp on 10/8/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import Firebase
import GoogleAPIClientForREST
import GoogleSignIn



protocol AuthenticationMasterDelegate: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    func spotify_login_done ()
    
    func google_login_done ()
    
    func apple_login_done()
    
}


class AuthenticationMaster: NSObject, GIDSignInUIDelegate, GIDSignInDelegate, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
 
    let SpotifyClientID = "5b5198fe415746c0a9410281d041a4f9"
    let SpotifyRedirectURL = URL(string: "viraj-project2://spotify-login-callback")!
    let userDefaults = UserDefaults.standard
    var auth = SPTAuth.defaultInstance()
    var player: SPTAudioStreamingController!
    var session: SPTSession!
    var premiumloginUrl = URL(string: "spotify-action://authorize?nolinks=true&nosignup=true&response_type=code&scope=streaming%20playlist-read-private%20playlist-modify-public%20playlist-modify-private%20user-read-playback-state%20user-read-private%20user-library-read%20user-top-read%20user-library-modify%20user-read-recently-played&utm_source=spotify-sdk&utm_medium=ios-sdk&utm_campaign=ios-sdk&redirect_uri=viraj-project2%3A%2F%2Fspotify-login-callback&show_dialog=true&client_id=5b5198fe415746c0a9410281d041a4f9")
    let appleauthority = AppleMusicControl()
    let applemanager = AppleMusicManager()
    var access_token = ""
    var ErrorPointer: ErrorPointer = nil
    private let scopes = [kGTLRAuthScopeYouTubeReadonly,kGTLRAuthScopeYouTube]
    let signInButton = GIDSignInButton()
    private let service = GTLRYouTubeService()
    var delegate: AuthenticationMasterDelegate!
    var spotify_subscription: subscription! = .free
    var apple_subscription: subscription! = .free
    
  
    
  
    // MARK: Google
    
    
    //This is the beginning of the google authentocation sequence - this sets up the auth instance and makes the button visible on the screen.
      //My understanding is that the google sign in flow is initiated when the sign in button is pressed, unsure why it gives us a auth failed error before we click the button, will have to go over google auth flow documentation
      func google_initialize_sign_in(){
          print("In Google sign in set up")
          //Google sign in initialization
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance()?.clientID = "898533962642-u5k25pe6v3jgso5o8hkq16k1jalhec1l.apps.googleusercontent.com"
        userDefaults.setValue("AIzaSyCWyumtxOwkf0zXWsh2Pe0vSwXFNHfax8E", forKey: "google_api_key")
        
      }
    
    func google_sign_in () {
        
         GIDSignIn.sharedInstance().signIn()
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        //
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        //
    }
    
    //My understanding is that the google sign in flow is initiated when the sign in button is pressed, unsure why it gives us an auth failed error before we click the button, will have to go over google auth flow documentation
       func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
           print ("Google sign in")
           if let error = error {
               //this is the error we see
               showAlert(title: "Authentication Error", message: error.localizedDescription)
               self.service.authorizer = nil
           } else {
               //this means auth was successful
               self.signInButton.isHidden = true
               self.service.authorizer = user.authentication.fetcherAuthorizer()
               //we move on to apple auth flow
            self.delegate.google_login_done()
           }
       }
       
      
    
    
    // MARK: Spotify
    
      //Once login is done - we initialize the spotify player with the authorized session - here we just grab the session and then call the initialize player function with that session.
        //this player is a single instance that can be shared throughout the app - 90% sure
        //this function contains a lot of redundant steps - needs to reduced
        @objc func updateAfterFirstLogin (notification: Notification) {
            print("out here5")
            if let sessionObj: AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
                let sessionDataObj = sessionObj as! Data
                let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
                self.session = firstTimeSession
                self.player?.delegate = self
                initializePlayer(authSession: self.session)
                print("out here2")
                
                
            }
        }
        
        //We login to the player with the passed down session - once we are logged into the player, it calls audioStreamingDidLogin where we can do any operations that require the player to be initialized
        func initializePlayer(authSession:SPTSession){
            print("In initializePlayer")
            if self.player == nil {
                print ("In self.player == nil")
                self.player = SPTAudioStreamingController.sharedInstance()
                 print ("In self.player == nil2")
                self.player!.playbackDelegate = self as SPTAudioStreamingPlaybackDelegate
                 print ("In self.player == nil3")
                self.player!.delegate = self as SPTAudioStreamingDelegate
                 print ("In self.player == nil4")
                try! player!.start(withClientId: SpotifyClientID)
                print(authSession.accessToken)
                self.player!.login(withAccessToken: authSession.accessToken)
                print("out here3")
                
            }
        }
        
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController) {
            // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method is called
            print("logged in")
            
            //here we make a request to get the current user name from the authenticated session.
            let request1: URLRequest = try! SPTUser.createRequestForCurrentUser(withAccessToken: self.session.accessToken, error: ErrorPointer)
            print (self.session.accessToken)
            SPTRequest.sharedHandler().perform(request1, callback: { (error, response, data) in
                if error == nil {
                    let dataAsString = String(data: data!, encoding: .utf8)
                    print (dataAsString)
                    var user = SPTUser(from: data!, with: response!, error: self.ErrorPointer)
                    if self.ErrorPointer != nil {
                        print(self.ErrorPointer)
                    }
                    print(" and this guy")
                    print("Spotify subscription is \(user.product.rawValue)")
                    //Here we store it in user defaults for further use within the app
                    self.userDefaults.set(user.canonicalUserName, forKey: "current_spotify_username")
//                    if user.product == .free {
//                        self.spotify_subscription = .free
//                        print("Spotify subscription is free")
//                    } else if user.product == .premium {
//                        self.spotify_subscription = .premium
//                        print("Spotify subscription is premium")
//                    } else if user.product == .unknown {
//                        print("Spotify subscription is unknown")
//                    } else if user.product == .unlimited {
//                        print("Spotify subscription is unlimited")
//                    }
//
//                    //Need to find a better place for this
//                    //Here we grab what is essentially the users latest library and playlists
//                    /*
//                    let playlist_access = UserAccess(myPlaylistQuery: MPMediaQuery.playlists(), myLibrarySongsQuery: MPMediaQuery.songs(), mypodcastsQuery: MPMediaQuery.podcasts())
//
//                    if self.userDefaults.string(forKey: "UserAccount") == "Spotify" {
//                        playlist_access.get_spotify_playlists()
//                        playlist_access.get_spotify_all_tracks()
//                    } else {
//                        //
//                    }
//                    */
//                    print("username set")
//                }else {
//                    print ("error getting username")
//                    print (error)
                }
            })
//
        
        self.applemanager.get_spotify_current_user().done { user in
            
            print("\(user.display_name)")
            print("\(user.email)")
            print("\(user.product)")
            if user.product == "\(subscription.free)" {
                self.spotify_subscription = .free
                print("Spotify subscription is free")
            } else if user.product == "\(subscription.premium)" {
                self.spotify_subscription = .premium
                print("Spotify subscription is premium")
            } else if user.product == "\(subscription.unknown)" {
                self.spotify_subscription = .unknown
                print("Spotify subscription is unknown")
            } else if user.product == "\(subscription.unlimited)" {
                self.spotify_subscription = .unlimited
                print("Spotify subscription is unlimited")
            }
            
           
            
            
        }
            
//        self.applemanager.performSpotifyCurrentPlayingSearch().done { spotify_current_playing_context in
//
//            guard !spotify_current_playing_context.isEmpty else {
//                print ("Spotify: Nothing is playing - spotify_current_playing_context is nil")
//                return
//            }
//
//            print ("Spotify: Something is playing - spotify_current_playing_context is not nil")
//
//        }
            self.delegate.spotify_login_done()
    }
    
    
    
    func spotify_sign_in_initialize_old_sdk () {
           print("spotify_sign_in_initialize_old_sdk")
           NotificationCenter.default.addObserver(self, selector: #selector(self.updateAfterFirstLogin), name: Notification.Name(rawValue: "loginSuccessfull"), object: nil )
           
           //Spotify sign in initialization
           SPTAuth.defaultInstance().clientID = SpotifyClientID
           SPTAuth.defaultInstance().redirectURL = SpotifyRedirectURL
           SPTAuth.defaultInstance().sessionUserDefaultsKey = "current session"
           SPTAuth.defaultInstance().tokenSwapURL = URL(string: "https://viraj-project2.herokuapp.com/api/token")
           SPTAuth.defaultInstance().tokenRefreshURL = URL(string: "https://viraj-project2.herokuapp.com/api/refresh_token")
           SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthUserLibraryReadScope, SPTAuthUserLibraryModifyScope, SPTAuthUserReadPrivateScope]
           //loginUrl = SPTAuth.defaultInstance().spotifyAppAuthenticationURL()
           //This is the AppAuthenticationURL format  - using a hardcoded value because SPTAuth from the old sdk does not have 'user-read-playback-state' and 'user-read-recently-played' scopes.
           
           print(premiumloginUrl)
           print(SPTAuth.defaultInstance().spotifyAppAuthenticationURL())
           print(SPTAuth.defaultInstance().spotifyWebAuthenticationURL())
           
           //Now we go to check if we already have a valid session or if the user needs to sign in
           self.spotify_sign_in_session_check_old_sdk()
           
       }

       func spotify_sign_button_old_sdk () {
           //User has to sign in - here we use the loginUrl that we set up in spotify_sign_in_initialize_old_sdk.
           //openURL on that URL takes us to the spotify app to get authorized - when we come back - app delegate takes control - so go to app deleagte from here to follow the flow.
           
           if UIApplication.shared.openURL(premiumloginUrl!)
           {
               print ("HEY HEY HEY ")
               if auth.canHandle(auth.redirectURL!) {
                   // To do - build in error handling

               }
           }

       }
       
       
       //Here we check if a session object exists, if it does we check if it is valid or not,
       // if not valid, we have to renew the session,
       // if session object is Null, user has to sign in.
       func spotify_sign_in_session_check_old_sdk () {
         print ("spotify_sign_in_session_check_old_sdk")
           //We grab the Spotify session object from User defaults
           if let sessionObj: AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject {
               //Something that I don't understand is that, if the session obj is Null, which means the user has to sign in again, how do we even get past the above if let statement
               print("why are we here if obj is NSNull")
               if let sessionDataObj = sessionObj as? NSData {
                   //session obj exists - so we don't have to ask the user to login  - and we can use the current session.
                   
                   let session =  NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj as Data) as! SPTSession

                   if (!session.isValid()) {
                       print("Session is not valid")
                       SPTAuth.defaultInstance().renewSession(session) { (error, session) in
                           if error == nil {
                               let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
                               self.userDefaults.set(sessionData, forKey: "SpotifySession")
                               self.userDefaults.set("Apple", forKey: "UserAccount") //<- this value is independent of any auth flow, it is used as a flag throughout the app to simulate if the user uses apple music or spotify - see top of this file for full explanantion.
                            //DO WE NEED TO SAVE THESE ??
                               self.userDefaults.set(session?.accessToken, forKey: "spotify_access_token")
                               self.userDefaults.set(session?.encryptedRefreshToken, forKey: "spotify_refresh_token")
                               self.userDefaults.synchronize()
                               self.session = session
                               print("Session was refreshed")
                               
                               //As soon as we are done authenticating, we want to get the currently playing item from apple/spotify
                               //I'm not sure if this is blocking anything as of now, but it can probably go on a background thread
                            /*
                               self.poller.grab_now_playing_item().done {
                                   print("Done checking for now playing")
                               }
                             */
                               //this notification will call updateAfterFirstLogin
                               NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
                               
                           }else{
                               print(error)
                               print("error refreshing session")
                           }
                       }
                   }else {
                       print("Session is valid")
                       //As soon as we are done authenticating, we want to get the currently playing item from apple/spotify
                       //I'm not sure if this is blocking anything, but it can probably go on a background thread - Look at now_playing_poller.swift under Model
                    /*
                       self.poller.grab_now_playing_item().done {
                           print ("Done checking for now playing")
                       }
                    */
                       
                       //this notification will call updateAfterFirstLogin
                       NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
                   }
               } else if let sessionDataObj = sessionObj as? NSNull {
                   print("sessionObj is null - so we have to login with credentials again")
                   //sessionObj is null - so we have to login with credentials again
                   spotify_sign_button_old_sdk()
               }

           }


       }
    
    
    
    func handle_spotify_redirect_url (url: URL) -> Bool {
        
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
                    self.userDefaults.set(sessionData, forKey: "SpotifySession")
                    self.userDefaults.set("Apple", forKey: "UserAccount") //<- this value is independent of any auth flow, it is used as a flag throughout the app to simulate if the user uses apple music or spotify - see top of this file for full
                    self.userDefaults.set(session?.accessToken, forKey: "spotify_access_token")
                    self.userDefaults.set(session?.encryptedRefreshToken, forKey: "spotify_refresh_token")
                    self.userDefaults.synchronize()
                    print ("\(session?.accessToken)")
                    print ("\(session?.expirationDate)")
                    if session?.encryptedRefreshToken != nil {
                        print ("refresh token present")
                    } else {
                        print ("refresh token is nil")
                    }
                    
                    // 6 - Tell notification center login is successful - this will run updateAfterFirstLogin in SigninViewController
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
                    print ("oit here 7")
                }
            })
            return true
        }
        
        return false
        
    }
        
    
    
    
    
    // MARK: Apple
    
    func apple_sign_in_initialize () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.apple_music_sub_present_handler), name: Notification.Name(rawValue: "NoAppleMusicSubscriptionPresent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.apple_music_sub_absent_handler), name: Notification.Name(rawValue: "AppleMusicSubscriptionPresent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.apple_music_media_lib_authorized_handler), name: Notification.Name(rawValue: "AppleMusicMediaLibraryAuthorized"), object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(self.apple_music_sub_present_handler), name: Notification.Name(rawValue: "AppleMusicCloudServiceAuthorized"), object: nil)
        
        //Was trying to make sure that the segue is called synchronously after the three apple auth calls - used dispatch groups for that - no sure if there is a simpler/better way to do this here
        
        //the three function calls are straightup apple code copied from their example music kit project - haven't touched it much at all - see AppleMusicControl.swift
       // let mygroup = DispatchGroup()
        
       // mygroup.enter()
        
        self.appleauthority.initialize()
        self.appleauthority.requestCloudServiceAuthorization()
        //self.appleauthority.requestMediaLibraryAuthorization()
        print ("apple authorization requested")
        
        //mygroup.leave()
        
       // mygroup.notify(queue: .main) {
             //Here we move to the newsfeed
             //self.performSegue(withIdentifier: "toNewsFeed", sender: self)
            //self.delegate.apple_login_done()
        //}
        
    }
    
    @objc func apple_music_sub_present_handler () {
        print(" --------------------- apple_music_sub_present_handler ------------------------- ")
        self.appleauthority.requestMediaLibraryAuthorization()
    }
    
    @objc func apple_music_sub_absent_handler () {
        print(" ------------------------  apple_music_sub_absent_handler ------------------------")
        self.showAlert(title: "Create Apple Music Account?", message: "We can't seem to detect an Apple Music subscription on your Itunes account")
    }
    
    @objc func apple_music_media_lib_authorized_handler () {
        print(" ------------------------  apple_music_sub_absent_handler ------------------------ ")
        self.delegate.apple_login_done()
    }
    
    func apple_sign_in () {
        
        appleauthority.requestCloudServiceAuthorization()
        appleauthority.requestMediaLibraryAuthorization()
        
    }

    
    
    func showAlert(title : String, message: String) {
           let alert = UIAlertController(
               title: title,
               message: message,
               preferredStyle: UIAlertController.Style.alert
           )
           let ok = UIAlertAction(
               title: "OK",
               style: UIAlertAction.Style.default,
               handler: nil
           )
           alert.addAction(ok)
           self.delegate.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
}
