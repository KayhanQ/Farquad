//
//  GameScene.swift
//  Farquad
//
//  Created by Kayhan Qaiser on 2016-03-14.
//  Copyright (c) 2016 Paddy Crab. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Start Space Invaders")
        myLabel.text = "Start Farquad";
        myLabel.fontSize = 45;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)
    }
    
    override func mouseDown(theEvent: NSEvent) {
        
        //let secondScene = MainScene(size: self.size)
        let secondScene = SpaceScene(size: self.size)
        
        let transition = SKTransition.flipVerticalWithDuration(1.0)
        secondScene.scaleMode = SKSceneScaleMode.AspectFit
        self.scene!.view?.presentScene(secondScene, transition: transition)
        
        
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }}
