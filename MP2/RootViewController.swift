//
//  RotoViewController.swift
//  MP2
//
//  Created by SlimAdam on 15/8/22.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit

public enum MenuState: Int {
    case Opened
    case Closed
}

protocol MenuDelegate {
    func openMenu()
    func closeMenu()
}

var menuState:MenuState = MenuState.Closed

class RootViewController: UIViewController ,MenuDelegate,Module,ViewManager{
    
    var moduleLoader : ModuleLoader?
    
    var delegate : Operations?
    
    var model : ModelManager?

    
    var mainController:UINavigationController!
    
    var leftController:UINavigationController!
    
    var tapRecognizer:UITapGestureRecognizer?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        mainController = storyboard.instantiateViewControllerWithIdentifier("mainVC") as! UINavigationController
        var mainScrollView = mainController.viewControllers[0] as! MainScrollViewController
        mainScrollView.menuDelegate = self
        mainScrollView.delegate = self.delegate
        mainScrollView.moduleLoader = self.moduleLoader
        mainScrollView.model = self.model
//        (mainController.viewControllers[0] as! MainScrollViewController).menuDelegate = self
        leftController = storyboard.instantiateViewControllerWithIdentifier("LeftController") as! UINavigationController
        
        var leftVC = leftController.viewControllers[0] as! LeftController
        leftVC.menuDelegate = self
        
        leftVC.rightVC = mainScrollView
        
        self.view.addSubview(mainController.view)
        
        mainController.view.frame = self.view.bounds
        mainController.view.layer.shadowRadius = 10.0
        mainController.view.layer.shadowOpacity = 0.8
        self.view.addSubview(leftController.view)
        
        leftController.view.frame = self.view.bounds
        self.view.bringSubviewToFront(mainController.view)
        
        //暂时去掉滑动显示功能
        //var panGesture = UIPanGestureRecognizer(target: self, action: Selector("pan:"))
        //self.mainController.view.addGestureRecognizer(panGesture)
        
        self.tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("closeMenu"))
    }

    func pan(panGesture:UIPanGestureRecognizer) {
        switch panGesture.state {
        case .Changed:
            var point = panGesture.translationInView(self.view)
            
            if point.x > 0 || panGesture.view!.center.x > self.view.center.x {
                panGesture.view?.center = CGPointMake(panGesture.view!.center.x + point.x, panGesture.view!.center.y)
                panGesture.setTranslation(CGPointMake(0, 0), inView: self.view)
            }
        case .Ended, .Failed:
            if mainController.view.frame.origin.x > self.view.frame.origin.x + 100{
                openMenu()
            } else {
                closeMenu()
            }
        default:
            break
        }
    }
    
    //打开菜单
    func openMenu() {
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
        mainController.view.frame = CGRectMake(200, mainController.view.frame.origin.y, mainController.view.frame.size.width, mainController.view.frame.size.height)
        UIView.commitAnimations()
        menuState = MenuState.Opened
        
        mainController.view.addGestureRecognizer(self.tapRecognizer!)
    }
    
    //关闭菜单
    func closeMenu() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
        mainController.view.frame = CGRectMake(0, mainController.view.frame.origin.y, mainController.view.frame.size.width, mainController.view.frame.size.height)
        UIView.commitAnimations()
        menuState = MenuState.Closed
        
        mainController.view.removeGestureRecognizer(self.tapRecognizer!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
