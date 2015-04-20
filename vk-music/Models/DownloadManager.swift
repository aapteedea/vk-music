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
    
    var session: NSURLSession!
    var documentsDirectory: String!
    lazy var activeTasks = [String:(NSURLSessionDownloadTask, String?)]()
    
    override init() {
        super.init()
        self.documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
        
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
        
    func startDownload(URL: NSURL!, suggestedFilename: String? = nil) -> NSURLSessionDownloadTask! {
        var downloadTask = self.session.downloadTaskWithURL(URL)
        downloadTask.resume()
        self.activeTasks[URL.absoluteString!] = (downloadTask, suggestedFilename)
        return downloadTask
    }
    
    func sanitizeFileName(fileName: String) -> String {
        var illegalFileNameCharacters = NSCharacterSet(charactersInString:" /\\?%*|\"<>")
        return "_".join(fileName.componentsSeparatedByCharactersInSet(illegalFileNameCharacters))
    }
    
    // MARK: - NSURLSessionDownloadDelegate
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        var (_, fileName) = self.activeTasks[downloadTask.originalRequest.URL!.absoluteString!]!
        if fileName == nil {
           fileName = downloadTask.response?.suggestedFilename
        }
        fileName = self.sanitizeFileName(fileName!)

        var filePath = self.documentsDirectory.stringByAppendingPathComponent(fileName!)
        var destURL = NSURL(fileURLWithPath: filePath)

        var fileError: NSError?
        NSFileManager.defaultManager().moveItemAtURL(location, toURL: destURL!, error: &fileError)
        if let error = fileError {
            NSLog("error: \(error)");
            return
        }

        NSLog("saved as: \(fileName!)");
        NSNotificationCenter.defaultCenter().postNotificationName(NewFilesAvailableNotification, object: nil)
    }
    
}
