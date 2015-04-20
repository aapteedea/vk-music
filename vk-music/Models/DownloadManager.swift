//
//  DownloadManager.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 8/8/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit
import Foundation

let NewFilesAvailableNotification = "NewFilesAvailableNotification"

class DownloadManager: NSObject {
    
    static let sharedManager = DownloadManager()
    
    var configuration: NSURLSessionConfiguration!
    var manager: AFURLSessionManager!
    lazy var activeTasks = [String:NSURLSessionDownloadTask]()
    
    override init() {
        self.configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.manager = AFURLSessionManager(sessionConfiguration: self.configuration)
        super.init()
    }
        
    func startDownload(URL: NSURL!, suggestedFilename: String? = nil) -> NSURLSessionDownloadTask! {
        
        var request = NSURLRequest(URL: URL)

        var filename: String? = suggestedFilename
        var documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var documentsDirectoryURL = NSURL(fileURLWithPath: documentsDirectory, isDirectory: true)
        var tmpDirectoryURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        var downloadTask = manager.downloadTaskWithRequest(request, progress: nil,
            destination: { (targetPath: NSURL!, response: NSURLResponse!) -> NSURL! in

                if filename == nil {
                   filename = response.suggestedFilename!
                }

                return tmpDirectoryURL?.URLByAppendingPathComponent(filename!)
            },
            completionHandler: { (response: NSURLResponse!, filePath: NSURL!, error: NSError!) -> Void in
                if (error == nil) {

                    if filename == nil {
                        filename = response.suggestedFilename!
                    }

                    var srcURL = tmpDirectoryURL!.URLByAppendingPathComponent(filename!)
                    var destURL = documentsDirectoryURL!.URLByAppendingPathComponent(filename!)
                    
                    var fileError: NSError?
                    NSFileManager.defaultManager().moveItemAtURL(srcURL, toURL: destURL, error: &fileError)
                    if (fileError != nil) { NSLog("error: \(error)"); return }
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(NewFilesAvailableNotification, object: nil)
                }
            }
        )
        
        downloadTask.resume()
        self.activeTasks[URL.absoluteString!] = downloadTask
        return downloadTask
    }
    
    func cancelDonwload(URL: NSURL) -> Void {
        if let task = self.activeTasks[URL.absoluteString!] {
            task.cancel()
        }
    }
}
