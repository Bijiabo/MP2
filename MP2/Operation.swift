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
    
    func wrongPlayerUrl()
    
    func switchToScene(scene : String)
    
    func playNext()
    
    func updateChildInformation()
    
    
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

protocol DownloadOperation
{
    //下载全部媒体文件
    func startAllDownload()
}

typealias Operations = protocol<PlayerOperation , ViewOperation , DownloadOperation>