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
        
        var parameters: [NSObject: AnyObject] = ["q": searchText, "auto_complete": 1, "lyrics": 0, "performer_only": 0, "sort": 2, "search_own": 1, "count": 50]
        var request = VKRequest(method: "audio.search", andParameters: parameters, andHttpMethod: "GET")

        request.executeWithResultBlock({ (response: VKResponse!) -> Void in
            
                var songs: Array<Audio> = []

                var dict = response.json as! NSDictionary
                var items = dict["items"] as! NSArray

                for item in items {
                    var song = Audio(vkDictionary: item as! NSDictionary)
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

        var URLRequest = NSMutableURLRequest(URL: URL)
        URLRequest.HTTPMethod = "HEAD"
        
        var operation = AFHTTPRequestOperation(request: URLRequest)
        operation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in

            var headers = operation.response.allHeaderFields as NSDictionary
            var contentLength = headers.objectForKey("Content-Length") as! String

            successBlock(size: contentLength.toInt()!)
            
            }) { (operation, error) -> Void in
                if let block = failureBlock { block(error: error) }
        }
        
        NSOperationQueue.mainQueue().addOperation(operation)
    }
    
}
