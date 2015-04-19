//
//  Utilities.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 9/22/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit

class Utilities: NSObject {

    class func prettifyTime(seconds: NSTimeInterval) -> String {
        var minutes = (Int(seconds) / 60) % 60
        var seconds = Int(seconds) % 60
        return String(format:"%2d:%02d", minutes, seconds)
    }
    
    class func prettifySize(bytesCount: Int) -> String {
        return NSByteCountFormatter.stringFromByteCount(CLongLong(bytesCount), countStyle: .File)
    }
    
}
