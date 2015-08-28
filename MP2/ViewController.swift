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
    var menuDelegate:MenuDelegate?
    
    var moduleLoader : ModuleLoader?
    
    var delegate : Operations?
    
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var audioName: UILabel!
    @IBOutlet var audioTag: UILabel!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var mainNavigationBar: UINavigationBar!
    @IBOutlet var navigationBarTitle: UINavigationItem!
    @IBOutlet var downloadingTipView: UIView!
    @IBOutlet var downloadingTipLabel: UILabel!
    @IBOutlet var downloadingTipActivityView: UIActivityIndicatorView!

    @IBOutlet var childNameLabel: UILabel!
    
    var scrollViewController : MainScrollViewController!
    
    var model : ModelManager?
    var isFirst : Bool = false
    //首次载入,界面要显示的数据
    var sceneDataCache : Dictionary<String,AnyObject>?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        isFirst = NSUserDefaults.standardUserDefaults().boolForKey("isFirstLoad")
        
        if isFirst
        {
            initSceneView()
            
            if let _sceneName : Dictionary<String,AnyObject> = sceneDataCache
            {
                _refreshBackgroundImageView(view: backgroundImageView,sceneName: _sceneName["sceneName"] as? String)
            }
            
        }else{
            initAudioInfoView()
            _refreshBackgroundImageView(view: backgroundImageView,sceneName: nil)
        }
        
        
        //初始化播放暂停按钮
        initPlayPauseButton()
        
        //initAudioInfoView()
        
        //_refreshBackgroundImageView(view: backgroundImageView)
        
        //添加一个观察者,观察通知名字为CurrentPlayingDataHasChanged的通知,得到通知后执行CurrentPlayingDataHasChanged方法
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("CurrentPlayingDataHasChanged:"), name: "CurrentPlayingDataHasChanged", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playingStatusChanged:"), name: "PlayingStatusChanged", object: nil)
        //添加一个观察者,如果接收到childNameHasChange消息,就修改孩子名
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateChildNameLabel"), name: "childDataHasChange", object: nil)
        
        //初始化下载提示页面
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
                    let childAge : (age : Int , month: Int) = AgeCalculator(birth: childBirthday).age
                    
                    childNameLabel.text = childNameLabel.text! + "-\(childAge.age)岁"
                }
                
            }else{
                childNameLabel.text = ""
            }
        }else{
            childNameLabel.text = ""
        }
        
    }
    
    //初始化各个界面
    func initSceneView()
    {
        //获取场景显示显示数据
        if let sceneDataItem = sceneDataCache
        {
            self.audioName.text = sceneDataItem["playingName"] as? String
            self.audioTag.text = sceneDataItem["playingTag"] as? String
            let sceneName = sceneDataItem["sceneName"] as! String
            self.navigationBarTitle.title = "\(sceneName)磨耳朵"
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
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        _refreshNavigationBar(navigationBar: mainNavigationBar)
        _refreshPlayButton()
        
        //test
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //播放暂停按钮被点击
    @IBAction func togglePlayPause(sender: AnyObject) {
        
        
        self.scrollViewController.switchSceneToIndex(self.view.tag)
        
        //currentPlayingViewCode
        NSUserDefaults.standardUserDefaults().setInteger(self.view.tag, forKey: "currentPlayingViewCode")
        
        let selectedIndex : Int = self.view.tag
//        println("tabTag:\(selectedIndex)")
        let targetScene : String = model!.scenelist[selectedIndex]
        
        if targetScene != model?.status.currentScene
        {
            delegate?.switchToScene(targetScene)
        }
        
        
        if playPauseButton.tag == 1 {
            //play
            delegate?.pause()
            
            playPauseButton.tag = 0
            
            
            
        } else {
            delegate?.play()
            
            playPauseButton.tag = 1
            
            
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
        let currentPlayingViewCode = NSUserDefaults.standardUserDefaults().integerForKey("currentPlayingViewCode")
        
        if currentPlayingViewCode == self.view.tag
        {
            audioName.text = model?.currentPlayingData["name"] as? String
            audioTag.text = model?.currentPlayingData["tag"] as? String
            
            if let currentScene : String = model?.status.currentScene
            {
                self.title = "主界面"
                
                navigationBarTitle.title = "\(currentScene)磨耳朵"
            }
        }
        
        
    }
    
    func CurrentPlayingDataHasChanged(notification : NSNotification)
    {
//        println("CurrentPlayingDataHasChanged")
        refreshAudioInfoView()
        
        _refreshBackgroundImageView(view: backgroundImageView,sceneName: nil)
    }
    //用户点击触发
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!)
    {
        let selectedIndex : Int = item.tag
//        println("tabTag:\(item.tag)")
        let targetScene : String = model!.scenelist[selectedIndex]
        delegate?.switchToScene(targetScene)
    }
    
    //喜欢按钮触发事件
    @IBAction func tapLikeButton(sender: AnyObject)
    {
        NSUserDefaults.standardUserDefaults().setInteger(self.view.tag, forKey: "currentPlayingViewCode")
        delegate?.doLike()
        
    }
    //不喜欢按钮触发事件
    @IBAction func tapDislikeButton(sender: AnyObject)
    {
        
        NSNotificationCenter.defaultCenter().postNotificationName("tapDislike", object:model as? AnyObject)
        
        let sceneName = model!.scenelist[self.view.tag]
        NSUserDefaults.standardUserDefaults().setInteger(self.view.tag, forKey: "currentPlayingViewCode")
        
        //如果不喜欢按钮触发界面不是当前场景
        if model!.status.currentScene != sceneName
        {
//            delegate?.switchToScene(sceneName)
//            NSUserDefaults.standardUserDefaults().setInteger(self.view.tag, forKey: "currentPlayingViewCode")
//            delegate?.doDislike()
        }else{
            
            NSUserDefaults.standardUserDefaults().setInteger(self.view.tag, forKey: "currentPlayingViewCode")
            delegate?.doDislike()
        }
        
        
    }
    //改变播放按钮状态
    func playingStatusChanged(notification : NSNotification)
    {
        //_refreshPlayButton()
    }
    
    private func _refreshPlayButton()
    {
        let currentPlayingViewCode = NSUserDefaults.standardUserDefaults().integerForKey("currentPlayingViewCode")
//        let scenesVCCollection : [ViewController] = NSUserDefaults.standardUserDefaults().objectForKey("scenesVCCollection") as! [ViewController]
//        for i in 0..<scenesVCCollection.count
//        {
//            let _view = scenesVCCollection[i]
//            
//            _view.playPauseButton.setBackgroundImage(UIImage(named: "pauseButton") , forState: UIControlState.Normal)
//        }
        if currentPlayingViewCode == self.view.tag
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
    }
    
    private func _refreshBackgroundImageView (#view : UIImageView?,sceneName:String?) -> Void
    {
        let currentPlayingViewCode = NSUserDefaults.standardUserDefaults().integerForKey("currentPlayingViewCode")
        //update by slimadam on 15/08/12
        if view == nil {return}
        
        let resourceURL : NSURL = NSBundle.mainBundle().resourceURL!.URLByAppendingPathComponent("resource/image", isDirectory: true)
        var sceneKey : String = model!.status.currentScene
        
        //如果是刚加载的话
        if sceneName != nil
        {

            sceneKey  = sceneName!
            let imagePath : NSURL = resourceURL.URLByAppendingPathComponent("\(sceneKey).jpg")
            
            view!.image = UIImage(contentsOfFile: imagePath.relativePath!)
        
        }else{//修改数据的时候走else
            
            if currentPlayingViewCode == self.view.tag
            {

                let imagePath : NSURL = resourceURL.URLByAppendingPathComponent("\(sceneKey).jpg")
                
                view!.image = UIImage(contentsOfFile: imagePath.relativePath!)
            }
        }
        
        
        
    }
    
    
    func _refreshNavigationBar (#navigationBar : UINavigationBar?) -> Void
    {
        /*
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        self.navigationController?.navigationBar.shadowImage = UIImage()
        */
        
        //outlet🈯️定的,一会儿需要删除
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
        let downloadingCount = NSUserDefaults.standardUserDefaults().integerForKey("downloadingCount")
        let downloadCount = model!.getDownloadList().count
        
        //downloadingTipLabel.text = "已下载\(downloadingCount/downloadCount)"
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
    
    //当前界面跳转到别的界面去的时候被触发
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        var playListData =  [Dictionary<String,AnyObject>]()
        
        var playingData = model?.currentPlayingData
        
        var playListVC : PlayListTableViewController = segue.destinationViewController as! PlayListTableViewController
        
        //判断是否是跳转到播放列表界面
        if segue.identifier == "playListVCId" || segue.identifier == "playListVCId_0"
        {
            
            
            let sceneName = model!.scenelist[self.view.tag]
            NSUserDefaults.standardUserDefaults().setInteger(self.view.tag, forKey: "currentPlayingViewCode")
            
            if model!.status.currentScene != sceneName
            {
//                delegate?.switchToScene(sceneName)
                println(sceneName)
                playListData = delegate!.getCurrentScenePlayList(sceneName)
                playListVC.title = "\(sceneName)情景"
                
            }else{
                playListData = delegate!.getCurrentScenePlayList(nil)
                playListVC.title = "\(model!.status.currentScene)情景"
            }
            

            
            playListVC.currentSceneData = playListData
            playListVC.currentPlayingData = playingData!
            playListVC.moduleLoader = self.moduleLoader
            playListVC.delegate = self.delegate
            
            
        }
        
        
    }

    //MARK: 侧边菜单
    @IBAction func clickLeftButton(sender: UIBarButtonItem) {
        if menuState == MenuState.Closed {
            menuDelegate?.openMenu()
        } else {
            menuDelegate?.closeMenu()
        }
    }
    
}


