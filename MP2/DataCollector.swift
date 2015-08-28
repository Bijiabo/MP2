//
//  DataCollection.swift
//  MP2
//
//  Created by SlimAdam on 15/8/27.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation
import Alamofire

class DataCollector: NSObject {
    
    var applicationStatus : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
    
    var recorder : Recorder!
    
    let targetNotifications : NSArray = [
        "tapDislike",
        "listenOnce",
        "switchScene",
        "switchActive",
        "lockAudio",
        "switchAudio",
        "changeVolume",
        "togglePlay",
        "changePose",
        "appWillTerminate"
    ]
    
    override init() {
        super.init()
        recorder = Recorder()
        
        _addObservers()
    }
    //接收所有的通知
    private func _addObservers() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receivedNotification:"), name: nil, object: nil)
    }
    
    //接收到通知
    func receivedNotification(notification : NSNotification) {
        
        
        if targetNotifications.containsObject(notification.name) {
            
            
            println( notification.name )
            
            //MARK:分开记录用户的操作
            
            switch notification.name {
                
                //点击不喜欢
            case "tapDislike" :
                
                _tapDislike(notification)
                
            case "switchScene":
                
                _switchScene(notification)
                
            case "appWillTerminate" :
                
                _appWillTerminate()
                
            default:
                break
            }
        
            
            let postBody : Dictionary<String,AnyObject> = [
                "user" : "HuChunbo",
                "date" : _getCurrentShortDate(),
                "location" : "home",
                "baby" : "Shandian",
                "detail" : ["test" : "test"],
                "motion" : notification.name
            ]
            
            //send request
//            let requestURLString : String = "http://localhost:3000/collection/add"
//            let request : Request = Alamofire.request(Alamofire.Method.POST, requestURLString, parameters: postBody)
//            
//            request.responseJSON {  _, _, result in
//                //NSLog("new motion")
//                if result.isSuccess {
//                    //let jsonData = JSON(result.value!)
//                    //print(jsonData)
//                }
//                
//            }
        }
    }
    
    private func _getCurrentShortDate() -> String {
        let todaysDate = NSDate()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let DateInFormat = dateFormatter.stringFromDate(todaysDate)
        
        return DateInFormat
    }
    
    //MARK:用户操作,实现方法
    
    private func _tapDislike(notification:NSNotification)
    {
        var aOperateData : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
        //println(notification.object)
        
        var model = notification.object as! ModelManager
        let operateTime = recorder.dateToString(NSDate()).date + recorder.dateToString(NSDate()).time
        aOperateData["operateTime"] = operateTime
        aOperateData["operateMode"] = "tapDislike"
        aOperateData["sceneName"] = model.status.currentScene
        aOperateData["childInfo"] = recorder.childInfo
        aOperateData["musicInfo"] = model.currentPlayingData
        
        recorder.allOperateData?.append(aOperateData)
        
        
        //println(recorder.allOperateData!)
    }
    
    private func _switchScene(notification:NSNotification)
    {
        let argsDic = notification.object as! Dictionary<String,AnyObject>
        
        var aOperateData : Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
        //println(notification.object)
        
        var model = argsDic["model"] as! ModelManager
        
        let operateTime = recorder.dateToString(NSDate()).date + recorder.dateToString(NSDate()).time
        aOperateData["operateTime"] = operateTime
        
        aOperateData["operateMode"] = "switchScene"
        
        aOperateData["sceneName"] = argsDic["currentScene"]
        
        aOperateData["switchToScene"] = argsDic["toScene"]
        
        aOperateData["childInfo"] = recorder.childInfo
        
        aOperateData["musicInfo"] = model.currentPlayingData
        
        
        recorder.allOperateData?.append(aOperateData)
    }
    private func _appWillTerminate(){
        //程序将退出,保存数据到
        let saveTime = recorder.dateToString(NSDate())
        
        var savePath = NSHomeDirectory().stringByAppendingString("/Documents/OperationDate/"+saveTime.date)
        
        //如果目录不存在
        if !NSFileManager().fileExistsAtPath(savePath)
        {
            
            NSFileManager().createDirectoryAtPath(savePath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
        savePath = savePath.stringByAppendingString("/"+saveTime.time+".json")
        //println(savePath)
        recorder.saveToFile(recorder.allOperateData!, toFile: savePath)
    }
}