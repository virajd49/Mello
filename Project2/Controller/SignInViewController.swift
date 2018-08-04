//
//  SignInViewController.swift
//  Project2
//
//  Created by virdeshp on 3/18/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit
import MediaPlayer

class SignInViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {

    
    let userDefaults = UserDefaults.standard
    var auth = SPTAuth.defaultInstance()!
    var session: SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    var offset: TimeInterval = 0.0
    var paused: Bool = false
    var playing: Bool = false
    let appleauthority = AppleMusicControl()
    var access_token = ""
    let playlist_access = UserAccess(musicPlayerController: MPMusicPlayerController.applicationMusicPlayer, myPlaylistQuery: MPMediaQuery.playlists(), myLibrarySongsQuery: MPMediaQuery.songs())
    
    
    
    
    func setup(){
        
        SPTAuth.defaultInstance().clientID = "5b5198fe415746c0a9410281d041a4f9"
        SPTAuth.defaultInstance().redirectURL = URL(string: "spotify-tutorial-login://callback" )
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthUserLibraryReadScope, SPTAuthUserLibraryModifyScope]
        loginUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
    }
    
    @IBAction func signIn(_ sender: Any) {
        self.performSegue(withIdentifier: "toNewsFeed", sender: self)
        if SPTAuth.supportsApplicationAuthentication() {
            UIApplication.shared.open(loginUrl!, options: [:], completionHandler: nil)
            
        } else {
            
            if UIApplication.shared.openURL(loginUrl!)
            {
                if auth.canHandle(auth.redirectURL) {
                    // To do - build in error handling
                    
                }
            }
        }
    }
    @IBAction func signInToAppleMusic(_ sender: Any) {
        appleauthority.requestCloudServiceAuthorization()
        appleauthority.requestMediaLibraryAuthorization()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
         //NotificationCenter.default.addObserver(self, selector: #selector(self.movetonewsfeed), name: Notification.Name(rawValue: "loggedinperformsegue"), object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateAfterFirstLogin), name: Notification.Name(rawValue: "loginSuccessfull"), object: nil )
        print("out here1")
        
        appleauthority.initialize()
        
        appleauthority.requestCloudServiceAuthorization()
        appleauthority.requestMediaLibraryAuthorization()
        
        print ("apple authorization requested")
        
        // Do any additional setup after loading the view.
    }
    
    @objc func movetonewsfeed (notification: Notification){
        print ("segue perform")
        self.performSegue(withIdentifier: "toNewsFeed", sender: self)
    }
    
    @objc func updateAfterFirstLogin (notification: Notification) {
        print("out here5")
        if let sessionObj: AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            userDefaults.set(self.session.accessToken, forKey: "Spotify_access_token")
            
            initializePlayer(authSession: session)
            
            print("out here2")
            
            
        }
    }
    
    func initializePlayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self as SPTAudioStreamingPlaybackDelegate
            self.player!.delegate = self as SPTAudioStreamingDelegate
            try! player!.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
            print("out here3")
            
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("logged in")
        let request1: URLRequest = try! SPTUser.createRequestForCurrentUser(withAccessToken: self.session.accessToken)
        print (self.session.accessToken)
        SPTRequest.sharedHandler().perform(request1, callback: { (error,response, data) in
            if error == nil {
                var user = try! SPTUser(from: data, with: response)
                print("\(user.canonicalUserName) and this guy")
                self.userDefaults.set(user.canonicalUserName, forKey: "current_spotify_username")
            }else {
                print ("error getting username")
                print (error)
            }
        })
        
        //self.playlist_access.getYourSpotifyLibrary()
        //let array1 = self.playlist_access.get_spotify_playlists()
        //let array2 = self.playlist_access.all_spotify_playlist_names
        //let array3 = self.playlist_access.get_spotify_all_tracks()
        
        //self.playlist_access.get_spotify_playlists()
        //self.playlist_access.get_spotify_all_tracks()
        //self.userDefaults.set(self.playlist_access.all_spotify_playlist_dict, forKey: "Spotify_playlist_dict")
        //self.userDefaults.set(self.playlist_access.get_spotify_all_tracks(), forKey: "Spotify_library_tracks")
       
        
        
        //self.player?.playSpotifyURI("spotify:track:58s6EuEYJdlb0kO7awm3Vp", startingWith: 0, startingWithPosition: 0, callback: { (error) in
        //if (error != nil) {
        //   print("playing!")
        //}
        //else {
        //  print ("error this one!")
        // }
        // })
        print("out here4")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
