//
//  FeedBackViewController.swift
//  MP2
//
//  Created by SlimAdam on 15/8/22.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit

class FeedBackViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
//        self.view.backgroundColor = UIColor.blackColor()
        _setImage("qrcode.jpg")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func _setImage(imgName : String)
    {
        let resourceURL : NSURL = NSBundle.mainBundle().resourceURL!.URLByAppendingPathComponent("resource/image", isDirectory: true)
        let imgURL = resourceURL.URLByAppendingPathComponent(imgName)
        
        println(imgURL)
        
        //设置图片
        self.imageView.image = UIImage(contentsOfFile: imgURL.relativePath!)
    }

    @IBAction func clickBackButton(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
