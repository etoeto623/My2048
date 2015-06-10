//
//  BoardView.swift
//  My2048
//
//  Created by 隆海 on 15/5/23.
//  Copyright (c) 2015年 隆海. All rights reserved.
//

import UIKit

class BoardView: UIView{
    
    let blockRadius:CGFloat = 4
    var blockValue:Int = 0
    var vc:ViewController?;

    var label:UILabel = UILabel()
    
    // 方块颜色和分数的对应关系234 187 25
    let bgColorWithScore:[Int:UIColor] = [
        2:UIColor(red: 0.91, green: 0.87, blue: 0.82, alpha: 1),
        4:UIColor(red: 0.91, green: 0.85, blue: 0.75, alpha: 1),
        8:UIColor(red: 0.93, green: 0.63, blue: 0.4, alpha: 1),
        16:UIColor(red: 0.93, green: 0.5, blue: 0.32, alpha: 1),
        32:UIColor(red: 0.94, green: 0.4, blue: 0.3, alpha: 1),
        64:UIColor(red: 0.96, green: 0.27, blue: 0.15, alpha: 1),
        128:UIColor(red: 0.92, green: 0.77, blue: 0.34, alpha: 1),
        256:UIColor(red: 0.91, green: 0.765, blue: 0.28, alpha: 1),
        512:UIColor(red: 0.91, green: 0.75, blue: 0.21, alpha: 1),
        1024:UIColor(red: 0.91, green: 0.74, blue: 0.156, alpha: 1),
        2048:UIColor(red: 0.91, green: 0.73, blue: 0.1, alpha: 1),
        4096:UIColor(red: 0.91, green: 0.72, blue: 0.06, alpha: 1)
    ]
    
    enum FontSize:CGFloat{
        case small = 22
        case middle = 28
        case big = 35
    }
    
    init( point:CGPoint, size:CGSize, stage:UIView, vc:ViewController ){
        super.init(frame: CGRect(origin: point,size: size))
        self.vc = vc
        self.label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size:size))
        let bv = getRandScore()
        self.blockValue = bv
        self.layer.cornerRadius = blockRadius
        self.backgroundColor = self.bgColorWithScore[bv]
        self.label.text = "\(self.blockValue)"
        let font = UIFont(name: "American Typewriter", size: getFontSize(bv))
        self.label.font = font
        self.label.textAlignment = NSTextAlignment.Center
        self.label.textColor = getFontColor(bv)
        self.addSubview(self.label)
        self.showIn(inview: stage)
    }
    
    init( point:CGPoint, size:CGSize, bv:Int, vc:ViewController ){
        super.init(frame: CGRect(origin: point,size: size))
        self.vc = vc
        self.label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size:size))
        self.blockValue = bv
        self.layer.cornerRadius = blockRadius
        self.backgroundColor = self.bgColorWithScore[bv]
        self.label.text = "\(self.blockValue)"
        let font = UIFont(name: "American Typewriter", size: getFontSize(bv))
        self.label.font = font
        self.label.textAlignment = NSTextAlignment.Center
        self.label.textColor = getFontColor(bv)
        self.addSubview(self.label)
//        self.showIn(inview: stage)
    }
    
    func getRandScore() -> Int{
        return arc4random() % 2 == 0 ? 2 : 4
    }
    
    func update(){
        self.label.font = UIFont(name: "American Typewriter", size: getFontSize(self.blockValue))
        self.label.textColor = getFontColor(self.blockValue)
        self.label.text = "\(self.blockValue)"
        self.backgroundColor = self.bgColorWithScore[self.blockValue]
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getFontSize( score:Int )->CGFloat{
        switch score{
        case 1 ..< 100 :
            return max(13,FontSize.big.rawValue - CGFloat((self.vc!.deminsion - 4)*8))
        case 100 ..< 1000 :
            return max(13,FontSize.middle.rawValue - CGFloat((self.vc!.deminsion - 4)*8))
        case 1000 ..< 100000 :
            return max(13,FontSize.small.rawValue - CGFloat((self.vc!.deminsion - 4)*8))
        default:
            return max(13,FontSize.small.rawValue - CGFloat((self.vc!.deminsion - 4)*8))
        }
    }
    private func getFontColor( score:Int )->UIColor{
        if score < 10 {
            return UIColor(red: 0.38, green: 0.35, blue: 0.32, alpha: 1)
        }else{
            return UIColor.whiteColor()
        }
    }

}
