//
//  ViewController.swift
//  UIScrollViewDemo
//
//  Created by SlimAdam on 15/6/18.
//  Copyright (c) 2015年 SlimAdam. All rights reserved.
//

import UIKit


//枚举类型:标识不同ios设备
enum VJDeviceEnum{
    
    case VJDeviceEnum_iphone
    case VJDeviceEnum_iphoneRetina
    case VJDeviceEnum_ihphone6plus
    case VJDEviceEnum_unknow
    
    
}


class GuideViewController: UIViewController , UIScrollViewDelegate , Module
{

    var moduleLoader : ModuleLader?
    let guideImgDirName : String = "Guide-images"
    @IBOutlet var scrollVIew1: UIScrollView!
    
    
    @IBOutlet var pageControl: UIPageControl!
    //获取设备宽高
    let devWidth: CGFloat = UIScreen.mainScreen().bounds.width
    let devHeight: CGFloat = UIScreen.mainScreen().bounds.height
    
    //定义变量,页码数
    var pages : Int = 4
    
    var currentPix : CGFloat = 0
    
    var currentDeviceImageSubFix  = ""
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentDeviceImageSubFix = getCurrentDiveceImageFlag("jpg")
        //设置delegate属性，否则拓展拖动之后事件无法使用
        scrollVIew1.delegate = self
        
       // scrollVIew1.backgroundColor=UIColor.grayColor()
        //给页码数赋值
       // self.setPageNum()
        
        //初始化scrollView
        self.initScrollView()
        
        //设置pageControl
        pageControl.numberOfPages = pages

        
        //println(getCurrentDiveceImageFlag("png"))
        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    //获取指定目录下的图片数量
    func setPageNum () {
        
        //返回当前项目根目录NSURL对象
        let bundleURL : NSURL = NSBundle.mainBundle().resourceURL!
        //println("\(bundleURL)")
        //在基础URL上新增URL路径
        let imageDirectoryURL : NSURL = bundleURL.URLByAppendingPathComponent(guideImgDirName)

        
        var error : NSError?
        //获取文件目录
        let fileList = NSFileManager.defaultManager().contentsOfDirectoryAtURL(imageDirectoryURL, includingPropertiesForKeys: nil, options: nil, error: &error)
        
        if error == nil{
            
            pages = fileList!.count
            println("pageNum=\(pages)")
        }else{
            println("setPageNum error!!!")
        }
        
        
    }
    //给定一个图片的格式,返回匹配设备大小
    func getCurrentDiveceImageFlag(subFix : String ) ->String{
        var imageFlag = ""
        
        
        switch getCurrentDevice() {
            
        case .VJDeviceEnum_iphone:
            imageFlag = "." + subFix
        case .VJDeviceEnum_iphoneRetina:
            imageFlag += "@2x" + "." + subFix
        case .VJDeviceEnum_ihphone6plus:
            imageFlag += "@3x" + "." + subFix
        default:
            imageFlag += subFix
        }
        
        println("imageFlag:-->\(imageFlag)")
        return imageFlag
    }
    //初始化scrollView的方法
    func initScrollView(){
        
        
        
        //缩放系数
        let scaleRate: CGFloat = 1
        //设置宽高
        scrollVIew1.contentSize = CGSize(width: devWidth*CGFloat(pages), height: devHeight)
        
        //初始化后的scrollView ->contentOffSet
        currentPix = scrollVIew1.contentOffset.x
        
        println("currentPix \(currentPix)")
        
        //println("scrollView(width,height)->\(scrollVIew1.contentSize)")
        
        for tempI in 0..<pages{
            
            let viewFrame : CGRect = CGRect(x: devWidth*CGFloat(tempI) + (devWidth - devWidth / scaleRate )/2, y: (devHeight - devHeight / scaleRate)/2, width: devWidth/scaleRate, height: devHeight/scaleRate)
            
            let containerView : UIView = UIView(frame: viewFrame)
            
            let imageView = UIImageView(frame: CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height))
            
            containerView.addSubview(imageView)
            
            //设置imageView的内容填充模式
            imageView.contentMode = UIViewContentMode.ScaleToFill
            
            //imageView.backgroundColor = UIColor.blackColor()
            
            //得到图片的URL
            var imageURL : NSURL = NSBundle.mainBundle().resourceURL!.URLByAppendingPathComponent("\(guideImgDirName)/\(tempI)" + currentDeviceImageSubFix)
            
            var isNotDir : ObjCBool = false
            
            if NSFileManager.defaultManager().fileExistsAtPath(imageURL.relativePath!, isDirectory: &isNotDir){
                
                imageView.image=UIImage(contentsOfFile: imageURL.relativePath!)
                
               // println("\(scrollVIew1.contentOffset)")
            }
            //最后一页,生日选择引导页
            if tempI == pages-1{
                
                //引导文字
                var uiLabel : UILabel = UILabel(frame: CGRectMake((viewFrame.size.width-200)/2, viewFrame.size.height - viewFrame.size.height * 0.9 , 200, 100))
                
                var confirmButton : UIButton = UIButton( frame: CGRectMake((viewFrame.size.width-200)/2 , (devHeight-150)/1.1, 200, 30))
                var cancelButton : UIButton = UIButton(frame: CGRectMake((viewFrame.size.width-200)/2 , (devHeight-100)/1.1 , 200, 30) )
                
                uiLabel.text = "\t为了给您的孩子提供更好的适龄语感启蒙内容，我们希望知道您孩子的具体出生日期。"
                //uiLabel.backgroundColor = UIColor.grayColor()
                uiLabel.numberOfLines = 4
                cancelButton.setTitle("不,谢谢", forState : UIControlState.Normal)
                //cancelButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
                
                confirmButton.setTitle("好的",forState : UIControlState.Normal)
                //confirmButton.setTitleColor(UIColor(red: 0.23, green: 0.68, blue: 0.87, alpha: 1), forState: UIControlState.Normal)
                
                cancelButton.backgroundColor = UIColor(red:0.16, green:0.67, blue:0.95, alpha:1)
                cancelButton.layer.cornerRadius = 8.0
                confirmButton.layer.cornerRadius = 8.0
                confirmButton.backgroundColor = UIColor(red:0.16, green:0.67, blue:0.95, alpha:1)
                
                //给按钮添加事件
                
                cancelButton.addTarget(self, action: Selector("clickCancelButton"), forControlEvents: UIControlEvents.TouchUpInside)
                confirmButton.addTarget(self, action: Selector("clickConfirmButton"), forControlEvents: UIControlEvents.TouchUpInside)
                
                containerView.addSubview(uiLabel)
                
                containerView.addSubview(confirmButton)
                containerView.addSubview(cancelButton)
                
                
            }
            
            scrollVIew1.addSubview(containerView)
            
            //println("loop --> \(tempI)")
        }
    }
    
    //
    
    func clickCancelButton(){
        
        /*
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC : UIViewController = storyboard.instantiateViewControllerWithIdentifier("mainVC") as! UIViewController
        
        self.presentViewController(mainVC, animated: true, completion: nil)
        */
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "applicationHadActivated")
        
        moduleLoader?.loadModule("Main", storyboardIdentifier: "mainVC")
    }
    
    func clickConfirmButton(){
        
        moduleLoader?.loadModule("Guide", storyboardIdentifier: "datePickerVC")
        
    }
    
    
    //正在拖动的时候调用
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
       // println("\(scrollView.contentOffset.x)")
        dynAddImage(scrollView,pageC: pageControl)
        pageControl.currentPage = Int(scrollView.contentOffset.x / devWidth)
    }
    
    //拖动结束调用
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        //println("currentPage:-->\(scrollView.contentOffset.x / devWidth)")
        
        //设置拖动页面之后当前的pageControl
        
    }
    
    
    //内存优化,动态添加图片
    func dynAddImage(sv : UIScrollView , pageC: UIPageControl){
        //判断用户是左滑还是右滑
        
        let tempPix : Int = Int(sv.contentOffset.x) - Int(currentPix)
        
        if(tempPix > 0){
            
          //  println("drag right")
            
        }else{
            
           // println("drag left")
        }
        
        currentPix = sv.contentOffset.x
    }
    
    //return:VJDeviceEnum,判断当前设备,返回一个枚举类型的设备标识
    func getCurrentDevice() ->VJDeviceEnum{
        
        //得到当前设备width或者height的最大值/2
        let greateerPixelDimension = UIScreen.mainScreen().bounds.size.width > UIScreen.mainScreen().bounds.size.height ? UIScreen.mainScreen().bounds.size.width :UIScreen.mainScreen().bounds.size.height * 2
        
        println("当前设备大小:\(greateerPixelDimension)")
        switch greateerPixelDimension {
            
        case 480:
            return VJDeviceEnum.VJDeviceEnum_iphone
        case 960:
            return VJDeviceEnum.VJDeviceEnum_iphoneRetina
        case 1136:
            return VJDeviceEnum.VJDeviceEnum_iphoneRetina
        case 1334:
            return VJDeviceEnum.VJDeviceEnum_iphoneRetina
        case 1472:
            return VJDeviceEnum.VJDeviceEnum_ihphone6plus
        case 1920:
            return VJDeviceEnum.VJDeviceEnum_ihphone6plus
        default:
            return VJDeviceEnum.VJDEviceEnum_unknow
            
        }
        
        
    }
    
}

