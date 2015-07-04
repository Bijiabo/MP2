//
//  Player.swift
//  MP2
//
//  Created by bijiabo on 15/6/19.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation
import AVFoundation

class Player : NSObject ,PlayerManager, AVAudioPlayerDelegate
{
    var delegate : PlayerOperation?
    
    //播放状态
    var playing : Bool {
        get {
            if _player == nil
            {
                return false
            }
            else
            {
                return _player.playing
            }
        }
    }
    
    //播放来源
    var source : NSURL {
        get {
            if _player == nil || _player.url == nil
            {
                return NSURL()
            }
            else
            {
                return _player.url
            }
        }
    }
    
    //player对象，内部使用
    private var _player : AVAudioPlayer!
    
    //初始化方法
    init(source : NSURL)
    {
        super.init()
        
        setSource(source)

        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        _addObserver()
    }

    //切换到播放状态
    func play() {
        if _player != nil
        {
            _player.play()
        }
    }
    
    //切换到暂停状态
    func pause() {
        if _player != nil
        {
            _player.pause()
        }
    }
    
    //设定播放来源
    func setSource(source: NSURL) {
        var isNotDir : ObjCBool = false
        
        //若与原音频相同，则不做操作
        if source == self.source {return}
        
        if NSFileManager.defaultManager().fileExistsAtPath(source.relativePath!, isDirectory: &isNotDir)
        {
            var error : NSError?
            
            var playerData : NSData = NSData(contentsOfURL: source)!
            
            _player = AVAudioPlayer(data: playerData, error: &error)
                //AVAudioPlayer(contentsOfURL: source, error: &error)
            if _player != nil
            {
                _player.delegate = self
            
                _player.prepareToPlay()
            }
            
            //测试切换歌曲
            //_player.currentTime = _player.duration - 10
        }
        
    }
    
    //MARK:
    //MARK: avaudioPlayerDelegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        delegate?.playerDidFinishPlaying()
    }
    
    
    //MARK:
    //MARK:中断与恢复
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
            println("began interuption")
            
            _player.pause()
        }
        else if interuptionType == AVAudioSessionInterruptionType.Ended.rawValue
        {   
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), { () -> Void in
                if self.delegate?.playing == true
                {
                    self.delegate?.play()
                }
            })
            
            
            AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
            AVAudioSession.sharedInstance().setActive(true, error: nil)
            
            println("end interuption")
            
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