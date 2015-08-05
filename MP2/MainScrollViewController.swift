//
//  MainScrollViewController.swift
//  MP2
//
//  Created by SlimAdam on 15/7/30.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit

class MainScrollViewController: UIViewController,UIScrollViewDelegate,Module,ViewManager {

    var moduleLoader : ModuleLoader?
    
    var delegate : Operations?
    
    var model : ModelManager?
    
    //主播放界面对象
    var mainVC : ViewController!
    //设备宽高
    var deviceWidth : CGFloat = 0
    var deviceHeight : CGFloat = 0
    //scrollView页数
    var pageCount : Int = 0
    
    @IBOutlet var mainScrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*初始化*/
        mainScrollView.delegate = self
        
//        deviceWidth = UIScreen.mainScreen().bounds.width
//        deviceWidth = UIScreen.mainScreen().bounds.height
        
        deviceWidth = self.view.frame.width
        deviceHeight = self.view.frame.height
        
        pageCount = model!.scenelist.count
        
        //初始化scrollView大小
        mainScrollView.contentSize = CGSize(width: deviceWidth * CGFloat(pageCount), height: deviceHeight)
        println(deviceWidth)
        
        var frame = CGRect(x: 0, y: 0, width: deviceWidth, height: deviceHeight)
        mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainVC_0") as! ViewController
        mainVC.model = self.model
        mainVC.delegate = self.delegate
        mainVC.moduleLoader = self.moduleLoader
        
        self.addChildViewController(mainVC)
        mainScrollView.addSubview(mainVC.view)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        println(scrollView.contentOffset)
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        println(scrollView.contentOffset)
    }
    
    
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
