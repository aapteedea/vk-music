//
//  DataFetcher.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 8/6/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit

class DataFetcher: NSObject {

    class func searchAudio(searchText: String!, successBlock: ((songs: Array<Audio>!) -> Void)!, failureBlock: ((error: NSError!) -> Void)? = nil) {
        
        let parameters: [NSObject: AnyObject] = ["q": searchText, "auto_complete": 1, "lyrics": 0, "performer_only": 0, "sort": 2, "search_own": 1, "count": 50]
        let request = VKRequest(method: "audio.search", andParameters: parameters, andHttpMethod: "GET")

        request.executeWithResultBlock({ (response: VKResponse!) -> Void in
            
                var songs: Array<Audio> = []

                let dict = response.json as! NSDictionary
                let items = dict["items"] as! NSArray

                for item in items {
                    let song = Audio(vkDictionary: item as! NSDictionary)
                    songs.append(song)
                }
                
                successBlock(songs: songs)
            },

            errorBlock: { (error: NSError!) -> Void in
                NSLog("\(error)")
                if let block = failureBlock { block(error: error) }
            }
        )
    }
    
    class func audioInfo(URL: NSURL, successBlock: ((size: Int) -> Void)!, failureBlock: ((error: NSError!) -> Void)? = nil) {

        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "HEAD"
        
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                NSLog("\(error)")
                failureBlock?(error: error)
                return
            }
            if let response = response {
                let contentLength = response.expectedContentLength
                successBlock?(size: Int(contentLength))
            }
        }).resume()
    }
    
}
