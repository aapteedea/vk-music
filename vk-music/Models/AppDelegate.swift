//
//  AppDelegate.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 8/6/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, VKSdkDelegate, VKSdkUIDelegate {
                            
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        window?.backgroundColor = UIColor.whiteColor()
        
        guard
            let VKInfoDict = NSBundle.mainBundle().infoDictionary?["VK"] as? [String: NSObject],
            let appId = VKInfoDict["AppID"] as? String
            else { return true }

        configureVKSdk(appId)

        return true
    }
    
    func configureVKSdk(appId: String) {
        let VKSdkInstance = VKSdk.initializeWithAppId(appId)
        VKSdkInstance.registerDelegate(self)
        VKSdkInstance.uiDelegate = self

        let scope = ["audio"]
        VKSdk.wakeUpSession(scope) { (state, error) -> Void in
            switch state {
            case .Initialized:
                VKSdk.authorize(scope)
            case .Authorized:
                NSLog("VK SDK autorized.")
            case .Error:
                NSLog("\(error)")
            default: break
            }
        }
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
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        VKSdk.processOpenURL(url, fromApplication: sourceApplication)
        return true
    }

    // MARK: - VKSdkDelegate
    
    func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {

    }
    
    func vkSdkUserAuthorizationFailed() {
        
    }
    
    func vkSdkAccessTokenUpdated(newToken: VKAccessToken?, oldToken: VKAccessToken!) {
        guard let newToken = newToken else { return }
        newToken.saveTokenToDefaults("VKAccessToken")
    }
    
    func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        
    }
    
    // MARK: - VKSdkUIDelegate
    
    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        
    }
    
    func vkSdkWillDismissViewController(controller: UIViewController!) {
        
    }
    
    func vkSdkDidDismissViewController(controller: UIViewController!) {
        
    }
    
    // MARK: - Remote Control Events
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event!.type == .RemoteControl {
            switch event!.subtype {
            case .RemoteControlPlay:
                AudioPlayer.sharedAudioPlayer.resume()
            case .RemoteControlPause:
                AudioPlayer.sharedAudioPlayer.pause()
            case .RemoteControlTogglePlayPause:
                AudioPlayer.sharedAudioPlayer.togglePlayPause()
            case .RemoteControlPreviousTrack:
                AudioPlayer.sharedAudioPlayer.previousTrack(true)
            case .RemoteControlNextTrack:
                AudioPlayer.sharedAudioPlayer.nextTrack(true)
            default: break
            }
        }
    }
    
}
