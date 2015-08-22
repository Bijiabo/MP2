//
//  LeftController.swift
//  MP2
//
//  Created by SlimAdam on 15/8/22.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit

class LeftController: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var menuDelegate:MenuDelegate?
    
    var menus : Array<String> = ["个人设置","意见与建议"]
    
    var rightVC : MainScrollViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableView.backgroundColor = UIColor.blackColor()
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: tableView
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return menus.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        cell.textLabel?.text = menus[indexPath.row]
        cell.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1)
        
        cell.textLabel?.textColor = UIColor.whiteColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        switch  indexPath.row {
        case 0:
            //个人设置
            println("个人设置")
            
            menuDelegate?.closeMenu()
            var userInfoView : userInformationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("userInformationSetting") as! userInformationViewController
            self.rightVC!.navigationController?.pushViewController(userInfoView, animated: true)
//            self.navigationController?.pushViewController(userInfoView, animated: true)
        case 1:
            //意见反馈
            println("意见反馈")
            
            menuDelegate?.closeMenu()
            var feedBackVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("feedBackVC") as! UIViewController
            self.rightVC?.navigationController?.pushViewController(feedBackVC, animated: true)
        case 2:
            //关于
            println("关于")
        default:
            break
        }
    }

}
