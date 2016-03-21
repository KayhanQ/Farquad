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
    
    var quadrotor = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 10, height: 10))
    
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
        obstacles.velocity = 5
        
        quadrotor.fillColor = NSColor.blueColor()
        self.addChild(quadrotor)

    }
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        let trackingArea = NSTrackingArea(rect: view.frame, options: [NSTrackingAreaOptions.MouseMoved, NSTrackingAreaOptions.ActiveInKeyWindow], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        
        setup()
        
        
    }

    func testBridge() {
        //CPP_Wrapper().helloWorld_cpp_wrapped()
        //CPP_Wrapper().hello_cpp_wrapped("Hello everyone")
        
        CPP_Wrapper().hasCollided_wrapped();
        
        let string = CPP_Wrapper().getQuadBox_wrapped();
        let stringArr = string.componentsSeparatedByString(" ");

        var floatArr = [Float]();
        
        for s in stringArr {
            let floatValue : Float = NSString(string: s).floatValue
            floatArr.append(floatValue)
        }
        
        let cgfloatArr = floatArr.map {
            CGFloat($0)
        }
        
        print(string);

        if cgfloatArr.count >= 4 {
            quadrotor = SKShapeNode(rect: CGRect(x: cgfloatArr[0], y: cgfloatArr[1], width: cgfloatArr[2], height: cgfloatArr[3]))
        }
        
        
        //print("Collided is \(CPP_Wrapper().hasCollided_wrapped())")
    }
    
    override func update(currentTime: NSTimeInterval) {

        obstacles.update()
        
        testBridge()

    }
    
}