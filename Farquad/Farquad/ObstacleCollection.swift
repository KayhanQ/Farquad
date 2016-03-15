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
    let obWidth:CGFloat = 30
    var numObstaclesInRow = 0
    var velocity:CGFloat = 0

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
                let newObs = Obstacle(x: screenWidth, y: obs.position.y, width: obWidth, height: 50)
                self.addChild(newObs)
                obs.removeFromParent()
                
            }
        }
    }

    func setup() {

        populate(0, y: 500)
        populate(0, y: 50)
    }
    
    func populate(var x: CGFloat, y: CGFloat) {
        var array = [Obstacle]()
        let obHeight:CGFloat = 50;
        
        array.append(Obstacle(x:x, y:y, width: obWidth, height: obHeight))

        for _ in 1...numObstaclesInRow {
            x = x + obWidth
            let obs = Obstacle(x:x, y:y, width: obWidth, height: obHeight)
            array.append(obs)
        }
        
        for obs in array {
            self.addChild(obs)
        }
    }
    
}