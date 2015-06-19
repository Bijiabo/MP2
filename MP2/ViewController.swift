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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func togglePlayPause(sender: AnyObject) {
        if playPauseButton.tag == 0
        {
            playPauseButton.setTitle("pause", forState: UIControlState.Normal)
            
            model?.playerManager.play()
            playPauseButton.tag = 1
        }
        else
        {
            playPauseButton.setTitle("play", forState: UIControlState.Normal)
            
            model?.playerManager.pause()
            playPauseButton.tag = 0
        }
    }
    
    func initTabBar()
    {
        var tabBarItems : [UITabBarItem] = []
        for var i=0; i<model?.scenelist.count ; i++
        {
            let barItem : UITabBarItem = UITabBarItem(title: model?.scenelist[i], image: UIImage(), tag: i)
            tabBarItems.append( barItem )
        }
        
        tabBar.setItems(tabBarItems, animated: false)
    }
    
    func initPlayPauseButton()
    {
        if model?.playerManager.playing == true
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
        
        model?.status.set_CurrentScene(model!.scenelist[selectedIndex])
    }
}

