//
//  UserAccount.swift
//  Project2
//
//  Created by virdeshp on 10/10/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import PromiseKit

protocol UserAccountDelegate: UIViewController {
    
}


enum service_name: String {
    case apple = "apple"
    case spotify = "spotify"
    case youtube = "youtube"
}

enum subscription: String {
    case free = "free"
    case open = "open"
    case paid = "paid"
    case premium = "premium"
    case unlimited = "unlimited"
    case unknown = "unknown"
}

struct Service {
    var name: service_name!
    var subscription: subscription!
    //These are apple music specific - don't mean anything for Spotify or Youtube
    var can_play: Bool!
    var can_add: Bool!
}


class UserAccount: NSObject {
    
    let userDefaults = UserDefaults.standard
    var delegate: UserAccountDelegate!
    
    
    var email: String? = ""
    var password: String? = ""
    var name: String? = ""
    var username: String? = ""
    var services = [Service]()

    
    
    func set_as_logged_in () {
        userDefaults.setisLoggedIn(value: true)
    }
    
    func set_as_logged_out() {
        userDefaults.setisLoggedIn(value: false)
    }
    
    func is_user_logged_in () -> Bool {
        return userDefaults.getisLoggedIn()
    }
    
    func register_new_user () {
        
        guard !is_user_logged_in() else {
            return
        }
        
        //Set the user creds up with the Auth server
        //Set user creds up with the Database
        add_new_user_to_firebase()
        
        //Save current user data locally and token
        set_as_logged_in()
        save_current_user()
    }
    
    func login_user (user: UserAccount) -> Promise<Bool> {
        print("login_user")
        return Promise { seal in
        //Check against Auth server get token
            check_if_username_exists_in_firebase().done { found_user in
                if found_user {
                    self.set_as_logged_in()
                    self.save_current_user()
                    seal.fulfill(true)
                } else {
                    self.showAlert(title: "Ooops!", message: "We could not find any records in our database for those credentials")
                    seal.fulfill(false)
                }
            }
        }
        
        // Save current user data locally and token
        
    }
    
    
    func login_and_save_user_on_device () {
        self.set_as_logged_in()
        self.save_current_user()
    }
    
    //Save current username/UUID
    func save_current_user () {
        self.userDefaults.set(username, forKey: "currentUser_username")
        userDefaults.synchronize()
    }
    
    func remove_current_user () {
        userDefaults.removeObject(forKey: "currentUser_username")
    }
    
    
    //To get current username/UUID
    func get_current_user () -> String {
        print ("get_current_user")
        var current_username = ""
        if self.userDefaults.getisLoggedIn() {
            print("getting user right now \(userDefaults.value(forKey: "currentUser_username") as! String)")
            current_username = userDefaults.value(forKey: "currentUser_username") as! String
        }
        return current_username
    }
    
    // MARK: Firebase Stuff
    func add_new_user_to_firebase () {

        var user_creds = [String: String]()
        
        user_creds.updateValue(email!, forKey: "email")
        user_creds.updateValue(password!, forKey: "password")
        user_creds.updateValue(name!, forKey: "name")
        
        var services_dict = [String: [String: String]]()
        for service in services {
            var temp_dict = [String: String] ()
            temp_dict.updateValue(service.subscription.rawValue, forKey:"subscription_type")
            temp_dict.updateValue(String(service.can_play), forKey:"can_play")
            temp_dict.updateValue(String(service.can_add), forKey:"can_add")
            services_dict.updateValue(temp_dict, forKey: service.name.rawValue)
        }
        
        let final_user_dict = [username: user_creds]
        let root_ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        root_ref.child("user_db").child("users").updateChildValues(final_user_dict) { (err, ref) in
            if err != nil {
                print ("ERROR saving post value")
                print (err as! String)
                return
            }
            print ("saved post value to db")
            let services_dict = ["services": services_dict]
            root_ref.child("user_db").child("users").child(self.username!).updateChildValues(services_dict) { (err, ref) in
                if err != nil {
                    print ("ERROR saving post value")
                    print (err as! String)
                    return
                }
                print ("saved post value to db")
            }
        }
        
    }
    
    //called from sign up controller only after user has entered a username - self username has been assigned to what the user entered
    func check_if_username_exists_in_firebase () -> Promise<Bool> {
        return Promise { seal in
            print("check_if_username_exists_in_firebase")
            let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
            var found = false
            ref.child("user_db").child("users").observeSingleEvent(of: .value, with: { snapshot in
                print (snapshot.childrenCount)
                for child in snapshot.children {
                    print ("for child in snapshot children")
                    let snap = child as! DataSnapshot
                    print (snap.key)
                    print (self.username)
                    if self.username == snap.key  {
                        print("found a username!!")
                        found = true
                        break
                    }
                }
                print("promise should fulfill")
                seal.fulfill(found)
            })
        }
    }
    
    //called from sign up controller only after user has entered an email - self email has been assigned to what the user entered
    func check_if_email_exists_in_firebase () -> Bool {

        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        var found = false
        ref.child("user_db").child("users").observeSingleEvent(of: .value, with: { snapshot in
            print (snapshot.childrenCount)
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let temp_value = snap.value as! [String : String]
                if self.email == temp_value["email"]  {
                    found = true
                }
            }
               
        })
        return found
    }
    
    //Grabs all the services for a user given the username of self instance - requires the current username
    func get_user_subscriptions () -> Promise<[Service]> {
        return Promise { seal in
        print("get_user_subscriptions")
        let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
        var temp_services = [Service]()
        
        if self.username == "" {
            print("username is empty string")
            self.username = self.get_current_user()
        }
        print ("username is \(self.username)")
        
        ref.child("user_db").child("users").child(self.username!).child("services").observeSingleEvent(of: .value, with: { snapshot in
            print (snapshot.childrenCount)
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                
                let temp_value_dict = snap.value as! [String: String]
                let temp_key = snap.key as! String
                
                var temp_service = Service()
                switch temp_key {
                    case service_name.apple.rawValue:
                        temp_service.name = service_name.apple
                        print("apple service")
                        break
                    case service_name.spotify.rawValue:
                        temp_service.name = service_name.spotify
                        print("spotify service")
                        break
                    case service_name.youtube.rawValue:
                        temp_service.name = service_name.youtube
                        print("youtube service")
                        break
                    default:
                        temp_service.name = service_name.youtube
                        break
                }
                    
                switch temp_value_dict["subscription_type"] {
                    case subscription.free.rawValue:
                        temp_service.subscription = subscription.free
                        print("free subs")
                        break
                    case subscription.paid.rawValue:
                        temp_service.subscription = subscription.paid
                        print("paid subs")
                        break
                    case subscription.premium.rawValue:
                        temp_service.subscription = subscription.premium
                        print("premium subs")
                        break
                    default:
                        temp_service.subscription = subscription.free
                        print("free subs")
                        break
                }
                
                if temp_value_dict["can_play"] == "true" {
                    temp_service.can_play = true
                } else {
                    temp_service.can_play = false
                }
                
                if temp_value_dict["can_add"] == "true" {
                    temp_service.can_add = true
                } else {
                    temp_service.can_add = false
                }
                    
                temp_services.append(temp_service)
                
            }
            seal.fulfill(temp_services)
        })
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
              self.delegate.present(alert, animated: true, completion: nil)
       }
    
    
    
    func does_user_exist_in_db (username_or_email: String) -> Promise<String?> {
        return Promise { seal in
            if username_or_email.contains("@") {
                if !check_if_email_exists_in_firebase() {
                    seal.fulfill("We could'nt find an account with that email address, Sign up ?")
                } else {
                    seal.fulfill(nil)
                }
            } else {
                check_if_username_exists_in_firebase().done { found_user in
                    print("found user returned")
                    if !found_user {
                        print("found user is false")
                        seal.fulfill("We could'nt find an account with that username address, Sign up ?")
                    } else {
                        print("found user is true")
                        seal.fulfill(nil)
                    }
                }
            }
                    
        }
    }
    
    func refresh_apple_service_info (subscription: subscription, can_play: Bool, can_add: Bool) {
        
        var services_attributes_dict = [String: String]()
              for service in services {
                if service.name == service_name.apple {
                    services_attributes_dict.updateValue(service.subscription.rawValue, forKey:"subscription_type")
                    services_attributes_dict.updateValue(String(service.can_play), forKey:"can_play")
                    services_attributes_dict.updateValue(String(service.can_add), forKey:"can_add")
                }
              }
        
        
        if !services_attributes_dict.isEmpty {
            let root_ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
            root_ref.child("user_db").child("users").child(self.username!).child("services").child(service_name.apple.rawValue).updateChildValues(services_attributes_dict) { (err, ref) in
                if err != nil {
                    print ("ERROR saving post value")
                    print (err as! String)
                    return
                }
                print ("saved post value to db")
            }
        }
    }
    
    
    func refresh_spotify_subscription () {
        var services_attributes_dict = [String: String]()
                     for service in services {
                       if service.name == service_name.spotify {
                           services_attributes_dict.updateValue(service.subscription.rawValue, forKey:"subscription_type")
                           services_attributes_dict.updateValue(String(service.can_play), forKey:"can_play")
                           services_attributes_dict.updateValue(String(service.can_add), forKey:"can_add")
                       }
                     }
               
               
               if !services_attributes_dict.isEmpty {
                   let root_ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
                   root_ref.child("user_db").child("users").child(self.username!).child("services").child(service_name.spotify.rawValue).updateChildValues(services_attributes_dict) { (err, ref) in
                       if err != nil {
                           print ("ERROR saving post value")
                           print (err as! String)
                           return
                       }
                       print ("saved post value to db")
                   }
               }
    
    }
    
    func refresh_youtube_subscription () {
        var services_attributes_dict = [String: String]()
                     for service in services {
                       if service.name == service_name.youtube {
                           services_attributes_dict.updateValue(service.subscription.rawValue, forKey:"subscription_type")
                           services_attributes_dict.updateValue(String(service.can_play), forKey:"can_play")
                           services_attributes_dict.updateValue(String(service.can_add), forKey:"can_add")
                       }
                     }
               
               
               if !services_attributes_dict.isEmpty {
                   let root_ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
                   root_ref.child("user_db").child("users").child(self.username!).child("services").child(service_name.youtube.rawValue).updateChildValues(services_attributes_dict) { (err, ref) in
                       if err != nil {
                           print ("ERROR saving post value")
                           print (err as! String)
                           return
                       }
                       print ("saved post value to db")
                   }
               }
    
    }
    
    
    func authenticate_login_creds (username_or_email: String) -> Promise<String?> {
        print("authenticate login creds")
        return Promise { seal in
            //Need the proper authentication routine here
            var authenticated: String? = "We could not authneticate those credentials, forgot password ?"
            let ref = Database.database().reference(fromURL: "https://project2-a2c32.firebaseio.com/")
             if username_or_email.contains("@") {
              
                 ref.child("user_db").child("users").observeSingleEvent(of: .value, with: { snapshot in
                     print (snapshot.childrenCount)
                     for child in snapshot.children {
                        let snap = child as! DataSnapshot
                        let temp_dict = snap.value as! [String : String]
                        if self.email == temp_dict["email"] {
                            if self.password == temp_dict["email"] {
                                authenticated = nil
                            }
                         }
                     }
                    seal.fulfill(authenticated)
                 })
                
             } else {
                ref.child("user_db").child("users").observeSingleEvent(of: .value, with: { snapshot in
                    print (snapshot.childrenCount)
                    for child in snapshot.children {
                        let snap = child as! DataSnapshot
                        if username_or_email == snap.key {
                            let temp_dict = snap.value as! [String : Any]
                            if self.password == temp_dict["password"] as! String {
                                 authenticated = nil
                            }
                        }
                    }
                    seal.fulfill(authenticated)
                })
                
            }
        }
        
    }
    
    
    
       
    
    
    
}