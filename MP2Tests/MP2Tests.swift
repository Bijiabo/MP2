//
//  MP2Tests.swift
//  MP2Tests
//
//  Created by bijiabo on 15/6/18.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit
import XCTest

class MP2Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    //MARK:
    //MARK: server
    //model 测试数据
    let modelTestData : Array<AnyObject> = [
        [
            "name" : "qichuang",
            "list" : [
                ["name" : "color song"],
                ["name" : "the music room"]
            ]
        ],
        [
            "name" : "shuiqian",
            "list" : [
                ["name" : "good night"],
                ["name" : "little star"]
            ]
        ]
    ]
    
    //测试从server获取场景列表
    func test_Server_Scenelist ()
    {
        let server : ModelManager = Server(data : modelTestData)
        
        XCTAssert(server.scenelist == ["qichuang" , "shuiqian"] , "server scene list get success.")
    }
    
    //从server获取当前应该播放的内容
    func test_Server_currentPlayingData ()
    {
        let server : ModelManager = Server(data: modelTestData, statusManager: Status())
        
        let currentPlayingData = server.currentPlayingData
        
        server.status.set_CurrentScene("qichuang")
        server.status.set_IndexForScene(server.status.currentScene, index: 1)
        
        var getNameSuccess : Bool = false
        
        if let name : String = currentPlayingData["name"] as? String
        {
            getNameSuccess = ( name == "the music room" )
        }
        
        XCTAssert( getNameSuccess, "get currentPlayingData")
    }
    
    //用户改变场景后server刷新currentPlayingData
    func test_server_refresh_currentPlayingData_when_currentScene_changed ()
    {
        let server : ModelManager = Server(data: modelTestData, statusManager: Status())
        
        server.status.set_CurrentScene("qichuang")
        server.status.set_CurrentSceneIndex(0)
        server.status.set_IndexForScene("shuiqian", index: 0)
        
        server.status.set_CurrentScene("shuiqian")
        
        XCTAssert(server.currentPlayingData["name"] as! String == "good night", "test_server_refresh_currentPlayingData_when_currentScene_changed")
        
    }
    
    //MARK:
    //MARK: status
    
    //测试status记录场景
    func test_StatusManager_currentScene ()
    {
        let status : StatusManager = Status()
        let server : ModelManager = Server(data: modelTestData , statusManager : status)
        
        server.status.set_CurrentScene("qichuang")
        
        XCTAssert(status.currentScene == "qichuang", "status current scene test success.")
    }
    
    //读取场景进度
    func test_StatusManager_sceneIndex ()
    {
        let status : StatusManager = Status()
        let server : ModelManager = Server(data: modelTestData , statusManager : status)
        
        server.status.set_IndexForScene("qichuangxxx", index: 0)
        server.status.set_IndexForScene("qichuang", index: 1)
        
        let checkSceneIndexForNoSuchScene : Bool = status.playIndexForScene("qichuangxxx") == 0
        //test_Server_currentPlayingData() 设定qichuang模式序数为1
        let checkSceneIndexForScene : Bool = status.playIndexForScene("qichuang") == 1
        
        XCTAssert(checkSceneIndexForNoSuchScene && checkSceneIndexForScene  , "status current scene test success.")
    }
    
    //测试场景播放序数和读取
    func test_StatusManager_sceneIndexSet_and_Remember ()
    {
        let status : StatusManager = Status()
        let server : ModelManager = Server(data: modelTestData , statusManager : status)
        
        status.set_IndexForScene("qichuangTestMode" , index : 5)
        
        let status2 : StatusManager = Status()
        
        XCTAssert(status2.playIndexForScene("qichuangTestMode") == 5, "test status manager set scene index and remember success!")
    }
    
    //MARK:
    //MARK: 播放者
    let testMediaFileURL : NSURL = NSBundle.mainBundle().URLForResource("AreYouOK", withExtension: "mp3", subdirectory: "resource/media")!
    
    
    //player播放
    func test_Player_play()
    {
        let player : Player = Player(source: testMediaFileURL)

        
        player.play()
        
        XCTAssert(player.playing == true, "test player play")
        
    }
    
    //player暂停
    func test_Player_pause()
    {
        let player : Player = Player(source: testMediaFileURL)
        
        player.play()
        
        player.pause()
        
        XCTAssert(player.playing == false, "test player pause")
    }
    
    
}
