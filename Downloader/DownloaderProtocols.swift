//
//  DownloaderProtocol.swift
//  downloader
//
//  Created by bijiabo on 15/6/29.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation


protocol DownloadItemProtocol
{
    //编号
    var id : Int {get set}
    //远程地址
    var remoteURL : NSURL {get set}
    //本地地址
    var cacheRootURL : NSURL {get set}
    
    //本地保存文件名
    var filename : String {get set}
}

protocol DownloaderProtocol
{
    //建立下载任务，返回下载任务id
    func download(remoteURL: String , cacheRootURL : NSURL , filename : String?) -> Int
    
    func start(index : Int)
    func pause(index : Int)
    func cancel(index : Int)
    func resume(index : Int)
}

@objc protocol DownloaderObserverProtocol
{
    //下载完成
    func downloadCompleted(data : AnyObject)
    
    //下载出错
    func downloadErrorOccurd(data : AnyObject)
    
    //下载进度
    optional func refreshDownloadProgressFor(#id:Int , progress : Float)
}
