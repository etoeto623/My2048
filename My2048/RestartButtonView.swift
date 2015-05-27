//
//  RestartButtonView.swift
//  My2048
//
//  Created by 隆海 on 15/5/27.
//  Copyright (c) 2015年 隆海. All rights reserved.
//

import UIKit

class RestartButtonView: UILabel {
    
    init( rect:CGRect ){
        super.init(frame: rect)
        //重新开始按钮
        self.backgroundColor = UIColor.greenColor()
        self.alpha = 1
        self.textAlignment = NSTextAlignment.Center
        self.textColor = UIColor.blueColor()
        self.font = UIFont(name: "American Typewriter", size: 30)
        self.text = "重新开始"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
