//
//  model.swift
//  MP2
//
//  Created by bijiabo on 15/6/18.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation

protocol ModelManager
{
    var delegate : Operations? {get set}
    
    //情景列表
    var scenelist : Array<String> {get}
    //状态管理
    var status : StatusManager {get set}
    //所有场景数据缓存
    var scenesDataCache : [Dictionary<String,AnyObject>]? {get set}
    
    //当前播放数据
    var currentPlayingData : Dictionary<String,AnyObject> {get}
    
    //切换为下一首音频
    func next()
    
    //切换为上一首音频
    func previous()
    
    //获取下载列表
    func getDownloadList() -> [Dictionary<String,String>]
    
    //更新数据
    func updateData (data : Array<AnyObject>)
    
    //得到当前场景下的播放列表
    func getCurrentScenePlayList(sceneName:String?) -> [Dictionary<String,AnyObject>]
    
    //ugcData:传入要修改的数据,isAdd:是否是新增数据
    func updateCurrentScenePlayList(ugcData:Dictionary<String,AnyObject> ,isAdd:Bool,sceneName:String?)
    //得到当前年龄段的Json数据
    func getCurentAgeGroupData() ->Array<AnyObject>
    //得到当前场景名字
    func getCurrentSceneName( ) ->String
    
    //得到iTunes上传文件夹列表
    func getUploadList() ->Dictionary<String,NSURL>
}