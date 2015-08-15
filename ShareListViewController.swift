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
    
    let sharerList  = NSUserDefaults.standardUserDefaults().objectForKey("sharerList")as![Dictionary<String,AnyObject>]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "萌友分享列表"

        
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
        return sharerList.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let sharerName = sharerList[indexPath.row]["sharerName"]as! String
        
        let cellId = "sharerCell"
        
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellId) as! UITableViewCell
        
        cell.textLabel?.text = sharerName
        
        
        
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 64
    }
    //用户点击某行触发
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        let sharerData  = sharerList[indexPath.row]
        
        //添加列表
        delegate?.updateCurrentScenePlayList(sharerData, isAdd: true, sceneName: nil)
        
    }

    

}
