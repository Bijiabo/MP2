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
class AppDelegate: UIResponder, UIApplicationDelegate , Operations , UIAlertViewDelegate , DownloaderObserverProtocol , ModuleLader
{
    //模拟蜂窝网络网络调试，设为`true`时，会识别网络为蜂窝网络。正式上线和测试产品时应为false。
    let isCellPhoneDebug : Bool = true
    
    var mainVC : UIViewController!

    var window: UIWindow?

    var model : ModelManager!
    
    var player : PlayerManager!
    
    var nowPlayingInfoCenter : ViewManager!
    
    var downloader : Downloader?
    
    //缓存到本地的路径
    var cacheRootURL : NSURL!
    
    //MARK:
    //MARK: Network Operation
    
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
        return  isCellPhoneDebug ? true : IJReachability.isConnectedToNetworkOfType() == .WWAN
    }
    
    //MARK:
    //MARK: 检测网络变化
    let reachability = Reachability.reachabilityForInternetConnection()

    
    //MARK:
    //MARK: application
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        println(NSHomeDirectory())
        
        //初始化缓存路径
        let cacheRootPath : String = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! String
        cacheRootURL = NSURL(fileURLWithPath: cacheRootPath)!.URLByAppendingPathComponent("media/audio")
        //拷贝音频资源到cache目录
        //MARK: 需要修改，应该是应用安装后首次启动执行一遍
        CopyBundleFilesToCache(targetDirectoryInCache: "media/audio").doCopy(dirPathInBundle: "resource/media") //拷贝媒体文件
        CopyBundleFilesToCache(targetDirectoryInCache: "data").doCopy(dirPathInBundle: "resource/data") //拷贝数据
        
        //读取数据
        let jsonData : JSON = loadJSONData("0.json")
        var data = convertJSONtoArray(jsonData)
        
        //设定model和player
        model = Server(data: data, statusManager: Status())//初始化当前场景和场景需要数据
        model.delegate = self
        
        //初始化downloader
        downloader = Downloader()
        downloader?.delegate = self

        //检查音频文件是否存在
        let mediaFileURL : NSURL? = getLocalMediaFilePath()! // cacheRootURL.URLByAppendingPathComponent(model?.currentPlayingData["localURI"] as! String)
        
        if mediaFileURL != nil
        {
            player = Player(source: mediaFileURL!)
            player.delegate = self
            
        }
        else{
            // 待处理 文件不存在,切换到存在的音乐
            
            
        }
        
        //MARK:
        //MARK: 获取主界面view controller
        if NSUserDefaults.standardUserDefaults().boolForKey("applicationHadActivated") == false //判断是否是首次启动App
        {
            self.loadModule("Guide", storyboardIdentifier: "mainVC")
        }
        else
        {
            self.loadModule("Main", storyboardIdentifier: "mainVC")
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
        
        //检测网络变化 test
        reachability.whenReachable = { reachability in
            if reachability.isReachableViaWiFi()
            {
                println("Reachable via WiFi")
            } else {
                println("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { reachability in
            println("Not reachable")
        }

        reachability.startNotifier()
        
        addObserver()
        
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
    
    //MARK:
    //MARK: ViewOperation
    
    func doLike() {
        
    }
    
    func doDislike() {
        playNext()
    }

    func wrongPlayerUrl() {
        
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
    
    func getCurrentScenePlayList() -> [Dictionary<String, AnyObject>]
    {
        
        
        return model.getCurrentScenePlayList()
    }
    
    //MARK:
    //MARK: PlayerOperation
    
    var playing : Bool = false
    
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
    
    func playerDidFinishPlaying()
    {
        playNext()
    }
    
    //MARK:
    //MARK: 播放内容更新
    //MARK: 2遍播放问题所在，应去除。
    func currentPlayingDataHasChanged() {
        
        //println(model?.currentPlayingData["localURI"] )
        
        var mediaFileURL = getLocalMediaFilePath()
        
        //判断当前播放文件是否存在
        if mediaFileURL != nil
        {
            if player != nil
            {
                player.setTheSource(mediaFileURL!)
            }
            else
            {
                player = Player(source: mediaFileURL!)
               
            }
            
            if playing
            {
                play()
            }
            
            //处理音频无法播放bug，跳至下一首,
            //MARK:待处理:如果整个场景下的列表都没有歌曲,那么下载,下载的同时调到别的场景先播放,或者提示用户
            if player == nil
            {
                model.next()
            }
            
        }//本地没有数据,开始下载
        else
        {
            let mediaRemoteURLString : String = (model.currentPlayingData["remoteURL"] as! [String])[0]
            
            let filename : String? = model?.currentPlayingData["localURI"] as? String
            
            singleMediaNeedToDownload(remoteURL: mediaRemoteURLString, filename: filename)
            
            model.next()
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("CurrentPlayingDataHasChanged", object: nil)
    }
    
    
    //MARK:
    //MARK: 读取数据，并将其他格式数据转换为原生数组
    func loadJSONData(dataFilename : String) -> JSON
    {
        let cachePath : String = NSSearchPathForDirectoriesInDomains(.CachesDirectory , .UserDomainMask, true)[0] as! String
        
        let DataFilePath : String = cachePath + "/data/\(dataFilename)"
        
        let DataFileURL : NSURL = NSURL(fileURLWithPath: DataFilePath)!
        
        //读取文件内容
        //let dataRootURL : NSURL = NSBundle.mainBundle().resourceURL!.URLByAppendingPathComponent("resource/data")
        
        let dataFileData : NSData = NSData(contentsOfURL: DataFileURL )!

        let dataFileJSON : JSON = JSON(data:dataFileData)
        
        return dataFileJSON
    }
    
    //将json格式数据转换为原生数组
    func convertJSONtoArray (jsonData : JSON) -> [Dictionary<String,AnyObject>]
    {
        //所有数据
        var data : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]()
        
        //[{},{},{},{}]
        for (key:String,subJSON:JSON) in jsonData
        {
            var item : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
            
            //[name:"起床", list:[ item0, item1, item2... ] ]
            for (key_1:String,subJSON_1:JSON) in subJSON
            {
                
                if let value = subJSON_1.string//判断场景名,[起床,午后,玩耍,睡前]
                {
                    item[key_1] = value//存场景歌单列表
                }
                else
                {
                    //继续遍历:对应场景的音乐
                    var scenelist : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]() 
                    //["":"","":[],"":""]
                    for (key_2:String, subJSON_2:JSON) in subJSON_1
                    {
                        scenelist.append(subJSON_2.dictionaryObject!)
                    }
                    
                    item[key_1] = scenelist
                }
                
            }
            
            data.append(item)
        }
        
        return data
    }
    
    //检测文件是否存在
    func getLocalMediaFilePath () -> NSURL?
    {
        var isNotDir : ObjCBool = false
        
        var localURI : String = model?.currentPlayingData["localURI"] as! String
        
        if NSFileManager.defaultManager().fileExistsAtPath(localURI, isDirectory: &isNotDir)
        {
            return NSURL(fileURLWithPath:  localURI)
        }

        
       var mediaFileURL : NSURL  =  cacheRootURL.URLByAppendingPathComponent("\(localURI)")
        
        if NSFileManager.defaultManager().fileExistsAtPath(mediaFileURL.relativePath!, isDirectory: &isNotDir)
        {
            return mediaFileURL
        }
        else
        {
            return nil
        }
    }
    
    //MARK:
    //MARK: 下载相关
    
    //下载Item的id队列，用于检测是否所有下载已完成
    var downloadQueue : [Dictionary<String,String?>] = [Dictionary<String,String?>]()
    //单个文件下载队列
    var mediaFilesNeedToDownloadQueue : [Dictionary<String,String?>] = [Dictionary<String,String?>]()
    
    func singleMediaNeedToDownload(#remoteURL : String , filename : String?)
    {
        mediaFilesNeedToDownloadQueue.append([
            "remoteURL" : remoteURL,
            "filename" : filename
            ])
     
        if CellularNetwork
        {
            //蜂窝网络环境，申请用户下载许可
            showDownloadAlert(allDownload: false)
        }
        else
        {
            //直接下载
            downloadMediaFilesInQueue()
        }
        
    }
    
    func downloadMediaFilesInQueue ()
    {
        for i in 0..<mediaFilesNeedToDownloadQueue.count
        {
            let remoteURL : String = mediaFilesNeedToDownloadQueue[i]["remoteURL"]!!
            let filename : String? = mediaFilesNeedToDownloadQueue[i]["filename"]!
            downloader?.addTask(remoteURL, cacheRootURL: cacheRootURL, filename : filename )
            
            //更新总体下载队列暂存
            addTaskRecordsToDownloadQueue([
                "remoteURL" : remoteURL,
                "filename" : filename
                ])

            

        }
        
        downloader?.startDownload()
        
        mediaFilesNeedToDownloadQueue.removeAll(keepCapacity: false)
    }
    
    //记录下载任务至下载队列，便于总体下载状态统计，是否已经全部完成
    func addTaskRecordsToDownloadQueue(item : Dictionary<String,String?>)
    {
        var aleardyHasTask : Bool = false
        
        for item1 in downloadQueue
        {
            let sameRemoteURL : Bool = item1["remoteURL"]! == item["remoteURL"]!
            let sameFilename : Bool = item1["filename"]! == item["filename"]!
            
            if sameRemoteURL && sameFilename
            {
                aleardyHasTask = true
                break
            }
        }
        
        if aleardyHasTask == false
        {
            println("aleardyHasTask == false")
            downloadQueue.append(item)
        }
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
    var downloadAlertView : UIAlertView = UIAlertView()
    var downloadAlertViewIsShowing : Bool = false
    
    func showDownloadAlert(#allDownload : Bool)
    {
        if downloadAlertViewIsShowing {
            return
        }
        
        let tittle : String = "下载媒体资源"
        let message : String = "检测到您的设备处于蜂窝网络环境下，是否继续下载相关的媒体资源？"
        
        downloadAlertView = UIAlertView(title: tittle, message: message, delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "下载")
        
        if allDownload
        {
            downloadAlertView.tag = DownloadAlertAction.downloadAll.rawValue
        }
        else
        {
            downloadAlertView.tag = DownloadAlertAction.downloadCurrentMedia.rawValue
        }
        
        downloadAlertView.show()
        downloadAlertViewIsShowing = true
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if alertView.tag == DownloadAlertAction.downloadCurrentMedia.rawValue
        {
            if buttonIndex == 1
            {
                //下载媒体资源
                downloadMediaFilesInQueue()
            }
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
        
        downloadAlertViewIsShowing = false
    }
    
    //MARK:
    //MARK: Download Operation Protocol
    func startAllDownload() {
        
        //获取下载列表
        let downloadList : [Dictionary<String,String>] = model.getDownloadList()
        
        //下载全部媒体文件
        for item in downloadList
        {
            let remoteURL : String = item["remoteURL"]!
            let filename : String? = item["filename"]
            
            downloader?.addTask(remoteURL, cacheRootURL: cacheRootURL, filename: filename)
            
            //更新总体下载进度暂存
            addTaskRecordsToDownloadQueue([
                "remoteURL" : remoteURL,
                "filename" : filename
                ])
        }
        
        downloader?.startDownload()
        
        //记录 用户已经选择下载过全部内容
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasDownloadAllMediaFiles")
    }
    
    //MARK:
    //MARK: download observer protocol
    
    //下载完成
    func downloadCompleted(data : AnyObject)
    {
        if let downloadItem : DownloadItemProtocol = data as? DownloadItemProtocol
        {
            for var i = 0 ; i < downloadQueue.count ; i++
            {
                let item = downloadQueue[i]
                let sameRemoteURL : Bool = NSURL(string: item["remoteURL"]!!)! == downloadItem.remoteURL
                let sameFilename : Bool = item["filename"]! == downloadItem.filename
                
                if sameRemoteURL && sameFilename
                {
                    downloadQueue.removeAtIndex(i)
                    break
                }
            }
        }
        
        println("downloadItemIdQueue.count \(downloadQueue.count)")
        
        //所有下载任务完成触发
        if downloadQueue.count == 0
        {
            NSNotificationCenter.defaultCenter().postNotificationName("DownloadStoped", object: nil)
        }
    }
    
    //下载出错
    func downloadErrorOccurd(data : AnyObject)
    {
        
    }
    
    //Module Loader Protocol
    
    func loadModule(storyboardName: String, storyboardIdentifier: String) {
        
        
        switch storyboardName
        {
            case "Guide":
            //yuan
                mainVC = UIStoryboard(name: "Guide", bundle: nil).instantiateViewControllerWithIdentifier(storyboardIdentifier) as! UIViewController //传入一个storyboardIdentifier,初始化一个VC
                
                if let vc : Module = mainVC as? Module
                {
                    var VC : Module = mainVC as! Module
                    
                    VC.moduleLoader = self
                }
            
            case "Main":
            //hu
                mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(storyboardIdentifier) as! UIViewController
                
                var navigationController : UINavigationController = mainVC as! UINavigationController
                
                var mainViewController: AnyObject = navigationController.viewControllers[0]
                
                
                //若mainVC符合Module，则传入ModuleLoader
                if let vc : Module = mainViewController as? Module
                {
                    var VC : Module = mainViewController as! Module
                    
                    VC.moduleLoader = self
                }
                
                if storyboardIdentifier == "mainVC"
                {
                    
                    if let vc : ViewManager = mainViewController as? ViewManager
                    {
                        var VC : ViewManager = mainViewController as! ViewManager
                        
                        VC.model = self.model
                        VC.delegate = self
                    }
                }
            
            //MARK:待处理:默认情况下,启动哪个ViewController
            default:
                
                break
        }
        
        self.window?.rootViewController?.presentViewController(mainVC, animated: true, completion: nil)//设置/跳转/显示指定的VC
        
    }
    
    func addObserver()
    {
        //年龄改变
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("ageChanged:"), name: "childAgeGroupChanged", object: nil)
        
        //主播放界面加载完毕
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("mainPlayerViewControllerDidLoad:"), name: "MainPlayerViewControllerDidLoad", object: nil)
    }
    
    func ageChanged (notification : NSNotification)
    {
        let ageObject : Dictionary<String,Int> = notification.object as! Dictionary<String,Int>
        var age : Int = ageObject["age"]!
        
        //MARK: 调试，超过三岁的暂用6岁数据
        if age>3 {age = 3}
        
        //println("age : \(age)")
        
        let jsonData : JSON = loadJSONData("\(age).json")
        var data = convertJSONtoArray(jsonData)
        
        model.updateData(data)
    }
    
    func mainPlayerViewControllerDidLoad (notification : NSNotification)
    {
        //若之前没有下载过内容，则自动下载
        if NSUserDefaults.standardUserDefaults().boolForKey("hasDownloadAllMediaFiles") == false || isCellPhoneDebug
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
    }
    //用户上传内容添加到列表操作方法
    func updateCurrentScenePlayList(ugcData:Dictionary<String,AnyObject> ,isAdd:Bool)
    {
        
        model.updateCurrentScenePlayList(ugcData, isAdd: isAdd)
        
        
    }
    //得到当前年龄段的Json数据
    func getCurentAgeGroupData() ->Array<AnyObject>
    {
        
        return model.getCurentAgeGroupData()
        
    }
    //得到当前场景名
    func getCurrentSceneName( ) ->String
    {
        return model.getCurrentSceneName()
    }
    
    //得到iTunes上传文件夹列表
    func getUploadList() ->Dictionary<String,NSURL>
    {
        return model.getUploadList()
    }
}

