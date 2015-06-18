//
//  Player.swift
//  MP2
//
//  Created by bijiabo on 15/6/19.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation
import AVFoundation

class Player : PlayerManager
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
    init()
    {
        
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
}