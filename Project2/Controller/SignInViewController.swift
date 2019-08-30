//
//  SignInViewController.swift
//  Project2
//
//  Created by virdeshp on 3/18/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit
import MediaPlayer
import Firebase
import GoogleAPIClientForREST
import GoogleSignIn



/*This is the Sign in View controller, here we initiate and handle user login into streaking service accounts:
 Current order is:
 Spotify authentication sequence -> Google authentication sequence -> Apple authnetication sequence
 
 Ignore all the new spotify sdk stuff, we are sticking to the old sdk for now.
 Most of what is going on in this view controller is following standard auth flow as documented by Spotify, apple and google.
 */

class SignInViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
   
    let SpotifyClientID = "5b5198fe415746c0a9410281d041a4f9"
    let SpotifyRedirectURL = URL(string: "viraj-project2://spotify-login-callback")!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefaults = UserDefaults.standard
    var auth = SPTAuth.defaultInstance()
    var player: SPTAudioStreamingController?
    var session: SPTSession!
    var loginUrl: URL?
    var offset: TimeInterval = 0.0
    var paused: Bool = false
    var playing: Bool = false
    let appleauthority = AppleMusicControl()
    var access_token = ""
    var ErrorPointer: ErrorPointer = nil
    private let scopes = [kGTLRAuthScopeYouTubeReadonly,kGTLRAuthScopeYouTube]
    let signInButton = GIDSignInButton()
    private let service = GTLRYouTubeService()
    //let requestedScopes: SPTScope = [.appRemoteControl, .userReadCurrentlyPlaying]
    var poller = now_playing_poller.shared
    let myGroup = DispatchGroup()
    
    
    //NEW SPOTIFY SDK STUFF - IGNORE THIS - THIS IS FROM WHEN I TRIED TO SWITCH OVER TO THE NEW API AND ABANDONED IT CAUSE THE USE FLOW WAS WEIRD
//    lazy var configuration = SPTConfiguration(
//        clientID: SpotifyClientID,
//        redirectURL: SpotifyRedirectURL
//    )
//
//    //Setup session manager for authentication
//    lazy var session_manager: SPTSessionManager = {
//        if let tokenSwapURL = URL(string: "https://viraj-project2.herokuapp.com/api/token"),
//            let tokenRefreshURL = URL(string: "https://viraj-project2.herokuapp.com/api/refresh_token") {
//            self.configuration.tokenSwapURL = tokenSwapURL
//            self.configuration.tokenRefreshURL = tokenRefreshURL
//            self.configuration.playURI = ""  //if empty - will play last played song, if given specific URI will play that song
//        }
//        let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
//        return manager
//    }()
    

    //This is called at the end of the spotify authentication sequence
    //This is the beginning of the google authentocation sequence - this sets up the auth instance and makes the button visible on the screen.
    //My understanding is that the google sign in flow is initiated when the sign in button is pressed, unsure why it gives us a auth failed error before we click the button, will have to go over google auth flow documentation
    func google_sign_in_initialize(){
        print("In Google sign in set up")
        //Google sign in initialization
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance()?.clientID = "898533962642-u5k25pe6v3jgso5o8hkq16k1jalhec1l.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().signInSilently()
        userDefaults.setValue("AIzaSyCWyumtxOwkf0zXWsh2Pe0vSwXFNHfax8E", forKey: "google_api_key")
        
        view.addSubview(signInButton)
        signInButton.center.x = self.view.center.x
        signInButton.frame.origin.y = 200
        
        
      
    }
    
    //IGNORE - inactive code for now - don't press the Sign in to Spotify button on the screen
    @IBAction func signIn(_ sender: Any) {
        
        //self.spotify_sign_button_old_sdk()
        //self.performSegue(withIdentifier: "toNewsFeed", sender: self)
    }
    
    
    @IBAction func signInToAppleMusic(_ sender: Any) {
        appleauthority.requestCloudServiceAuthorization()
        appleauthority.requestMediaLibraryAuthorization()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This is the beggining of the spotify authentication sequence
        self.spotify_sign_in_initialize_old_sdk()

    }
    
    func apple_sign_in_initialize () {
        
        //Was trying to make sure that the segue is called synchronously after the three apple auth calls - used dispatch groups for that - no sure if there is a simpler/better way to do this here
        
        //the three function calls are straightup apple code copied from their example music kit project - haven't touched it much at all - see AppleMusicControl.swift
        let mygroup = DispatchGroup()
        
        mygroup.enter()
        
        self.appleauthority.initialize()
        self.appleauthority.requestCloudServiceAuthorization()
        self.appleauthority.requestMediaLibraryAuthorization()
        print ("apple authorization requested")
        
        mygroup.leave()
        
        mygroup.notify(queue: .main) {
             //Here we move to the newsfeed
             self.performSegue(withIdentifier: "toNewsFeed", sender: self)
        }
        
        
    }
    
    @objc func movetonewsfeed (notification: Notification){
        print ("segue perform")
        self.performSegue(withIdentifier: "toNewsFeed", sender: self)
    }
    
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
            userDefaults.set(self.session.accessToken, forKey: "spotify_access_token")
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
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
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
                //Here we store it in user defaults for further use within the app
                self.userDefaults.set(user.canonicalUserName, forKey: "current_spotify_username")
                
                //Here we grab what is essentially the users latest library and playlists
                let playlist_access = UserAccess(myPlaylistQuery: MPMediaQuery.playlists(), myLibrarySongsQuery: MPMediaQuery.songs())
                playlist_access.get_spotify_playlists()
                playlist_access.get_spotify_all_tracks()
                print("username set")
            }else {
                print ("error getting username")
                print (error)
            }
        })
        //NotificationCenter.default.post(name: Notification.Name(rawValue: "loggedinperformsegue"), object: nil)
//        self.playlist_access.getYourSpotifyLibrary()
//        let array1 = self.playlist_access.get_spotify_playlists()
//        let array2 = self.playlist_access.all_spotify_playlist_names
//        let array3 = self.playlist_access.get_spotify_all_tracks()
        
      
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
        //self.performSegue(withIdentifier: "toNewsFeed", sender: self)
        
        //And then we proceed to the google authentication process.
        self.google_sign_in_initialize()
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
            self.apple_sign_in_initialize()
        }
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
        present(alert, animated: true, completion: nil)
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
 
    
    //Most of this is standard setup based on Spotify guidelines of their authentication flow
    //Here we initiate a SPT Auth instance
    func spotify_sign_in_initialize_old_sdk () {
        print("spotify_sign_in_initialize_old_sdk")
        //NotificationCenter.default.addObserver(self, selector: #selector(self.movetonewsfeed), name: Notification.Name(rawValue: "loggedinperformsegue"), object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateAfterFirstLogin), name: Notification.Name(rawValue: "loginSuccessfull"), object: nil )
        
        //Spotify sign in initialization
        SPTAuth.defaultInstance().clientID = SpotifyClientID
        SPTAuth.defaultInstance().redirectURL = SpotifyRedirectURL
        SPTAuth.defaultInstance().tokenSwapURL = URL(string: "https://viraj-project2.herokuapp.com/api/token")
        SPTAuth.defaultInstance().tokenRefreshURL = URL(string: "https://viraj-project2.herokuapp.com/api/refresh_token")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthUserLibraryReadScope, SPTAuthUserLibraryModifyScope, SPTAuthUserReadPrivateScope]
        //loginUrl = SPTAuth.defaultInstance().spotifyAppAuthenticationURL()
        //This is the AppAuthenticationURL format  - using a hardcoded value because SPTAuth from the old sdk does not have 'user-read-playback-state' and 'user-read-recently-played' scopes.
        loginUrl = URL(string: "spotify-action://authorize?nolinks=true&nosignup=true&response_type=code&scope=streaming%20playlist-read-private%20playlist-modify-public%20playlist-modify-private%20user-read-playback-state%20user-library-read%20user-library-modify%20user-read-recently-played&utm_source=spotify-sdk&utm_medium=ios-sdk&utm_campaign=ios-sdk&redirect_uri=viraj-project2%3A%2F%2Fspotify-login-callback&show_dialog=true&client_id=5b5198fe415746c0a9410281d041a4f9")
        print(loginUrl)
        print(SPTAuth.defaultInstance().spotifyAppAuthenticationURL())
        print(SPTAuth.defaultInstance().spotifyWebAuthenticationURL())
        
        //Now we go to check if we already have a valid session or if the user needs to sign in
        self.spotify_sign_in_session_check_old_sdk()
        
    }

    func spotify_sign_button_old_sdk () {
        //User has to sign in - here we use the loginUrl that we set up in spotify_sign_in_initialize_old_sdk.
        //openURL on that URL takes us to the spotify app to get authorized - when we come back - app delegate takes control - so go to app deleagte from here to follow the flow.
        
        if UIApplication.shared.openURL(loginUrl!)
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
                            self.userDefaults.set("Spotify", forKey: "UserAccount") //<- this value is independent of any auth flow, it is used as a flag throughout the app to simulate if the user uses apple music or spotify - see top of this file for full explanantion.
                            self.userDefaults.set(session?.accessToken, forKey: "spotify_access_token")
                            self.userDefaults.set(session?.encryptedRefreshToken, forKey: "spotify_refresh_token")
                            self.userDefaults.synchronize()
                            self.session = session
                            print("Session was refreshed")
                            
                            //As soon as we are done authenticating, we want to get the currently playing item from apple/spotify
                            //I'm not sure if this is blocking anything as of now, but it can probably go on a background thread
                            self.poller.grab_now_playing_item().done {
                                print("Done checking for now playing")
                            }
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
                    self.poller.grab_now_playing_item().done {
                        print ("Done checking for now playing")
                    }
                    
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
    
//    func spotify_sign_in_session_check_new_sdk () {
//
//
//        appDelegate.sessionManager.initiateSession(with: requestedScopes, options: .default)
//
//        if let sessionObj: AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject {
//            print("why are we here if obj is NSNull")
//            if let sessionDataObj = sessionObj as? NSData {
//
//                let session =  NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj as Data) as! SPTSession
//
//                //if the session has expired renew it
//                if session.isExpired {
//                    print ("session is expired")
//                    session_manager.session = session
//                    session_manager.renewSession()
//
//
//                } else {
//                    //if not directly connect to the remoteApp
//                    print ("session is valid")
//                    let access_token = self.userDefaults.value(forKey: "spotify_access_token") as! String
//                    print(access_token)
//                    self.session = session
//                    NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
//
//                }
//            }
//
//        } else {
//
//            //Initiates session for authentication - takes user to sign in page - if token is valid - returns immmediately
//            appDelegate.sessionManager.initiateSession(with: requestedScopes, options: .default)
//        }
//    }
//
//
//    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
//        print("success", session)
//        print("We authenticated succesfully !!")
//        //We come here once the user succesfully authenticates
//        //Once the user succesfully authenticates we can remote connect to the spotify app.
//        self.userDefaults.set(session.accessToken, forKey: "spotify_access_token")
//        self.userDefaults.set(session.refreshToken, forKey: "spotify_refresh_token")
//        let sessionData =  try? NSKeyedArchiver.archivedData(withRootObject: session, requiringSecureCoding: false)
//        print (self.session_manager.session.debugDescription)
//        self.userDefaults.set(sessionData, forKey: "SpotifySession")
//
//        userDefaults.set("Spotify", forKey: "UserAccount")
//        userDefaults.synchronize()
//        // 6 - Tell notification center login is successful
//        print ("oit here 7")
//        self.poller.grab_now_playing_item()
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
//
//    }
//
//    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
//        print("fail", error)
//        appDelegate.sessionManager.initiateSession(with: requestedScopes, options: .default)
//    }
//
//    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
//        print("renewed", session)
//        self.userDefaults.set(session.accessToken, forKey: "spotify_access_token")
//        self.userDefaults.set(session.refreshToken, forKey: "spotify_refresh_token")
//        let sessionData =  try? NSKeyedArchiver.archivedData(withRootObject: session, requiringSecureCoding: false)
//        print (self.session_manager.session.debugDescription)
//        self.userDefaults.set(sessionData, forKey: "SpotifySession")
//
//        userDefaults.set("Spotify", forKey: "UserAccount")
//        userDefaults.synchronize()
//        // 6 - Tell notification center login is successful
//        print ("oit here 7")
//        self.poller.grab_now_playing_item()
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
//
//    }
//
//
  
}
