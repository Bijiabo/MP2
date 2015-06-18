//
//  status.swift
//  MP2
//
//  Created by bijiabo on 15/6/18.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation

protocol StatusManager
{
    //当前情景
    var currentScene : String {get}
    //设置当前情景
    func setCurrentScene(scene : String)
    
    //获取指定情景播放序数
    func playIndexForScene(scene : String) -> Int
    
    //设定指定情景播放序数
    func setIndexForScene(scene : String , index : Int)
}