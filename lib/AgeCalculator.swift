//
//  AgeCalculator.swift
//  MP
//
//  Created by bijiabo on 15/6/13.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation

class AgeCalculator: NSObject {
    var age : (age : Int , month : Int) = (age : 0 , month : 0)
    
    init(birth : NSDate)
    {
        super.init()
        
        age = ageWithDateOfBirth(birth)
    }
    
    func ageWithDateOfBirth(date: NSDate) -> (age : Int , month : Int) {
        // 出生日期转换 年月日
        let components1 = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear, fromDate: date);
        let brithDateYear  = components1.year;
        let brithDateDay   = components1.day;
        let brithDateMonth = components1.month;
        
        // 获取系统当前 年月日
        let components2 = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear, fromDate: NSDate())
        let currentDateYear  = components2.year;
        let currentDateDay   = components2.day;
        let currentDateMonth = components2.month;
        
        // 计算年龄
        var iAge = currentDateYear - brithDateYear - 1;
        var mongth = currentDateMonth - brithDateMonth
        if ((currentDateMonth > brithDateMonth) || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay)) {
            iAge++;
        }
        
        return (age : iAge , month : mongth);
    }
}
