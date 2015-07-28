//
//  BrowserViewController.swift
//  MP2
//
//  Created by SlimAdam on 15/7/26.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit
import WebKit

//Handeler
class NotificationScriptMessageHandler : NSObject ,WKScriptMessageHandler {
    
    let cacheRootPath : String = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! String
    var cacheRootURL : NSURL!
    var downloader : Downloader!
    var delegate : Operations?
    var webView1 : WKWebView!
    
    //用户点击页面下载被触发
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        
        /*
        js中:window.webkit.messageHandlers.notification.postMessage(data)
        */
        let receiveData = message.body as! Dictionary<String,AnyObject>
        println(receiveData)
        
        //println("下载地址:")
       // println(receiveData[5])
        
        //调用downloader下载
//        cacheRootURL = NSURL(fileURLWithPath: cacheRootPath)!
//        cacheRootURL = cacheRootURL.URLByAppendingPathComponent("media/audio/download")
//        
//        
//        downloader.addTask(receiveData[1] as! String, cacheRootURL: cacheRootURL, filename: receiveData[0] as? String)
//        downloader.startDownload()
//        println(downloader.list)
//        
        
        //标记已经下载的
        let operation = receiveData["operation"] as? String
        
        if  operation == "refreshPage"
        {
            markPageDownload(webView1, marItem: nil)
        }else{
            addToSenceList(receiveData["sceneName"] as! String, sourceData: receiveData)
            markPageDownload(webView1, marItem: receiveData)
        }
        
    }
    
    
    func addToSenceList(sceneName:String,sourceData :Dictionary<String,AnyObject>)
    {
//        var currentAgeGroupData : Array<AnyObject> = delegate!.getCurentAgeGroupData()
//        //println(currentAgeGroupData)
//        
//        for sceneItem in currentAgeGroupData
//        {
//            if sceneItem["name"] as! String == sceneName
//            {
//                var currentSceneList = sceneItem["list"]
//                
//                
//            }
//        }
        
        //var webResource : Dictionary<String,AnyObject> = genarateData(sourceData)
        delegate?.updateCurrentScenePlayList(sourceData, isAdd: true, sceneName: sceneName)
       
    }
    
    func markPageDownload(wkWebView1:WKWebView,marItem:Dictionary<String,AnyObject>?)
    {
        var currentAgeGroupData : Array<AnyObject> = delegate!.getCurentAgeGroupData()
        //println(currentAgeGroupData)
        
//        for sceneItem in currentAgeGroupData
//        {
//            if sceneItem["name"] as! String == marItem["sceneName"]as! String
//            {
//                var currentSceneList = sceneItem["list"] as! [Dictionary<String,AnyObject>]
//                
//                for listItem in currentSceneList
//                {
//                    if listItem["id"]as! String == marItem["id"]as! String
//                    {
//                        let id = marItem["id"] as! String
//                        let jsString = "downloadCompleteById(\"\(id)\")"
//                        wkWebView1.evaluateJavaScript(jsString, completionHandler: nil)
//                        
//                    }
//                }
//            }
//        }

        for sceneItem in currentAgeGroupData
        {
            
                var currentSceneList = sceneItem["list"] as! [Dictionary<String,AnyObject>]
                
                for listItem in currentSceneList
                {
                    
                        let id = listItem["id"] as! String
                        let jsString = "downloadCompleteById(\"\(id)\")"
                        wkWebView1.evaluateJavaScript(jsString, completionHandler: nil)
                        
                    
                }
            }
        
    }
    //格式化新增内容属性
    func genarateData(dataArray:NSArray) -> Dictionary<String,AnyObject>
    {
        
        var ugcData : Dictionary<String,AnyObject>  = Dictionary<String,AnyObject>()
        
        var name = dataArray[0] as! String
        var remoteURL = dataArray[1] as! String
        var localURI = dataArray[2] as! String
        var tag = dataArray[3] as! String
        var series = dataArray[4] as! String
        var isUGC = "true"
        
//        let nameCount = count(name)
//        //对名字进行处理,截掉后缀名
//        var isError : NSError?
//        let pattern = "\\.\\w+$"
//        var regex:NSRegularExpression = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive, error: &isError)!
//        
//        let modName = regex.stringByReplacingMatchesInString(name, options: nil, range: NSMakeRange(0, nameCount), withTemplate: "")
        
        ugcData["name"]=name
        ugcData["remoteURL"]=remoteURL
        ugcData["localURI"]=localURI
        ugcData["tag"]=tag
        ugcData["series"]=series
        ugcData["isUGC"]=isUGC
        ugcData["numberOfLoops"]=0
        
        return ugcData
        
    }

}

class BrowserViewController: UIViewController  {

    var downloader : Downloader!
    var delegate : Operations?

    var webView1 : WKWebView!
    //ugc下载列表
    var ugcDownloadList : Array<DownloadItemProtocol> = Array<DownloadItemProtocol>()
    var handler : NotificationScriptMessageHandler!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //println(downloader.list)

        //下载列表按钮
        //添加iTunes上传帮助教程
        var downloadListButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action:Selector("showDoloadList") )
        //下载列表按钮
        //self.navigationItem.rightBarButtonItem = downloadListButton
        self.title = "资源库"
//        webView1.loadRequest(NSURLRequest(URL: NSURL(string: "http://localhost/UGC_HTML/UGC3rdOnlineResource.html")!))
////        uiWebView1.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.baidu.com")!))
        
        //初始化WKWebView
        initWKWebView(self)
        
        webView1.loadRequest(NSURLRequest(URL: NSURL(string: "http://localhost/UGC_HTML_2/UGC3rdOnlineResource.html")!))
        
        self.view.addSubview(webView1)
    }
    
    //界面即将丢失触发
    override func viewWillDisappear(animated: Bool) {
        
        //ugcDownloadList = handler.downloader.list
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //初始化WKWebView方法
    func initWKWebView(obj :UIViewController){
        
        let toolBarWidth : CGFloat = self.navigationController!.navigationBar.bounds.size.width
        let toolBarHeight : CGFloat = self.navigationController!.navigationBar.bounds.size.height
        let deviceWidth : CGFloat = obj.view.bounds.width
        let deviceHeight :CGFloat = obj.view.bounds.height
        
        
        let userContentController = WKUserContentController()
        handler = NotificationScriptMessageHandler()
        handler.downloader = self.downloader
        handler.delegate = self.delegate
        let configuration = WKWebViewConfiguration()
        userContentController.addScriptMessageHandler(handler, name: "notification")
        configuration.userContentController = userContentController
        
        
        webView1 = WKWebView(frame: CGRect(x:0, y: 0, width: deviceWidth, height: deviceHeight-toolBarHeight), configuration: configuration)
        //给handler的webview对象赋值,
        handler.webView1 = self.webView1
    }
    
    //MARK:自定义方法
    
    //显示下载列表页面
    func showDoloadList(){
        //获取要跳转的界面
        var downLoadListVC : DownLoadTableViewController = UIStoryboard(name: "UGC", bundle: nil).instantiateViewControllerWithIdentifier("downLoadListVC") as! DownLoadTableViewController
        downLoadListVC.downloader = self.downloader
        self.navigationController?.pushViewController(downLoadListVC, animated: true)
    }

    }
