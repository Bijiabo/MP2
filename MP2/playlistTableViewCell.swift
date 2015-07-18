//
//  playlistTableViewCell.swift
//  MP2
//
//  Created by SlimAdam on 15/7/17.
//  Copyright (c) 2015年 JYLabs. All rights reserved.
//

import UIKit

class playlistTableViewCell: UITableViewCell {

    @IBOutlet var audioNameLabel: UILabel!
    @IBOutlet var audioTagLabel: UILabel!
    
    var active : Bool = false {
        didSet {
            if active == true
            {
                self.backgroundColor = UIColor(red:0.83, green:0.93, blue:0.96, alpha:1)
            }
            else
            {
                //false
                self.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
