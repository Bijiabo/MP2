//
//  datePickerViewController.swift
//  UIScrollViewDemo
//
//  Created by SlimAdam on 15/7/10.
//  Copyright (c) 2015年 SlimAdam. All rights reserved.
//

import UIKit

class datePickerViewController: UIViewController , Module
{
    var moduleLoader : ModuleLader?
    
    let ageMax : Int = 5

    @IBOutlet var childBirthdayDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initDatePicker()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initDatePicker () -> Void
    {
        
        let minimumDate : NSDate = NSDate(timeIntervalSinceNow: NSTimeInterval( -3600*24*365*(ageMax+1) + 3600*24*1 ))
        childBirthdayDatePicker.minimumDate = minimumDate
        childBirthdayDatePicker.maximumDate = NSDate()
        
        if let childBirthday: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("childBirthday")
        {
            childBirthdayDatePicker.date = childBirthday as! NSDate
        }
    }

    func checkChildAgeGroupChanged () -> Bool
    {
        //获取先前孩子年龄设置
        if let previousChildBirthDay : NSDate = NSUserDefaults.standardUserDefaults().objectForKey("childBirthday") as? NSDate
        {
            let previouseChildAge : (age : Int , month : Int) = AgeCalculator(birth: previousChildBirthDay).age
            
            //获取现在孩子年龄设置
            let presentChildBirthDay : NSDate = childBirthdayDatePicker.date
            let presentChildAge : (age : Int , month : Int) = AgeCalculator(birth: presentChildBirthDay).age
            
            return previouseChildAge.age != presentChildAge.age ? true : false
        }
        else
        {
            return true
        }
    }
    
    @IBAction func tapStartButton(sender: AnyObject) {
        if checkChildAgeGroupChanged()
        {
            //若孩子年龄段改变，则发送通知
            let presentChildBirthDay : NSDate = childBirthdayDatePicker.date
            let presentChildAge : (age : Int , month : Int) = AgeCalculator(birth: presentChildBirthDay).age
            
            let age : (age : Int , month : Int) = presentChildAge.age <= ageMax ? presentChildAge : (age : presentChildAge.age , month : 0)
            
            NSNotificationCenter.defaultCenter().postNotificationName("childAgeGroupChanged", object: ["age" : age.age] as AnyObject)
        }
        
        //储存用户修改的数据
        NSUserDefaults.standardUserDefaults().setObject(childBirthdayDatePicker.date, forKey: "childBirthday")
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "applicationHadActivated")
        
        moduleLoader?.loadModule("Main", storyboardIdentifier: "mainVC")
    }
}
