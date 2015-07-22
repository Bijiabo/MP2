//
//  ViewController.swift
//  UGCModule
//
//  Created by SlimAdam on 15/7/18.
//  Copyright (c) 2015年 SlimAdam. All rights reserved.
//

import UIKit

class UGCViewController: UIViewController,Module{

    @IBOutlet var upLoadButton: UIButton!
    
    var moduleLoader : ModuleLader?
    var currentSceneData : [Dictionary<String,AnyObject>] = [Dictionary<String,AnyObject>]()
    
    var delegate : Operations?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //println("UGCVIEW:\(currentSceneData)")
        self.title = "添加内容"
        
        
        
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


}

