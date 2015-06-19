//
//  Observable.swift
//  MP2
//
//  Created by bijiabo on 15/6/19.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation

class Observable<T> {
    
    let didChange = Event<(T, T)>()
    
    private var value: T
    
    init(_ initialValue: T) {
        value = initialValue
    }
    
    func set(newValue: T) {
        let oldValue = value
        value = newValue
        didChange.raise(oldValue, newValue)
    }
    
    func get() -> T {
        return value
    }
}