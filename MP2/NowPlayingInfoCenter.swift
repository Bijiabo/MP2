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
    
    var delegate : Operation?
    
    var model : ModelManager?
    
    private let _view: MPNowPlayingInfoCenter = MPNowPlayingInfoCenter.defaultCenter()
    
    override init()
    {
        super.init()
        
        setupViewControls()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("CurrentPlayingDataHasChanged:"), name: "CurrentPlayingDataHasChanged", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playingStatusChanged:"), name: "PlayingStatusChanged", object: nil)
    }
    
    func CurrentPlayingDataHasChanged(notification : NSNotification)
    {
        updateView()
    }
    
    func playingStatusChanged(notification : NSNotification)
    {
        updateView()
    }
    
    func updateView ()
    {
        _view.nowPlayingInfo = [
            MPMediaItemPropertyAlbumArtist: "MPMediaItemPropertyAlbumArtist", // not displayed
            MPMediaItemPropertyAlbumTitle: "磨耳朵",
            MPMediaItemPropertyTitle: model?.currentPlayingData["name"] as! String,
            MPMediaItemPropertyArtist:  model!.status.currentScene,
            //            MPMediaItemPropertyArtwork: artwork,
            //            MPNowPlayingInfoPropertyElapsedPlaybackTime : player.currentTime,
            //            MPNowPlayingInfoPropertyPlaybackRate : 1.0,
            //            MPMediaItemPropertyPlaybackDuration : player.duration
        ]
    }
    
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
        ///*
        remoteCommandCenter.nextTrackCommand.addTargetWithHandler { (event: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            //self.setViewProperty(MPMediaItemPropertyTitle, value: "长按⏩键切换到XXX模式")
            
            //self.app.refreshPlayerAndView(switchToNext: true)
            
            return MPRemoteCommandHandlerStatus.Success
        }
        /*
        remoteCommandCenter.seekForwardCommand.addTargetWithHandler { (event: MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
        self.app.switchScene(targetScene: "午后")
        return MPRemoteCommandHandlerStatus.Success
        }
        */
        
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
}