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
    var deminsion = 4 //方格阵列的维度
    var blockHolder = [[BoardView?]]() //存放方块的地方
    let boardRadius:CGFloat = 6
    let animationDuration = 0.3
    
    // 手势滑动的方向
    enum PanDirection:Int{
        case left = 1
        case right
        case up
        case down
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 给最上层的view绑定手势识别
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "pan:"))
    }

    //游戏开始
    @IBAction func startButtonTapped(sender: UIButton) {
        let paddingTwoSide:CGFloat = 10
        let bwidth = self.view.bounds.width - 2 * paddingTwoSide
        let topYCoord = self.view.bounds.height - bwidth * 5 / 4
        board = UIView(frame: CGRect(origin: CGPoint(x: paddingTwoSide, y:topYCoord), size: CGSize(width: bwidth, height: bwidth)))
        board.backgroundColor = UIColor(red: 0.675, green: 0.61, blue: 0.56, alpha: 1)
        board.layer.cornerRadius = boardRadius
        self.view.addSubview(board)
        
        bt = board.center.y - board.bounds.width/2
        bl = board.center.x - board.bounds.width/2

        showBlockWithDimen(dimensions: deminsion)
        initBlockHolder()
        appendOneBlock()
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
                if moveBlockAfterPan(dir){
                    if hasEmptySpace(){
                        appendOneBlock()
                        if isGameOver(){
                            println("game over")
                        }
                    }
                }
            }
        }
    }
    
    func getPanDirection( delta:CGPoint, velocity:CGPoint )->PanDirection?{
//        if abs(velocity.x)<80 && abs(velocity.y)<80{
//            return nil
//        }
        if abs(delta.x)<30 && abs(delta.y)<30{
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
            blockHolder[x][y] = BoardView(point: getSpecPoint(y, y: x), size: blockSize, stage: self.view)
        }
    }
    
    
    //根据触摸的方向移动方块
    func moveBlockAfterPan( direction:PanDirection )->Bool{
        var count = 0
        if direction == .left{ //左移
            for x in 0 ..< deminsion{
                for y in 1 ..< deminsion{   //每一行
                    if blockHolder[x][y] == nil{
                        continue
                    }
                    for t in 1 ... y{
                        if blockHolder[x][y-t] == nil{
                            if y-t == 0{
                                //移动方块到行首
                                blockHolder[x][0] = BoardView(point: getSpecPoint(0, y: x), size: blockSize, bv: blockHolder[x][y]!.blockValue)
                                let tmp = BoardView(point: getSpecPoint(y, y: x), size: blockSize, bv: blockHolder[x][y]!.blockValue)
                                self.view.addSubview(tmp)
                                tmp.moveMySelf(to: getSpecCenter(0, y: x), moveCompleted: {
                                    assert(self.blockHolder[x][0] != nil, "shit happened:\(x):\(y)-->\(x):\(0)")
                                    self.view.addSubview( self.blockHolder[x][0]! )
                                    tmp.removeFromSuperview()
                                })
                                blockHolder[x][y]!.removeFromSuperview()
                                blockHolder[x][y] = nil
                                count++
                                break
                            }else{
                                continue
                            }
                        }else{
                            if blockHolder[x][y-t]!.blockValue == blockHolder[x][y]!.blockValue{ //两个方块的值相同，融合
                                blockHolder[x][y-t]!.blockValue = blockHolder[x][y-t]!.blockValue * 2
                                let tmp = BoardView(point: getSpecPoint(y, y: x), size: blockSize, bv: blockHolder[x][y]!.blockValue)
                                self.view.addSubview(tmp)
                                tmp.moveMySelf(to: getSpecCenter(y-t, y: x), moveCompleted: {
                                    assert(self.blockHolder[x][y-t] != nil, "shit happened:\(x):\(y)-->\(x):\(y-t)")
                                    self.blockHolder[x][y-t]!.update()
                                    tmp.removeFromSuperview()
                                })
                                blockHolder[x][y]!.removeFromSuperview()
                                blockHolder[x][y] = nil
                                count++
                                break
                            }else{
                                if t==1{
                                    break
                                }
                                blockHolder[x][y-t+1] = BoardView(point: getSpecPoint(y-t+1, y: x), size: blockSize, bv: blockHolder[x][y]!.blockValue)
                                let tmp = BoardView(point: getSpecPoint(y, y: x), size: blockSize, bv: blockHolder[x][y]!.blockValue)
                                self.view.addSubview(tmp)
                                tmp.moveMySelf(to: getSpecCenter(y-t+1, y:x), moveCompleted: {
                                    assert(self.blockHolder[x][y-t+1] != nil, "shit happened:\(x):\(y)-->\(x):\(y-t+1)")
                                    self.view.addSubview( self.blockHolder[x][y-t+1]! )
                                    tmp.removeFromSuperview()
                                })
                                blockHolder[x][y]!.removeFromSuperview()
                                blockHolder[x][y] = nil
                                count++
                            }
                            break
                        }
                    }
                }
            }
        }else if direction == .right{
            for x in 0 ..< deminsion{
                for y in 0 ..< deminsion-1{   //每一行
                    if blockHolder[x][deminsion-2-y] == nil{
                        continue
                    }
                    for t in deminsion-2-y+1 ..< deminsion{
                        if blockHolder[x][t] == nil{
                            if t == deminsion-1{
                                //移动方块到行尾
                                blockHolder[x][deminsion-1] = BoardView(point: getSpecPoint(deminsion-1, y: x), size: blockSize, bv: blockHolder[x][deminsion-2-y]!.blockValue)
                                let tmp = BoardView(point: getSpecPoint(deminsion-2-y, y: x), size: blockSize, bv: blockHolder[x][deminsion-2-y]!.blockValue)
                                self.view.addSubview(tmp)
                                tmp.moveMySelf(to: getSpecCenter(deminsion-1, y: x), moveCompleted: {
                                    self.view.addSubview( self.blockHolder[x][self.deminsion-1]! )
                                    tmp.removeFromSuperview()
                                })
                                blockHolder[x][deminsion-2-y]!.removeFromSuperview()
                                blockHolder[x][deminsion-2-y] = nil
                                count++
                                break
                            }else{
                                continue
                            }
                        }else{
                            if blockHolder[x][t]!.blockValue == blockHolder[x][deminsion-2-y]!.blockValue{ //两个方块的值相同，融合
                                blockHolder[x][t]!.blockValue = blockHolder[x][t]!.blockValue * 2
                                let tmp = BoardView(point: getSpecPoint(deminsion-2-y, y: x), size: blockSize, bv: blockHolder[x][deminsion-2-y]!.blockValue)
                                self.view.addSubview(tmp)
                                tmp.moveMySelf(to: getSpecCenter(t, y: x), moveCompleted: {
                                    self.blockHolder[x][t]!.update()
                                    tmp.removeFromSuperview()
                                })
                                blockHolder[x][deminsion-2-y]!.removeFromSuperview()
                                blockHolder[x][deminsion-2-y] = nil
                                count++
                                break
                            }else{
                                if t==deminsion-2-y+1{
                                    break
                                }
                                blockHolder[x][t-1] = BoardView(point: getSpecPoint(t-1, y: x), size: blockSize, bv: blockHolder[x][deminsion-2-y]!.blockValue)
                                let tmp = BoardView(point: getSpecPoint(deminsion-2-y, y: x), size: blockSize, bv: blockHolder[x][deminsion-2-y]!.blockValue)
                                self.view.addSubview(tmp)
                                tmp.moveMySelf(to: getSpecCenter(t-1, y:x), moveCompleted: {
                                    self.view.addSubview( self.blockHolder[x][t-1]! )
                                    tmp.removeFromSuperview()
                                })
                                blockHolder[x][deminsion-2-y]!.removeFromSuperview()
                                blockHolder[x][deminsion-2-y] = nil
                                count++
                            }
                            break
                        }
                    }
                }
            }
        }else if direction == .up{
            for y in 0 ..< deminsion{
                for x in 1 ..< deminsion{   //每一行
                    if blockHolder[x][y] == nil{
                        continue
                    }
                    for t in 1 ... x{
                        if blockHolder[x-t][y] == nil{
                            if x-t == 0{
                                //移动方块到行首
                                blockHolder[0][y] = BoardView(point: getSpecPoint(y, y: 0), size: blockSize, bv: blockHolder[x][y]!.blockValue)
                                let tmp = BoardView(point: getSpecPoint(y, y: x), size: blockSize, bv: blockHolder[x][y]!.blockValue)
                                self.view.addSubview(tmp)
                                tmp.moveMySelf(to: getSpecCenter(y, y: 0), moveCompleted: {
                                    self.view.addSubview( self.blockHolder[0][y]! )
                                    tmp.removeFromSuperview()
                                })
                                blockHolder[x][y]!.removeFromSuperview()
                                blockHolder[x][y] = nil
                                count++
                                break
                            }else{
                                continue
                            }
                        }else{
                            if blockHolder[x-t][y]!.blockValue == blockHolder[x][y]!.blockValue{ //两个方块的值相同，融合
                                blockHolder[x-t][y]!.blockValue = blockHolder[x-t][y]!.blockValue * 2
                                let tmp = BoardView(point: getSpecPoint(y, y: x), size: blockSize, bv: blockHolder[x][y]!.blockValue)
                                self.view.addSubview(tmp)
                                tmp.moveMySelf(to: getSpecCenter(y, y: x-t), moveCompleted: {
                                    self.blockHolder[x-t][y]!.update()
                                    tmp.removeFromSuperview()
                                })
                                blockHolder[x][y]!.removeFromSuperview()
                                blockHolder[x][y] = nil
                                count++
                                break
                            }else{
                                if t==1{
                                    break
                                }
                                blockHolder[x-t+1][y] = BoardView(point: getSpecPoint(y, y: x-t+1), size: blockSize, bv: blockHolder[x][y]!.blockValue)
                                let tmp = BoardView(point: getSpecPoint(y, y: x), size: blockSize, bv: blockHolder[x][y]!.blockValue)
                                self.view.addSubview(tmp)
                                tmp.moveMySelf(to: getSpecCenter(y, y:x-t+1), moveCompleted: {
                                    self.view.addSubview( self.blockHolder[x-t+1][y]! )
                                    tmp.removeFromSuperview()
                                })
                                blockHolder[x][y]!.removeFromSuperview()
                                blockHolder[x][y] = nil
                                count++
                            }
                            break
                        }
                    }
                }
            }
        }else if direction == .down{
            for y in 0 ..< deminsion{
                for x in 0 ..< deminsion-1{   //每一行
                    if blockHolder[deminsion-2-x][y] == nil{
                        continue
                    }
                    for t in deminsion-2-x+1 ..< deminsion{
                        if blockHolder[t][y] == nil{
                            if t == deminsion-1{
                                //移动方块到行尾
                                blockHolder[deminsion-1][y] = BoardView(point: getSpecPoint(y, y: deminsion-1), size: blockSize, bv: blockHolder[deminsion-2-x][y]!.blockValue)
                                let tmp = BoardView(point: getSpecPoint(y, y: deminsion-2-x), size: blockSize, bv: blockHolder[deminsion-2-x][y]!.blockValue)
                                self.view.addSubview(tmp)
                                tmp.moveMySelf(to: getSpecCenter(y, y: deminsion-1), moveCompleted: {
                                    self.view.addSubview( self.blockHolder[self.deminsion-1][y]! )
                                    tmp.removeFromSuperview()
                                })
                                blockHolder[deminsion-2-x][y]!.removeFromSuperview()
                                blockHolder[deminsion-2-x][y] = nil
                                count++
                                break
                            }else{
                                continue
                            }
                        }else{
                            if blockHolder[t][y]!.blockValue == blockHolder[deminsion-2-x][y]!.blockValue{ //两个方块的值相同，融合
                                blockHolder[t][y]!.blockValue = blockHolder[t][y]!.blockValue * 2
                                let tmp = BoardView(point: getSpecPoint(y, y: deminsion-2-x), size: blockSize, bv: blockHolder[deminsion-2-x][y]!.blockValue)
                                self.view.addSubview(tmp)
                                tmp.moveMySelf(to: getSpecCenter(y, y: t), moveCompleted: {
                                    self.blockHolder[t][y]!.update()
                                    tmp.removeFromSuperview()
                                })
                                blockHolder[deminsion-2-x][y]!.removeFromSuperview()
                                blockHolder[deminsion-2-x][y] = nil
                                count++
                                break
                            }else{
                                if t==deminsion-2-x+1{
                                    break
                                }
                                blockHolder[t-1][y] = BoardView(point: getSpecPoint(y, y: t-1), size: blockSize, bv: blockHolder[deminsion-2-x][y]!.blockValue)
                                let tmp = BoardView(point: getSpecPoint(y, y: deminsion-2-x), size: blockSize, bv: blockHolder[deminsion-2-x][y]!.blockValue)
                                self.view.addSubview(tmp)
                                tmp.moveMySelf(to: getSpecCenter(y, y:t-1), moveCompleted: {
                                    self.view.addSubview( self.blockHolder[t-1][y]! )
                                    tmp.removeFromSuperview()
                                })
                                blockHolder[deminsion-2-x][y]!.removeFromSuperview()
                                blockHolder[deminsion-2-x][y] = nil
                                count++
                            }
                            break
                        }
                    }
                }
            }
        }
        if count > 0{
            return true
        }
        return false
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
        for i in 0 ..< deminsion{
            var tmp = [BoardView?]()
            for j in 0 ..< deminsion{
                tmp.append(nil)
            }
            blockHolder.append(tmp)
        }
    }
    
    func hasEmptySpace()->Bool{
        for i in blockHolder{
            for j in i{
                if j == nil{
                    return true
                }
            }
        }
        return false
    }
    
    func isGameOver() ->Bool{
        for x in 0 ..< deminsion{
            for y in 0 ..< deminsion{
                if blockHolder[x][y] == nil{
                    return false
                }
                switch (x,y){
                case let(a,b) where a > 0:
                    if blockHolder[a][b]!.blockValue == blockHolder[a-1][b]?.blockValue{
                        return false
                    }
                case let(a,b) where a < deminsion-1:
                    if blockHolder[a][b]!.blockValue == blockHolder[a+1][b]?.blockValue{
                        return false
                    }
                case let(a,b) where b > 0:
                    if blockHolder[a][b]!.blockValue == blockHolder[a][b-1]?.blockValue{
                        return false
                    }
                case let(a,b) where b < deminsion-1:
                    if blockHolder[a][b]!.blockValue == blockHolder[a][b+1]?.blockValue{
                        return false
                    }
                default:
                    return true
                }
            }
        }
        return true
    }
    
}

extension UIView {
    // 移动view
    func moveMySelf( #to: CGPoint, moveCompleted:(()->Void)? ){
        UIView.animateWithDuration(0.2, animations: {
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
        self.transform = CGAffineTransformMakeScale(0, 0)
        inview.addSubview(self)
        UIView.animateWithDuration(0.2, delay: 0.2, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.alpha = 1
            self.transform = CGAffineTransformMakeScale(1, 1)
        }, completion: nil)
    }
}