//
//  HttpController.swift
//  Tutorial_2_Online_MusicPlayer
//
//  Created by Edward Lucas on 9/20/14.
//  Copyright (c) 2014 Yan. All rights reserved.
//
import UIKit
class HttpController :NSObject{
    
    var viewControllerDelegate:HttpProtocol?
    
    

    func onSearch(url:String){
        
   
        var urlPath = NSURL(string: url)
        var request = NSURLRequest(URL: urlPath)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
                (response,rawJsonData,error) -> Void in
            
            //case JsonData into NSDictonary type
            let convertedData = NSJSONSerialization.JSONObjectWithData(rawJsonData, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            
            
                    println(convertedData) 
            
            self.viewControllerDelegate?.didReResults(convertedData)
            
        })
    }
}