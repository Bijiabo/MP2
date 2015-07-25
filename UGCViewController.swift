//
//  ViewController.swift
//  UGCModule
//
//  Created by SlimAdam on 15/7/18.
//  Copyright (c) 2015年 SlimAdam. All rights reserved.
//

import UIKit

class UGCViewController: UIViewController,Module{

   
    
    var moduleLoader : ModuleLader?
    var currentSceneData : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]()
    
    var delegate : Operations?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //println("UGCVIEW:\(currentSceneData)")
        self.title = "添加内容"
        
        
    }

    override func viewWillAppear(animated: Bool) {
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //界面跳转传值
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //println("identifieer-------\(segue.identifier)")
        if segue.identifier == "addLocalDataVC"
        {
            var addMusicVC = segue.destinationViewController as! TempListTableViewController
            
            addMusicVC.currentSceneData = self.currentSceneData
            addMusicVC.delegate = self.delegate
        }
    }
    
    
    @IBAction func clickUploadDataButton(sender: UIButton) {
        
        //如果上传列表不为空,跳转到上传列表界面
        let tempListCount = delegate!.getUploadList().count
        println(tempListCount)
        if tempListCount != 0
        {
            var tempListTableVC : TempListTableViewController = UIStoryboard(name: "UGC", bundle: nil).instantiateViewControllerWithIdentifier("tempListTableVC") as! TempListTableViewController
            tempListTableVC.currentSceneData = self.currentSceneData
            tempListTableVC.delegate = self.delegate
            
            self.navigationController?.pushViewController(tempListTableVC, animated: true)
        }else{
            gotoUploadMessageVC()
        }
    }

    func gotoUploadMessageVC()
    {
        //获取要跳转的界面
        var uploadMessageVC : UploadMessageViewController = UIStoryboard(name: "UGC", bundle: nil).instantiateViewControllerWithIdentifier("uploadMessageVC") as! UploadMessageViewController
        
        self.navigationController?.pushViewController(uploadMessageVC, animated: true)
    }


}

