//
//  MessageViewController.swift
//  Project2
//
//  Created by virdeshp on 5/7/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation
import UIKit

class MessageViewController: UIViewController {
    
    
    let bottomView = BottomView()
    let alertController = UIAlertController(title: nil, message: "Takes the appearance of the bottom bar if specified; otherwise, same as UIActionSheetStyleDefault.", preferredStyle: .actionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        // ...
    }
    
    let OKAction = UIAlertAction(title: "OK", style: .default) { action in
        // ...
    }
    
    let destroyAction = UIAlertAction(title: "Destroy", style: .destructive) { action in
        print (action)
    }
    
    
    @IBAction func alertbutton(_ sender: Any) {
        
        /*self.present(alertController, animated: true) {
            // ...
        }
        */
        bottomView.bringupview(id: "")
        
        
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        alertController.addAction(destroyAction)
        
       
    }
    
    
}
