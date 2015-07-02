//
//  Server.swift
//  MP2
//
//  Created by bijiabo on 15/6/18.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation
import AVFoundation

class Server : NSObject , ModelManager ,StatusObserver
{
    
    var delegate : Operations?
    
    //情景列表
    var scenelist : Array<String> = Array<String>()
    //状态管理
    var status : StatusManager = Status()

    
    //当前播放数据
    var currentPlayingData : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
    
    private var _data : Array<AnyObject> = Array<AnyObject>()
    private var currentSceneIndex : Int = 0
    
    override init()
    {
        super.init()
    }
    
    init (data : Array<AnyObject>)
    {
        super.init()
        
        _data = data
        
        _updateScenelist(_data)
        
        _updateCurrentPlayingData()
        
        
    }
    
    init (data : Array<AnyObject> , statusManager : StatusManager)
    {
        super.init()
        
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
    
    private func _getCurrentScenePlaylist () -> [Dictionary<String,AnyObject>]
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
                            return list
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
                    return list
                }
            }
        }
        
        return [Dictionary<String,AnyObject>]()
    }
    
    private func _getCurrentPlayingData () -> Dictionary<String,AnyObject>
    {
        let currentScenePlaylist : [Dictionary<String,AnyObject>] = _getCurrentScenePlaylist()
        
        if currentScenePlaylist.count > status.currentSceneIndex
        {
            return currentScenePlaylist[status.currentSceneIndex]
        }
        else if currentScenePlaylist.count > 0
        {
            return currentScenePlaylist[0]
        }
        else
        {
            return Dictionary<String,AnyObject>()
        }
    }
    
    private func _updateCurrentPlayingData ()
    {
        let playingData : Dictionary<String, AnyObject> = _getCurrentPlayingData()
        
        for (key , value) in playingData
        {
            currentPlayingData[key] = value
        }
        
    }
    
    //切换为下一首音频
    func next() {
        
        let currentScenePlaylist : [Dictionary<String,AnyObject>] = _getCurrentScenePlaylist()
        
        if currentScenePlaylist.count > ( status.currentSceneIndex + 1 )
        {
            status.set_CurrentSceneIndex(status.currentSceneIndex + 1)
        }
        else
        {
            status.set_CurrentSceneIndex(0)
        }
    }
    
    //切换上一个音频
    func previous() {
        let currentScenePlaylist : [Dictionary<String,AnyObject>] = _getCurrentScenePlaylist()
        
        if status.currentSceneIndex > 0
        {
            status.set_CurrentSceneIndex(status.currentSceneIndex - 1)
        }
        else
        {
            status.set_CurrentSceneIndex(currentScenePlaylist.count - 1)
        }
    }
    
    //状态已改变
    func statusHasChanged(keyPath: String) {
        _updateCurrentPlayingData()
        
        delegate?.currentPlayingDataHasChanged()
    }
    
    //获取下载列表
    func getDownloadList() -> [Dictionary<String,String>]
    {
        
        let cacheRootPath : String = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! String
        let cacheRootURL : NSURL = NSURL(fileURLWithPath: cacheRootPath)!.URLByAppendingPathComponent("media/audio")
        
        var downloadList : [Dictionary<String,String>] = [Dictionary<String,String>]()
        
        for var i=0; i<_data.count; i++
        {
            if let dataItem = _data[i] as? Dictionary<String,AnyObject>
            {
                let list = dataItem["list"] as! [Dictionary<String,AnyObject>]
                
                for listItem in list
                {
                    var  isNotDir : ObjCBool = false
                    
                    if NSFileManager.defaultManager().fileExistsAtPath(cacheRootURL.URLByAppendingPathComponent(listItem["localURI"] as! String).relativePath!, isDirectory: &isNotDir) == false
                    {
                        let remoteURL : String = (listItem["remoteURL"] as! [String])[0]
                        let filename : String = listItem["localURI"] as! String
                        downloadList.append([
                            "remoteURL" : remoteURL,
                            "filename" : filename
                            ])
                    }
                }
            }
        }
        
        
        
        return downloadList
        
    }
    
    
}