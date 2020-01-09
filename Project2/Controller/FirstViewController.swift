//
//  FirstViewController.swift
//  Project2
//
//  Created by virdeshp on 10/7/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import YoutubePlayer_in_WKWebView
import MediaPlayer


/*
 
 PENDING CHANGES
 1. We need to keep information abour what services the user has linked. This page currently goes through all three services, we don't need to do that.
 2. We need to grab the now playing item on this VC before going to TabBar - or we can do it when we load tabbar.
 
 
 */


var newsfeed_yt_player: WKYTPlayerView!

func newsfeed_yt_player_init () {
    print("global_yt_player_init called")
    newsfeed_yt_player = WKYTPlayerView.init(frame: CGRect(origin: CGPoint(x:0, y:0), size: CGSize(width: 375, height: 375)))
    //self.youtubeplayer?.delegate = self
    newsfeed_yt_player?.contentMode = UIView.ContentMode.scaleAspectFill
    //self.view.addSubview(youtubeplayer!)
    newsfeed_yt_player?.backgroundColor = UIColor.white
    newsfeed_yt_player?.clipsToBounds = true
    //global_yt_player?.layer.cornerRadius = 10
    //newsfeed_yt_player?.load(withVideoId: "kyAA2C5wk4Y" , playerVars: [ "playsinline": 1, "showinfo": 0, "origin": "https://www.youtube.com", "modestbranding" : 1, "controls": 0, "rel": 0, "iv_load_policy": 3])
    print ("global youtube_player_setup done")
 
}



class FirstViewController: UIViewController, AuthenticationMasterDelegate {
    

    @IBOutlet weak var logo_view: UIView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
              return .lightContent
          }
    var userIsLoggedIn = false
    var authMaster = AuthenticationMaster()
    var user_account = UserAccount()
    var userDefaults = UserDefaults.standard
    var user_has_apple: Bool = false
    var user_has_spotify: Bool = false
    var user_has_youtube: Bool = false
    
    
    override func viewDidLoad() {
        
        self.userDefaults.set("Spotify", forKey: "UserAccount")
        
        logo_view.layer.cornerRadius = 40
        self.navigationController?.navigationBar.layer.backgroundColor = self.view.layer.backgroundColor
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        //IF USER IS LOGGED IN - CHECK IF SESSIONS ARE ACTIVE
        
        if (userDefaults.getisLoggedIn()) {
            //IF USER IS LOGGED IN - CHECK IF SESSIONS ARE ACTIVE
            print ("checking services")
            //check what the user's services are first
            authMaster.delegate = self
            authMaster.google_initialize_sign_in()
            user_account.get_current_user()
            user_account.get_user_subscriptions().done { services_array in
                
                for service in services_array {
                    switch service.name {
                    case .apple:
                        self.user_has_apple = true
                        break
                    case .spotify:
                        self.user_has_spotify = true
                        break
                    case .youtube:
                        self.user_has_youtube = true
                        break
                    default:
                        break
                    }
                }
                self.check_streaming_service_sessions()
                //newsfeed_yt_player_init()
            }
        } else {
            //ELSE IF USER IS NOT LOGGED IN TAKE USER TO PRIMARY LOGIN SCREEN
            print ("going to sign up vc")
            go_to_signup_vc()
        }
        //ELSE IF USER IS NOT LOGGED IN TAKE USER TO PRIMARY LOGIN SCREEN
        
    }
    
    
    func check_streaming_service_sessions () {
        if self.user_has_spotify {
            authMaster.spotify_sign_in_initialize_old_sdk()
        } else {
            spotify_login_done()
        }
    }
    
    
    
    func spotify_login_done() {
        if self.user_has_youtube {
            authMaster.google_sign_in()
        } else {
            google_login_done()
        }
    }
      
    func google_login_done() {
        if user_has_apple {
            print ("user_has_apple - calling refresh")
            //Need to check dev token and user token here
            //Need to check if capabilities have chnaged or not
            
            //Need to know if cloud is authorized - check if authorized - if not - ask for authorization
            //generate new dev token and user token
            //Need to know that we got latest capabilities - call request for capabilities
            //need to know if media library is authorized - check if authorized if not - as for authorization
            authMaster.apple_refresh_session_check()
          
                        
        } else {
            print ("apple_login_done")
            apple_login_done()
        }
    }
      
    func apple_login_done() {
        //This is a delegate function, we expect by the time this is called, AuthMaster has all the capabilities and tokens we need to proceed
        self.user_account.refresh_apple_service_info(subscription: self.authMaster.apple_subscription, can_play: self.authMaster.can_play_music , can_add: self.authMaster.can_add_music)
        go_to_tabbar_vc()
    }
 
    func go_to_signup_vc () {
        if let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "signupVC") {
            self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.pushViewController(signUpVC, animated: true)
                       
        }
    }
    
    
    func go_to_tabbar_vc () {
        self.performSegue(withIdentifier: "logo_to_tabbar", sender: self)
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
           //
       }
    
}
