//
//  moduleLoader.swift
//  MP2
//
//  Created by bijiabo on 15/7/10.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation

protocol ModuleLoader
{
    func loadModule(storyboardName : String , storyboardIdentifier : String)
}

protocol Module
{
    var moduleLoader : ModuleLoader? {get set}
}