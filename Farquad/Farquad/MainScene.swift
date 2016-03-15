//
//  MainScene.swift
//  Farquad
//
//  Created by Kayhan Qaiser on 2016-03-14.
//  Copyright © 2016 Paddy Crab. All rights reserved.
//

import Foundation
import SpriteKit

class MainScene: SKScene {
    
    var obstacles = ObstacleCollection()
    
//    override init() {
//        super.init()
//
//        setup()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
    
    
    func setup() {
        self.addChild(obstacles)
        obstacles.velocity = 1
    }
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        let trackingArea = NSTrackingArea(rect: view.frame, options: [NSTrackingAreaOptions.MouseMoved, NSTrackingAreaOptions.ActiveInKeyWindow], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        
        setup()
    }

    
    override func update(currentTime: NSTimeInterval) {

        obstacles.update()
        
        
    }
    
}