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

class AppleMusicControl: NSObject {
    
    
    let cloudServiceController = SKCloudServiceController()
    var cloudServiceCapabilities = SKCloudServiceCapability()
    var cloudServiceStorefrontCountryCode = ""
    var userToken = ""
    var appleMusicManager: AppleMusicManager!
    let cloudServiceDidUpdateNotification = Notification.Name("cloudServiceDidUpdateNotification")
    //var musicPlayerManager: MusicPlayerManager!
    let musicPlayerController = MPMusicPlayerController.systemMusicPlayer
    
    /// Notification that is posted whenever there is a change in the authorization status that other parts of the sample should respond to.
    let authorizationDidUpdateNotification = Notification.Name("authorizationDidUpdateNotification")
    
    /// The `UserDefaults` key for storing and retrieving the Music User Token associated with the currently signed in iTunes Store account.
    let userTokenUserDefaultsKey = "UserTokenUserDefaultsKey"
        
        
    
    func requestCloudServiceAuthorization() {
    
            print("cloud service autho reached")
        /*
       An application should only ever call `SKCloudServiceController.requestAuthorization(_:)` when their
       current authorization is `SKCloudServiceAuthorizationStatusNotDetermined`
         */
        guard SKCloudServiceController.authorizationStatus() == .notDetermined else { return }
        
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
        guard MPMediaLibrary.authorizationStatus() == .notDetermined else { return }
        
        /*
         `MPMediaLibrary.requestAuthorization(_:)` triggers a prompt for the user asking if they wish to allow the application
         that requested authorization access to the device's media library.
         
         This prompt will also include the value provided in the application's Info.plist for the `NSAppleMusicUsageDescription` key.
         This usage description should reflect what the application intends to use this access for.
         */
        
        MPMediaLibrary.requestAuthorization { (_) in
            NotificationCenter.default.post(name: (self.cloudServiceDidUpdateNotification), object: nil)
        }
    }
    
    // MARK: `SKCloudServiceController` Related Methods
    
    @objc func requestCloudServiceCapabilities() {
        cloudServiceController.requestCapabilities(completionHandler: { [weak self] (cloudServiceCapability, error) in
            guard error == nil else {
                fatalError("An error occurred when requesting capabilities: \(error!.localizedDescription)")
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
            
            self?.cloudServiceStorefrontCountryCode = countryCode
            
            NotificationCenter.default.post(name: (self?.cloudServiceDidUpdateNotification)!, object: nil)
        }
        
        if SKCloudServiceController.authorizationStatus() == .authorized {
            if #available(iOS 11.0, *) {
                /*
                 On iOS 11.0 or later, if the `SKCloudServiceController.authorizationStatus()` is `.authorized` then you can request the storefront
                 country code.
                 */
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
                
                /// Store the Music User Token for future use in your application.
                let userDefaults = UserDefaults.standard
                
                userDefaults.set(token, forKey: (self?.userTokenUserDefaultsKey)!)
                userDefaults.synchronize()
                
                if self?.cloudServiceStorefrontCountryCode == "" {
                    self?.requestStorefrontCountryCode()
                }
                
                NotificationCenter.default.post(name: (self?.cloudServiceDidUpdateNotification)!, object: nil)
            }
            
            if #available(iOS 11.0, *) {
                cloudServiceController.requestUserToken(forDeveloperToken: developerToken, completionHandler: completionHandler)
            } else {
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
        let developerAuthenticationToken: String? = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Iko3VDc3WjQ0V1oifQ.eyJpc3MiOiIyODJIMlU4VkZUIiwiaWF0IjoxNTIyMzc2MjkyLCJleHAiOjE1MjY2OTYyOTJ9.ANe09NkjAhMSGtjtKet8gwwOnIjsApWzW0em0SanZBE0aUWf-I-k02Q5vyg_Oq8vOaZxED2442zhmMGDoqZV1Q"
        return developerAuthenticationToken
    }
    

    func initialize() {
        
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
        
        if SKCloudServiceController.authorizationStatus() == .authorized {
            requestCloudServiceCapabilities()
            
            /// Retrieve the Music User Token for use in the application if it was stored from a previous run.
            if let token = UserDefaults.standard.string(forKey: userTokenUserDefaultsKey) {
                userToken = token
            } else {
                /// The token was not stored previously then request one.
                requestUserToken()
            }
        }
    }
    
    
    
    
    
}
