//
//  Utilities.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 9/22/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit

var _defaultBlueTintColor: UIColor?

extension UIColor {
    
    class func defaultBlueTintColor() -> UIColor {
        if (_defaultBlueTintColor == nil) {
            let tmpButton = UIButton(type: .System) as UIButton
            _defaultBlueTintColor = tmpButton.titleColorForState(.Normal)
        }
        return _defaultBlueTintColor!
    }
    
}

class Utilities: NSObject {

    class func prettifyTime(seconds: NSTimeInterval) -> String {
        let minutes = (Int(seconds) / 60) % 60
        let seconds = Int(seconds) % 60
        return String(format:"%2d:%02d", minutes, seconds)
    }
    
    class func prettifySize(bytesCount: Int) -> String {
        return NSByteCountFormatter.stringFromByteCount(CLongLong(bytesCount), countStyle: .File)
    }
    
}
