//
//  userInformationViewController.swift
//  MP2
//
//  Created by bijiabo on 15/7/3.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit

class userInformationViewController: UIViewController , Module
{
    var moduleLoader : ModuleLoader?
    
    @IBOutlet var childNameTextField: UITextField!
    @IBOutlet var childSexualitySegmentedControl: UISegmentedControl!
    @IBOutlet var childBirthdayDatePicker: UIDatePicker!
    
    let ageMax : Int = 6
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func initView () -> Void
    {
        initDatePicker()
        
        if let childName =  NSUserDefaults.standardUserDefaults().stringForKey("childName")
        {
            childNameTextField.text = childName
        }
        
        if let childSexuality = NSUserDefaults.standardUserDefaults().stringForKey("childSexuality")
        {
            for var i = 0 ; i < childSexualitySegmentedControl.numberOfSegments ; i++
            {
                if childSexualitySegmentedControl.titleForSegmentAtIndex(i) == childSexuality
                {
                    childSexualitySegmentedControl.selectedSegmentIndex = i
                    break
                }
            }
        }
        
    }
    
    func initDatePicker () -> Void
    {
        //最大年龄计算不准,update by SlimAdam on 15/7/23
        //let minimumDate : NSDate = NSDate(timeIntervalSinceNow: NSTimeInterval( -3600*24*365*(ageMax) + 3600*24*1 ))
        let minimumDate : NSDate = NSDate(timeIntervalSinceNow: NSTimeInterval( -3600*24*365*(ageMax) - 3600*24*1 ))
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
    
    
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        childNameTextField.resignFirstResponder()
    }
    @IBAction func tapSaveButton(sender: AnyObject) {
        
        if checkChildAgeGroupChanged()
        {
            //若孩子年龄段改变，则发送通知
            let presentChildBirthDay : NSDate = childBirthdayDatePicker.date
            let presentChildAge : (age : Int , month : Int) = AgeCalculator(birth: presentChildBirthDay).age
            
            let age : (age : Int , month : Int) = presentChildAge.age <= ageMax ? presentChildAge : (age : presentChildAge.age , month : 0)
            
            NSNotificationCenter.defaultCenter().postNotificationName("childAgeGroupChanged", object: ["age" : age.age] as AnyObject)
        }
        
        //若为新用户，注册
        //...
        
        //储存用户修改的数据
        NSUserDefaults.standardUserDefaults().setObject(childNameTextField.text, forKey: "childName")
        
        let childSexuality : String =  childSexualitySegmentedControl.titleForSegmentAtIndex(childSexualitySegmentedControl.selectedSegmentIndex)!
        NSUserDefaults.standardUserDefaults().setObject(childSexuality, forKey: "childSexuality")
        NSUserDefaults.standardUserDefaults().setObject(childBirthdayDatePicker.date, forKey: "childBirthday")
        //用户数据修改后,发送一个通知,
        NSNotificationCenter.defaultCenter().postNotificationName("childDataHasChange", object: nil)
        
        
        //关闭页面
        self.navigationController?.popViewControllerAnimated(true)
//        self.dismissViewControllerAnimated(true, completion: nil)
//        moduleLoader?.loadModule("Main", storyboardIdentifier: "mainVC")
        
        
        
    }
    
}
