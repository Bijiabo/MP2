//
//  ViewController.swift
//  MP2
//
//  Created by bijiabo on 15/6/18.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//
import UIKit

class ViewController: UIViewController , UITabBarDelegate , ViewManager , UIAlertViewDelegate
{
    var delegate : Operations?

    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var tabBar: UITabBar!
    @IBOutlet var audioName: UILabel!
    @IBOutlet var audioTag: UILabel!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var mainNavigationBar: UINavigationBar!
    @IBOutlet var navigationBarTitle: UINavigationItem!

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
        
        _refreshNavigationBar(navigationBar: mainNavigationBar)
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
        audioName.text = model?.currentPlayingData["name"] as? String
        audioTag.text = model?.currentPlayingData["tag"] as? String
    }
    
    func CurrentPlayingDataHasChanged(notification : NSNotification)
    {
        audioName.text = model?.currentPlayingData["name"] as? String
        audioTag.text = model?.currentPlayingData["tag"] as? String
        
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
}


