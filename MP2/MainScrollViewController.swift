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
    //当前页数(对应场景)
    var currentPage : Int = 0
    //scrollView上次拖动位移
    var lastOffset : CGFloat = 0
    
    //一个移动方向标识
    var isToRight = false
    
    //左/右场景
    var leftSubVC : ViewController!
    var rightSubVC :  ViewController!
    
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
        currentPage = model!.status.currentSceneIndex
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
        initSubVC()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //开始拖动的时候触发事件
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        println(scrollView.contentOffset)
        
    }
    
    //
    func scrollViewDidScroll(scrollView: UIScrollView) {
        println(scrollView.contentOffset)
        
        let rightFlag : Bool = (scrollView.contentOffset.x - lastOffset) > 0
        
        //如果方向改变了,重新给方向标识赋值
        if isToRight != rightFlag
        {
            isToRight = rightFlag
            
        }else{
            
        }
        addNextSubView()
    }
    
    
    //拖动结束触发:当手离开屏幕
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        lastOffset = scrollView.contentOffset.x
        
        if isToRight
        {
            currentPage++
        }else{
            currentPage--
        }
        initSubVC()
    }
    
    //添加子界面
    func addNextSubView()
    {
        if isToRight
        {
            
            self.addChildViewController(rightSubVC)
            mainScrollView.addSubview(rightSubVC.view)
            
        }else{
            self.addChildViewController(leftSubVC)
            mainScrollView.addSubview(leftSubVC.view)
            
        }
    }
    
    
    //初始化左右界面
    
    func initSubVC(){
        
        //如果当前场景不在第一页或者最后一页
        if currentPage > 0 && currentPage < pageCount - 1
        {
            leftSubVC  = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainVC_0") as! ViewController
            leftSubVC.delegate = self.delegate
            leftSubVC.model = self.model
            leftSubVC.moduleLoader = self.moduleLoader
            leftSubVC.view.frame = CGRect(x: CGFloat((currentPage-1)) * deviceWidth, y: 0, width: deviceWidth, height: deviceHeight)
            
            rightSubVC  = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainVC_0") as! ViewController
            rightSubVC.delegate = self.delegate
            rightSubVC.model = self.model
            rightSubVC.moduleLoader = self.moduleLoader
            rightSubVC.view.frame = CGRect(x: CGFloat((currentPage+1)) * deviceWidth, y: 0, width: deviceWidth, height: deviceHeight)
            
        }else if currentPage == 0{
            rightSubVC  = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainVC_0") as! ViewController
            rightSubVC.delegate = self.delegate
            rightSubVC.model = self.model
            rightSubVC.moduleLoader = self.moduleLoader
            rightSubVC.view.frame = CGRect(x: CGFloat((currentPage+1)) * deviceWidth, y: 0, width: deviceWidth, height: deviceHeight)
        }else if currentPage == pageCount-1{
            
            leftSubVC  = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainVC_0") as! ViewController
            leftSubVC.delegate = self.delegate
            leftSubVC.model = self.model
            leftSubVC.moduleLoader = self.moduleLoader
            leftSubVC.view.frame = CGRect(x: CGFloat((currentPage-1)) * deviceWidth, y: 0, width: deviceWidth, height: deviceHeight)
        }
        
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
