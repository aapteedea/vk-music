//
//  AppDelegate.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 8/6/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, VKSdkDelegate {
                            
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
                
        window?.backgroundColor = UIColor.whiteColor()
        window?.makeKeyAndVisible()

        let appId = "4493769"
        VKSdk.initializeWithDelegate(self, andAppId: appId)
        if VKSdk.wakeUpSession() {
            NSLog("VK session started")
        }
        
        if let token = VKAccessToken(fromDefaults: "VKAccessToken") {
            NSLog("%@", token)
        } else {
            var permission = ["audio"]
            VKSdk.authorize(permission)
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        VKSdk.processOpenURL(url, fromApplication: sourceApplication)
        return true
    }

    // MARK: - VKSdkDelegate
    
    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        
    }
    
    func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        
    }
    
    func vkSdkUserDeniedAccess(authorizationError: VKError!) {
        
    }

    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    func vkSdkReceivedNewToken(newToken: VKAccessToken!) {
        newToken.saveTokenToDefaults("VKAccessToken")
    }
    
    // MARK: - Remote Control Events
    
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        if event.type == .RemoteControl {
            switch event.subtype {
            case .RemoteControlPlay:
                AudioPlayer.sharedAudioPlayer.resume()
            case .RemoteControlPause:
                AudioPlayer.sharedAudioPlayer.pause()
            case .RemoteControlTogglePlayPause:
                AudioPlayer.sharedAudioPlayer.togglePlayPause()
            case .RemoteControlPreviousTrack:
                AudioPlayer.sharedAudioPlayer.previousTrack(userAction: true)
            case .RemoteControlNextTrack:
                AudioPlayer.sharedAudioPlayer.nextTrack(userAction: true)
            default: break
            }
        }
    }
    
}
