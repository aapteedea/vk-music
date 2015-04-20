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

class DownloadManager: NSObject, NSURLSessionDownloadDelegate {
    
    static let sharedManager = DownloadManager()
    
    var configuration: NSURLSessionConfiguration!
    var session: NSURLSession!
    var documentsDirectory: String!
    var documentsDirectoryURL: NSURL!
    var tmpDirectoryURL: NSURL!

    lazy var activeTasks = [String:(NSURLSessionDownloadTask, String?)]()
    
    override init() {
        super.init()
        self.configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration: self.configuration, delegate: self, delegateQueue: nil)

        self.documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
        self.documentsDirectoryURL = NSURL(fileURLWithPath: documentsDirectory, isDirectory: true)
        self.tmpDirectoryURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }
        
    func startDownload(URL: NSURL!, suggestedFilename: String? = nil) -> NSURLSessionDownloadTask! {
        let request = NSURLRequest(URL: URL)
        var downloadTask = self.session.downloadTaskWithRequest(request)
        downloadTask.resume()
        self.activeTasks[URL.absoluteString!] = (downloadTask, suggestedFilename)
        return downloadTask
    }
    
    func cancelDonwload(URL: NSURL) -> Void {
        if let (task, _)  = self.activeTasks[URL.absoluteString!] {
            task.cancel()
        }
    }
    
    // MARK: - NSURLSessionDownloadDelegate
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        var (_, fileName) = self.activeTasks[downloadTask.originalRequest.URL!.absoluteString!]!
        if fileName == nil {
           fileName = downloadTask.response?.suggestedFilename
        }
        
        var destURL = self.documentsDirectoryURL.URLByAppendingPathComponent(fileName!)
        var fileError: NSError?
        NSFileManager.defaultManager().moveItemAtURL(location, toURL: destURL, error: &fileError)
        if let error = fileError {
            NSLog("error: \(error)");
            return
        }

        NSNotificationCenter.defaultCenter().postNotificationName(NewFilesAvailableNotification, object: nil)
    }
    
}
