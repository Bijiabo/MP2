//
//  PlayListTableViewController.swift
//  MP2
//
//  Created by SlimAdam on 15/7/16.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit

class PlayListTableViewController: UITableViewController ,UIActionSheetDelegate,Module,UIAlertViewDelegate{

    var moduleLoader : ModuleLoader?
    @IBOutlet var uiView1: UITableView!
    
    //播放列表
    var currentSceneData : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]()
    var currentPlayingData : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
    
    var cellHeight : CGFloat = 0
    var delegate : Operations?
    var downloader : Downloader!
    var upYun = UpYun()
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        
        //初始化upYun
        _initUpYun()
    }
    
    private func _initUpYun()
    {
        upYun.passcode = "ukeX7vTiPkknHGT9gtUholk2MdI="
        upYun.bucket = "earlyenglishstudy"
        upYun.expiresIn = 6000
    }
    func downloadSuccess()
    {
        //var returnContent = NSUserDefaults.standardUserDefaults().objectForKey("returnContent") as! String
        print(NSUserDefaults.standardUserDefaults().objectForKey("returnContent"))
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //准备加载该界面,获取最新场景列表
        currentSceneData = delegate!.getCurrentScenePlayList(nil)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let navigationbarBackgroundImage : UIImage = createImageWithColor( UIColor.whiteColor() )
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(navigationbarBackgroundImage, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = false
        
        let statusBarBackgroundViewPositionY : CGFloat = 0 - self.navigationController!.navigationBar.frame.size.height - 20.0
        
        var uiView1 = UIView(frame: CGRect(x: 0, y: statusBarBackgroundViewPositionY , width: self.view.frame.size.width, height: 20))
        uiView1.backgroundColor = UIColor.redColor()

        //刷新当前界面
        self.tableView.reloadData()
        
//        self.view.addSubview(uiView1)
//        self.view.sendSubviewToBack(uiView1)
    }
    
    func createImageWithColor ( color : UIColor ) -> UIImage
    {
        let rect : CGRect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        
        UIGraphicsBeginImageContext(rect.size)
        var context : CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
    
        let theImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return theImage
    }
    
    
        
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSceneData.count
        //为了暂时能体现列表的歌曲在动,限定在只显示10首歌曲
        //return 10
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tempDataDictionary = currentSceneData[indexPath.row]
        let cellId = "playListItem"
        
        var cell : playlistTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellId) as! playlistTableViewCell

        let name = currentSceneData[indexPath.row]["name"] as? String
        
        cell.audioNameLabel.text = name
        cell.audioTagLabel.text = currentSceneData[indexPath.row ]["tag"] as? String
        //let isUGC = currentSceneData[indexPath.row ]["isGUC"]
        //println(currentSceneData[indexPath.row]["isGUC"])
        
        
        if tempDataDictionary["isUGC"] != nil
        {
            cell.audioFromLabel.text = "来自用户上传"
        }else{
            cell.audioFromLabel.text = "来自系统推送"
        }
        
        
        //判断当前播放歌曲
        if  currentPlayingData["name"] as? String == name
        {
            cell.active = true
        }else{
            cell.active = false
        }
        return cell
    }
    
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 64
    }

    //
    @IBAction func clickAddResourceButton(sender: UIBarButtonItem) {
        
        var sheet = UIActionSheet(title: nil , delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil ,otherButtonTitles: "添加歌曲","列表分享")
        sheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        switch buttonIndex
        {
        case 0:
            break
        case 1:
            //获取要跳转的界面
            var UGCHomeVC : UGCViewController = UIStoryboard(name: "UGC", bundle: nil).instantiateViewControllerWithIdentifier("mainVC") as! UGCViewController
            
            UGCHomeVC.currentSceneData = self.currentSceneData
            UGCHomeVC.delegate = self.delegate
            self.navigationController?.pushViewController(UGCHomeVC, animated: true)
            
            println("切换到UGC界面")
        case 2:
            postShareData()
        default:
            break
        }
        
    }
    
    //MARK: 分享
    
    //发送分享内容
    func postShareData()
    {
        //得到当前场景下的播放列表
        if var _scenePlayList : [Dictionary<String,AnyObject>] = delegate?.getCurrentScenePlayList(nil){
            
            for i in 0..<_scenePlayList.count
            {
                //如果是用户自定义上传的歌曲,上传音乐文件到服务器
                if _scenePlayList[i]["isUGC"] != nil
                {
                    
                    var localURL = _scenePlayList[i]["localURI"] as! String
                    upYun.uploadFile(localURL, saveKey:_scenePlayList[i]["name"]as! NSString as String)
                    
                    let remoteURL : AnyObject? = "http://v0.api.upyun.com/earlyenglishstudy/media/\(localURL)"
                    
                  
                    //MARK: 拼接远程URL
                    _scenePlayList[i]["remoteURL"] = remoteURL
                    
                }
            }
            
            
            //要分享的歌单
            var shareData: Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
            //先保存到tmp文件夹
            var savePathURL = NSURL(fileURLWithPath: NSHomeDirectory())?.URLByAppendingPathComponent("tmp")
            
            var date:NSDate = NSDate()
            var formatter : NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let dateString = formatter.stringFromDate(date)
            
            var fileName = ""
            //fileName = "\(dateString).json"
            //获取宝宝名字
           if let childName : String = NSUserDefaults.standardUserDefaults().stringForKey("childName")
           {
                shareData["sharerName"] = "来自 \(childName) 宝宝妈的分享"
                savePathURL = savePathURL?.URLByAppendingPathComponent("\(childName).json")
                fileName = "\(childName).json"
            
           }else{
            
                shareData["sharerName"] = "来自匿名宝妈的分享"
                savePathURL = savePathURL?.URLByAppendingPathComponent("000.json")
                fileName = "匿名妈妈.json"
            }
            
            shareData["list"] = _scenePlayList
            
            let toFile = savePathURL?.relativePath!
            
            save(shareData,toFile:toFile!)
            
            upYun.uploadFile(toFile, saveKey: "/data/\(fileName)")
            
        }
        
       let upSuccessAlert =  UIAlertView(title: nil, message: "分享成功", delegate: self, cancelButtonTitle: "ok")
        upSuccessAlert.alertViewStyle = UIAlertViewStyle.Default
        upSuccessAlert.show()
        
    }
    
    //数组转换成Json
    func toJSONString(dict:AnyObject)->NSString{
        
        var data = NSJSONSerialization.dataWithJSONObject(dict, options:NSJSONWritingOptions.PrettyPrinted , error: nil)
        var strJson=NSString(data: data!, encoding: NSUTF8StringEncoding)
        return strJson!
        
    }

    func save(jsonData :AnyObject, toFile : String)
    {
        var error:NSError?
        
        let str: AnyObject = toJSONString(jsonData)
        str.writeToFile(toFile, atomically: false, encoding: NSUTF8StringEncoding, error: &error)
        
        if error != nil
        {
            println(error)
        }
        else
        {
            println("他喵的保存文件成功了好么!!!")
        }
        
    }

    

}
