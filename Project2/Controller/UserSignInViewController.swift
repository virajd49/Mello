//
//  UserSignInViewController.swift
//  Project2
//
//  Created by virdeshp on 10/7/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import UIKit



class UserSignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email_username_text_field: UITextField!
    @IBOutlet weak var password_text_field: UITextField!
    @IBOutlet weak var sign_in_button: UIButton!
    @IBOutlet weak var email_error_label: UILabel!
    @IBOutlet weak var password_error_label: UILabel!
    var email_username_check = false
    var password_check = false
    var user_login = UserAccount()
    var current_text_field: UITextField?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UITextField.endEditing(_:)))
              view.addGestureRecognizer(tap)
        
        email_username_text_field.delegate = self
        email_username_text_field.tag = 1
        email_username_text_field.layer.cornerRadius = 5
        password_text_field.delegate = self
        password_text_field.tag = 4
        password_text_field.layer.cornerRadius = 5
        
        email_error_label.isHidden = true
        email_error_label.layer.cornerRadius = 5
        
        password_error_label.isHidden = true
        password_error_label.layer.cornerRadius = 5
        
        self.navigationController?.navigationBar.layer.backgroundColor = self.view.layer.backgroundColor
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        email_username_text_field.text = ""
        password_text_field.text = ""
        email_error_label.isHidden = true
        password_error_label.isHidden = true
        
        email_error_label.isHidden = true
        email_error_label.layer.cornerRadius = 5
   
        password_error_label.isHidden = true
        password_error_label.layer.cornerRadius = 5
               
        email_username_text_field.layer.borderColor = UIColor.clear.cgColor
        email_username_text_field.layer.borderWidth = 0
        email_username_text_field.textColor = UIColor.black
               
        password_text_field.layer.borderColor = UIColor.clear.cgColor
        password_text_field.layer.borderWidth = 0
        password_text_field.textColor = UIColor.black
             
    }
    
    
    @IBAction func sign_in_action(_ sender: Any) {
        
        if let currently_active_text_field = current_text_field {
            currently_active_text_field.resignFirstResponder()
        }
        
        if email_username_check {
            user_login.does_user_exist_in_db(username_or_email: email_username_text_field.text!).done { return_string in
                if return_string != nil {
                    print(return_string!)
                    
                    self.email_error_label.text = return_string
                    self.email_error_label.isHidden = false
                    
                    self.email_username_text_field.layer.borderColor = UIColor.systemPink.cgColor
                    self.email_username_text_field.layer.borderWidth = 1
                    self.email_username_text_field.textColor = UIColor.systemPink
                    return
                } else {
                    print("we reach password check")
                    if self.password_check {
                        print("password check is true")
                             //Authenticate credentials
                             
                             //if authenticated move ahead
                             
                             //else
                             
                        self.user_login.authenticate_login_creds(username_or_email: self.email_username_text_field.text!).done { auth_check in
                                 if auth_check != nil {
                                     print (auth_check!)
                                     
                                     self.password_error_label.text = auth_check
                                     self.password_error_label.isHidden = false
                                     
                                     self.password_text_field.layer.backgroundColor = UIColor.systemPink.cgColor
                                     self.password_text_field.layer.borderWidth = 1
                                     self.password_text_field.textColor = UIColor.systemPink
                                     return
                                 } else {
                                     print("auth check done")
                                     self.user_login.login_and_save_user_on_device()
                                     self.go_to_servicesVC()
                                 }
                             }
                    } else {
                        print("password check is false")
                    }
                    
                }
            }
        }
     
      
    }
    
    func go_to_servicesVC () {
        
        //Here - we need to grab the sessions from the DB 
        if let servicesigninVC = self.storyboard?.instantiateViewController(withIdentifier: "servicesigninVC") {
                  self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
                  self.navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.white
                  self.navigationController?.pushViewController(servicesigninVC, animated: true)
              }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
           print("textFieldDidEndEditing")
        if textField.tag == 1 {
            print("tag = 1")
            if textField.text != nil {
                //email
                //check if thats a valid email address
                email_username_check = true
                
                if (textField.text?.contains("@"))! {
                    user_login.email = textField.text
                } else {
                    user_login.username = textField.text
                }
                
            } else {
                email_username_check = false
            }
        } else if textField.tag == 4 {
            print("tag = 2 text is \(textField.text)")
            if textField.text != nil {
                password_check = true
                print("password check is true")
                user_login.password = textField.text
            } else {
                password_check = false
            }
        }
           //If none of the fields are blank and all are valid values - make the button clickable
       }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        current_text_field = textField
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.borderWidth = 0
        textField.textColor = UIColor.black
        
        if textField.tag == 1 {
            email_error_label.text = "Error"
            email_error_label.isHidden = true
        } else if textField.tag == 2 {
            password_error_label.text = "Error"
            password_error_label.isHidden = true
        }
        
      }
    
}
