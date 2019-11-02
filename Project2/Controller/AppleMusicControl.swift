//
//  AppleMusicManager.swift
//  Project2
//
//  Created by virdeshp on 5/10/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation
import StoreKit
import UIKit
import MediaPlayer


/*This file is a direct copy from apple's music kit example project, changes made by me are mostly debugs - the only problem with apple auth stuff is the 'developerAuthenticationToken' - there is a specific process to generate this token, given on the apple developer docs website here -
    https://developer.apple.com/documentation/applemusicapi/getting_keys_and_creating_tokens
 
    and I was doing it wrong and running into some issues with the UserToken (used to work with the specific users library and playlists), which needs a proper developer token.
    after struggling a lot and wandering around on stack over flow
    - https://stackoverflow.com/questions/49547390/apple-music-kit-user-token-issue-ios-11-swift-4
    - I found this post  -
    https://stackoverflow.com/questions/45099905/applemusickit-sdk-sample-project-usertoken-issue
   - and used the python script solution given in the link in one of the comments -
    https://github.com/pelauimagineering/apple-music-token-generator
 
 - this script works great except that the developer token is only valid for a short amount of time:
  apple documention on the first link up there says the following - "The expiration time (exp) registered claim key, whose value must not be greater than 15777000 (6 months in seconds) from the Current Unix Time on the server."
    So 6 months is the max time allowed. The original python script has time = 1200 hrs which is roughly 50 days, but even with 50 days I was facing problems, so I reduced it to 480 hours (20 days) in the script. Every 20 days I need to generate a new dev token using that python script and paste it in this file and in AppleMusicManager.swift.
 
    This needs to be revisited and solved, I'm missing something here, at the time I had just been through too much chasing down this issue, so I gave up on it.
 
 */
class AppleMusicControl: NSObject {
    
    
    let cloudServiceController = SKCloudServiceController()
    var cloudServiceCapabilities = SKCloudServiceCapability()
    var cloudServiceStorefrontCountryCode = ""
    var userToken = ""
    var appleMusicManager: AppleMusicManager!
    let cloudServiceDidUpdateNotification = Notification.Name("cloudServiceDidUpdateNotification")
    //var musicPlayerManager: MusicPlayerManager!
    //let musicPlayerController = MPMusicPlayerController.systemMusicPlayer
    
    /// Notification that is posted whenever there is a change in the authorization status that other parts of the sample should respond to.
    let authorizationDidUpdateNotification = Notification.Name("authorizationDidUpdateNotification")
    
    /// The `UserDefaults` key for storing and retrieving the Music User Token associated with the currently signed in iTunes Store account.
    static let userTokenUserDefaultsKey = "UserTokenUserDefaultsKey"
 /*
    init(appleMusicManager: AppleMusicManager) {
        self.appleMusicManager = appleMusicManager
        
        super.init()
        
        let notificationCenter = NotificationCenter.default
        
        /*
         It is important that your application listens to the `SKCloudServiceCapabilitiesDidChangeNotification` and
         `SKStorefrontCountryCodeDidChangeNotification` notifications so that your application can update its state and functionality
         when these values change if needed.
         */
        
        notificationCenter.addObserver(self,
                                       selector: #selector(requestCloudServiceCapabilities),
                                       name: .SKCloudServiceCapabilitiesDidChange,
                                       object: nil)
        if #available(iOS 11.0, *) {
            notificationCenter.addObserver(self,
                                           selector: #selector(requestStorefrontCountryCode),
                                           name: .SKStorefrontCountryCodeDidChange,
                                           object: nil)
        }
        
        /*
         If the application has already been authorized in a previous run or manually by the user then it can request
         the current set of `SKCloudServiceCapability` and Storefront Identifier.
         */
        if SKCloudServiceController.authorizationStatus() == .authorized {
            requestCloudServiceCapabilities()
            
            /// Retrieve the Music User Token for use in the application if it was stored from a previous run.
            if let token = UserDefaults.standard.string(forKey: AppleMusicControl.userTokenUserDefaultsKey) {
                userToken = token
            } else {
                /// The token was not stored previously then request one.
                requestUserToken()
            }
        }
    }
*/
    func requestCloudServiceAuthorization() {
    
            print("cloud service autho reached")
        /*
       An application should only ever call `SKCloudServiceController.requestAuthorization(_:)` when their
       current authorization is `SKCloudServiceAuthorizationStatusNotDetermined`
         */
        guard SKCloudServiceController.authorizationStatus() == .notDetermined else {
            switch (SKCloudServiceController.authorizationStatus()) {
            case .authorized:
                print ("requestCloudServiceAuthorization - STATUS IS authorized")
                break
            case .denied:
                print ("requestCloudServiceAuthorization - STATUS IS denied")
                break
            case .restricted:
                print ("requestCloudServiceAuthorization - STATUS IS restricted")
                break
            default:
                print ("requestCloudServiceAuthorization - STATUS IS unknown")
                break
            }
            return
            
        }
        print ("requestCloudServiceAuthorization - STATUS NOT DETERMINED")
        /*
        `SKCloudServiceController.requestAuthorization(_:)` triggers a prompt for the user asking if they wish to allow the application
         that requested authorization access to the device's cloud services information.  This allows the application to query information
         such as the what capabilities the currently authenticated iTunes Store account has and if the account is eligible for an Apple Music
         Subscription Trial.
         
         This prompt will also include the value provided in the application's Info.plist for the `NSAppleMusicUsageDescription` key.
         This usage description should reflect what the application intends to use this access for.
         */
            
        SKCloudServiceController.requestAuthorization { [weak self] (authorizationStatus) in
            switch authorizationStatus {
                case .authorized:
                self?.requestCloudServiceCapabilities()
                
                self?.requestUserToken()
            default:
                break
            }
        
        NotificationCenter.default.post(name: (self?.authorizationDidUpdateNotification)!, object: nil)
        }
    }
    
    func requestMediaLibraryAuthorization() {
        
        print("med library autho reached")
        /*
         An application should only ever call `MPMediaLibrary.requestAuthorization(_:)` when their
         current authorization is `MPMediaLibraryAuthorizationStatusNotDetermined`
         */
        guard MPMediaLibrary.authorizationStatus() == .notDetermined else {
            
            switch (MPMediaLibrary.authorizationStatus()) {
                case .authorized:
                    print ("requestMediaLibraryAuthorization - STATUS IS authorized")
                    break
                case .denied:
                    print ("requestMediaLibraryAuthorization - STATUS IS denied")
                    break
                case .restricted:
                    print ("requestMediaLibraryAuthorization - STATUS IS restricted")
                    break
                default:
                    print ("requestMediaLibraryAuthorization - STATUS IS unknown")
                    break
            }
            return
            
        }
        print (" requestMediaLibraryAuthorization - STATUS NOT DETERMINED")
        /*
         `MPMediaLibrary.requestAuthorization(_:)` triggers a prompt for the user asking if they wish to allow the application
         that requested authorization access to the device's media library.
         
         This prompt will also include the value provided in the application's Info.plist for the `NSAppleMusicUsageDescription` key.
         This usage description should reflect what the application intends to use this access for.
         */

        MPMediaLibrary.requestAuthorization { (_) in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "AppleMusicMediaLibraryAuthorized"), object: nil)
            }
            NotificationCenter.default.post(name: (self.cloudServiceDidUpdateNotification), object: nil)
        }
        
    }
    
    // MARK: `SKCloudServiceController` Related Methods
    
    @objc func requestCloudServiceCapabilities() {
        cloudServiceController.requestCapabilities(completionHandler: { [weak self] (cloudServiceCapability, error) in
            guard error == nil else {
                fatalError("An error occurred when requesting capabilities: \(error!.localizedDescription)")
            }
            
            if cloudServiceCapability.contains(SKCloudServiceCapability.musicCatalogPlayback) {
                print("user has Apple Music subscription and can play music from apple music api")
            }

            if cloudServiceCapability.contains(SKCloudServiceCapability.addToCloudMusicLibrary) {
                print("user has an Apple Music subscription, can play music from api, also can add to their music library")
            }

            if cloudServiceCapability.contains(SKCloudServiceCapability.musicCatalogSubscriptionEligible) {
                print("user does not have subscription")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "NoAppleMusicSubscriptionPresent"), object: nil)
                }
            } else {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "AppleMusicSubscriptionPresent"), object: nil)
                }
            }
            
            self?.cloudServiceCapabilities = cloudServiceCapability
            
            NotificationCenter.default.post(name: (self?.cloudServiceDidUpdateNotification)!, object: nil)
        })
    }
    
    @objc func requestStorefrontCountryCode() {
        let completionHandler: (String?, Error?) -> Void = { [weak self] (countryCode, error) in
            guard error == nil else {
                print("An error occurred when requesting storefront country code: \(error!.localizedDescription)")
                return
            }
            
            guard let countryCode = countryCode else {
                print("Unexpected value from SKCloudServiceController for storefront country code.")
                return
            }
            print ("we did this guy 1")
            print (countryCode)
            self?.cloudServiceStorefrontCountryCode = countryCode
            
            let userDefaults = UserDefaults.standard
            
            userDefaults.set(countryCode, forKey: ("Country_code"))
            NotificationCenter.default.post(name: (self?.cloudServiceDidUpdateNotification)!, object: nil)
        }
        
        if SKCloudServiceController.authorizationStatus() == .authorized {
            if #available(iOS 11.0, *) {
                /*
                 On iOS 11.0 or later, if the `SKCloudServiceController.authorizationStatus()` is `.authorized` then you can request the storefront
                 country code.
                 */
                print("we did this guy 2")
                cloudServiceController.requestStorefrontCountryCode(completionHandler: completionHandler)
            } else {
                appleMusicManager.performAppleMusicGetUserStorefront(userToken: userToken, completion: completionHandler)
            }
        } else {
            determineRegionWithDeviceLocale(completion: completionHandler)
        }
    }
    
    func requestUserToken() {
        guard let developerToken = self.fetchDeveloperToken() else {
            return
        }
        print("we did this guy 4")
        self.requestStorefrontCountryCode()
        self.cloudServiceStorefrontCountryCode = "us"
        if SKCloudServiceController.authorizationStatus() == .authorized {
            
            let completionHandler: (String?, Error?) -> Void = { [weak self] (token, error) in
                guard error == nil else {
                    print("An error occurred when requesting user token: \(error!.localizedDescription)")
                    return
                }
                
                guard let token = token else {
                    print("Unexpected value from SKCloudServiceController for user token.")
                    return
                }
                
                self?.userToken = token
                print("user token is \(self!.userToken)")
                
                
                /// Store the Music User Token for future use in your application.
                let userDefaults = UserDefaults.standard
                
                userDefaults.set(token, forKey: (AppleMusicControl.userTokenUserDefaultsKey))
                userDefaults.synchronize()
                
                if self?.cloudServiceStorefrontCountryCode == "" {
                    self?.requestStorefrontCountryCode()
                    print ("we did this guy 3")
                }
                
                NotificationCenter.default.post(name: (self?.cloudServiceDidUpdateNotification)!, object: nil)
            }
            
            if #available(iOS 11.0, *) {
                print("ios 11")
                print("developer token is \(developerToken)")
                cloudServiceController.requestUserToken(forDeveloperToken: developerToken, completionHandler: completionHandler)
            } else {
                print("< ios 11")
                cloudServiceController.requestPersonalizationToken(forClientToken: developerToken, withCompletionHandler: completionHandler)
            }
        }
    }
    
    func determineRegionWithDeviceLocale(completion: @escaping (String?, Error?) -> Void) {
        /*
         On other versions of iOS or when `SKCloudServiceController.authorizationStatus()` is not `.authorized`, your application should use a
         combination of the device's `Locale.current.regionCode` and the Apple Music API to make an approximation of the storefront to use.
         */
        
        let currentRegionCode = Locale.current.regionCode?.lowercased() ?? "us"
        
        appleMusicManager.performAppleMusicStorefrontsLookup(regionCode: currentRegionCode, completion: completion)
    }
    
    func fetchDeveloperToken() -> String? {
        
        // MARK: ADAPT: YOU MUST IMPLEMENT THIS METHOD
        let developerAuthenticationToken: String? = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Iko3VDc3WjQ0V1oifQ.eyJpc3MiOiIyODJIMlU4VkZUIiwiaWF0IjoxNTcyMTA3ODMxLCJleHAiOjE1NzM4Mzk0MzF9.y7zHJXZ66kaHoo1PmE6fM8aceIfz6XhPwMzcAr3457jLn7EnF9DNY5qGo0GfkEjZWuVP4DMABOUxUYeNcW8evA"
        return developerAuthenticationToken
    }
    

    func initialize() {
        
        let notificationCenter = NotificationCenter.default
        //print("yeah yeah 1")
        /*
         It is important that your application listens to the `SKCloudServiceCapabilitiesDidChangeNotification` and
         `SKStorefrontCountryCodeDidChangeNotification` notifications so that your application can update its state and functionality
         when these values change if needed.
         */
        
        notificationCenter.addObserver(self,
                                       selector: #selector(requestCloudServiceCapabilities),
                                       name: .SKCloudServiceCapabilitiesDidChange,
                                       object: nil)
        if #available(iOS 11.0, *) {
            notificationCenter.addObserver(self,
                                           selector: #selector(requestStorefrontCountryCode),
                                           name: .SKStorefrontCountryCodeDidChange,
                                           object: nil)
            //print ("yeah yeah 2")
        }
        
        
        /*
         If the application has already been authorized in a previous run or manually by the user then it can request
         the current set of `SKCloudServiceCapability` and Storefront Identifier.
         */
        if SKCloudServiceController.authorizationStatus() == .authorized {
            requestCloudServiceCapabilities()
            //print ("yeah yeah 3")
            /// Retrieve the Music User Token for use in the application if it was stored from a previous run.
            
            
            
            if let token = UserDefaults.standard.string(forKey: AppleMusicControl.userTokenUserDefaultsKey) {
                userToken = token
                print("user token is \(userToken)")
                self.requestStorefrontCountryCode()
                print("then this")
            } else {
                /// The token was not stored previously then request one.
                print("was not stored previously")
                requestUserToken()
            }
            
            
        }
    }

    
    
    
    
}
