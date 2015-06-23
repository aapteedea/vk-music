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

class DownloadOperation: NSOperation, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate {
    
    private var done = false
    var URL: NSURL!
    var suggestedFilename: String?
    var session: NSURLSession!
    var downloadTask: NSURLSessionDownloadTask!
    var previouslyLoggedValue: Int = -1
    
    init(URL: NSURL, suggestedFilename: String?) {
        super.init()
        self.URL = URL
        self.suggestedFilename = suggestedFilename
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        self.downloadTask = session.downloadTaskWithURL(self.URL)
    }
    
    override func main() {
        if self.cancelled { return }
        self.downloadTask!.resume()
        repeat {
            if self.cancelled {
                self.downloadTask.cancel()
            }
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture() as NSDate)
        }
        while (!self.done)
    }
    
    func sanitizeFileName(fileName: String) -> String {
        let illegalFileNameCharacters = NSCharacterSet(charactersInString:" /\\?%*|\"<>")
        return "_".join(fileName.componentsSeparatedByCharactersInSet(illegalFileNameCharacters))
    }
    // MARK: - NSURLSessionTaskDelegate
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error { NSLog("error: \(error)") }
        self.done = true
    }

    // MARK: - NSURLSessionDownloadDelegate
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let contentLenght = downloadTask.response?.expectedContentLength {
            let progress = Double(totalBytesWritten) / Double(contentLenght)
            let progressPercentage = Int(progress * 100)
            if (progressPercentage != self.previouslyLoggedValue) {
                previouslyLoggedValue = progressPercentage
                NSLog("completed: \(progressPercentage)%%")
            }
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        var fileName = self.suggestedFilename
        if fileName == nil {
            fileName = downloadTask.response?.suggestedFilename
        }
        fileName = self.sanitizeFileName(fileName!)
        
        let filePath = DownloadManager.sharedManager.documentsDirectory.stringByAppendingPathComponent(fileName!)
        let destURL = NSURL(fileURLWithPath: filePath)
        
        do {
            try NSFileManager.defaultManager().moveItemAtURL(location, toURL: destURL)
        } catch let error as NSError {
            NSLog("error: \(error)");
            return
        }
        
        NSLog("saved as: \(fileName!)");
        NSNotificationCenter.defaultCenter().postNotificationName(NewFilesAvailableNotification, object: nil)
    }
}

class DownloadManager: NSObject {
    
    static let sharedManager = DownloadManager()
    
    var documentsDirectory: String!
    var operationQueue: NSOperationQueue!
    
    override init() {
        super.init()
        self.documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        self.operationQueue = NSOperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 1
    }
        
    func startDownload(URL: NSURL!, suggestedFilename: String? = nil) -> DownloadOperation {
        let operation = DownloadOperation(URL: URL, suggestedFilename: suggestedFilename)
        self.operationQueue.addOperation(operation)
        return operation
    }
}
