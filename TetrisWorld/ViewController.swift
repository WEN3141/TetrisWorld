//
//  ViewController.swift
//  TetrisWorld
//
//  Created by 012 on 2021/10/25.
//  Copyright © 2021 wwt. All rights reserved.
//

import UIKit

class Cord{ //Coordinate
    var x : Int
    var y : Int
    init(xC: Int, yC: Int) {
        x = xC
        y = yC
    }
}
var BoardLimitLength = -1
let BoardLimitWidth = 10
let AmountOfTargetBlocks = 4
var AmountOfAllBlocks = -1
let NextTargetWindowLength = 4
let DownMoveAmount = 4
let AmountOfTypes = 7
let Line = 0
let UpLimitation = 3
let DeadLine = 6
let PointMul = 1000
let AllType =
    [
        [Cord(xC: 0,yC: 1), Cord(xC: 0,yC: 2), Cord(xC: 0,yC: 3)],/* I */
        [Cord(xC: 1,yC: 0), Cord(xC: 1,yC: 1), Cord(xC: 0,yC: 1)],/* O */
        [Cord(xC: 0,yC: 1), Cord(xC: 1,yC: 1), Cord(xC: 1,yC: 2)],/* S */
        [Cord(xC: 0,yC: 1), Cord(xC: -1,yC: 1), Cord(xC: -1,yC: 2)],/* Z */
        [Cord(xC: 0,yC: 1), Cord(xC: 0,yC: 2), Cord(xC: 1,yC: 2)],/* L */
        [Cord(xC: 0,yC: 1), Cord(xC: 0,yC: 2), Cord(xC: -1,yC: 2)],/* J */
        [Cord(xC: 2,yC: 0), Cord(xC: 1,yC: 0),Cord(xC: 1,yC: 1)]/* T */
    ]
let NextWindowPosition =
    [
        /*[Cord(xC: 1, yC: 0)], [Cord(xC: 0, yC: 1)], [Cord(xC: 1, yC: 0)], [Cord(xC: 0, yC: 1)],/* I */
        [Cord(xC: 1, yC: 1)], [Cord(xC: 1, yC: 1)], [Cord(xC: 1, yC: 1)], [Cord(xC: 1, yC: 1)],/* 0 */
        [Cord(xC: 1, yC: 1)], [Cord(xC: 2, yC: 1)], [Cord(xC: 2, yC: 2)], [Cord(xC: 0, yC: 2)],/* S */*/
        [ [1,5,9,13], [8,9,10,11], [1,5,9,13], [8,9,10,11] ], /* I */
        [ [5,6,9,10], [5,6,9,10], [5,6,9,10], [5,6,9,10] ],/* O */
        [ [5,9,10,14], [6,5,9,8], [5,9,10,14], [6,5,9,8] ],/* S */
        [ [6,10,9,13], [4,5,9,10], [6,10,9,13], [4,5,9,10] ],/* Z */
        [ [5,9,13,14], [4,5,6,8], [5,6,10,14], [6,8,9,10] ],/* L */
        [ [6,10,14,13], [4,8,9,10], [6,5,9,13], [4,5,6,10] ],/* J */
        [ [4,5,6,9], [6,10,14,9], [5,8,9,10], [5,9,13,10] ],/* T */
    ]
let CenterPoint = [2, -1, 2, 2, 2, 2, 2]// center i refer to TargetCoordinates[ CenterPoint[i] ]
let ColorType = [ #colorLiteral(red: 0.897996366, green: 0.8987259269, blue: 0.9176015258, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.7960784314, alpha: 1), #colorLiteral(red: 0.7568627451, green: 0.6392156863, blue: 0.8901960784, alpha: 1), #colorLiteral(red: 0.8509803922, green: 0.4823529412, blue: 0.4862745098, alpha: 1), #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1) ]
var UpdateTime:TimeInterval = 0.1//循环刷新的频率
var FallDownTime = 0.0 //目标落下的刷新时间
var Difficulty = 50.0 //难度
var TargetCoordinates = [Cord(xC: 0,yC: 0)]//目标的四个单元位置坐标
var TargetColor = 0
var TargetColorNext = 0
var TargetAfterRotationCoordinates = [Cord(xC: 0,yC: 0)]//目标的四个单元位置坐标
var Type = 0;//目标类型
var TypeNext = 0
var TargetAppearence = false//是否存在目标
var FastShiftDown = false
var GameStartTimes = 0
var PointUpdate = 0//分数的加成情况

//init target
var ShiftHorizontaltMove = 0
var ShifDownMove = 1
var RotationMove = 0
var RotationMoveNext = 0
//init start
var Screen = [false]//全部单元的情况
var ScreenColor = [0]
var FirstTarget = true//是否为第一个方块
var IfExit = false


class ViewController: UIViewController {

    override var shouldAutorotate: Bool{
        return false
    }
    var Point = 0
    {
        didSet
        {
            Points.text = "\(Point)"
        }
    }
    @IBOutlet weak var Points: UILabel!
    
    @IBOutlet var SingleBlock: [UIView]!
    
    @IBOutlet var NextTargetBlock: [UIView]!
    

    @IBAction func Exit(_ sender: Any) {
        IfExit = true
    }
    
    
    
    @IBAction func Button(_ sender: UIButton) {
        TargetAppearence = false
        AmountOfAllBlocks = self.SingleBlock.capacity
        BoardLimitLength = self.SingleBlock.capacity / BoardLimitWidth
        GameStartInit()
        let ThisGameRound = GameStartTimes
        UpdateTimer(ThisGameRound: ThisGameRound)
        return
    }
    
    @IBAction func LeftMove(_ sender: UIButton) {
        if(TargetAppearence == true){
            ShiftHorizontaltMove -= 1
        }
    }
    
    @IBAction func RightMove(_ sender: UIButton) {
        if(TargetAppearence == true){
            ShiftHorizontaltMove += 1
        }
    }
    
    @IBAction func DownMove(_ sender: UIButton) {
        if(TargetAppearence == true){
            ShifDownMove += DownMoveAmount
            FastShiftDown = true
        }
    }
    
    @IBAction func Place(_ sender: UIButton) {
        if(TargetAppearence == true){
            ShifDownMove += BoardLimitLength
            FastShiftDown = true
        }
    }
    
    
    @IBAction func Rotation(_ sender: UIButton) {//rotation around Corrdinate 3
        if(TargetAppearence == true){
            RotationMove += 1
        }
    }
    
    func GameStartInit() ->Void {//Start Initialization
        GameStartTimes += 1
        FirstTarget = true
        IfExit = false
        Point = 0
        if(GameStartTimes == 1){
            for _ in 1..<AmountOfAllBlocks{
                Screen.append(false)
                ScreenColor.append(0)
                
            }
            for _ in 1..<AmountOfTargetBlocks{
                TargetCoordinates.append( Cord(xC: 0,yC: 0) )
                TargetAfterRotationCoordinates.append(Cord(xC: 0, yC: 0))
            }
        }else{
            for index in 0..<AmountOfAllBlocks{
                Screen[index] = false
                ScreenColor[index] = 0
            }
        }
        //let AmountBlocks = BoardLimitWidth * (UpLimitation + 1)

        let Showlimits = BoardLimitWidth * (UpLimitation + 1)
        for index in 0..<Showlimits{
            self.SingleBlock[index].backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //white
        }
        
    }
    func TargetNextWindowInit() -> Void {
        for block in self.NextTargetBlock{
            block.backgroundColor = ColorType[0]
        }
       if FirstTarget == true{
            FirstTarget = false
        }
            let times =  NextTargetWindowLength * NextTargetWindowLength
            for index in 0..<times{
                self.NextTargetBlock[index].backgroundColor = ColorType[0]
            }
            for index in 0..<AmountOfTargetBlocks{
                self.NextTargetBlock[ NextWindowPosition[TypeNext][RotationMoveNext][index] ].backgroundColor = ColorType[TargetColorNext]
            }
        //}
        
    }
    
    func UpdateTimer(ThisGameRound : Int) ->Void{//looping Update
        
        if(ThisGameRound != GameStartTimes){//still in this game
            return
        }
        
        
        Timer.scheduledTimer(withTimeInterval: UpdateTime, repeats: true) { (ktimer) in
            
            if(PointUpdate > 0){
                self.Point += PointMul * PointUpdate * PointUpdate
                PointUpdate = 0
            }
            let Showlimits = BoardLimitWidth * (UpLimitation + 1)
            if(TargetAppearence == false){
                
                TargetInit()
                self.TargetNextWindowInit()
                
                for index in 0..<AmountOfAllBlocks{
                    if Screen[index] == true {
                        self.SingleBlock[index].backgroundColor = ColorType[ScreenColor[index]]
                    }else{
                        if(index >= Showlimits){
                            self.SingleBlock[index].backgroundColor = ColorType[0]
                        }
                    }
                }
                TargetAppearence = true
            }
            
            for CordIndex in 0..<AmountOfTargetBlocks{
                let index = CordTranstoIndex(CordIndex: CordIndex)
                if(index >= Showlimits){
                    self.SingleBlock[index].backgroundColor = ColorType[0]
                }
            }
            if(ThisGameRound == GameStartTimes && TargetAppearence == true ){
                if(FallDownTime >=  UpdateTime * Difficulty || ShifDownMove > 1){
                    update()
                    FallDownTime = 0
                }else{
                    FallDownTime += UpdateTime * 10
                }
                if(FastShiftDown == true){
                    update()
                    FastShiftDown = false
                }
                //update ShiftHorizontalMove
                ShiftHorizontaltMove = CorrectHorizontaltMove(ShiftHorizontaltMoveC: ShiftHorizontaltMove)
                for index in 0..<AmountOfTargetBlocks{
                    TargetCoordinates[index].x += ShiftHorizontaltMove
                }
                ShiftHorizontaltMove = 0
                AdjustmentShift()
                
                CorrectRotationMove()
                
            }
            
            
            for CordIndex in 0..<AmountOfTargetBlocks{
                let index = CordTranstoIndex(CordIndex: CordIndex)
                if(index >= Showlimits){
                    self.SingleBlock[index].backgroundColor = ColorType[TargetColor]
                }
            }

            if(ThisGameRound != GameStartTimes || IfExit == true){
                ktimer.invalidate()
                return
            }
            
        }
        
    }
}

func CordTranstoIndex(CordIndex:Int) ->Int{//Transform
    return TargetCoordinates[CordIndex].x + BoardLimitWidth * TargetCoordinates[CordIndex].y
}


func update() -> Void{
    let ShifDownMoveC = ShifDownMove
    //******
    
    for index in 0..<AmountOfTargetBlocks{
        let Limit = BoardLimitLength * BoardLimitWidth - 1
        var position = CordTranstoIndex(CordIndex: index) + BoardLimitWidth
        var distance = 0
        while position <= Limit {
            if( Screen[position] == true ){
                ShifDownMove = min( ShifDownMove,  distance)
                break
            }
            position += BoardLimitWidth
            distance += 1
        }
        if( position > Limit ){//detect into the last line
            ShifDownMove = min( ShifDownMove,  distance)
        }
    }
    
    
    //******
    for index in 0..<AmountOfTargetBlocks{
        TargetCoordinates[index].y += ShifDownMove
    }
    if(ShifDownMoveC != ShifDownMove){
        TargetAppearence = false
    }
    ShifDownMove = 1
}



func ShiftMove(LeftOrRight : Bool, Index: Int) ->Void{
    var ShiftAmount : Int
    if(LeftOrRight == true){//Shift Right
        ShiftAmount = 0 - TargetCoordinates[Index].x
    }else{
        ShiftAmount = BoardLimitWidth - 1 - TargetCoordinates[Index].x
    }
    for index in 0..<AmountOfTargetBlocks{
        TargetCoordinates[index].x += ShiftAmount
    }
}

func AdjustmentShift() -> Void{
    for index in 0..<AmountOfTargetBlocks{
        if(TargetCoordinates[index].x < 0){
            ShiftMove(LeftOrRight: true, Index: index)
        }
        if(TargetCoordinates[index].x >= BoardLimitWidth){
            ShiftMove(LeftOrRight: false, Index: index)
        }
    }
}

func UpLimitAdjustment() -> Void{//avoid targrt out of limit of uoscreen after rotation
    var ShiftAmount = 0
    for index in 0..<AmountOfTargetBlocks{
        if(TargetCoordinates[index].y < 0){
            ShiftAmount = 0 - TargetCoordinates[index].y
            for index2 in 0..<AmountOfTargetBlocks{
                TargetCoordinates[index2].y += ShiftAmount
            }
        }
    }
}

func UpdateScreen() -> Void {
    
    if( FirstTarget == true ){
        return
    }else{
        for index in 0..<AmountOfTargetBlocks{
            Screen[CordTranstoIndex(CordIndex: index)] = true
            ScreenColor[CordTranstoIndex(CordIndex: index)] = TargetColor
        }
        var y = BoardLimitLength - 1
        while y > 3 + Line{
            var IfDelete = true
            var x = 0
            while IfDelete && x<BoardLimitWidth {
                IfDelete = IfDelete && Screen[x + y * BoardLimitWidth]
                x += 1
            }
            if IfDelete {
                PointUpdate += 1
                var index = (y + 1) * BoardLimitWidth - 1
                while index >= BoardLimitWidth{
                    Screen[index] = Screen[index - BoardLimitWidth]
                    ScreenColor[index] = ScreenColor[index - BoardLimitWidth]
                    index -= 1
                }
                y += 1
            }
            y -= 1
        }
    }
}



func TargetInit()->Void{//target Initialization
    UpdateScreen()
    for index in 0..<BoardLimitWidth{
        if Screen[DeadLine * BoardLimitWidth + index] == true {
            GameStartTimes += 1
            return
        }
    }
    //Create a New Target
    let y = 0
    let x = Int(arc4random_uniform(UInt32(BoardLimitWidth))) //random appearence place of the target
    TargetCoordinates[0].x = x
    TargetCoordinates[0].y = y
    
    if(FirstTarget == true){
        Type = Int(arc4random_uniform(UInt32(AmountOfTypes)))//random type
        TargetColor = 1 + Int(arc4random_uniform(UInt32(ColorType.capacity - 1)))
        for index in 0..<(AmountOfTargetBlocks-1){
            TargetCoordinates[index+1].x = x + AllType[Type][index].x
            TargetCoordinates[index+1].y = y + AllType[Type][index].y
        }
        RotationMove = Int(arc4random_uniform(4))
    }else{
        Type = TypeNext
        TargetColor = TargetColorNext
        for index in 0..<(AmountOfTargetBlocks-1){
            TargetCoordinates[index+1].x = x + AllType[TypeNext][index].x
            TargetCoordinates[index+1].y = y + AllType[TypeNext][index].y
        }
        RotationMove = RotationMoveNext
    }
    TypeNext = Int(arc4random_uniform(UInt32(AmountOfTypes)))//random type
    TargetColorNext = 1 + Int(arc4random_uniform(UInt32(ColorType.capacity - 1)))
    RotationMoveNext = Int(arc4random_uniform(4))
    //adjustment
    AdjustmentShift()
    ShifDownMove = 1
    ShiftHorizontaltMove = 0
    
    CorrectRotationMove()
    for index in 0..<AmountOfTargetBlocks{
        TargetCoordinates[index].y -= BoardLimitLength
    }
    AdjustmentShift()
    UpLimitAdjustment()
    
    var UpLimitMove = BoardLimitLength
    for index in 0..<AmountOfTargetBlocks{
        UpLimitMove = min(UpLimitMove, UpLimitation - TargetCoordinates[index].y)
    }
    for index in 0..<AmountOfTargetBlocks{
        TargetCoordinates[index].y += UpLimitMove
    }
    
    RotationMove = 0
}

func CorrectHorizontaltMove (ShiftHorizontaltMoveC: Int) -> Int{
    if ShiftHorizontaltMoveC == 0{
        return 0
    }
    var  CorrectShiftHorizontaltMove = ShiftHorizontaltMoveC
    for index in 0..<AmountOfTargetBlocks{
        let x = TargetCoordinates[index].x
        let LeftLimit = TargetCoordinates[index].y * BoardLimitWidth
        let RightLimit = LeftLimit + BoardLimitWidth - 1
        if(ShiftHorizontaltMoveC < 0){
            var position = LeftLimit + x  - 1
            while position >= LeftLimit {
                if Screen[position] == true{
                    CorrectShiftHorizontaltMove = max( CorrectShiftHorizontaltMove, position - LeftLimit + 1 - x )
                    break
                }
                position -= 1
            }
        }else{
            var position = LeftLimit + x + 1
            while position <= RightLimit {
                if Screen[position] == true{
                    CorrectShiftHorizontaltMove = min( CorrectShiftHorizontaltMove, position - LeftLimit - 1 - x )
                    break
                }
                position += 1
            }
        }
    }
    return CorrectShiftHorizontaltMove //not out of limitation
}

func CorrectRotationMove () -> Void{
    RotationMove = RotationMove % 4
    if(RotationMove == 0 || CenterPoint[Type] == -1){
        return
    }
    let XCenter = TargetCoordinates[ CenterPoint[Type] ].x
    let YCenter = TargetCoordinates[ CenterPoint[Type] ].y
    var IfCorrect = true
    switch RotationMove {
    case 3:
        for index in 0..<AmountOfTargetBlocks{
            TargetAfterRotationCoordinates[index].x = XCenter + (TargetCoordinates[index].y - YCenter)
            TargetAfterRotationCoordinates[index].y = YCenter - (TargetCoordinates[index].x - XCenter)
            if(TargetAfterRotationCoordinates[index].y >= 0 && TargetAfterRotationCoordinates[index].y < BoardLimitLength && TargetAfterRotationCoordinates[index].x >= 0 && TargetCoordinates[index].x < BoardLimitWidth){
                if(Screen[ TargetAfterRotationCoordinates[index].x + TargetAfterRotationCoordinates[index].y * BoardLimitWidth ] == true){
                    IfCorrect = false
                    break
                }
            }
        }
        break
    case 2:
        for index in 0..<AmountOfTargetBlocks{
            TargetAfterRotationCoordinates[index].x = XCenter - (TargetCoordinates[index].x - XCenter)
            TargetAfterRotationCoordinates[index].y = YCenter - (TargetCoordinates[index].y - YCenter)
            if(TargetAfterRotationCoordinates[index].y >= 0 && TargetAfterRotationCoordinates[index].y < BoardLimitLength && TargetAfterRotationCoordinates[index].x >= 0 && TargetCoordinates[index].x < BoardLimitWidth){
                if(Screen[ TargetAfterRotationCoordinates[index].x + TargetAfterRotationCoordinates[index].y * BoardLimitWidth ] == true){
                    IfCorrect = false
                    break
                }
            }
        }
        break
    case 1:
        for index in 0..<AmountOfTargetBlocks{
            TargetAfterRotationCoordinates[index].x = XCenter - (TargetCoordinates[index].y - YCenter)
            TargetAfterRotationCoordinates[index].y = YCenter + (TargetCoordinates[index].x - XCenter)
            if(TargetAfterRotationCoordinates[index].y >= 0 && TargetAfterRotationCoordinates[index].y < BoardLimitLength && TargetAfterRotationCoordinates[index].x >= 0 && TargetCoordinates[index].x < BoardLimitWidth){
                if(Screen[ TargetAfterRotationCoordinates[index].x + TargetAfterRotationCoordinates[index].y * BoardLimitWidth ] == true){
                    IfCorrect = false
                    break
                }
            }
        }
        break
    default:
        return
    }


    if( IfCorrect == true ){
        for index in 0..<AmountOfTargetBlocks{
            TargetCoordinates[index].x = TargetAfterRotationCoordinates[index].x
            TargetCoordinates[index].y = TargetAfterRotationCoordinates[index].y
        }
        UpLimitAdjustment()
        AdjustmentShift()
    }
    RotationMove = 0
    return
    
    
}
