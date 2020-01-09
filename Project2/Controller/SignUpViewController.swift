//
//  SignUpViewController.swift
//  Project2
//
//  Created by virdeshp on 10/7/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import UIKit



class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email_text_field: UITextField!
    @IBOutlet weak var name_text_field: UITextField!
    @IBOutlet weak var username_text_field: UITextField!
    @IBOutlet weak var password_text_field: UITextField!
    @IBOutlet weak var sign_up_button: UIButton!
    @IBOutlet weak var email_error_label: UILabel!
    @IBOutlet weak var name_error_label: UILabel!
    @IBOutlet weak var username_error_label: UILabel!
    @IBOutlet weak var password_error_label: UILabel!
    var email_error = false
    var name_error = false
    var username_error = false
    var password_error = false
    var current_text_field: UITextField?
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var new_user =  UserAccount()
    let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
                     "~-]+)*|\\“(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
                     "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\\“)@(?:(?:[a-z0-9](?:[a-" +
                     "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
                     "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
                     "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
                     "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    var emailTest: NSPredicate!
    
    override func viewDidLoad() {
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UITextField.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        
              
        self.navigationController?.navigationBar.layer.backgroundColor = self.view.layer.backgroundColor
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
             
        email_text_field.delegate = self
        email_text_field.tag = 1
        email_text_field.layer.cornerRadius = 5
        name_text_field.delegate = self
        name_text_field.tag = 2
        name_text_field.layer.cornerRadius = 5
        username_text_field.delegate = self
        username_text_field.tag = 3
        username_text_field.layer.cornerRadius = 5
        password_text_field.delegate = self
        password_text_field.tag = 4
        password_text_field.layer.cornerRadius = 5
        
        email_error_label.isHidden = true
        email_error_label.layer.cornerRadius = 5
        
        name_error_label.isHidden = true
        name_error_label.layer.cornerRadius = 5
        
        username_error_label.isHidden = true
        username_error_label.layer.cornerRadius = 5
        
        password_error_label.isHidden = true
        password_error_label.layer.cornerRadius = 5
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        email_text_field.text = ""
        name_text_field.text = ""
        password_text_field.text = ""
        username_text_field.text = ""
        
        email_error_label.isHidden = true
        email_error_label.layer.cornerRadius = 5
               
        name_error_label.isHidden = true
        name_error_label.layer.cornerRadius = 5
               
        username_error_label.isHidden = true
        username_error_label.layer.cornerRadius = 5
               
        password_error_label.isHidden = true
        password_error_label.layer.cornerRadius = 5
        
        email_text_field.layer.borderColor = UIColor.clear.cgColor
        email_text_field.layer.borderWidth = 0
        email_text_field.textColor = UIColor.black
        
        name_text_field.layer.borderColor = UIColor.clear.cgColor
        name_text_field.layer.borderWidth = 0
        name_text_field.textColor = UIColor.black
        
        password_text_field.layer.borderColor = UIColor.clear.cgColor
        password_text_field.layer.borderWidth = 0
        password_text_field.textColor = UIColor.black
        
        username_text_field.layer.borderColor = UIColor.clear.cgColor
        username_text_field.layer.borderWidth = 0
        username_text_field.textColor = UIColor.black
    }
    
    func is_email_valid(_ email: String) -> Bool {
        return emailTest.evaluate(with: email)
    }
    
    
    @IBAction func go_to_user_sign_in(_ sender: Any) {
        
        if let usersigninVC = self.storyboard?.instantiateViewController(withIdentifier: "usersigninVC") {
            self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            self.navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.white
            self.navigationController?.pushViewController(usersigninVC, animated: true)
        }
    
    }
    
    @IBAction func sign_up_and_go_to_service_sign_in(_ sender: Any) {
        print("sign_up_and_go_to_service_sign_in")
        
        if let currently_active_text_field = current_text_field {
                   currently_active_text_field.resignFirstResponder()
        }
       
        if all_fields_check() {
            print("all checks passed")
            current_text_field?.endEditing(true)
            
            //new_user.register_new_user() - > do this is service sign in after we've signed up for services
            if let servicesigninVC = self.storyboard?.instantiateViewController(withIdentifier: "servicesigninVC") as? ServiceSignInViewController {
                self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
                self.navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.white
                
                servicesigninVC.new_user = self.new_user
                self.navigationController?.pushViewController(servicesigninVC, animated: true)
            }
        } else {
            print("else ")
            if name_error || name_text_field.text == "" {
                print ("name_error || name_text_field.text == ni")
                name_text_field.layer.borderColor = UIColor.systemPink.cgColor
                name_text_field.layer.borderWidth = 1
                name_error_label.isHidden = false
                name_error_label.text = "Please enter a Name"
            }
            
            if password_error || password_text_field.text == "" {
                print ("password_error || password_text_field.text == ni")
                password_text_field.layer.borderColor = UIColor.systemPink.cgColor
                password_text_field.layer.borderWidth = 1
                password_error_label.isHidden = false
                password_error_label.text = "Please enter a password"
            }
            
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
            if textField.tag == 1 {
                //email
                //check if thats a valid email address
                 if textField.text != nil {
                    if is_email_valid(textField.text!) {
                        new_user.email = textField.text
                        email_error = false
                        
                        email_error_label.isHidden = true
                        email_error_label.text = "Error"
                        
                    } else {
                        // Please enter a valid email address
                        print("Please enter a valid email address")
                        textField.layer.borderColor = UIColor.systemPink.cgColor
                        textField.layer.borderWidth = 1
                        textField.textColor = UIColor.systemPink
                        email_error = true
                        
                        email_error_label.isHidden = false
                        email_error_label.text = "Please enter a valid email address"
                       
                    }
                }
            } else if textField.tag == 2 {
                //Name
                 if textField.text != nil {
                    new_user.name = textField.text
                    name_error = false
                 } else {
                    name_error = true
                }
             
                
            } else if textField.tag == 3 {
                //username
                print("tag 3")
                
                 if textField.text != nil {
                    print(textField.text)
                    new_user.username = textField.text
                    new_user.check_if_username_exists_in_firebase().done { found_user in
                        if found_user {
                            // Sorry that username already exists!
                            print("Sorry that username already exists!")
                            textField.layer.borderColor = UIColor.systemPink.cgColor
                            textField.layer.borderWidth = 1
                            textField.textColor = UIColor.systemPink
                            self.username_error = true
                            
                            self.username_error_label.isHidden = false
                            self.username_error_label.text = "Sorry that username already exists!"
                            
                         
                        } else {
                            self.new_user.username = textField.text
                            self.username_error = false
                            
                            self.username_error_label.isHidden = true
                            self.username_error_label.text = "Error"
                        }
                    }
                }
            } else if textField.tag == 4 {
                //password
                 if textField.text != nil {
                    new_user.password = textField.text
                    password_error = false
                 } else {
                    password_error = true
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
            email_error_label.isHidden = true
            email_error_label.text = "Error"

        } else if textField.tag == 2 {
            name_error_label.isHidden = true
            name_error_label.text = "Error"
                   
        } else if textField.tag == 3 {
            username_error_label.isHidden = true
            username_error_label.text = "Error"
 
        } else if textField.tag == 4 {
            password_error_label.isHidden = true
            password_error_label.text = "Error"

        }
        
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        print ("text change detected")
    }
    
    
    func all_fields_check () -> Bool {
        
        if email_text_field.text != nil && username_text_field.text != nil && name_text_field.text != nil && password_text_field != nil {
            
            print("returning combined error status")
            print ("username error is \(username_error)")
            print ("password error is \(password_error)")
            print ("name error is \(name_error)")
            print ("email error is \(email_error)")
            
            if (email_error || username_error || password_error || name_error) {
                return false
            } else {
                return true
            }
        }
        
        print ("returning false")
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
