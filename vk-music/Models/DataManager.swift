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

        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let documentsDirectoryURL = NSURL(fileURLWithPath: documentsDirectory, isDirectory: true)
        
        var files: [AnyObject]?
        do {
            files = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsDirectoryURL,
                                                                                            includingPropertiesForKeys: nil,
                                                                                            options: .SkipsHiddenFiles)
        } catch let error as NSError {
            NSLog("error: \(error)")
            return [Audio]()
        }
        
        
        let sortedFiles: NSArray = (files as NSArray!).sortedArrayUsingComparator { (obj1, obj2) -> NSComparisonResult in

            let attr1: NSDictionary = try! NSFileManager.defaultManager().attributesOfItemAtPath((obj1 as! NSURL).path!)
            let date1 = attr1.objectForKey(NSFileModificationDate) as! NSDate
            
            let attr2: NSDictionary = try! NSFileManager.defaultManager().attributesOfItemAtPath((obj2 as! NSURL).path!)
            let date2 = attr2.objectForKey(NSFileModificationDate) as! NSDate

            return date2.compare(date1)
        }
        
        var audioFiles = [Audio]()
        for fileURL in sortedFiles {
            audioFiles.append(Audio(fileURL: fileURL as! NSURL))
        }
        
        return audioFiles
    }
    
    class func removeFile(fileURL: NSURL, error: NSErrorPointer) {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(fileURL)
        } catch let fileError as NSError {
            error.memory = fileError
        }
    }
    
}
