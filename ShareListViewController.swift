//
//  ShareListViewController.swift
//  MP2
//
//  Created by SlimAdam on 15/8/14.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit

class ShareListViewController: UIViewController{

    @IBOutlet weak var tableView1: UITableView!
    
    var delegate : Operations?
    
    var upYun = UpYun()
    var callBackStr = ""
    var sharerNameArray : [String] = []
    var shareData : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("downloadSuccess"), name: "DownloadSuccess", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("downloadSuccessWithJson"), name: "DownloadSuccessWithJsonData", object: nil)
        self.title = "萌友分享列表"
        _initUpYun()
        
        upYun.downloadFile("data")
//        NSUserDefaults.standardUserDefaults().setBool(<#value: Bool#>, forKey: <#String#>)
        
    }

    func stringToArray(str : String) -> [String]
    {
        
        var tempArray : [String] = []
        var strhtml : NSString = NSString(string: str)
        
        strhtml = strhtml.stringByReplacingOccurrencesOfString("\t", withString: "\\")
            
        strhtml = strhtml.stringByReplacingOccurrencesOfString("\n", withString: "\\")

        var arr : NSArray  =  strhtml.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\\"))
        
        var j = 0
        for i in 0..<arr.count
        {
            if i%4 == 0
            {
                //tempArray[j] = arr[i] as! String
                var n : NSString = NSString( string: arr[i] as! String)
                n = n.stringByReplacingOccurrencesOfString(".json", withString: "")
                
                tempArray.append(n as String)
                println("index\(i)--value\(arr[i])")
                //j++
            }
        }
        return tempArray
    }
    
    private func _initUpYun()
    {
        upYun.passcode = "ukeX7vTiPkknHGT9gtUholk2MdI="
        upYun.bucket = "earlyenglishstudy"
        upYun.expiresIn = 6000
    }
    //读取目录成功
    func downloadSuccess()
    {
        callBackStr = NSUserDefaults.standardUserDefaults().objectForKey("returnContent") as! String
        
        sharerNameArray = stringToArray(callBackStr)
        
        self.tableView1.reloadData()
    }
    //读取指定文件成功
    func downloadSuccessWithJson()
    {
        let callbackData =  NSUserDefaults.standardUserDefaults().objectForKey("returnJsonData") as! Dictionary<String,AnyObject>
        
        shareData = callbackData
        
        self.tableView1.reloadData()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return currentSceneData.count
        //为了暂时能体现列表的歌曲在动,限定在只显示10首歌曲
        return sharerNameArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //let sharerName = sharerList[indexPath.row]["sharerName"]as! String
        
        let cellId = "sharerCell"
        
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellId) as! UITableViewCell
        
        
        cell.textLabel?.text = "来自宝妈 " + sharerNameArray[indexPath.row] + " 的分享"
        
        
        
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 64
    }
    //用户点击某行触发
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
       // let sharerData  = sharerList[indexPath.row]
        
        let file  = "data/\(sharerNameArray[indexPath.row] ).json"
        
        upYun.downloadFile(file)
        
        println(shareData)
        //添加列表
       // delegate?.updateCurrentScenePlayList(sharerData, isAdd: true, sceneName: nil)
        delegate?.updateCurrentScenePlayList(shareData, isAdd: true, sceneName: nil)
        
    }

    

}
