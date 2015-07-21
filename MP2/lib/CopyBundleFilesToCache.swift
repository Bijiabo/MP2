//
//  CopyFile.swift
//  MP
//
//  Created by bijiabo on 15/6/7.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation

class CopyBundleFilesToCache {
    
    var targetDirectoryInCache : String = "/"
    
    init(targetDirectoryInCache : String)
    {
        self.targetDirectoryInCache = targetDirectoryInCache
        
        let isNewVersion : Bool = checkNewVersion()
        
        if isNewVersion
        {
            doCopy()
        }
    }
    
    func checkNewVersion () -> Bool
    {
        let oldVersion : Int = NSUserDefaults.standardUserDefaults().integerForKey("version")
        
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("version") as! Int
        
        if version > oldVersion
        {
            return true
        }
        else
        {
            return false
        }
        
    }
    
    func doCopy(dirPathInBundle : String = "resource/media") -> Void
    {
        let cachePath : String = NSSearchPathForDirectoriesInDomains(.CachesDirectory , .UserDomainMask, true)[0] as! String
        
        let targetPath : String = cachePath + "/\(targetDirectoryInCache)/"

        //若目标文件夹不存在，则创建
        var isDir : ObjCBool = true
        
        if NSFileManager.defaultManager().fileExistsAtPath(targetPath, isDirectory: &isDir) == false
        {
            NSFileManager.defaultManager().createDirectoryAtPath(targetPath, withIntermediateDirectories: true, attributes: [NSFileProtectionKey : NSFileProtectionNone], error: nil)
        }
        
        let bundleResourceDirectoryURL : NSURL! = NSBundle.mainBundle().resourceURL?.URLByAppendingPathComponent( dirPathInBundle )
        
        copyBundleFilesToCache(fromeURL: bundleResourceDirectoryURL, targetPath: targetPath)
        
        
        removeFileProtection(path: targetPath)
        removeFileProtection(path: targetPath /*+ "media"*/)
        
        loopFilesToRemoveProtection(path: targetPath /*+ "media"*/)
    }
    
    func copyBundleFilesToCache(#fromeURL : NSURL  , targetPath : String) -> Void
    {
        let fileManager : NSFileManager = NSFileManager.defaultManager()
        
        var isDir : ObjCBool = true
        var isNotDir : ObjCBool = false
        
        
        let fileExists : Bool = fileManager.fileExistsAtPath(targetPath)
        
        if fileExists
        {
            let pathlist : [AnyObject]? = fileManager.contentsOfDirectoryAtURL( fromeURL  , includingPropertiesForKeys: nil, options: nil, error: nil)
            
            if (pathlist != nil)
            {
                //is a directory
                
                for path in pathlist!
                {
                    let pathLastPathComponent : String = path.lastPathComponent
                    
                    let URLForPath : NSURL = NSURL(fileURLWithPath: targetPath + pathLastPathComponent)!
                    
                    let pathExists : Bool = fileManager.fileExistsAtPath(URLForPath.relativePath!)
                    
                    if pathExists == false
                    {
                        //文件不存在，拷贝！
                        fileManager.copyItemAtURL(path as! NSURL, toURL: NSURL(fileURLWithPath: targetPath + "/" + pathLastPathComponent)!, error: nil)
                    }
                    else
                    {
                        //文件存在，检查一下里面
                        copyBundleFilesToCache(fromeURL: path as! NSURL, targetPath: targetPath + "/" + pathLastPathComponent + "/")
                    }
                }
            }
            
        }
        else
        {
            fileManager.copyItemAtURL(fromeURL, toURL: NSURL(fileURLWithPath: targetPath)!, error: nil)
        }
    }
    
    func removeFileProtection (#path : String) -> Void
    {
        
        let attributes : Dictionary = [NSFileProtectionKey : NSFileProtectionNone]
        
        var error : NSError?
        
        NSFileManager.defaultManager().setAttributes(attributes, ofItemAtPath: path, error: &error)

    }
    
    func loopFilesToRemoveProtection (#path : String) -> Void
    {
        let fileURL : NSURL = NSURL(fileURLWithPath: path)!
        
        let list = NSFileManager.defaultManager().contentsOfDirectoryAtURL(fileURL, includingPropertiesForKeys: nil, options: nil, error: nil)!
        
        for item in list //as [AnyObject]
        {
            removeFileProtection(path: (item as! NSURL).relativePath!  )
        }
    }
}