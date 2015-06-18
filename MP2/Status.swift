//
//  Status.swift
//  MP2
//
//  Created by bijiabo on 15/6/18.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation

class Status : StatusManager {
    
    //当前情景
    var currentScene : String = ""
    
    //各个情景播放序数缓存
    private var _sceneIndexStatusCache : Dictionary<String,Int> = Dictionary<String,Int> ()
    {
        didSet
        {
            NSUserDefaults.standardUserDefaults().setObject(_sceneIndexStatusCache, forKey: "_sceneIndexStatusCache")
        }
    }
    
    init()
    {
        currentScene = ""
        
        //初始化各个情景播放序数缓存
        if let sceneCache :Dictionary<String,Int> = NSUserDefaults.standardUserDefaults().objectForKey("_sceneIndexStatusCache") as? Dictionary<String,Int>
        {
            _sceneIndexStatusCache = sceneCache
        }
    }
    
    //设置当前情景
    func setCurrentScene(scene: String) {
        currentScene = scene
        
        if _sceneIndexStatusCache[scene] == nil
        {
           _sceneIndexStatusCache[scene] = 0
        }
    }
    
    //获取指定情景播放序数
    func playIndexForScene(scene: String) -> Int
    {
        if _sceneIndexStatusCache[scene] != nil
        {
            return _sceneIndexStatusCache[scene]!
        }
        else
        {
            return 0
        }
    }
    
    //设定指定情景播放序数
    func setIndexForScene(scene: String, index: Int) {
        _sceneIndexStatusCache[scene] = index
    }
}