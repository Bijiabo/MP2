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
    
    //情景(名称)列表，保存所有场景，如：["起床","玩耍","午后","睡前"]
    var scenelist : Array<String> = Array<String>()
    //所有场景缓存
    var scenesDataCache : [Dictionary<String,AnyObject>]?
    //状态管理
    var status : StatusManager = Status()
    
    //当前播放数据
    var currentPlayingData : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
    //不喜欢的歌曲
    var disLikePlayingData :Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
    //当前json文件路径
   // var currentJsonPath : NSURL?
    
    private var _data : Array<AnyObject> = Array<AnyObject>()
    private var updateData : Array<AnyObject> = Array<AnyObject>()
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
        
        _setScenesDataCache()
    }
    
    init (data : Array<AnyObject> , statusManager : StatusManager)
    {
        super.init()
        
        _data = data
        
        _updateScenelist(_data)
        
        //初始化播放器状态管理
        self.status = statusManager
        
        status.observer = self
        
        //设定启动默认设置场景为上次退出前场景
        if self.status.currentScene.isEmpty
        {
            //先前没有保存对应场景，则默认为第一个
            self.status.set_CurrentScene(scenelist[0])
        }
        
        currentSceneIndex = status.currentSceneIndex
        
        //修改当前场景播放数据
        _updateCurrentPlayingData()
    
        _setScenesDataCache()
    }
    //得到当前场景下的播放列表
    func getCurrentScenePlayList(sceneName:String?) -> [Dictionary<String, AnyObject>] {
        
        if sceneName != nil
        {
            return _getCurrentScenePlaylist (sceneName)
        }else{
            return _getCurrentScenePlaylist (nil)
        }
        
    }
 
    private func _updateScenelist (data : Array<AnyObject>)
    {
        scenelist = Array<String>()
        
        for var i=0; i<data.count; i++
        {
            if let dataItem = data[i] as? Dictionary<String,AnyObject>
            {
                scenelist.append(dataItem["name"] as! String )
            }
        }
    }
    
    //设置scenesDataCache值
    private func _setScenesDataCache()
    {
        //实例化scenesDataCache
        scenesDataCache = [Dictionary<String,AnyObject>]()
        
        
        for i in 0..<scenelist.count
        {
            var sceneDataCache = Dictionary<String,AnyObject>()
            let _sceneName : String = scenelist[i]
            sceneDataCache["sceneName"] = _sceneName
            println("_SceneName\(_sceneName)")
            let _scenePlayList = getCurrentScenePlayList(_sceneName) as [Dictionary<String, AnyObject>]
            //println("_scenePlayList:\(_scenePlayList)")
            let _index = status.getSceneIndexStatusCache()
            println("index:\(_index[_sceneName])")
            
            var _scenePlayingIndex = _index[_sceneName]
            
            if _scenePlayingIndex != nil
            {
                _scenePlayingIndex = _index[_sceneName]!
                
            }else{
                
                status.set_IndexForScene(_sceneName, index: 0)
                _scenePlayingIndex = status.getSceneIndexStatusCache()[_sceneName]!
            }
            
            for j in 0..<_scenePlayList.count
            {
                if j == _scenePlayingIndex
                {
                    sceneDataCache["playingName"] = _scenePlayList[j]["name"]
                    sceneDataCache["playingTag"] = _scenePlayList[j]["tag"]
                }
            }
            //继续读取
            scenesDataCache?.append(sceneDataCache)
        }
        //println("scenesDataCache:\(scenesDataCache)")
    }
    private func _getCurrentScenePlaylist (sceneName:String?) -> [Dictionary<String,AnyObject>]
    {
        
        println("Server-->_getCurrentScenePlaylist ()")
        if sceneName != nil
        {
            for var i=0; i<_data.count; i++
            {
                if let dataItem = _data[i] as? Dictionary<String,AnyObject>
                {
                    if let sceneName1 : String = dataItem["name"] as? String
                    {
                        if sceneName1 == sceneName
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
        }else{
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
        }
        
        
        //update by SlimAdam on 15/07/29
        //_data为当前年龄数据
//        if _data.count>0
//        {
//            if let dataItem = _data[0] as? Dictionary<String,AnyObject>
//            {
//                if let list : [Dictionary<String,AnyObject>] = dataItem["list"] as? [Dictionary<String,AnyObject>]
//                {
//                    return list
//                }
//            }
//        }
        
        return [Dictionary<String,AnyObject>]()
    }
    
    private func _getCurrentPlayingData () -> Dictionary<String,AnyObject>
    {
        let currentScenePlaylist : [Dictionary<String,AnyObject>] = _getCurrentScenePlaylist(nil)
        
        //如果要播放的歌曲索引小于播放列表索引,那么久播放这首歌
        if currentScenePlaylist.count > status.currentSceneIndex
        {
            return currentScenePlaylist[status.currentSceneIndex]
        }//如果有歌曲,直接播放第一首歌曲
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
        //MARK: fuck!!!
//        for (key , value) in playingData
//        {
//            currentPlayingData[key] = value
//        }
        currentPlayingData = playingData
        //println(currentPlayingData)
    }
    
    //切换为下一首音频
    func next() {
        
        let currentScenePlaylist : [Dictionary<String,AnyObject>] = _getCurrentScenePlaylist(nil)
        let isDisLike = NSUserDefaults.standardUserDefaults().boolForKey("clickDisLike")
        
        if isDisLike
        {
            if currentScenePlaylist.count > ( status.currentSceneIndex  )
            {
                status.set_CurrentSceneIndex(status.currentSceneIndex )
            }
            else
            {
                status.set_CurrentSceneIndex(0)
            }
            
        }else{
            
            if currentScenePlaylist.count > ( status.currentSceneIndex + 1 )
            {
                status.set_CurrentSceneIndex(status.currentSceneIndex + 1)
            }
            else
            {
                status.set_CurrentSceneIndex(0)
            }
        }
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "clickDisLike")
        
    }
    
    //切换上一个音频
    func previous() {
        let currentScenePlaylist : [Dictionary<String,AnyObject>] = _getCurrentScenePlaylist(nil)
        
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
        
        println("whatfuck---\(keyPath)")
        
        //场景切换伴随着歌曲切换,所以只要判断歌曲切换了再更新界面就好了
        if keyPath == "currentSceneIndex"
        {
            _updateCurrentPlayingData()
            
            delegate?.currentPlayingDataHasChanged()
        }
        
        
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
    
    
    func updateData (data : Array<AnyObject>)
    {
        _data = data
        
        _updateScenelist(_data)
        
        _updateCurrentPlayingData()
        
        delegate?.currentPlayingDataHasChanged()
    }
    
    
    
    //ugcData:传入要修改的数据,isAdd:是否是新增数据
    func updateCurrentScenePlayList(ugcData:Dictionary<String,AnyObject> ,isAdd:Bool,sceneName:String?)
    {
        var currentScienceList = getCurrentScenePlayList(nil)
        //判断是否是新增数据
        if isAdd
        {
            
            for sceneItemIndex in 0..<_data.count
            {
                var completed : Bool = false
                
                if sceneName != nil{
                    println(_data[sceneItemIndex]["name"])
                    if _data[sceneItemIndex]["name"]as! String == sceneName!
                    {
                        
                        
                        var sceneMusicList =  _data[sceneItemIndex]["list"] as! NSArray
                        var mutableArrayList : NSMutableArray = sceneMusicList.mutableCopy() as! NSMutableArray
                        
                        for index in 0..<mutableArrayList.count
                        {
                            //判断是否是分享文件,
                            let shareList = ugcData["list"] as? [Dictionary<String,AnyObject>]
                            
                            if shareList != nil
                            {
                                println(shareList)
                                
                                for _index in 0..<shareList!.count
                                {
                                    let shareListItem = shareList![_index]
                                    
                                    
                                    if mutableArrayList[index]["localURI"]as! String != shareListItem["localURI"]as! String && index == mutableArrayList.count-1
                                    {
                                        mutableArrayList.addObject(shareListItem)
                                        //sceneMusicList = mutableArrayList .copy() as! NSArray
                                        var d : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
                                        
                                        d["list"] = mutableArrayList
                                        d["name"] = sceneName
                                        
                                        _data[sceneItemIndex] = d
                                        
                                        completed = true
                                        
                                        break
                                        
                                        
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }
                    if completed
                    {
                        break
                    }
                }else{
                    if _data[sceneItemIndex]["name"]as! String == status.currentScene
                    {
                        
                        
                        var sceneMusicList =  _data[sceneItemIndex]["list"] as! NSArray
                        var mutableArrayList : NSMutableArray = sceneMusicList.mutableCopy() as! NSMutableArray
                        
                        for index in 0..<mutableArrayList.count
                        {
                            
                            //判断是否是分享文件,
                            let shareList = ugcData["list"] as? [Dictionary<String,AnyObject>]
                            
                            if shareList != nil
                            {
                                for _index in 0..<shareList!.count
                                {
                                    let shareListItem = shareList![_index]
                                    
                                    if mutableArrayList[index]["localURI"]as! String != shareListItem["localURI"]as! String && index == mutableArrayList.count-1
                                    {
                                        mutableArrayList.addObject(shareListItem)
                                        //sceneMusicList = mutableArrayList .copy() as! NSArray
                                        var d : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
                                        
                                        d["list"] = mutableArrayList
                                        d["name"] = status.currentScene
                                        
                                        _data[sceneItemIndex] = d
                                        
                                        completed = true
                                        
                                        break
                                        
                                        
                                    }
                                }
                            }
                            
                            
                            
                        }
                        
                    }
                    if completed
                    {
                        break
                    }
                }
                
            }
            
        }else{
            
            var completed : Bool = false
            
            for sceneItemIndex in 0..<_data.count
            {
                //println("当前场景")
                //println(_data[sceneItemIndex]["name"])
                //println(status.currentScene)
                if _data[sceneItemIndex]["name"]as! String == status.currentScene
                {
                    var sceneMusicList =  _data[sceneItemIndex]["list"] as! NSArray
                    //Remove(ugcData, from: sceneMusicList)
                    
                    var mutableArrayList : NSMutableArray = sceneMusicList.mutableCopy() as! NSMutableArray
                    
                    for index in 0..<mutableArrayList.count
                    {
                        if mutableArrayList[index]["localURI"]as! String == ugcData["localURI"]as! String
                        {
                            //如果数组总量大于索引,可以删除
                            if mutableArrayList.count >= index
                            {
                                mutableArrayList.removeObjectAtIndex(index)
                            }
                            //sceneMusicList = mutableArrayList .copy() as! NSArray
                            var d : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
                            
                            d["list"] = mutableArrayList
                            d["name"] = status.currentScene
                            
                            _data[sceneItemIndex] = d
                            
                            completed = true
                            
                            break
                        }
                        
                    }

                }
                
                if completed
                {
                    break
                }
            }
        
            
            
        }
       // println(_data)
        
        
        var error : NSError?
        println(NSUserDefaults.standardUserDefaults().objectForKey("childBirthday"))
        if let childBirthday : NSDate = NSUserDefaults.standardUserDefaults().objectForKey("childBirthday") as? NSDate
        {
            let childAge : (age : Int , month : Int) = AgeCalculator(birth: childBirthday).age
            
            let cachePath : String = NSSearchPathForDirectoriesInDomains(.CachesDirectory , .UserDomainMask, true)[0] as! String
            
            let DataFilePath : String = cachePath + "/data/\(childAge.age).json"
            
            //println(DataFilePath)
            
            
            if error != nil
            {
                println(error)
            }
            save(_data, toFile: DataFilePath)

            
        }
        
        
    }
    
    
    func getCurrentJsonPath()->NSURL
    {
        var jsonPath : NSURL?
        
        //判断年龄,得到当前年龄段
        if let childBirthday : NSDate = NSUserDefaults.standardUserDefaults().objectForKey("childBirthday") as? NSDate
        {
            let childAge : (age : Int , month : Int) = AgeCalculator(birth: childBirthday).age
            
            jsonPath  = NSBundle.mainBundle().resourceURL!.URLByAppendingPathComponent("resource/data/\(childAge.age).json")
            
        }
        
        return jsonPath!
    }
    
    
    func updateJsonData ()
    {
        for sceneItem in _data
        {
            if sceneItem["name"]as! String == status.currentScene
            {
                
                let listarray = sceneItem["list"]as!NSArray
                
                for listDictionary in listarray
                {
                    let jsonData = listDictionary as! Dictionary<String,AnyObject>
                    
                    //println(jsonData["localURI"])
                }
                
            }
        }

    }
    
    //数组转换成Json
    func toJSONString(dict:AnyObject)->NSString{
        
        var data = NSJSONSerialization.dataWithJSONObject(dict, options:NSJSONWritingOptions.PrettyPrinted , error: nil)
        var strJson=NSString(data: data!, encoding: NSUTF8StringEncoding)
        return strJson!
        
    }
    
    //存储到Json文件中
    func save(jsonData :AnyObject, toFile : String)
    {
        var error:NSError?
        
        let str = toJSONString(jsonData)
        str.writeToFile(toFile, atomically: false, encoding: NSUTF8StringEncoding, error: &error)
        
        if error != nil
        {
            println(error)
        }
        else
        {
            println("他喵的保存文件成功了好么!!!")
        }
        
    }
    
    //得到当前年龄段Json
    func getCurentAgeGroupData()->Array<AnyObject>
    {
        
        return _data
    }
    func getCurrentSceneName( ) ->String
    {
        return status.currentScene
    }
    
    //得到iTunes上传列表
    func getUploadList() -> Dictionary<String, NSURL> {
        //遍历document下的所有文件
        let homeDir = NSHomeDirectory().stringByAppendingPathComponent("Documents")
        var fileManager = NSFileManager.defaultManager()
        var listCount = 0
        let fileList = fileManager.contentsOfDirectoryAtURL(NSURL(fileURLWithPath: homeDir)!, includingPropertiesForKeys: nil, options: nil, error: nil) as! [NSURL]
        var localList : Dictionary<String,NSURL> = Dictionary<String,NSURL>()
        
        for item in fileList
        {
            //判断后缀
            if item.lastPathComponent!.lowercaseString.hasSuffix("mp3") || item.lastPathComponent!.lowercaseString.hasSuffix("m4a")
            {
                //println(item.lastPathComponent!)
                
                // if in
                //    if
                // else add
                
                //处理不同场景下,本地歌曲添加状态
                
                var loopReturnValue:(isIn:Bool,sceneName:String) = isInCurrentAgeList(item.relativePath!)
                if loopReturnValue.isIn
                {
                    if loopReturnValue.sceneName == status.currentScene
                    {
                        localList["\(listCount)"] = item
                        
                        listCount++
                    }
                    
                }else {
                    
                    localList["\(listCount)"] = item
                    
                    listCount++
                }
                
                
                //println(localList)
                
                
            }else{
                println("不是")
            }
            
            
        }
        
        
        return localList
    }
    
    //MARK:本类方法------
    
    //判断是否在被添加
    func isInCurrentAgeList(localPath:String) ->(isIn:Bool,sceneName:String)
    {
        var flag = 0
        var isIn = false
        var sceneName = ""
        
        for sceneListItem in _data
        {
            var isNot = false
            let listArray = sceneListItem["list"]as! NSArray
            
            for listArrayIndex in 0..<listArray.count
            {
                if listArray[listArrayIndex]["localURI"] as? String == localPath
                {
                    isIn = true
                    sceneName = sceneListItem["name"]as! String
                    
                    return (isIn,sceneName)
                    
                    
                }
                
                flag++
            }
            
            
        }
        
        return (isIn,sceneName)
    }
}