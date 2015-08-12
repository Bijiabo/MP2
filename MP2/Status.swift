//
//  Status.swift
//  MP2
//
//  Created by bijiabo on 15/6/18.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation

class Status : StatusManager {
    
    //状态观察者
    var observer : StatusObserver = statusObserver()

    
    //当前情景
    dynamic var currentScene : String = "" {
        
        didSet {
            
            observer.statusHasChanged("currentScene")
            
            NSUserDefaults.standardUserDefaults().setObject(currentScene, forKey: "currentScene")
        }
    }
    
    //update by SlimAdam on 15/07/30
    //当前场景歌曲索引
    dynamic var currentSceneIndex : Int = 0 {
        
        didSet {
            
            observer.statusHasChanged("currentSceneIndex")
        }
    }
    
    //各个情景播放序数缓存
    private var _sceneIndexStatusCache : Dictionary<String,Int> = Dictionary<String,Int> ()
    {
        didSet
        {
            NSUserDefaults.standardUserDefaults().setObject(_sceneIndexStatusCache, forKey: "_sceneIndexStatusCache")
        }
    }
    
    func getSceneIndexStatusCache ()-> Dictionary<String,Int>
    {
        println("sceneName:index:\(_sceneIndexStatusCache)")
        return _sceneIndexStatusCache
    }
    init()
    {
        
        //初始化各个情景播放序数缓存
        if let sceneCache :Dictionary<String,Int> = NSUserDefaults.standardUserDefaults().objectForKey("_sceneIndexStatusCache") as? Dictionary<String,Int>
        {
            _sceneIndexStatusCache = sceneCache
            
        }
        
        let savedCurrentScene: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("currentScene")
        
        currentScene = savedCurrentScene == nil ? "" : savedCurrentScene as! String
    }
    
    //设置当前情景
    func set_CurrentScene(scene: String) {
        
        currentScene = scene
        
        if _sceneIndexStatusCache[scene] == nil
        {
           _sceneIndexStatusCache[scene] = 0
            
        }
        
        currentSceneIndex = _sceneIndexStatusCache[scene]!
        
    }
    
    //设置当前情景播放序数
    func set_CurrentSceneIndex(index: Int) {
        set_IndexForScene(currentScene, index: index)
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
    func set_IndexForScene(scene: String, index: Int) {
        _sceneIndexStatusCache[scene] = index
        
        if scene == currentScene
        {
            currentSceneIndex = index
        }
    }
}

class statusObserver : StatusObserver {
    init()
    {
        
    }
    
    func statusHasChanged(keyPath: String) {
        
    }
}