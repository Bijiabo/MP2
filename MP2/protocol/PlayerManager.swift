//
//  playerManager.swift
//  MP2
//
//  Created by bijiabo on 15/6/19.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation

protocol PlayerManager
{
    var delegate : PlayerOperation? {get set}
    
    //播放状态
    var playing : Bool {get}
    
    //切换到播放状态
    func play()
    //切换到暂停状态
    func pause()

    //播放来源
    var playSource : NSURL {get set}
    //设定播放来源
    func setTheSource (playSource : NSURL)
}