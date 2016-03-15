//
//  Obstacle.swift
//  Farquad
//
//  Created by Kayhan Qaiser on 2016-03-14.
//  Copyright © 2016 Paddy Crab. All rights reserved.
//

import Foundation
import SpriteKit

class Obstacle: SKNode {
    
    var leftGoalX: CGFloat!
    var rightGoalX: CGFloat!
    
    init(x:CGFloat, y:CGFloat, width: CGFloat, height: CGFloat) {
        super.init()
        
        let rect = SKShapeNode(rect: CGRect(x: 0, y: 0, width: width, height: height))
        rect.fillColor = NSColor.whiteColor()
        self.addChild(rect)
        
        self.position = CGPoint(x: x, y: y)
        
        //rect.physicsBody = SKPhysicsBody(rectangleOfSize: rect.frame.size)
        //setup()
        
    }
    
    func setup() {
        let frame = self.calculateAccumulatedFrame()
        
        let screenWidth:CGFloat = 1000
        let screenHeight:CGFloat = 700
        
        let width:CGFloat = 800
        let height:CGFloat = 500
        let thickness:CGFloat = 20
        let goalSize:CGFloat = 150
        
        let xMargin:CGFloat = (screenWidth - width) / 2
        let yMargin:CGFloat = (screenHeight - height) / 2
        
        let tL:CGPoint = CGPoint(x: xMargin, y: yMargin + height)
        let tR:CGPoint = CGPoint(x: xMargin + width, y: yMargin + height)
        let bL:CGPoint = CGPoint(x: xMargin, y: yMargin)
        let bR:CGPoint = CGPoint(x: xMargin + width, y: yMargin)
        
        leftGoalX = tL.x - 20
        rightGoalX = tR.x + 20
        
        let gtY:CGFloat = screenHeight/2 + goalSize/2
        let gbY:CGFloat = screenHeight/2 - goalSize/2
        
        let tPath = CGPathCreateMutable()
        CGPathMoveToPoint(tPath, nil, xMargin, gtY)
        CGPathAddLineToPoint(tPath, nil, tL.x, tL.y)
        CGPathAddLineToPoint(tPath, nil, tR.x, tR.y)
        CGPathAddLineToPoint(tPath, nil, width + xMargin, gtY)
        
        let top = SKShapeNode(path: tPath)
        
        top.strokeColor = NSColor.whiteColor()
        self.addChild(top)
        top.physicsBody = SKPhysicsBody(edgeChainFromPath: tPath)
        top.physicsBody?.friction = 0
        
        
        let bPath = CGPathCreateMutable();
        CGPathMoveToPoint(bPath, nil, xMargin, gbY)
        CGPathAddLineToPoint(bPath, nil, bL.x, bL.y)
        CGPathAddLineToPoint(bPath, nil, bR.x, bR.y)
        CGPathAddLineToPoint(bPath, nil, xMargin + width, gbY)
        
        let bottom = SKShapeNode(path: bPath)
        self.addChild(bottom)
        bottom.physicsBody = SKPhysicsBody(edgeChainFromPath: bPath)
        bottom.physicsBody?.friction = 0
        
        
        
        
        //
        //        let gMX: CGFloat = 20
        //        let gDHeight: CGFloat = 30 + goalSize
        //
        //        let lGDPath = CGPathCreateMutable();
        //        CGPathMoveToPoint(lGDPath, nil, xMargin - gMX, screenHeight/2 - gDHeight/2)
        //        CGPathAddLineToPoint(lGDPath, nil, xMargin - gMX, screenHeight/2 + gDHeight/2)
        //
        //        let lGD = SKShapeNode(path: lGDPath)
        //        lGD.name = "leftGoal"
        //        self.addChild(lGD)
        //        lGD.physicsBody = SKPhysicsBody(edgeChainFromPath: lGDPath)
        //        lGD.physicsBody?.friction = 0
        //
        //
        //        let border = SKShapeNode(rect: CGRect(x: 100, y: 100, width: width, height: height))
        //        border.strokeColor = NSColor.whiteColor()
        //        self.addChild(border)
        //
        //        border.physicsBody = SKPhysicsBody(edgeLoopFromRect: border.frame)
        //        border.physicsBody?.friction = 0;
        
        
        
        
    }    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}