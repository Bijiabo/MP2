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
    
    func switchToScene(scene : String)//切换场景
    
    func playNext() //暂时无用
    
    func updateChildInformation() //暂时无用，已有其他方法代替
    
    func currentPlayingDataHasChanged()//当前播放数据改变
    
    //得到当前场景下的播放列表
    func getCurrentScenePlayList(sceneName:String?) -> [Dictionary<String,AnyObject>]
    
    //ugcData:传入要修改的数据,isAdd:是否是新增数据
    func updateCurrentScenePlayList(ugcData:Dictionary<String,AnyObject> ,isAdd:Bool,sceneName:String?)
    //得到当前年龄段的Json数据
    func getCurentAgeGroupData() ->Array<AnyObject>
    
    //得到当前场景名
    func getCurrentSceneName() ->String
    
    //得到iTunes上传文件夹列表
    func getUploadList() ->Dictionary<String,NSURL>
    //得到整个App的下载器对象
    func getAppDownloader() -> Downloader
    
    func updateCurrentScenePlayListByShare(ugcData:Dictionary<String,AnyObject> ,isAdd:Bool,sceneName:String?)
}

//播放器功能操作方法接口
protocol PlayerOperation
{
    var playing : Bool {get}
    
    func play()//播放
    
    func pause()//暂停
    
    func togglePlayPause()// 播放/暂停
    
    func playerDidFinishPlaying()//结束播放
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

typealias Operations = protocol<PlayerOperation , ViewOperation , DownloadOperation , NetWorkOperation> //所有操作的接口集合