//
//  Server.swift
//  MP2
//
//  Created by bijiabo on 15/6/18.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation
import AVFoundation

class Server : ModelManager ,StatusObserver {
    //情景列表
    var scenelist : Array<String> = Array<String>()
    //状态管理
    var status : StatusManager = Status()
    
    //播放管理
    var playerManager : PlayerManager = Player()
    
    //当前播放数据
    var currentPlayingData : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
    
    private var _data : Array<AnyObject> = Array<AnyObject>()
    private var currentSceneIndex : Int = 0
    
    init()
    {
    }
    
    init (data : Array<AnyObject>)
    {
        _data = data
        
        _updateScenelist(_data)
        
        _updateCurrentPlayingData()
        
        
    }
    
    init (data : Array<AnyObject> , statusManager : StatusManager)
    {
        _data = data
        
        _updateScenelist(_data)
        
        self.status = statusManager
        status.observer = self
        
        if self.status.currentScene == ""
        {
            self.status.set_CurrentScene(scenelist[0])
        }
        
        currentSceneIndex = status.currentSceneIndex
        
        _updateCurrentPlayingData()
    
    }
    
    
 
    private func _updateScenelist (data : Array<AnyObject>)
    {
        for var i=0; i<data.count; i++
        {
            if let dataItem = data[i] as? Dictionary<String,AnyObject>
            {
                scenelist.append(dataItem["name"] as! String )
            }
        }
    }
    
    private func _getCurrentPlayingData () -> Dictionary<String,AnyObject>
    {
        for var i=0; i<_data.count; i++
        {
            if let dataItem = _data[i] as? Dictionary<String,AnyObject>
            {
                if let sceneName : String = dataItem["name"] as? String
                {
                    if sceneName == status.currentScene
                    {
                        //取得对应播放列表数据
                        if let list : [Dictionary<String,AnyObject>] = dataItem["list"] as? [Dictionary<String,AnyObject>]
                        {
                            if list.count > status.playIndexForScene(status.currentScene)
                            {
                                return list[status.playIndexForScene(status.currentScene)]
                            }
                            else if list.count>0
                            {
                                return list[0]
                            }
                        }
                    }
                }
            }
        }
        
        //若取不到对应列表数据
        if _data.count>0
        {
            if let dataItem = _data[0] as? Dictionary<String,AnyObject>
            {
                if let list : [Dictionary<String,AnyObject>] = dataItem["list"] as? [Dictionary<String,AnyObject>]
                {
                    if list.count>0
                    {
                        return list[0]
                    }
                }
            }
        }
        
        return Dictionary<String,AnyObject>()
    }
    
    private func _updateCurrentPlayingData ()
    {
        currentPlayingData = _getCurrentPlayingData()
    }
    
    //状态已改变
    func statusHasChanged(keyPath: String) {
        _updateCurrentPlayingData()
        
        NSNotificationCenter.defaultCenter().postNotificationName("CurrentPlayingDataHasChanged", object: nil)
    }
    
    
    
    
}