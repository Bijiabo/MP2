//
//  Operation.swift
//  MP2
//
//  Created by bijiabo on 15/6/20.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import Foundation

protocol Operation {

    var playing : Bool {get}
    
    func doLike()
    
    func doDislike()
    
    func wrongPlayerUrl()
    
    func switchToScene(scene : String)
    
    func playNext()
    
    func updateChildInformation()
    
    func play()
    
    func pause()
    
    func togglePlayPause()
    
    func playerDidFinishPlaying()
    
    func currentPlayingDataHasChanged()
}