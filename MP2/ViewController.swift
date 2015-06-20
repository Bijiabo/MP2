//
//  ViewController.swift
//  MP2
//
//  Created by bijiabo on 15/6/18.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITabBarDelegate , ViewManager
{
    var delegate : Operations?

    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var tabBar: UITabBar!
    @IBOutlet var audioName: UILabel!
    @IBOutlet var audioTag: UILabel!

    var model : ModelManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.delegate = self
        
        initTabBar()
        
        initPlayPauseButton()
        
        initAudioInfoView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("CurrentPlayingDataHasChanged:"), name: "CurrentPlayingDataHasChanged", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playingStatusChanged:"), name: "PlayingStatusChanged", object: nil)
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
            let barItem : UITabBarItem = UITabBarItem(title: model?.scenelist[i], image: UIImage(), tag: i)
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
            playPauseButton.setTitle("pause", forState: UIControlState.Normal)
            
            playPauseButton.tag = 1
        }
        else
        {
            playPauseButton.setTitle("play", forState: UIControlState.Normal)
            
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
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!)
    {
        let selectedIndex : Int = item.tag
        let targetScene : String = model!.scenelist[selectedIndex]
        
        delegate?.switchToScene(targetScene)
    }
    
    @IBAction func tapLikeButton(sender: AnyObject)
    {
        delegate?.doLike()
    }
    
    @IBAction func tapDislikeButton(sender: AnyObject)
    {
        delegate?.doDislike()
    }
    
    func playingStatusChanged(notification : NSNotification)
    {
        if delegate?.playing == true
        {
            self.playPauseButton.setTitle("pause", forState: UIControlState.Normal)
        }
        else
        {
            self.playPauseButton.setTitle("play", forState: UIControlState.Normal)
            
        }
    }
}

