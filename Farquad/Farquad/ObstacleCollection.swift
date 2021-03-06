//
//  ObstacleCollection.swift
//  Farquad
//
//  Created by Kayhan Qaiser on 2016-03-14.
//  Copyright © 2016 Paddy Crab. All rights reserved.
//

import Foundation
import SpriteKit

class ObstacleCollection: SKNode {
    
    let screenWidth: CGFloat = 1000
    let screenHeight: CGFloat = 600
    
    let obWidth:CGFloat = 25
    var numObstaclesInRow = 0
    var velocity:CGFloat = 0

    var direction = 1
    var caveHeight: CGFloat = 600
    var caveHeightDelta: CGFloat = -0.01
    var minCaveHeight: CGFloat = 450
    
    var obsHeightDelta: CGFloat = 5
    
    var minBotH: CGFloat = 10
    var maxBotH: CGFloat = 120

    var botHeight: CGFloat = 50
    
    var middleObsHeight: CGFloat = 140
    
    var wallCount = 0
    var numWallsBetweenMiddles = 35
    
    override init() {
        super.init()
        
        numObstaclesInRow = Int(screenWidth/obWidth)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        for obs in self.children as! [Obstacle] {
            obs.position.x -= velocity
            if obs.position.x < 0 {
                obs.removeFromParent()
                if obs.type == Obstacle.ObsType.WallTop {
                    addNext()
                }
            }
        }
        
        if caveHeight > minCaveHeight {
            caveHeight += caveHeightDelta
        }

        if Int.random(10) == 0 {
            obsHeightDelta = CGFloat.random(min: 4, max: 10)
        }
        maxBotH = screenHeight - caveHeight - 10
    }
    
    func addNext() {
        var tmpBotHeight:CGFloat = botHeight
        
        if Int.random(20) == 0 {
            tmpBotHeight += CGFloat.random(min: 40, max: 80)
        }
        
        tmpBotHeight += obsHeightDelta * CGFloat(direction)
        
        if tmpBotHeight < maxBotH && tmpBotHeight > minBotH {
            botHeight = tmpBotHeight
            if Int.random(10) == 0 {
                direction *= -1
            }
        }
        else {
            direction *= -1
        }
        
        
        let x: CGFloat = getLastX() + obWidth - velocity
        let bot = Obstacle(x: x, y: 0, width: obWidth, height: botHeight)
        bot.type = Obstacle.ObsType.WallBot
        self.addChild(bot)
        
        let topHeight = screenHeight - caveHeight - botHeight
        let top = Obstacle(x: bot.position.x, y: screenHeight-topHeight, width: obWidth, height: topHeight)
        top.type = Obstacle.ObsType.WallTop
        self.addChild(top)
        
        
        wallCount++
        
        if wallCount >= numWallsBetweenMiddles {
            let buffer:CGFloat = 10
            //crashed app
            let y = CGFloat.random(min: bot.position.y + botHeight + buffer, max: top.position.y-middleObsHeight-buffer)
            
            let middle = Obstacle(x: bot.position.x, y: y, width: obWidth, height: middleObsHeight)
            middle.type = Obstacle.ObsType.Middle
            self.addChild(middle)
            
            wallCount = 0
        }

    }
    
    func getLastX() -> CGFloat {
        return (self.children.last?.position.x)!
    }
    
    func getLastY() -> CGFloat {
        return (self.children.last?.position.y)!
    }
    
    func setup() {
        
        
        populate()
    }
    
    func populate() {
        var x: CGFloat = 0
        
        for _ in 1...numObstaclesInRow {
            let obsBot = Obstacle(x:x, y: 0, width: obWidth, height: botHeight)
            obsBot.type = Obstacle.ObsType.WallBot
            self.addChild(obsBot)
            
            let obsTop = Obstacle(x:x, y: screenHeight-botHeight, width: obWidth, height: botHeight)
            obsTop.type = Obstacle.ObsType.WallTop
            self.addChild(obsTop)
            x = x + obWidth
        }
        
        caveHeight = screenHeight - botHeight * 2
    }
    

}