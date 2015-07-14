//
//  downloader.swift
//  downloader
//
//  Created by bijiabo on 15/6/28.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation
import Alamofire

class DownloadItem : DownloadItemProtocol
{
    var id : Int = 0
    var remoteURL : NSURL
    var cacheRootURL : NSURL
    var filename : String = ""

    var downloadComplete : Bool = false
    var status : String = "start"
    
    init(remoteURL : NSURL , cacheRootURL : NSURL)
    {
        self.remoteURL = remoteURL
        self.cacheRootURL = cacheRootURL
    }
}

class Downloader : DownloaderProtocol
{
    var delegate : DownloaderObserverProtocol?
    
    var list : Array<DownloadItemProtocol> = Array<DownloadItemProtocol>()
    
    var requestlist : [Request] = [Request]()
    
    init()
    {
        
    }
    
    func addTask(remoteURL: String , cacheRootURL : NSURL , filename : String?) -> Int?
    {
        
        let RemoteURL : NSURL? = NSURL(string: remoteURL)
        var item : DownloadItemProtocol!
        
        //如果URL格式正确,就不为空,那么可以初始化下载选项
        if RemoteURL != nil
        {
            item = DownloadItem(remoteURL: RemoteURL!, cacheRootURL: cacheRootURL)
            
        }
        else{
            println("URL格式不正确")
            
            return nil
            
        }
        
        
        if filename != nil
        {
            item.filename = filename!
        }
        
        
        var newURL : Bool = true
        
        var id : Int = 0
        
        for var i = 0; i < list.count ; i++
        {
            if list[i].remoteURL == item.remoteURL
            {
                newURL = false
                
                id = i
                
                break
            }
        }
        
        if newURL
        {
            //若路径不存在，则创建
            var isDir : ObjCBool = true
            if NSFileManager.defaultManager().fileExistsAtPath(cacheRootURL.relativePath!, isDirectory: &isDir) == false
            {
                NSFileManager.defaultManager().createDirectoryAtURL(cacheRootURL, withIntermediateDirectories: true, attributes: [NSFileProtectionKey : NSFileProtectionNone], error: nil)
            }
            
            item.id = list.count
            
            list.append(item)
        }
        
        //开始下载
        //start(id)
        
        return id
    }
    
    func startDownload()
    {
        //遍历下载列表,下载列表中的所有内容
        for i in 0..<list.count
        {
            if list[i].status == "start"
            {
                let destination : (NSURL, NSHTTPURLResponse) -> NSURL = _getDestination(remoteURL : list[i].remoteURL, cacheRootURL : list[i].cacheRootURL, filename : list[i].filename)
                
                let request = Alamofire.download(.GET, list[i].remoteURL, destination)
                
                //delegate是否有进度显示,若支持，则提供下载进度更新
                if self.delegate?.refreshDownloadProgressFor != nil
                {
                    request.progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                        
                        let percent = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
                        
                        self.delegate?.refreshDownloadProgressFor!(id: self.list[i].id, progress: percent)
                        
                    }
                }
                
                //_的用法,在这里的意思是忽略掉第三个参数
                //MARK:待完善->对error出错进行处理
                request.response { (request, response, _, error) in
                    
                    println("download complete  [\(self.list[i].remoteURL)]\n\n")
                    
                    self.list[i].status = "complete"
                    
                    self.delegate?.downloadCompleted( self.list[i] as! AnyObject )
                    
                    self.startDownload()
                }
                
                break
            }
            
        }
    }
    
    
    private func _getDestination ( #remoteURL : NSURL , cacheRootURL : NSURL , filename : String ) -> (NSURL, NSHTTPURLResponse) -> NSURL
    {
        let destination : (NSURL, NSHTTPURLResponse) -> NSURL = {(temporaryURL, response) -> NSURL in
            
            var _filename : String = remoteURL.lastPathComponent!
            
            if filename != ""
            {
                _filename = filename
            }
            
            let url : NSURL = cacheRootURL.URLByAppendingPathComponent(_filename)
            
            return url
        }
        
        return destination
    }
    
    
    func start(index: Int) {
        
        let item = list[index]
        
        let destination : (NSURL, NSHTTPURLResponse) -> NSURL = _getDestination(remoteURL : item.remoteURL, cacheRootURL : item.cacheRootURL, filename : item.filename)

        
        if requestlist.count > index
        {
            requestlist[index].resume()
        }
        else
        {
            let request = Alamofire.download(.GET, item.remoteURL, destination)
            
            //delegate是否有进度显示,若支持，则提供下载进度更新
            if self.delegate?.refreshDownloadProgressFor != nil
            {
                request.progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                    
                    let percent = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
                    
                    self.delegate?.refreshDownloadProgressFor!(id: item.id, progress: percent)
                    
                }
            }
            
            
            request.response { (request, response, _, error) in
                
                println("download complete 111  [\(item.remoteURL)]\n\n")
                
                self.list[index].downloadComplete = true
                
                self.delegate?.downloadCompleted( item as! AnyObject )
            }
            
            requestlist.append(request)
        }
        
        //发送通知
        NSNotificationCenter.defaultCenter().postNotificationName("DownloadStarted", object: nil)
        
    }
    
    func pause(index: Int) {
        if requestlist.count>index
        {
            requestlist[index].suspend()
        }
    }
    
    func cancel(index: Int) {
        
    }
    
    func resume(index: Int) {
        
    }
}
