//
//  ProgressButton.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 8/8/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit
import QuartzCore

protocol ProgressButtonDelegate {
    func progressButton(progressButton: ProgressButton, didUpdateProgress progress: Double)
}

//@IBDesignable class ProgressButton: UIButton {
class ProgressButton: UIButton {

    private var backgroundLayer: CAShapeLayer!
    private var progressLayer: CAShapeLayer!
    var delegate: ProgressButtonDelegate?
    var operation: DownloadOperation?
    
//    @IBInspectable var progress: Double = 0.0 {
    var progress: Double = 0.0 {
        didSet {
            updateLayerProperties()
            delegate?.progressButton(self, didUpdateProgress: progress)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let color = UIColor.defaultBlueTintColor().CGColor
        
        // Circle background layer
        if (backgroundLayer == nil) {
            backgroundLayer = CAShapeLayer()
            backgroundLayer.path = UIBezierPath(ovalInRect:bounds).CGPath
            backgroundLayer.fillColor = nil
            backgroundLayer.lineWidth = 1.0
            backgroundLayer.strokeColor = color
            
            layer.addSublayer(backgroundLayer)
        }
        backgroundLayer.frame = layer.bounds
        
        // Progress layer
        let lineWidth: CGFloat = 3.0
        let rect = CGRectInset(bounds, lineWidth / 2.0, lineWidth / 2.0)
        if (progressLayer == nil) {
            progressLayer = CAShapeLayer()
            progressLayer.path = UIBezierPath(ovalInRect:rect).CGPath
            progressLayer.fillColor = nil
            progressLayer.lineWidth = lineWidth
            progressLayer.strokeColor = color
            progressLayer.transform = CATransform3DRotate(progressLayer.transform, CGFloat(-M_PI/2.0), 0.0, 0.0, 1.0)
            progressLayer.strokeEnd = CGFloat(progress)
            
            layer.addSublayer(progressLayer)
        }
        progressLayer.frame = layer.bounds
    }

    func updateLayerProperties() {
        if (progressLayer != nil) {
            progressLayer.strokeEnd = CGFloat(progress)
        }
    }
    
    func configure() {
        if self.operation != nil {
            self.stopObserving()
        }
    }
    
    func setProgress(downloadProgressOfOperation operation: DownloadOperation) {
        self.operation = operation
        self.operation?.downloadTask.addObserver(self, forKeyPath: "countOfBytesReceived", options: .New, context: nil)
        self.operation?.downloadTask.addObserver(self, forKeyPath: "state", options: .New, context: nil)
    }
    
    func stopObserving() {
        self.operation?.downloadTask.removeObserver(self, forKeyPath: "state")
        self.operation?.downloadTask.removeObserver(self, forKeyPath: "countOfBytesReceived")
        self.operation = nil
    }
    
    // MARK: KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<()>) {
        let task = object as! NSURLSessionTask
        if let keyPath = keyPath {
            switch keyPath {
            case "countOfBytesReceived":
                if (task.countOfBytesExpectedToReceive > 0) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.progress = Double(task.countOfBytesReceived) / Double(task.countOfBytesExpectedToReceive)
                    })
                }
            case "state":
                switch task.state {
                case .Canceling, .Completed:
                    self.stopObserving()
                default: break
                }
            default: break
            }
        }
    }
}