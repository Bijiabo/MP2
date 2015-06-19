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
    
    var nowPlayingInfoCenter : ViewManager!

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
                    ["name" : "good ni8ght"],
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
        
        nowPlayingInfoCenter = NowPlayingInfoCenterController()
        nowPlayingInfoCenter.model = self.model
        
        let screen: AnyObject = UIScreen.screens()[0]
        self.window = UIWindow(frame: screen.bounds)
        self.window!.rootViewController = mainVC
        self.window!.makeKeyAndVisible()
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        self.becomeFirstResponder()
        
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

}

