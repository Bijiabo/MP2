//
//  uploadMessageViewController.swift
//  MP2
//
//  Created by SlimAdam on 15/7/25.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit

class UploadMessageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "已上传内容"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func clickUploadGuideButton(sender: UIButton) {
        
        //获取要跳转的界面
        var iTnuesHelpVC : ItunesGuiderViewController = UIStoryboard(name: "UGC", bundle: nil).instantiateViewControllerWithIdentifier("iTnuesHelpVC") as! ItunesGuiderViewController
        
        self.navigationController?.pushViewController(iTnuesHelpVC, animated: true)
    }

    
}
