//
//  PlayListTableViewController.swift
//  MP2
//
//  Created by SlimAdam on 15/7/16.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit

class PlayListTableViewController: UITableViewController ,Module{

    var moduleLoader : ModuleLader?
    @IBOutlet var uiView1: UITableView!
    
    //播放列表
    var currentSceneData : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]()
    var currentPlayingData : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
    
    var cellHeight : CGFloat = 0
    var delegata : Operations?
    var downloader : Downloader!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //self.title = "播放列表"
        //println(currentSceneData[0]["name"] as! String)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //准备加载该界面,获取最新场景列表
        currentSceneData = delegata!.getCurrentScenePlayList()
        
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
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return currentSceneData.count
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
        UGCHomeVC.delegate = self.delegata
        self.navigationController?.pushViewController(UGCHomeVC, animated: true)
        
        println("切换到UGC界面")
    }
    
    
    /*
    //界面跳转传值,navigation跳转不行
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "mainVC"
        {
            var addMusicVC = segue.destinationViewController as! UGCViewController
            
            addMusicVC.currentSceneData = self.currentSceneData
        }
    }
    */
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
