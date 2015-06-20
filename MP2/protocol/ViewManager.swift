//
//  viewManager.swift
//  MP2
//
//  Created by bijiabo on 15/6/19.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation

protocol ViewManager
{
    var delegate : Operations? {get set}
    
    var model : ModelManager? {get set}
}