//
//  Recorder.swift
//  MP2
//
//  Created by SlimAdam on 15/8/27.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation

class Recorder : NSObject,RecorderProtocol{
    
    var allOperateData : [Dictionary<String,AnyObject>]?
    var aOperateData : Dictionary<String,AnyObject>?
    var musicInfo : AnyObject?
    var childInfo : Dictionary<String,AnyObject>?
    var operateTime : NSDate?
    
    
    override init ()
    {
        super.init()
        
        _addObserver()
        
        allOperateData = [Dictionary<String,AnyObject>]()
        aOperateData = Dictionary<String,AnyObject>()
        musicInfo = Dictionary<String,AnyObject>()
        childInfo = Dictionary<String,AnyObject>()
        operateTime = NSDate()
        generateChildInfo(nil)
    }
    
    private func _addObserver()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("childInfoChange"), name: "childAgeGroupChanged", object: nil)
    }
    
    init ( musicInfo: AnyObject,childInfo:Dictionary<String,AnyObject>,operateTime:NSDate)
    {
        //调用默认构造器
        Recorder()
        
        self.musicInfo = musicInfo
        self.childInfo = childInfo
        self.operateTime = operateTime
    }
    
    //孩子信息改变,重新获取
    func childInfoChange()
    {
        generateChildInfo(nil)
    }
    

    //构建childInfo
    func generateChildInfo(childInfo:Dictionary<String,AnyObject>?)
    {
        if childInfo != nil
        {
            self.childInfo = childInfo
            
        }else{
            
            var _childInfo = Dictionary<String,AnyObject>()
            
            let userDefault = NSUserDefaults.standardUserDefaults()
            
            _childInfo["name"] = userDefault.objectForKey("childName") as! String
            _childInfo["gender"] = userDefault.objectForKey("childSexuality")
            
            let childAge : (age : Int , month: Int) = AgeCalculator(birth: userDefault.objectForKey("childBirthday") as! NSDate).age
            _childInfo["age"] = childAge.age
            
            self.childInfo = _childInfo
        }
    }
    
    //构建musicInfo
    func generateMusicInfo(musicInfo:AnyObject?)
    {
        if musicInfo != nil
        {
            self.musicInfo = musicInfo
        }else{
            
        }
    }
    
    //转换为json格式
    func toJSONString(obj: AnyObject) ->NSString{
        
        var data = NSJSONSerialization.dataWithJSONObject(obj, options:NSJSONWritingOptions.PrettyPrinted , error: nil)
        var strJson=NSString(data: data!, encoding: NSUTF8StringEncoding)
        return strJson!
    }
    
    func dateToString(oDate:NSDate) -> (date:String,time:String)
    {
        
        var _date:NSDate = oDate
        var formatter : NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let date = formatter.stringFromDate(_date)
        formatter.dateFormat = "HHmmss"
        let time = formatter.stringFromDate(_date)
        return (date,time)
    }
    //保存到文件
    func saveToFile(data :AnyObject, toFile : String) {
        
        var error:NSError?
        
        let str: AnyObject = toJSONString(data)
        str.writeToFile(toFile, atomically: false, encoding: NSUTF8StringEncoding, error: &error)
        
        if error != nil
        {
            println(error)
        }
        else
        {
            println("他喵的保存文件成功了好么!!!")
        }
    }
    
    
}