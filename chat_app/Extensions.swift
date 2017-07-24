//
//  Extensions.swift
//  chat_app
//
//  Created by Xiaoping Weng on 6/27/17.
//  Copyright © 2017 Xiaoping Weng. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    
    func loadImageUsingCacheWithUrlString(urlString: String){
        
        self.image = nil
        
        //check cach iamge first
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            //hello world
            //fowejfowiejfowijefowiefjoewf
            print(123123123123)
                //this is second testing
            //this is a testing to pratice first branch
            return
        }
        
        //if no image in cache, then download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil{
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage  = UIImage(data: data!){
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage

                }
                
            }
        }).resume()
    }
}
