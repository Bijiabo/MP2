//
//  ViewController.swift
//  MP2
//
//  Created by bijiabo on 15/6/18.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//
import UIKit

class ViewController: UIViewController , UITabBarDelegate , ViewManager , UIAlertViewDelegate , Module
{
    var moduleLoader : ModuleLader?
    
    var delegate : Operations?

    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var tabBar: UITabBar!
    @IBOutlet var audioName: UILabel!
    @IBOutlet var audioTag: UILabel!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var mainNavigationBar: UINavigationBar!
    @IBOutlet var navigationBarTitle: UINavigationItem!
    @IBOutlet var downloadingTipView: UIView!
    @IBOutlet var downloadingTipLabel: UILabel!
    @IBOutlet var downloadingTipActivityView: UIActivityIndicatorView!

    @IBOutlet var childNameLabel: UILabel!
    
    var model : ModelManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.delegate = self
        
        initTabBar()
        
        initPlayPauseButton()
        
        initAudioInfoView()
        
        _refreshBackgroundImageView(view: backgroundImageView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("CurrentPlayingDataHasChanged:"), name: "CurrentPlayingDataHasChanged", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playingStatusChanged:"), name: "PlayingStatusChanged", object: nil)
        //添加一个观察者,如果接收到childNameHasChange消息,就修改孩子名
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateChildNameLabel"), name: "childDataHasChange", object: nil)
        
        _refreshNavigationBar(navigationBar: mainNavigationBar)
        
        initDownloadTipView()
        
        //加载完毕，发送通知
        NSNotificationCenter.defaultCenter().postNotificationName("MainPlayerViewControllerDidLoad", object: nil)
        
        //MARK: 播放界面显示宝宝姓名和年龄(待处理问题:用户输入空格...)
        //显示孩子名字,如果存在的话
        if let childName : String = NSUserDefaults.standardUserDefaults().stringForKey("childName")
        {
            
            if childName != ""
            {
                childNameLabel.text = childName
                
                //显示孩子的年龄,如果存在的话
                if let childBirthday : NSDate = NSUserDefaults.standardUserDefaults().objectForKey("childBirthday") as? NSDate
                {
                    let childAge : (age : Int , month : Int) = AgeCalculator(birth: childBirthday).age
                    
                    childNameLabel.text = childNameLabel.text! + "-\(childAge.age)岁"
                }
                
            }else{
                childNameLabel.text = ""
            }
            
            
        }else{
            childNameLabel.text = ""
        }
        
        
    }
    
    //接收到孩子年龄修改的通知,执行这个方法
    func updateChildNameLabel()
    {
        
        if let childName : String = NSUserDefaults.standardUserDefaults().stringForKey("childName")
        {
            if childName != ""
            {
                childNameLabel.text = childName
                
                //如果要显示年龄,那么孩子的名字必须是存在的
                let childBirthday : NSDate = NSUserDefaults.standardUserDefaults().objectForKey("childBirthday") as! NSDate
                
                let childAge : (age : Int , month : Int) = AgeCalculator(birth: childBirthday).age
                
                childNameLabel.text = childNameLabel.text! + "-\(childAge.age)岁"
            }else{
                childNameLabel.text =  ""
            }
            
        }
        
        
        
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        _refreshPlayButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func togglePlayPause(sender: AnyObject) {
        
        if delegate?.playing == true
        {
            delegate?.pause()
        }
        else
        {
            delegate?.play()
        }
    }
    
    func initTabBar()
    {
        //设定tabbar items
        var tabBarItems : [UITabBarItem] = []
        for var i=0; i<model?.scenelist.count ; i++
        {
            let barItem : UITabBarItem = UITabBarItem(title: model?.scenelist[i], image: UIImage(named: "Mode-\(model!.scenelist[i])"), tag: i)
            tabBarItems.append( barItem )
        }
        
        tabBar.setItems(tabBarItems, animated: false)
        
        //设定tabbar默认选中项目
        if let selectedIndex : Int = find(model!.scenelist, model!.status.currentScene)
        {
            for tabbarItem in tabBar.items as! [UITabBarItem]
            {
                if tabbarItem.tag == selectedIndex
                {
                    tabBar.selectedItem = tabbarItem
                    break
                }
            }
        }
        
    }
    
    func initPlayPauseButton()
    {
        if delegate?.playing == true
        {
            
            playPauseButton.setBackgroundImage(UIImage(named: "pauseButton") , forState: UIControlState.Normal)
            
            playPauseButton.tag = 1
        }
        else
        {
            playPauseButton.setBackgroundImage(UIImage(named: "playButton")!, forState: UIControlState.Normal)
            
            playPauseButton.tag = 0
        }
    }
    
    func initAudioInfoView ()
    {
        refreshAudioInfoView()
    }
    
    func refreshAudioInfoView ()
    {
        audioName.text = model?.currentPlayingData["name"] as? String
        audioTag.text = model?.currentPlayingData["tag"] as? String
        
        if let currentScene : String = model?.status.currentScene
        {
            navigationBarTitle.title = "\(currentScene)磨耳朵"
        }
    }
    
    func CurrentPlayingDataHasChanged(notification : NSNotification)
    {
        refreshAudioInfoView()
        
        _refreshBackgroundImageView(view: backgroundImageView)
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!)
    {
        let selectedIndex : Int = item.tag
        let targetScene : String = model!.scenelist[selectedIndex]
        
        delegate?.switchToScene(targetScene)
    }
    
    //喜欢按钮触发事件
    @IBAction func tapLikeButton(sender: AnyObject)
    {
        delegate?.doLike()
    }
    //不喜欢按钮触发事件
    @IBAction func tapDislikeButton(sender: AnyObject)
    {
        delegate?.doDislike()
    }
    
    func playingStatusChanged(notification : NSNotification)
    {
        _refreshPlayButton()
    }
    
    private func _refreshPlayButton()
    {
        if delegate?.playing == true
        {
            playPauseButton.setBackgroundImage(UIImage(named: "pauseButton") , forState: UIControlState.Normal)
        }
        else
        {
            playPauseButton.setBackgroundImage(UIImage(named: "playButton") , forState: UIControlState.Normal)
        }
    }
    
    private func _refreshBackgroundImageView (#view : UIImageView?) -> Void
    {
        
        if view == nil {return}
        
        let resourceURL : NSURL = NSBundle.mainBundle().resourceURL!.URLByAppendingPathComponent("resource/image", isDirectory: true)
        
        let sceneKey : String = model!.status.currentScene
        
        let imagePath : NSURL = resourceURL.URLByAppendingPathComponent("\(sceneKey).jpg")
        
        view!.image = UIImage(contentsOfFile: imagePath.relativePath!)
    }
    
    func _refreshNavigationBar (#navigationBar : UINavigationBar?) -> Void
    {
        if navigationBar == nil {return}
        
        navigationBar!.translucent = true
        navigationBar!.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        
        navigationBar!.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        navigationBar!.shadowImage = UIImage()
        
    }
    
    //MARK:
    //MARK: downloading Tip
    func initDownloadTipView()
    {
        hideDownloadingTip()
        
        addDownloadingObserver()
    }
    
    func addDownloadingObserver ()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("downloadStarted:"), name: "DownloadStarted", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("downloadStoped:"), name: "DownloadStoped", object: nil)
    }
    
    //下载开始
    func downloadStarted(notification : NSNotification)
    {
        showDownloadingTip()
    }
    
    //下载停止
    func downloadStoped(notification : NSNotification)
    {
        hideDownloadingTip()
    }
    
    func showDownloadingTip ()
    {
        downloadingTipActivityView.startAnimating()
        downloadingTipView.hidden = false
    }
    
    func hideDownloadingTip ()
    {
        downloadingTipActivityView.stopAnimating()
        downloadingTipView.hidden = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return UIStatusBarStyle.LightContent
    }
}


