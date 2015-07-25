//
//  TempListTableViewController.swift
//  
//
//  Created by SlimAdam on 15/7/18.
//
//

import UIKit

class TempListTableViewController: UITableViewController ,UITableViewDelegate,UITableViewDataSource,Module{

    var moduleLoader : ModuleLader?
    var currentSceneData : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]()
        
    var listCount = 0
    var localList : Dictionary<String,NSURL> = Dictionary<String,NSURL>()
    var selectedArray : [Int]! = []
    var delegate : Operations?
    var currentAgeGroupData : Array<AnyObject> = Array<AnyObject>()
    
    var currentSceneName :String?
    //表格显示数据
    
    //当界面被加载
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        localList = delegate!.getUploadList()
        
        currentSceneName = getCurrentSceneName()
        //println(currentSceneName)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = "已上传内容"
        
        //遍历document下的所有文件
        let homeDir = NSHomeDirectory().stringByAppendingPathComponent("Documents")
        var fileManager = NSFileManager.defaultManager()
        
        let fileList = fileManager.contentsOfDirectoryAtURL(NSURL(fileURLWithPath: homeDir)!, includingPropertiesForKeys: nil, options: nil, error: nil) as! [NSURL]
        
        //初始化数据
        currentAgeGroupData = delegate!.getCurentAgeGroupData()
        //println(currentAgeGroupData)
        

        
        //println(NSHomeDirectory())
        //println("TempListTableVC\(currentSceneData)")
        //初始化用户操作临时记录
        
        //添加iTunes上传帮助教程
        var iTunesBtn : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action:Selector("clickITunesBtn") )
        
        self.navigationItem.rightBarButtonItem = iTunesBtn
        
        
        //println("LOCALLIST:\(localList)")
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.backBarButtonItem?.title = "返回啦"
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows 1in the section.
        return localList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cellId = "listItem"
        
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellId) as! UITableViewCell
        
    
        var localListURL = localList["\(indexPath.row)"]!
        cell.textLabel!.text = localListURL.lastPathComponent!
        
        for sceneItem in currentAgeGroupData
        {
            let listarray = sceneItem["list"]as!NSArray
            for listDictionary in listarray
            {
                
                let localURL:String = listDictionary["localURI"] as! String
                
                if localURL == localListURL.relativePath
                {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    
                }
            }
        }
        

        return cell
    }
    
    


    //用户点击列表项触发
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //println("选中了:\(indexPath.row.hashValue)")
        
        
        let selectedItem = tableView.cellForRowAtIndexPath(indexPath)
        
        let itemData = localList["\(indexPath.row)"]
        
        
        //传入NSURL,生成固定格式的字典,并且返回
        var ugcData : Dictionary<String,AnyObject>  = genarateData(itemData!)
        
        //println(ugcData)
        
        if selectedItem?.accessoryType == UITableViewCellAccessoryType.Checkmark
        {
            selectedItem?.accessoryType = UITableViewCellAccessoryType.None
            delegate?.updateCurrentScenePlayList(ugcData, isAdd: false)
            println("删除内容")
        }else{
            
            selectedItem?.accessoryType = UITableViewCellAccessoryType.Checkmark
            delegate?.updateCurrentScenePlayList(ugcData, isAdd: true)
            println("添加内容")
            
        }
        
        //addSelectedItemToArray(indexPath.row)
        
        
        
        
    }
    
    //格式化新增内容属性
    func genarateData(fileURL:NSURL) -> Dictionary<String,AnyObject>
    {
        
        var ugcData : Dictionary<String,AnyObject>  = Dictionary<String,AnyObject>()
        
        var name = fileURL.lastPathComponent!
        var localURI : String
        var isUGC = "true"
        
        let nameCount = count(name)
        localURI = fileURL.relativePath!
        //对名字进行处理,截掉后缀名
        var isError : NSError?
        let pattern = "\\.\\w+$"
        var regex:NSRegularExpression = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive, error: &isError)!
        
        let modName = regex.stringByReplacingMatchesInString(name, options: nil, range: NSMakeRange(0, nameCount), withTemplate: "")
        
        ugcData["name"]=modName
        ugcData["localURI"]=localURI
        ugcData["isUGC"]=isUGC
        ugcData["numberOfLoops"]=0
        return ugcData
        
    }
    
    
    func getCurrentSceneName( ) ->String
    {
        return delegate!.getCurrentSceneName()
    }

    func clickITunesBtn(){
        
        //获取要跳转的界面
        var UGCHomeVC : ItunesGuiderViewController = UIStoryboard(name: "UGC", bundle: nil).instantiateViewControllerWithIdentifier("iTnuesHelpVC") as! ItunesGuiderViewController
        
        self.navigationController?.pushViewController(UGCHomeVC, animated: true)
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }*/
    

    
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
