//
//  UserFeedBackViewController.swift
//  MP2
//
//  Created by SlimAdam on 15/8/18.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit

class UserFeedBackViewController: UIViewController , UITextViewDelegate,UIAlertViewDelegate{

    @IBOutlet weak var contactInfo: UITextField!
    
    @IBOutlet weak var feedBackContent: UITextView!
    
    var tipContent : String!
    
    var upYun = UpYun()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _initFeedBackView()
        _initUpYun()
        
    }
    
    //发送反馈内容
    @IBAction func sendMessage(sender: UIBarButtonItem) {
        
        //内容不为提示内容,且不为空
        if feedBackContent.text != tipContent && !feedBackContent.text.isEmpty
        {
            var feedBackDic = Dictionary<String,AnyObject>()
            //feedBackDic["email"] = email.text
            feedBackDic["content"] = feedBackContent.text
            
            //文件名保存为发送时间
            var date:NSDate = NSDate()
            var formatter : NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let dateString = formatter.stringFromDate(date)
            
            //保存到临时文件夹,为了上传到upYun上
            var localURL = NSURL(fileURLWithPath: NSHomeDirectory())?.URLByAppendingPathComponent("tmp")
            localURL = localURL?.URLByAppendingPathComponent("\(dateString).json")
            
            save(feedBackDic, toFile: localURL!.relativePath!)
            //上传到upYun
            upYun.uploadFile(localURL, saveKey: "/FeedBack/\(dateString).json")
            
            var alertView = UIAlertView(title: nil, message: "感谢您的反馈,我们会尽快处理!", delegate: self, cancelButtonTitle: "ok")
            
            alertView.show()
            
        }
        
        //关闭页面
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func _initFeedBackView()
    {
        feedBackContent.layer.backgroundColor = UIColor.clearColor().CGColor
        feedBackContent.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).CGColor
        feedBackContent.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        feedBackContent.layer.cornerRadius = 5
        feedBackContent.layer.borderWidth = 1.0
        feedBackContent.text = "请输入您的建议或意见..."
        feedBackContent.delegate = self
        tipContent = feedBackContent.text
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if feedBackContent.text == "请输入您的建议或意见..."
        {
            feedBackContent.text = ""
            feedBackContent.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if feedBackContent.text.isEmpty
        {
            feedBackContent.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            feedBackContent.text = "请输入您的建议或意见..."
        }
    }
    
    //MARK:工具方法
    func _initUpYun()
    {
        upYun.passcode = "ukeX7vTiPkknHGT9gtUholk2MdI="
        upYun.bucket = "earlyenglishstudy"
        upYun.expiresIn = 6000
        
    }
    
    //数组转换成Json
    func toJSONString(dict:AnyObject)->NSString{
        
        var data = NSJSONSerialization.dataWithJSONObject(dict, options:NSJSONWritingOptions.PrettyPrinted , error: nil)
        var strJson=NSString(data: data!, encoding: NSUTF8StringEncoding)
        return strJson!
        
    }
    
    func save(jsonData :AnyObject, toFile : String)
    {
        var error:NSError?
        
        let str: AnyObject = toJSONString(jsonData)
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
