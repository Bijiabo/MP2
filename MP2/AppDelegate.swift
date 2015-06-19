//
//  AppDelegate.swift
//  MP2
//
//  Created by bijiabo on 15/6/18.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var model : ModelManager!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let modelTestData : Array<AnyObject> = [
            [
                "name" : "qichuang",
                "list" : [
                    ["name" : "color song"],
                    ["name" : "the music room"]
                ]
            ],
            [
                "name" : "shuiqian",
                "list" : [
                    ["name" : "good night"],
                    ["name" : "little star"]
                ]
            ]
        ]
        
        //设定model和player
        model = Server(data: modelTestData, statusManager: Status())
        
        let testMediaFileURL : NSURL = NSBundle.mainBundle().URLForResource("AreYouOK", withExtension: "mp3", subdirectory: "resource/media")!
        
        model.playerManager.setSource(testMediaFileURL)
        
        //获取主界面view controller
        var mainVC : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainVC") as! UIViewController
        
        //传入model给main view controller
        if let vc : ViewManager = mainVC as? ViewManager
        {
            var VC : ViewManager = mainVC as! ViewManager

            VC.model = self.model
        }
        
        
        let screen: AnyObject = UIScreen.screens()[0]
        self.window = UIWindow(frame: screen.bounds)
        self.window!.rootViewController = mainVC
        self.window!.makeKeyAndVisible()
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        _addObserver()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }

    
    func _addObserver() -> Void
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("avaudioSessionInterruption:"), name: AVAudioSessionInterruptionNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("audioSessionRouteChanged:"), name: AVAudioSessionRouteChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("audioSessionMediaServicesWereLost:"), name: AVAudioSessionMediaServicesWereLostNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("audioSessionMediaServicesWereReset:"), name: AVAudioSessionMediaServicesWereResetNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("audioSessionSilenceSecondaryAudioHint:"), name: AVAudioSessionSilenceSecondaryAudioHintNotification, object: nil)
        
        
    }
    
    func avaudioSessionInterruption(notification : NSNotification)
    {
        
        let interuption : NSDictionary = notification.userInfo!
        let interuptionType : UInt = interuption.valueForKey(AVAudioSessionInterruptionTypeKey) as! UInt
        
        
        if interuptionType == AVAudioSessionInterruptionType.Began.rawValue
        {
            println("began")
            
            self.model.playerManager.pause()
        }
        else if interuptionType == AVAudioSessionInterruptionType.Ended.rawValue
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), { () -> Void in
                //self.player.currentTime = NSTimeInterval(0)
                self.model.playerManager.play()
            })
            
            
            AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
            AVAudioSession.sharedInstance().setActive(true, error: nil)
            
            println("end")
            
        }
        
    }

}

