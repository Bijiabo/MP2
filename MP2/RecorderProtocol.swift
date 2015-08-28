//
//  RecorderProtocol.swift
//  MP2
//
//  Created by SlimAdam on 15/8/27.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation

protocol RecorderProtocol{
    
    //一次应用启动关闭周期的所有数据
    var allOperateData : [Dictionary<String,AnyObject>]?{get set}
    //一次用户操作的数据
    var aOperateData : Dictionary<String,AnyObject>?{get set}
    //不喜欢的歌曲信息
    var musicInfo : AnyObject?{get set}
    //孩子的年龄信息
    var childInfo : Dictionary<String,AnyObject>?{get set}
    //操作的时间
    var operateTime : NSDate?{get set}
    
    
    //转换为Json
    func toJSONString(obj: AnyObject) ->NSString
    //保存到文件系统
    func saveToFile(data :AnyObject, toFile : String)
    
    //构建childInfo
    func generateChildInfo(childInfo:Dictionary<String,AnyObject>?)
    
    //构建musicInfo
    func generateMusicInfo(musicInfo:AnyObject?)
}