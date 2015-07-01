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
    
    var downloader : Downloader?
    
    var cacheRootURL : NSURL!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //初始化路径
        let cacheRootPath : String = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! String
        cacheRootURL = NSURL(fileURLWithPath: cacheRootPath)!.URLByAppendingPathComponent("media/audio")
        
        //初始化downloader
        downloader = Downloader()
        
        //读取数据
        var modelTestData = loadData()

        
        //设定model和player
        model = Server(data: modelTestData, statusManager: Status())
        model.delegate = self
        
        
        //检查音频文件是否存在
        if checkCurrentMediaFileExists()
        {
            let mediaFileURL : NSURL = cacheRootURL.URLByAppendingPathComponent(model?.currentPlayingData["localURI"] as! String)
            
            player = Player(source: mediaFileURL)
            player.delegate = self
        }
        
        //检查
        
        
        
        
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
    
    
    var playing : Bool = false
    
    func doLike() {
        
    }
    
    func doDislike() {
        playNext()
    }

    func wrongPlayerUrl() {
        
    }
    
    func playerDidFinishPlaying()
    {
        playNext()
    }
    
    func switchToScene(scene : String)
    {
        model.status.set_CurrentScene(scene)
    }
    
    func playNext()
    {
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
        
        playing = true
        
        sendPlayingStatusChangeNotification()
        
    }
    
    func pause()
    {
        player.pause()
        
        playing = false
        
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
        
        if checkCurrentMediaFileExists()
        {
            let mediaFileURL : NSURL = cacheRootURL.URLByAppendingPathComponent(model?.currentPlayingData["localURI"] as! String)
            
            player = Player(source: mediaFileURL)
            player.delegate = self
            
            if playing
            {
                play()
                
            }
        }
        /*
        let mediaFileURL : NSURL = NSBundle.mainBundle().URLForResource(model?.currentPlayingData["localUri"] as! String, withExtension: "", subdirectory: "resource/media")!
        
        player.setSource(mediaFileURL)
        */
        
        
        
        
        NSNotificationCenter.defaultCenter().postNotificationName("CurrentPlayingDataHasChanged", object: nil)
    }
    
    
    //MARK:
    //MARK: 读取数据
    func loadData() -> [Dictionary<String,AnyObject>]
    {
        let dataRootURL : NSURL = NSBundle.mainBundle().resourceURL!.URLByAppendingPathComponent("resource/data")
        let dataFileData : NSData = NSData(contentsOfURL: dataRootURL.URLByAppendingPathComponent("standard.json"))!
        let dataFileJSON : JSON = JSON(data:dataFileData)
        
        var dataList : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]()
        
        for (key:String,subJSON:JSON) in dataFileJSON
        {
            var item : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
            //[name:"起床", list:[ item0, item1, item2... ] ]
            for (key_1:String,subJSON_1:JSON) in subJSON
            {
                
                if let value = subJSON_1.string
                {
                    item[key_1] = value
                }
                else
                {
                    //继续遍历
                    var scenelist : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]()
                    
                    for (key_2:String, subJSON_2:JSON) in subJSON_1
                    {
                        scenelist.append(subJSON_2.dictionaryObject!)
                    }
                    
                    item[key_1] = scenelist
                }
                
                
            }
            
            dataList.append(item)
        }
        
        return dataList
    }
    
    //检测文件是否存在，若不存在则下载
    func checkCurrentMediaFileExists () -> Bool
    {
        var isNotDir : ObjCBool = false
        let mediaFileURL : NSURL = cacheRootURL.URLByAppendingPathComponent(model?.currentPlayingData["localURI"] as! String)
        
        if NSFileManager.defaultManager().fileExistsAtPath(mediaFileURL.relativePath!, isDirectory: &isNotDir)
        {
            return true
        }
        else
        {
            println("media file is not exist. Will to be download...")
            
            
            let mediaRemoteURLString : String = (model.currentPlayingData["remoteURL"] as! [String])[0]
            let mediaRemoteFileURL : NSURL = NSURL(string: mediaRemoteURLString )!
            
            downloader?.download(mediaRemoteURLString, cacheRootURL: cacheRootURL, filename :model?.currentPlayingData["localURI"] as? String )

            return false
        }
    }
    
}

