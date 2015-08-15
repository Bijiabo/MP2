//
//  PlayListTableViewController.swift
//  MP2
//
//  Created by SlimAdam on 15/7/16.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit

class PlayListTableViewController: UITableViewController ,Module{

    var moduleLoader : ModuleLoader?
    @IBOutlet var uiView1: UITableView!
    
    //播放列表
    var currentSceneData : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]()
    var currentPlayingData : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
    
    var cellHeight : CGFloat = 0
    var delegate : Operations?
    var downloader : Downloader!
    var userindex = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
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
        
        //获取要跳转的界面
        var UGCHomeVC : UGCViewController = UIStoryboard(name: "UGC", bundle: nil).instantiateViewControllerWithIdentifier("mainVC") as! UGCViewController
        
        UGCHomeVC.currentSceneData = self.currentSceneData
        UGCHomeVC.delegate = self.delegate
        self.navigationController?.pushViewController(UGCHomeVC, animated: true)
        
        println("切换到UGC界面")
        postShareData()
    }
    
    
    //MARK: 分享
    
    //发送分享内容
    func postShareData()
    {
        //得到当前场景下的播放列表
        if let _scenePlayList : [Dictionary<String,AnyObject>] = delegate?.getCurrentScenePlayList(nil){
            
            for i in 0..<_scenePlayList.count
            {
                //如果是用户自定义上传得歌曲,上传音乐文件到服务器
                if _scenePlayList[i]["isUGC"] != nil
                {
                    let musicName = _scenePlayList[i]["name"] as! String
                    println("需要上传歌曲:\(musicName)")
                 
                }
            }
            
            //MARK:模拟后端存储
            var sharerList = NSUserDefaults.standardUserDefaults().objectForKey("sharerList")as! [Dictionary<String,AnyObject>]
            var shareData: Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
            
            shareData["sharerName"] = "用户\(userindex)的分享"
            shareData["list"] = _scenePlayList
            sharerList.append(shareData)
            NSUserDefaults.standardUserDefaults().setObject(sharerList, forKey: "sharerList")
            userindex++
        }
        
        
    }

    

}
