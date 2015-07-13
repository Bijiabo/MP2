//
//  NowPlayingInfoCenter.swift
//  MP2
//
//  Created by bijiabo on 15/6/19.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class NowPlayingInfoCenterController : NSObject, ViewManager {
    
    var delegate : Operations?
    
    var model : ModelManager?
    
    var viewModel: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
    
    private let _view: MPNowPlayingInfoCenter = MPNowPlayingInfoCenter.defaultCenter()
    
    
    //remoteCommandCenter 控制命令 的 缓存 （用于切换模式时）
    var remoteCommandCenterCache : Dictionary<String , AnyObject> = Dictionary<String , AnyObject>()
    //切换模式时提示显示时间
    let timeOfRemoteCommandCenterSwitchSceneTip : Int64 = 2 * 1000000000
    
    override init()
    {
        super.init()
        
        setupViewControls()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("CurrentPlayingDataHasChanged:"), name: "CurrentPlayingDataHasChanged", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playingStatusChanged:"), name: "PlayingStatusChanged", object: nil)
    }
    
    //播放数据改变通知
    func CurrentPlayingDataHasChanged(notification : NSNotification)
    {
        
        updateViewModel()
        
        updateView()
    }
    
    //播放器状态改变通知
    func playingStatusChanged(notification : NSNotification)
    {
        updateViewModel()
        
        updateView()
    }
    
    func updateViewModel ()
    {
        let title : String = model?.currentPlayingData["name"] as! String
        let description : String = model!.status.currentScene + "磨耳朵"
        
        let artworkImage : UIImage = _generateImage(view: _generateView(imageName: "lockScreen", title: title, description: description))
        
        let artwork : MPMediaItemArtwork = MPMediaItemArtwork(image:  artworkImage)
        
        viewModel = [
            MPMediaItemPropertyAlbumArtist: "MPMediaItemPropertyAlbumArtist", // not displayed
            MPMediaItemPropertyAlbumTitle: "磨耳朵",
            MPMediaItemPropertyTitle: model?.currentPlayingData["name"] as! String,
            MPMediaItemPropertyArtist:  model!.status.currentScene,
            MPMediaItemPropertyArtwork: artwork,
            //            MPNowPlayingInfoPropertyElapsedPlaybackTime : player.currentTime,
            //            MPNowPlayingInfoPropertyPlaybackRate : 1.0,
            //            MPMediaItemPropertyPlaybackDuration : player.duration
        ]
    }
    
    func updateView ()
    {
        _view.nowPlayingInfo = viewModel
    }
    
    //创建NowPlayingInfoCenter的时候被调用
    func setupViewControls ()
    {
        let remoteCommandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        
        remoteCommandCenter.playCommand.addTarget(self, action: Selector("playCommand:"))
        
        remoteCommandCenter.pauseCommand.addTargetWithHandler { (event: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            
            self.delegate?.pause()
            
            return MPRemoteCommandHandlerStatus.Success
        }
        
        remoteCommandCenter.playCommand.enabled = true
        
        remoteCommandCenter.togglePlayPauseCommand.addTargetWithHandler { (event: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            return MPRemoteCommandHandlerStatus.Success
        }
        
        //切换模式
        remoteCommandCenter.nextTrackCommand.addTargetWithHandler { (event: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            
            self.remoteCommandCenterCache["SwitchingScene"] = true
            
            //获取情景列表
            var scenelist : Array<String> = Array<String>()
            if let modelScenelist : Array<String> = self.model?.scenelist
            {
                scenelist = modelScenelist
            }
            
            //缓存当前切换提示模式
            func saveSceneIndexToCache (index : Int)
            {
                var nextIndex : Int = index + 1 < scenelist.count ? (index + 1) : 0
                
                if let currentSceneIndex : Int = self.model?.status.currentSceneIndex
                {
                    if nextIndex == currentSceneIndex
                    {
                        nextIndex = nextIndex + 1 < scenelist.count ? (nextIndex + 1) : 0
                    }
                }
                
                self.remoteCommandCenterCache["sceneIndex"] = nextIndex
            }
            
            //判断是否已经记录切换到得状态计数
            if self.remoteCommandCenterCache["sceneIndex"] == nil
            {
                if let currentSceneIndex : Int = self.model?.status.currentSceneIndex
                {
                    saveSceneIndexToCache(currentSceneIndex)
                }
            }
            else
            {
                if let currentSceneIndex : Int = self.remoteCommandCenterCache["sceneIndex"] as? Int
                {
                    saveSceneIndexToCache(currentSceneIndex)
                }
            }
            
            if let nextSceneIndex : Int = self.remoteCommandCenterCache["sceneIndex"] as? Int
            {
                let scene : String = scenelist[nextSceneIndex]
                
                self.viewModel[MPMediaItemPropertyTitle] = "长按⏩键切换到\(scene)模式" as AnyObject
                self.updateView()
            }
            
            //点击次序缓存，解决前一次点击会恢复后面点击切换的显示问题
            /*
            if self.remoteCommandCenterCache["switchActionVersion"] == nil
            {
                self.remoteCommandCenterCache["switchActionVersion"] = 0
            }
            else
            {
                if let switchActionVersionCache : Int = self.remoteCommandCenterCache["switchActionVersion"] as? Int
                {
                    self.remoteCommandCenterCache["switchActionVersion"] = switchActionVersionCache + 1
                }
            }
            */
            
            //timeOfRemoteCommandCenterSwitchSceneTip 时间后切换回原显示
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  self.timeOfRemoteCommandCenterSwitchSceneTip ), dispatch_get_main_queue(), { () -> Void in
                
                if let switchingScene : Bool = self.remoteCommandCenterCache["SwitchingScene"] as? Bool
                {
                    //判断是否是最后一次切换的回调函数，否则不执行
                    /*
                    var isLastSwitchAction : Bool = false
                    
                    if self.remoteCommandCenterCache["switchActionVersion"] == nil
                    {
                        isLastSwitchAction = true
                    }
                    else
                    {
                        if let switchActionVersionCache : Int = self.remoteCommandCenterCache["switchActionVersion"] as? Int
                        {
                            self.remoteCommandCenterCache["switchActionVersion"] = switchActionVersionCache + 1
                        }
                    }
                    */
                    if switchingScene == true
                    {
                        self.updateViewModel()
                        self.updateView()
                        
                        self.remoteCommandCenterCache["SwitchingScene"] = false
                    }
                }
            })
            
            return MPRemoteCommandHandlerStatus.Success
        }

        //长按确定切换模式
        remoteCommandCenter.seekForwardCommand.addTargetWithHandler { (event: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            
            if let switchingScene : Bool = self.remoteCommandCenterCache["SwitchingScene"] as? Bool
            {
                if switchingScene == true
                {
                    if let nextSceneIndex : Int = self.remoteCommandCenterCache["sceneIndex"] as? Int
                    {
                        if let scenelist : Array<String> = self.model?.scenelist
                        {
                            let scene : String = scenelist[nextSceneIndex]
                            
                            self.delegate?.switchToScene(scene)
                            
                            self.viewModel[MPMediaItemPropertyTitle] = "已切换到\(scene)模式" as AnyObject
                            self.updateView()
                        }
                    }
                    
                    self.remoteCommandCenterCache["SwitchingScene"] = false
                    
                    //timeOfRemoteCommandCenterSwitchSceneTip 时间后切换回原显示
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  self.timeOfRemoteCommandCenterSwitchSceneTip ), dispatch_get_main_queue(), { () -> Void in
                        
                        self.updateViewModel()
                        self.updateView()
                    })
                }
            }
            
            
            
            return MPRemoteCommandHandlerStatus.Success
        }

        
        //child like
        remoteCommandCenter.likeCommand.localizedTitle = "😃 孩子喜欢"
        
        remoteCommandCenter.likeCommand.addTarget(self, action: Selector("childLike:"))
        
        //child dislike
        remoteCommandCenter.dislikeCommand.localizedTitle = "😞 孩子不喜欢"
        
        remoteCommandCenter.dislikeCommand.addTarget(self, action: Selector("dislikeCommand:"))
        remoteCommandCenter.bookmarkCommand.localizedTitle = "🎵 再放一遍"
        remoteCommandCenter.bookmarkCommand.addTarget(self, action: Selector("playAgain:"))
        
    }
    
    internal func pauseCommand (e: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus
    {
        delegate?.pause()
        
        return MPRemoteCommandHandlerStatus.Success
    }
    
    internal func playCommand (e: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus
    {
        delegate?.play()
        
        return MPRemoteCommandHandlerStatus.Success
    }
    
    internal func togglePlayPauseCommand (e: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus
    {
        delegate?.togglePlayPause()
        
        return MPRemoteCommandHandlerStatus.Success
    }
    
    internal func previousTrackCommand (e: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus
    {
        
        return MPRemoteCommandHandlerStatus.Success
    }
    
    internal func nextTrackCommand (e: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus
    {
        delegate?.playNext()
        
        return MPRemoteCommandHandlerStatus.Success
    }
    
    internal func childLike (e: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus
    {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        
        commandCenter.likeCommand.active = true
        commandCenter.dislikeCommand.active = false
        
        delegate?.doLike()
        
        return MPRemoteCommandHandlerStatus.Success
    }
    
    internal func dislikeCommand (e: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus
    {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        
        commandCenter.likeCommand.active = false
        commandCenter.dislikeCommand.active = false
        
        delegate?.doDislike()
        
        return MPRemoteCommandHandlerStatus.Success
    }
    
    internal func playAgain (e: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus
    {
        let previousCommandActiveStatus : Bool = MPRemoteCommandCenter.sharedCommandCenter().bookmarkCommand.active
        
        triggerPlayAgainCommand( !previousCommandActiveStatus )
        
        return MPRemoteCommandHandlerStatus.Success
    }
    
    internal func triggerPlayAgainCommand (again : Bool) -> Void
    {
        refreshPlayAgainCommandView(active: again)
    }
    
    internal func refreshPlayAgainCommandView(#active : Bool) -> Void
    {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        
        commandCenter.bookmarkCommand.active = active
        
        if active
        {
            commandCenter.bookmarkCommand.localizedTitle = "🎵 取消再放一遍"
        }
        else
        {
            commandCenter.bookmarkCommand.localizedTitle = "🎵 再放一遍"
        }
        
    }
    
    //MARK:
    //MARK: 生成锁屏快照
    private func _generateView (#imageName : String , title : String , description : String) -> UIView
    {
        //设定画框颜色
        let frameColor : UIColor = UIColor.whiteColor()
        
        //设定view尺寸和背景颜色
        var view : UIView = UIView(frame: CGRectMake(0, 0, 600, 600))
        view.backgroundColor = frameColor
        
        //设定照片
        var backgroundImage : UIImage = UIImage()
        
        if let imageURL : NSURL = NSBundle.mainBundle().URLForResource(imageName, withExtension: "jpg", subdirectory: "resource/image")
        {
            let imageData : NSData = NSData(contentsOfURL: imageURL)!
            
            backgroundImage = UIImage(data: imageData)!
        }
        
        let backgroundView : UIImageView = UIImageView(frame: CGRectMake(20, 20, 560, 560))
        backgroundView.image = backgroundImage
        backgroundView.contentMode = UIViewContentMode.ScaleAspectFill
        
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
        
        //设定顶部白条，做出画框效果
        let topView : UIView = UIView(frame: CGRectMake(0, 0, 600, 20))
        topView.backgroundColor = frameColor
        view.addSubview(topView)
        
        //设定底部文字背景为白色，做出拍立得效果
        let bottomBackgroundView : UIView = UIView(frame: CGRectMake(0, 480, 600, 120))
        bottomBackgroundView.backgroundColor = frameColor
        view.addSubview(bottomBackgroundView)
        
        //设定文字
        var titleLabel : UILabel = UILabel(frame: CGRectMake(20, 486, 560, 60))
        titleLabel.text = title
        titleLabel.font =  UIFont (name: "HelveticaNeue-UltraLight", size: 36)
        view.addSubview(titleLabel)
        
        var descriptionLabel : UILabel = UILabel(frame: CGRectMake(20, 532, 560, 60))
        descriptionLabel.text = description
        descriptionLabel.font =  UIFont (name: "HelveticaNeue-UltraLight", size: 28)
        descriptionLabel.textColor = UIColor(red:0.31, green:0.32, blue:0.32, alpha:1)
        view.addSubview(descriptionLabel)
        
        return view
    }
    
    //生成快照图片
    private func _generateImage (#view : UIView) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(600.0, 600.0), false, 1.0)
        
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
}