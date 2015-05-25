//
//  ViewController.swift
//  My2048
//
//  Created by 隆海 on 15/5/16.
//  Copyright (c) 2015年 隆海. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var board = UIView()
    var bgBlocks = [[UIView]]()  //棋盘的背景色
    let bgBlockColor = UIColor(red: 0.75, green: 0.7, blue: 0.64, alpha: 1) //背景方格的颜色
    var blockWidth:CGFloat = 0  //方格宽度
    let blockMargin:CGFloat = 5  //方格之间的间距
    var bt:CGFloat = 0  // 存储棋盘到顶层view顶端的距离
    var bl:CGFloat = 0  // 存储棋盘到顶层view左侧的距离
    var blockSize:CGSize = CGSize() //方格的大小
    var deminsion = 5 //方格阵列的维度
    var blockHolder = [[BoardView?]]() //存放方块的地方
    
    // 手势滑动的方向
    enum PanDirection:Int{
        case left = 1
        case right
        case up
        case down
        
        var description:String{
            return "shit"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 给最上层的view绑定手势识别
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "pan:"))
    }

    @IBAction func startButtonTapped(sender: UIButton) {
        let paddingTwoSide:CGFloat = 10
        let bwidth = self.view.bounds.width - 2 * paddingTwoSide
        let topYCoord = (self.view.bounds.height - bwidth)/2
        board = UIView(frame: CGRect(origin: CGPoint(x: paddingTwoSide, y:topYCoord), size: CGSize(width: bwidth, height: bwidth)))
        board.backgroundColor = UIColor(red: 0.675, green: 0.61, blue: 0.56, alpha: 1)
        board.layer.cornerRadius = 6
        self.view.addSubview(board)
        
        bt = board.center.y - board.bounds.width/2
        bl = board.center.x - board.bounds.width/2

        showBlockWithDimen(dimensions: deminsion)
        initBlockHolder()
//        showRand()
        appendOneBlock()
    }
    
    
//    var d:BoardView = BoardView(point: CGPoint(x: 0, y: 0), size: CGSize(width: 0, height: 0), stage: UIView())
    func showRand(){
//        d = BoardView(point: getSpecPoint(2, y: 1), size: blockSize, stage: self.view)
//        d = UIView(frame: CGRect(origin: getSpecPoint(2, y: 3), size: blockSize))
//        d.backgroundColor = UIColor.redColor()
//        d.showIn(inview: self.view)
    }
    
    //获取触摸事件
    var panDelta:CGPoint = CGPoint()
    var panVelocity:CGPoint = CGPoint()
    func pan( sender:UIPanGestureRecognizer ){
        if sender.state == .Changed {
            panDelta = sender.translationInView(self.view)
            panVelocity = sender.velocityInView(self.view)
        }
        if sender.state == .Ended {
            if let dir = getPanDirection(panDelta, velocity: panVelocity){
                moveBlockAfterPan(dir)
                appendOneBlock()
            }
        }
    }
    
    func getPanDirection( delta:CGPoint, velocity:CGPoint )->PanDirection?{
        if abs(velocity.x)<200 && abs(velocity.y)<200{
            return nil
        }
        if abs(delta.x)<70 && abs(delta.y)<70{
            return nil
        }
        let sw = (delta.x,delta.y)
        switch sw{
        case let(x,y) where x>0 && (y==0 || abs(x/y)>2.5):
            return PanDirection.right
        case let(x,y) where x<0 && (y==0 || abs(x/y)>2.5):
            return PanDirection.left
        case let(x,y) where y>0 && (x==0 || abs(y/x)>2.5):
            return PanDirection.down
        case let(x,y) where y<0 && (x==0 || abs(y/x)>2.5):
            return PanDirection.up
        default:
            return nil
        }
    }
    
    // 添加一个方块
    func appendOneBlock(){
        let x = Int(arc4random()) % self.deminsion
        let y = Int(arc4random()) % self.deminsion
        if let tmp = blockHolder[x][y]{
            appendOneBlock()
        }else {
            blockHolder[x][y] = BoardView(point: getSpecPoint(x, y: y), size: blockSize, stage: self.view)
        }
    }
    
    
    //根据触摸的方向移动方块
    func moveBlockAfterPan( direction:PanDirection ){
        if direction == PanDirection.left{
            for y in 0 ..< deminsion{ //遍历列
                for x in 1 ..< deminsion{  //遍历行
                    if blockHolder[y][x] == nil{
                        continue
                    }
                    for tmp in 1 ... x{
                        if blockHolder[y][x-tmp] == nil{
                            if tmp != x{
                                continue
                            } else { //到达行首
                                var holder1 = BoardView(point: getSpecPoint(x, y: y), size: blockSize, bv: blockHolder[y][x]!.blockValue)
                                self.view.addSubview(holder1)
                                holder1.moveMySelf(to: getSpecCenter(x-tmp, y: y),moveCompleted:{
                                    holder1.removeFromSuperview()
                                    self.view.addSubview(self.blockHolder[y][x-tmp]!)
                                })
                                self.blockHolder[y][x-tmp] = BoardView(point: self.getSpecPoint(x-tmp, y: y), size: self.blockSize, bv: self.blockHolder[y][x]!.blockValue)
                                self.blockHolder[y][x]?.removeFromSuperview()
                                self.blockHolder[y][x] = nil
                                break
                            }
                        } else {
                            if blockHolder[y][x-tmp]?.blockValue == blockHolder[y][x]?.blockValue {
                                var holder1 = BoardView(point: getSpecPoint(x, y: y), size: blockSize, bv: blockHolder[y][x]!.blockValue)
                                var holder2 = BoardView(point: getSpecPoint(x-tmp, y: y), size: blockSize, bv: blockHolder[y][x-tmp]!.blockValue)
                                self.blockHolder[y][x-tmp]?.removeFromSuperview()
                                self.blockHolder[y][x]?.removeFromSuperview()
                                self.blockHolder[y][x-tmp] = BoardView(point: getSpecPoint(x-tmp, y: y), size: blockSize, bv: blockHolder[y][x-tmp]!.blockValue * 2)
                                self.blockHolder[y][x] = nil
                                println("遇到相同的了\(x):\(y)-->\(x-tmp):\(y)")
                                self.view.addSubview(holder1)
                                self.view.addSubview(holder2)
                                holder1.moveMySelf(to: getSpecCenter(x-tmp, y: y),moveCompleted:{
                                    self.view.addSubview(self.blockHolder[y][x-tmp]!)
                                    holder2.removeFromSuperview()
                                    holder1.removeFromSuperview()
                                })
                                break
                            } else {
                                var holder1 = BoardView(point: getSpecPoint(x, y: y), size: blockSize, bv: blockHolder[y][x]!.blockValue)
                                holder1.moveMySelf(to: getSpecCenter(x-tmp+1, y: y),moveCompleted:{
                                    holder1.removeFromSuperview()
                                    self.view.addSubview(self.blockHolder[y][x-tmp+1]!)
                                })
                                self.blockHolder[y][x-tmp+1] = BoardView(point: self.getSpecPoint(x-tmp+1, y: y), size: self.blockSize, bv:self.blockHolder[y][x]!.blockValue)
                                self.blockHolder[y][x]?.removeFromSuperview()
                                self.blockHolder[y][x] = nil
                                break
                            }
                        }
                    }
                }
            }
        }
    }

    // 绘制棋盘的背景方块
    func showBlockWithDimen( #dimensions: Int ){
        blockWidth = ( self.board.bounds.width - blockMargin * CGFloat(dimensions+1)) / CGFloat(dimensions)
        blockSize = CGSize(width: blockWidth, height: blockWidth)

        var loop1 = 0
        while loop1 < dimensions {
            var loop2 = 0
            var tmpBlocks = [UIView]()
            while loop2 < dimensions{
                tmpBlocks.append(UIView(frame: CGRect(origin: getSpecPoint(loop2, y: loop1), size: blockSize)))
                loop2 += 1
            }
            bgBlocks.append(tmpBlocks)
            loop1 += 1
        }
        for bs in bgBlocks{
            for b in bs{
                b.backgroundColor = bgBlockColor
                b.showIn(inview: self.view)
            }
        }
    }
    
    // 获取指定位置方块的中心坐标
    func getSpecPoint( x:Int, y:Int ) -> CGPoint{
        return CGPoint(x: bl + blockMargin + (blockWidth+blockMargin) * CGFloat(x),
            y: bt + blockMargin + (blockWidth+blockMargin) * CGFloat(y))
    }
    // 获取指定位置方块的左上角坐标
    func getSpecCenter( x:Int, y:Int ) -> CGPoint{
        let p1 = blockMargin + (blockWidth+blockMargin) * CGFloat(x)
        let p2 = blockMargin + (blockWidth+blockMargin) * CGFloat(y)
        return CGPoint(x: bl + p1 + blockWidth/2,
            y: bt + p2 + blockWidth/2)
    }
    
    func initBlockHolder(){
        var i = 0
        var j = 0
        for i in 0 ..< deminsion{
            var tmp = [BoardView?]()
            for j in 0 ..< deminsion{
                tmp.append(nil)
            }
            blockHolder.append(tmp)
        }
    }
}

extension UIView {
    // 移动view
    func moveMySelf( #to: CGPoint, moveCompleted:(()->Void)? ){
//        UIView.animateWithDuration(0.3, animations: {
//            
//        })
        UIView.animateWithDuration(0.3, animations: {
            self.center = to
        }) { (completed) -> Void in
            if moveCompleted != nil{
                moveCompleted!()
            }
        }
    }
    // 显示动画
    func showIn( #inview:UIView ){
        self.alpha = 0
        self.layer.cornerRadius = 3
        inview.addSubview(self)
        UIView.animateWithDuration(0.2, animations: {
            self.alpha = 1
        })
    }
}
//protocol GameBlock{
//    var blockValue:Int{ get set } //方块自身的分数
//    var label:UILabel{ get set }
//}