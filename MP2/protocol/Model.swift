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
    var delegate : Operation? {get set}
    
    //情景列表
    var scenelist : Array<String> {get}
    //状态管理
    var status : StatusManager {get set}
    
    //当前播放数据
    var currentPlayingData : Dictionary<String,AnyObject> {get}
    
    //切换为下一首音频
    func next()
}