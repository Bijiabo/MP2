//
//  ItunesGuiderViewController.swift
//  MP2
//
//  Created by SlimAdam on 15/7/21.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit

class ItunesGuiderViewController: UIViewController,UIScrollViewDelegate {

    @IBOutlet var scrollView1: UIScrollView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    var devWidth : CGFloat = 0
    var devHeight : CGFloat = 0
    
    var pages = 0 //页数
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView1.delegate = self
        self.title = "iTuens上传教程"
        let scrollViewHeight = UIScreen.mainScreen().bounds.height - self.navigationController!.navigationBar.bounds.height-22//22为状态栏的高度
        devWidth = UIScreen.mainScreen().bounds.width
        devHeight = UIScreen.mainScreen().bounds.height
        
        initImagesResouce()
        
        scrollView1.contentSize = CGSize(width: devWidth * CGFloat(pages) , height: scrollViewHeight)
        //scrollView1.backgroundColor = UIColor.grayColor()
        pageControl.numberOfPages = pages
        //添加图片
        for pageIndex in 0..<pages
        {
            let viewFrame : CGRect = CGRect(x:devWidth * CGFloat(pageIndex) , y: 0, width:devWidth, height:scrollViewHeight)
            
            let containerView : UIView = UIView(frame: viewFrame)
            containerView.backgroundColor = UIColor.redColor()
            let imageView = UIImageView(frame: CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height))
            //imageView.backgroundColor = UIColor.blackColor()
            
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            
            var imageURL : NSURL = NSBundle.mainBundle().resourceURL!.URLByAppendingPathComponent("iTunesGuide-images/\(pageIndex).jpg")
            
            var isNotDir : ObjCBool = false
            
            if NSFileManager.defaultManager().fileExistsAtPath(imageURL.relativePath!, isDirectory: &isNotDir){
                
                imageView.image=UIImage(contentsOfFile: imageURL.relativePath!)
                
                // println("\(scrollVIew1.contentOffset)")
            }

            containerView.addSubview(imageView)
            
            scrollView1.addSubview(containerView)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        pageControl.currentPage = Int(scrollView.contentOffset.x / devWidth)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //初始化图片资源
    func initImagesResouce()
    {
        let bundleURL = NSBundle.mainBundle().resourceURL
        let imagesDir = bundleURL?.URLByAppendingPathComponent("iTunesGuide-images")
        
        var error : NSError?
        //获取文件目录
        let fileList = NSFileManager.defaultManager().contentsOfDirectoryAtURL(imagesDir!, includingPropertiesForKeys: nil, options: nil, error: &error)
        
        if error != nil
        {
            
            println(error)
        }else{
            
           pages = fileList!.count/3
        }
        
    }

}
