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
class AppDelegate: UIResponder, UIApplicationDelegate , Operations {

    var window: UIWindow?

    var model : ModelManager!
    
    var player : PlayerManager!
    
    var nowPlayingInfoCenter : ViewManager!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let modelTestData : Array<AnyObject> = [
            [
                "name" : "qichuang",
                "list" : [
                    [
                        "name" : "color song",
                        "localUri" : "0yriqss4.1iq.m4a"
                    ],
                    [
                        "name" : "the music room",
                        "localUri" : "1p42n5xz.l0t.m4a"
                    ]
                ]
            ],
            [
                "name" : "shuiqian",
                "list" : [
                    [
                        "name" : "good ni8ght",
                        "localUri" : "3dwtaehv.c2d.m4a"
                    ],
                    [
                        "name" : "little star",
                        "localUri" : "3nkbvksq.xmz.m4a"
                    ]
                ]
            ],
            [
                "name" : "wanshua",
                "list" : [
                    [
                        "name" : "good ni8ght",
                        "localUri" : "3dwtaehv.c2d.m4a"
                    ],
                    [
                        "name" : "little star",
                        "localUri" : "3nkbvksq.xmz.m4a"
                    ]
                ]
            ]
        ]
        
        //设定model和player
        model = Server(data: modelTestData, statusManager: Status())
        model.delegate = self
        
        let mediaFileURL : NSURL = NSBundle.mainBundle().URLForResource(model?.currentPlayingData["localUri"] as! String, withExtension: "", subdirectory: "resource/media")!

        
        player = Player(source: mediaFileURL)
        player.delegate = self
        
        
        //获取主界面view controller
        var mainVC : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainVC") as! UIViewController
        
        //传入model给main view controller
        if let vc : ViewManager = mainVC as? ViewManager
        {
            var VC : ViewManager = mainVC as! ViewManager

            VC.model = self.model
            VC.delegate = self
        }
        
        nowPlayingInfoCenter = NowPlayingInfoCenterController()
        nowPlayingInfoCenter.model = self.model
        nowPlayingInfoCenter.delegate = self
        
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
    
    
    var playing : Bool {
        get {
            return player.playing
        }
    }
    
    private var _previousPlaying : Bool = false
    private var _justFinishPlaying : Bool = false
    
    func doLike() {
        
    }
    
    func doDislike() {
        playNext()
    }

    func wrongPlayerUrl() {
        
    }
    
    func playerDidFinishPlaying()
    {
        _justFinishPlaying = true
        
        playNext()
    }
    
    func switchToScene(scene : String)
    {
        model.status.set_CurrentScene(scene)
    }
    
    func playNext()
    {
        _previousPlaying = playing
        
        model.next()
    }
    
    func updateChildInformation()
    {
        
    }

    func sendPlayingStatusChangeNotification()
    {
        NSNotificationCenter.defaultCenter().postNotificationName("PlayingStatusChanged", object: playing)
    }
    
    func play()
    {
        player.play()
        
        sendPlayingStatusChangeNotification()
        
    }
    
    func pause()
    {
        player.pause()
        
        sendPlayingStatusChangeNotification()
    }
    
    func togglePlayPause()
    {
        if playing
        {
            pause()
        }
        else
        {
            play()
        }
    }
    
    func currentPlayingDataHasChanged() {
        
        let mediaFileURL : NSURL = NSBundle.mainBundle().URLForResource(model?.currentPlayingData["localUri"] as! String, withExtension: "", subdirectory: "resource/media")!
        
        player.setSource(mediaFileURL)
        
        if _previousPlaying || _justFinishPlaying
        {
            play()

            _previousPlaying = false
            _justFinishPlaying = false
        }
        
        
        NSNotificationCenter.defaultCenter().postNotificationName("CurrentPlayingDataHasChanged", object: nil)
    }
}

