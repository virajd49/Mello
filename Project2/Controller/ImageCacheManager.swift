//
//  ImageCacheManager.swift
//  Project2
//
//  Created by virdeshp on 12/2/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit


/*
 
 I think this is a cachemanager I found off of stackoverflow or somewhere, I'm not sure. It's used all over the app where ever we load images.
 
 
 
 */
class ImageCacheManager {
    
    // MARK: Types
    
    static let imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        
        cache.name = "ImageCacheManager"
        
        // Max 20 images in memory.
        cache.countLimit = 30
        
        // Max 10MB used.
        cache.totalCostLimit = 20 * 1024 * 1024
        
        return cache
    }()
    
    // MARK: Image Caching Methods
    
    func cachedImage(url: URL) -> UIImage? {
        return ImageCacheManager.imageCache.object(forKey: url.absoluteString as NSString)
    }
    
    func fetchImage(url: URL, completion: @escaping ((UIImage?) -> Void)) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            print ("\(error)")
//            print ("\(response)")
//            let dataAsString = String(data: data!, encoding: .utf8)
//            print(dataAsString)
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200, let data = data else {
                // Your application should handle these errors appropriately depending on the kind of error.
                //print ("http error for image")
                DispatchQueue.main.async {
                    completion(nil)
                }
                
                return
            }
            //print ("no http error for image")
            if let image = UIImage(data: data) {
                
                ImageCacheManager.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(UIImage())
                }
            }
        }
        
        task.resume()
    }
    
}
