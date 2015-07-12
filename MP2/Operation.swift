//
//  Operation.swift
//  MP2
//
//  Created by bijiabo on 15/6/20.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation

protocol ViewOperation {

    func doLike()
    
    func doDislike()
    
    func wrongPlayerUrl() //过渡设计，应去除
    
    func switchToScene(scene : String)
    
    func playNext() //暂时无用
    
    func updateChildInformation() //暂时无用，已有其他方法代替
    
    func currentPlayingDataHasChanged()
}

protocol PlayerOperation
{
    var playing : Bool {get}
    
    func play()
    
    func pause()
    
    func togglePlayPause()
    
    func playerDidFinishPlaying()
}

//过度设计，可去除
protocol DownloadOperation
{
    //下载全部媒体文件
    func startAllDownload()
}

protocol NetWorkOperation
{
    //网络状态
    var Wifi : Bool {get}
    var Connected : Bool {get}
    var CellularNetwork : Bool {get}
   
}

typealias Operations = protocol<PlayerOperation , ViewOperation , DownloadOperation , NetWorkOperation>