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
    
    //所有场景缓存
    var scenesDataCache : [Dictionary<String,AnyObject>]?
    
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
        self.view.backgroundColor = UIColor.grayColor()
        /*初始化*/
        mainScrollView.delegate = self
        
        scenesDataCache = model!.scenesDataCache
        
        deviceWidth = self.view.frame.width
        deviceHeight = self.view.frame.height
        
        pageCount = model!.scenelist.count
        currentPage = model!.status.currentSceneIndex
        
        
        
        _initScrollView()
    }

    private func _initScrollView()
    {
        //初始化scrollView大小
        mainScrollView.contentSize = CGSize(width: deviceWidth * CGFloat(pageCount), height: deviceHeight)
        println(deviceWidth)
        //标示首次加载
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isFirstLoad")
        var scenesVCCollection : [ViewController] = []
        for i in 0..<model!.scenesDataCache!.count
        {
            
            var frame = CGRect(x: deviceWidth * CGFloat(i), y: 0, width: deviceWidth, height: deviceHeight)
            var mainVC1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainVC_0") as! ViewController
            
            if let sceneArray : [Dictionary<String,AnyObject>] = scenesDataCache
            {
                mainVC1.sceneDataCache = sceneArray[i]
            }
            
            mainVC1.model = self.model
            mainVC1.delegate = self.delegate
            mainVC1.moduleLoader = self.moduleLoader
            mainVC1.view.frame = frame
            mainVC1.view.tag = i
            
            mainVC1.scrollViewController = self
            
            self.addChildViewController(mainVC1)
            
            mainScrollView.addSubview(mainVC1.view)
            
            scenesVCCollection.append(mainVC1)
            
        }
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isFirstLoad")
        //保存VC数组
        //NSUserDefaults.standardUserDefaults().setObject(scenesVCCollection, forKey: "scenesVCCollection")
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
        
    }
    
    func switchSceneToIndex(index : Int) {
        println("切换到场景序数\(index)")
        
        for childVC in self.childViewControllers {
            let childPlayViewController : ViewController = childVC as! ViewController
            
            if childPlayViewController.view.tag == index {
                
                if childPlayViewController.playPauseButton.tag == 0 {
                    childPlayViewController.playPauseButton.setBackgroundImage(UIImage(named: "pauseButton") , forState: UIControlState.Normal)
                } else {
                    childPlayViewController.playPauseButton.setBackgroundImage(UIImage(named: "playButton")!, forState: UIControlState.Normal)
                }
            } else {
                childPlayViewController.playPauseButton.setBackgroundImage(UIImage(named: "playButton")!, forState: UIControlState.Normal)
                
                //childPlayViewController.playPauseButton.tag = 0
                
            }
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
