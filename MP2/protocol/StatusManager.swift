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
    var currentScene : String { get }
    //当前情景播放序数
    var currentSceneIndex : Int { get }
    
    //设置当前情景
    func set_CurrentScene(scene : String)
    
    //设置当前情景播放序数
    func set_CurrentSceneIndex(index : Int)
    
    //获取指定情景播放序数
    func playIndexForScene(scene : String) -> Int
    
    //设定指定情景播放序数
    func set_IndexForScene(scene : String , index : Int)
    //获取所有场景最后播放的索引
    func getSceneIndexStatusCache ()-> Dictionary<String,Int>
    //状态观察者
    var observer : StatusObserver { get set }
}

protocol StatusObserver
{
    //状态已改变
    func statusHasChanged(keyPath : String)
}