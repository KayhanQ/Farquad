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
    var caveHeight: CGFloat = 400
    var deltaH: CGFloat = 8.6
    var minBotH: CGFloat = 10
    var maxBotH: CGFloat = 80

    var botHeight: CGFloat = 50
    
    override init() {
        super.init()
        
        numObstaclesInRow = Int(screenWidth/obWidth)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        for obs in self.children {
            obs.position.x -= velocity
            if obs.position.x < 0 {
                obs.removeFromParent()
                if obs.name == "top" {
                    addNext()
                }
            }

        }
    }

    func addNext() {
        //let topY = getLastY()
        
        if botHeight > maxBotH || botHeight < minBotH {
            direction *= -1
        }
        
        botHeight += deltaH * CGFloat(direction)
        
        let bot = Obstacle(x: screenWidth, y: 0, width: obWidth, height: botHeight)
        bot.name = "bot"
        self.addChild(bot)
        
        let topHeight = screenHeight - caveHeight - botHeight
        let top = Obstacle(x: screenWidth, y: screenHeight-topHeight, width: obWidth, height: topHeight)
        top.name = "top"
        self.addChild(top)
        

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
            obsBot.name = "bot"
            self.addChild(obsBot)
            
            let obsTop = Obstacle(x:x, y: screenHeight-botHeight, width: obWidth, height: botHeight)
            obsTop.name = "top"
            self.addChild(obsTop)
            x = x + obWidth
        }
        
        caveHeight = screenHeight - botHeight * 2
    }
    
    
//    func populate(var x: CGFloat, y: CGFloat) {
//        var array = [Obstacle]()
//        
//        array.append(Obstacle(x:x, y:y, width: obWidth, height: obHeight))
//
//        for _ in 1...numObstaclesInRow {
//            x = x + obWidth
//            let obs = Obstacle(x:x, y:y, width: obWidth, height: obHeight)
//            array.append(obs)
//        }
//        
//        for obs in array {
//            self.addChild(obs)
//        }
//    }
    
}