//
//  Player.swift
//  MP2
//
//  Created by bijiabo on 15/6/19.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation
import AVFoundation

class Player : NSObject , PlayerManager
{
    //播放状态
    var playing : Bool {
        get {
            return _player.playing
        }
    }
    
    //播放来源
    var source : NSURL {
        get {
            return _player.url
        }
    }
    
    //player对象，内部使用
    private var _player : AVAudioPlayer = AVAudioPlayer()
    
    //初始化方法
    override init()
    {
        super.init()
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        _addObserver()
    }

    //切换到播放状态
    func play() {
        _player.play()
    }
    
    //切换到暂停状态
    func pause() {
        _player.pause()
    }
    
    //设定播放来源
    func setSource(source: NSURL) {
        var isNotDir : ObjCBool = false
        
        if NSFileManager.defaultManager().fileExistsAtPath(source.relativePath!, isDirectory: &isNotDir)
        {
            _player = AVAudioPlayer(contentsOfURL: source, error: nil)
            
            _player.prepareToPlay()
        }
        
    }
    
    func _addObserver() -> Void
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("avaudioSessionInterruption:"), name: AVAudioSessionInterruptionNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("audioSessionRouteChanged:"), name: AVAudioSessionRouteChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("audioSessionMediaServicesWereLost:"), name: AVAudioSessionMediaServicesWereLostNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("audioSessionMediaServicesWereReset:"), name: AVAudioSessionMediaServicesWereResetNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("audioSessionSilenceSecondaryAudioHint:"), name: AVAudioSessionSilenceSecondaryAudioHintNotification, object: nil)
        
        
    }
    
    func avaudioSessionInterruption(notification : NSNotification)
    {
        
        let interuption : NSDictionary = notification.userInfo!
        let interuptionType : UInt = interuption.valueForKey(AVAudioSessionInterruptionTypeKey) as! UInt
        
        
        if interuptionType == AVAudioSessionInterruptionType.Began.rawValue
        {
            println("began")
            
            _player.pause()
        }
        else if interuptionType == AVAudioSessionInterruptionType.Ended.rawValue
        {   
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), { () -> Void in
                //self.player.currentTime = NSTimeInterval(0)
                self._player.play()
            })
            
            
            AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
            AVAudioSession.sharedInstance().setActive(true, error: nil)
            
            println("end")
            
        }
        
    }
    
    func audioSessionRouteChanged (notification : NSNotification)
    {
    }
    
    func audioSessionMediaServicesWereLost (notification : NSNotification)
    {
        
    }
    
    func audioSessionMediaServicesWereReset (notification : NSNotification)
    {
        
    }
    
    func audioSessionSilenceSecondaryAudioHint (notification : NSNotification)
    {
        
    }
    
    
    func audioSessionInterruptionTypeEnded (notification : NSNotification)
    {
        println("audioSessionInterruptionTypeEnded")
    }

    
}