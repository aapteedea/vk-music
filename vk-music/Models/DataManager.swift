//
//  DataManager.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 9/22/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit

class DataManager: NSObject {

    class func audioFiles() -> [Audio] {

        var documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var documentsDirectoryURL = NSURL(fileURLWithPath: documentsDirectory, isDirectory: true)
        
        var error: NSError?
        var files = NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsDirectoryURL!,
                                                                                includingPropertiesForKeys: nil,
                                                                                options: .SkipsHiddenFiles,
                                                                                error: &error)
        if (error != nil) { NSLog("error: \(error)"); return [Audio]() }
        
        var sortedFiles: NSArray = (files as NSArray!).sortedArrayUsingComparator { (obj1, obj2) -> NSComparisonResult in

            var attr1: NSDictionary = NSFileManager.defaultManager().attributesOfItemAtPath((obj1 as! NSURL).path!, error: nil)!
            var date1 = attr1.objectForKey(NSFileModificationDate) as! NSDate
            
            var attr2: NSDictionary = NSFileManager.defaultManager().attributesOfItemAtPath((obj2 as! NSURL).path!, error: nil)!
            var date2 = attr2.objectForKey(NSFileModificationDate) as! NSDate

            return date2.compare(date1)
        }
        
        var audioFiles = [Audio]()
        for fileURL in sortedFiles {
            audioFiles.append(Audio(fileURL: fileURL as! NSURL))
        }
        
        return audioFiles
    }
    
    class func removeFile(fileURL: NSURL, error: NSErrorPointer) {
        NSFileManager.defaultManager().removeItemAtURL(fileURL, error: error)
    }
    
}
