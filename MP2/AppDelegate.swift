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
class AppDelegate: UIResponder, UIApplicationDelegate , Operations , UIAlertViewDelegate
{

    var window: UIWindow?

    var model : ModelManager!
    
    var player : PlayerManager!
    
    var nowPlayingInfoCenter : ViewManager!
    
    var downloader : Downloader?
    
    var cacheRootURL : NSURL!
    
    //Network protocol
    var Wifi : Bool {
        get{
            return IJReachability.isConnectedToNetworkOfType() == .WiFi
        }
    }
    
    var Connected : Bool {
        get{
            return IJReachability.isConnectedToNetwork()
        }
    }
    
    var CellularNetwork : Bool {
        return IJReachability.isConnectedToNetworkOfType() == .WWAN
    }
    
    //检测网络变化
    let reachability = Reachability.reachabilityForInternetConnection()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //初始化路径
        let cacheRootPath : String = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! String
        cacheRootURL = NSURL(fileURLWithPath: cacheRootPath)!.URLByAppendingPathComponent("media/audio")
        
        //拷贝音频资源到cache目录
        CopyBundleFilesToCache(targetDirectoryInCache: "media/audio").doCopy()
        
        //读取数据
        var modelTestData = loadData()
        

        
        //设定model和player
        model = Server(data: modelTestData, statusManager: Status())//初始化当前场景和场景需要数据
        model.delegate = self
        
        //初始化downloader
        downloader = Downloader()
        
        
        
        //检查音频文件是否存在
        if currentMediaFileExist()
        {
            let mediaFileURL : NSURL = cacheRootURL.URLByAppendingPathComponent(model?.currentPlayingData["localURI"] as! String)
            
            player = Player(source: mediaFileURL)
            player.delegate = self
        }
        
        
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
        self.window!.makeKeyAndVisible()//调用这个方法,显示界面
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()//开始监听事件
        
        self.becomeFirstResponder()
        
        //若之前没有下载过内容，则自动下载
        if NSUserDefaults.standardUserDefaults().boolForKey("hasDownloadAllMediaFiles") == false
        {
            if CellularNetwork
            {
                showDownloadAlert(allDownload: true)
            }
            else
            {
                startAllDownload()
            }
        }
        
        //检测网络变化 test
        reachability.whenReachable = { reachability in
            if reachability.isReachableViaWiFi() {
                println("Reachable via WiFi")
            } else {
                println("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { reachability in
            println("Not reachable")
        }

        reachability.startNotifier()
        
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

    //播放器播放状态改变发送一个通知
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
        
        if currentMediaFileExist()
        {
            let mediaFileURL : NSURL = cacheRootURL.URLByAppendingPathComponent(model?.currentPlayingData["localURI"] as! String)
            
            if player != nil
            {
                player.setSource(mediaFileURL)
            }
            else
            {
                player = Player(source: mediaFileURL)
            }
            
            if playing
            {
                play()
                
            }
        }
        else
        {
            if CellularNetwork
            {
                showDownloadAlert(allDownload: false)
            }
            
            model.next()
        }
        
        
        
        
        NSNotificationCenter.defaultCenter().postNotificationName("CurrentPlayingDataHasChanged", object: nil)
    }
    
    
    //MARK:
    //MARK: 读取数据
    func loadData() -> [Dictionary<String,AnyObject>]
    {
        let dataRootURL : NSURL = NSBundle.mainBundle().resourceURL!.URLByAppendingPathComponent("resource/data")

        let dataFileData : NSData = NSData(contentsOfURL: dataRootURL.URLByAppendingPathComponent("6.json"))!

        let dataFileJSON : JSON = JSON(data:dataFileData)
        
        var dataList : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]()
        
        for (key:String,subJSON:JSON) in dataFileJSON
        {
            var item : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
            
            //[name:"起床", list:[ item0, item1, item2... ] ]
            for (key_1:String,subJSON_1:JSON) in subJSON
            {
                
                if let value = subJSON_1.string//判断场景名,[起床,午后,玩耍,睡前]
                {
                    item[key_1] = value//存场景名字
                }
                else
                {
                    //继续遍历:对应场景的音乐
                    var scenelist : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]()
                    
                    for (key_2:String, subJSON_2:JSON) in subJSON_1
                    {
                        scenelist.append(subJSON_2.dictionaryObject!)
                    }
                    
                    item[key_1] = scenelist//存对应场景的列表???稍微不理解,上面存得是string类型,这里是json类型$$$
                }
                
            }
            
            dataList.append(item)
        }
        
        return dataList
    }
    
    //检测文件是否存在，若不存在则下载
    func currentMediaFileExist () -> Bool
    {
        var isNotDir : ObjCBool = false
        let mediaFileURL : NSURL = cacheRootURL.URLByAppendingPathComponent(model?.currentPlayingData["localURI"] as! String)
        
        if NSFileManager.defaultManager().fileExistsAtPath(mediaFileURL.relativePath!, isDirectory: &isNotDir)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    private func _downloadCurrentMediaFile()
    {

        
        let mediaRemoteURLString : String = (model.currentPlayingData["remoteURL"] as! [String])[0]
        let mediaRemoteFileURL : NSURL = NSURL(string: mediaRemoteURLString )!
        
        let id : Int? = downloader?.download(mediaRemoteURLString, cacheRootURL: cacheRootURL, filename :model?.currentPlayingData["localURI"] as? String )
        
        NSNotificationCenter.defaultCenter().postNotificationName("NeedsToDownloadMediaFile", object: id)
        
        
    }
    
    //枚举：下载提示alertView绑定动作
    enum DownloadAlertAction : Int
    {
        //下载全部
        case downloadAll
        //下载当前所需
        case downloadCurrentMedia
    }
    
    //显示下载提示
    func showDownloadAlert(#allDownload : Bool)
    {
        let tittle : String = "下载媒体资源"
        let message : String = "检测到您的设备处于蜂窝网络环境下，是否继续下载相关的媒体资源？"
        
        let alert : UIAlertView = UIAlertView(title: tittle, message: message, delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "下载")
        
        if allDownload
        {
            alert.tag = DownloadAlertAction.downloadAll.rawValue
        }
        else
        {
            alert.tag = DownloadAlertAction.downloadCurrentMedia.rawValue
        }
        
        
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if alertView.tag == DownloadAlertAction.downloadCurrentMedia.rawValue
        {
            //下载当前媒体资源
            _downloadCurrentMediaFile()
        }
        else if alertView.tag == DownloadAlertAction.downloadAll.rawValue
        {
            //下载全部媒体资源
            if buttonIndex == 1
            {
                //用户确认点击了下载按钮
                startAllDownload()
            }
        }
    }
    
    //Download Operation Protocol
    
    func startAllDownload() {
        
        //获取下载列表
        let downloadList : [Dictionary<String,String>] = model.getDownloadList()
        
        //下载全部媒体文件
        for item in downloadList
        {
            downloader?.download(item["remoteURL"]!, cacheRootURL: cacheRootURL, filename: item["filename"])
        }
        
        //记录 用户已经选择下载过全部内容
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasDownloadAllMediaFiles")
    }
    
    
}

