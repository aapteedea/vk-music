//
//  UIColor+Extension.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 9/23/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import Foundation

var _defaultBlueTintColor: UIColor?

extension UIColor {
    
    class func defaultBlueTintColor() -> UIColor {
        if (_defaultBlueTintColor == nil) {
            var tmpButton = UIButton.buttonWithType(.System) as! UIButton
            _defaultBlueTintColor = tmpButton.titleColorForState(.Normal)
        }
        return _defaultBlueTintColor!
    }
    
}