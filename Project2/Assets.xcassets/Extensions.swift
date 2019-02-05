//
//  Extensions.swift
//  Project2
//
//  Created by virdeshp on 1/4/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import UIKit


let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(imageurlstring: String) {
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: imageurlstring as NSString) as?
            UIImage {
            self.image = cachedImage
            print ("cached image")
            return
        }
        let url = URL(string: imageurlstring)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
        
            if error != nil {
                print(error)
                return
            }
        
            DispatchQueue.main.async {
                            
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: imageurlstring as NSString)
                    print("downloaded image")
                    self.image = downloadedImage
                }
                            
            }
        
        }).resume()
    }
    
    
    
}
