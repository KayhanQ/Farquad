//
//  GameScene.swift
//  SKInvaders
//
//  Created by Riccardo D'Antoni on 15/07/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//


import Foundation
import SpriteKit


class SpaceScene: SKScene, SKPhysicsContactDelegate {
    
    // Game End
    var gameEnding: Bool = false
    var isLoaded = false
    let startVision = false
    
    let markerRadius: CGFloat = 60
    
    var visionTask = NSTask()

    // Contact
    var contactQueue = Array<SKPhysicsContact>()
    
    // Bitmask Categories
    let kInvaderCategory: UInt32 = 0x1 << 0
    let kShipFiredBulletCategory: UInt32 = 0x1 << 1
    let kShipCategory: UInt32 = 0x1 << 2
    let kSceneEdgeCategory: UInt32 = 0x1 << 3
    let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4
    
    // Bullet type
    enum BulletType {
        case ShipFired
        case InvaderFired
    }
    
    // Invader movement direction
    enum InvaderMovementDirection {
        case Down
        case Up
        case LeftThenUp
        case LeftThenDown
        case None
    }
    
    //1
    enum InvaderType {
        case A
        case B
        case C
    }
    
    //2
    let kInvaderSize = CGSize(width: 24, height: 18)
    let kInvaderGridSpacing = CGSize(width: 12, height: 9)
    let kInvaderRowCount = 12
    let kInvaderColCount = 12
    
    // 3
    let kInvaderName = "invader"
    
    // 4
    let kShipSize = CGSize(width: 30, height: 16)
    let kShipName = "ship"
    let kBoundingBoxName = "boundingBox"
    let kShipContainerName = "shipContainer"

    // 5
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    let kMarkersName = "markers"

    let kMinInvaderX: Float = 32.0
    
    
    // Score and Health
    var score: Int = 0
    var shipHealth: Float = 1.0
    
    // Bullets utils
    let kShipFiredBulletName = "shipFiredBullet"
    let kInvaderFiredBulletName = "invaderFiredBullet"
    let kBulletSize = CGSize(width:8, height: 4)
    
    // Private GameScene Properties
    
    var contentCreated: Bool = false
    
    // Invaders Properties
    var invaderMovementDirection: InvaderMovementDirection = .Up
    var timeOfLastMove: CFTimeInterval = 0.0
    var timePerMove: CFTimeInterval = 1.0
    let timePerMoveFactor: Double = 0.9

    // Queue
    var tapQueue: Array<Int> = []
    
    // Object Lifecycle Management
    
    // Scene Setup and Content Creation
    override func didMoveToView(view: SKView) {
        
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
            
            // SKScene responds to touches
            self.userInteractionEnabled = true
            
            self.physicsWorld.contactDelegate = self
        }
    }
    
    override func willMoveFromView(view: SKView) {
        print("Scene will be removed from view")
        
        if startVision {
            visionTask.terminate()
        }
    }
    
    func createMarkers() {
        
        let markers = SKNode()
        self.addChild(markers)
        markers.name = kMarkersName
        
        let topLeft = makeCircle()
        topLeft.position = CGPoint(x: markerRadius, y: self.frame.size.height - markerRadius)
        //topLeft.xScale = 1.1
        markers.addChild(topLeft)
        
        let botRight = makeCircle()
        botRight.position = CGPoint(x: self.frame.size.width - markerRadius, y: markerRadius)
        markers.addChild(botRight)
    }
    
    func makeCircle() -> SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: markerRadius)
        circle.fillColor = NSColor.redColor()
        circle.strokeColor = NSColor.redColor()

        return circle
    }
    
    
    func createContent() {
        self.backgroundColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0)

        physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        physicsBody!.categoryBitMask = kSceneEdgeCategory
        
        setupInvaders()
        
        setupShip()
        
        setupHud()
        
        if startVision {
            startVisionProcess()
        }
    }
    
    func startVisionProcess() {
        createMarkers()
        
        visionTask = NSTask()
        visionTask.launchPath = "/Users/kayhanacs/Library/Developer/Xcode/DerivedData/CollisionDetector-aryukpngkxwfkcexxmqhrsjavreg/Build/Products/Debug/CollisionDetector"
        
        let pipe = NSPipe()
        visionTask.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        var obs1 : NSObjectProtocol!
        obs1 = NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification,
            object: outHandle, queue: nil) {  notification -> Void in
                let data = outHandle.availableData
                if data.length > 0 {
                    self.calibrationCompleted()
                    if let str = NSString(data: data, encoding: NSUTF8StringEncoding) {
                        self.updateQuad(str as String)
                    }
                    outHandle.waitForDataInBackgroundAndNotify()
                } else {
                    print("EOF on stdout from process")
                    NSNotificationCenter.defaultCenter().removeObserver(obs1)
                }
        }
        
        visionTask.launch()
    }
    
    func calibrationCompleted() {
        if let markers = self.childNodeWithName(kMarkersName) {
            markers.removeFromParent()
        }
    }
    
    func recalibrate() {
        visionTask.terminate()
        startVisionProcess()
    }
    
    func updateQuad(string: String) {
        let stringArr = string.componentsSeparatedByString(" ")
        print("Rel coordinates \(string)")
        
        var floatArr = [Float]();
        
        for s in stringArr {
            let floatValue : Float = NSString(string: s).floatValue
            floatArr.append(floatValue)
        }
        
        let cgfloatArr = floatArr.map {
            CGFloat($0)
        }
        
        if cgfloatArr.count >= 4 {
            if let ship = self.childNodeWithName(kShipName) {
                let width = cgfloatArr[2] * self.frame.size.width
                let height = cgfloatArr[3] * self.frame.size.height
                
                let x = (cgfloatArr[0] + cgfloatArr[2]/2) * self.frame.size.width
                let y = (cgfloatArr[1] + cgfloatArr[3]/2) * self.frame.size.height
                
                ship.removeAllChildren()
                makeShip(ship, size: CGSize(width: width, height: height))
                ship.position = CGPoint(x: x, y: y)
                
                print("Actual coordinates \(ship.position)")
                let posLabel = self.childNodeWithName("posLabel") as! SKLabelNode
                posLabel.text = "position: \(ship.position)"
            }
        }
    }
    
    func loadInvaderTexturesOfType(invaderType: InvaderType) -> Array<SKTexture> {
        
        var prefix: String
        
        switch invaderType {
        case .A:
            prefix = "InvaderA"
        case .B:
            prefix = "InvaderB"
        case .C:
            prefix = "InvaderC"
        default:
            prefix = "InvaderC"
        }
        
        let name1 = prefix + "_00.png"
        let name2 = prefix + "_01.png"

        return [SKTexture(imageNamed: name1),
            SKTexture(imageNamed: name2)]
    }
    
    func makeInvaderOfType(invaderType: InvaderType) -> SKNode {
        
        let invaderTextures = self.loadInvaderTexturesOfType(invaderType)
        
        let invader = SKSpriteNode(texture: invaderTextures[0])
        invader.name = kInvaderName
        
        invader.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(invaderTextures, timePerFrame: self.timePerMove)))
        
        // invaders' bitmasks setup
        invader.physicsBody = SKPhysicsBody(rectangleOfSize: invader.frame.size)
        invader.physicsBody!.dynamic = false
        invader.physicsBody!.categoryBitMask = kInvaderCategory
        invader.physicsBody!.contactTestBitMask = 0x0
        invader.physicsBody!.collisionBitMask = 0x0
        
        return invader
    }
    
    
    func setupInvaders() {
        
        let baseOrigin = CGPointMake(self.frame.size.width - CGFloat(kInvaderRowCount)*(kInvaderSize.width+kInvaderGridSpacing.width) , self.frame.size.height/2 - CGFloat(kInvaderColCount)*(kInvaderSize.height+kInvaderGridSpacing.height)/2)
        
        for var row = 1; row <= kInvaderRowCount; row++ {
            
            var invaderType: InvaderType
            
            if row % 3 == 0 {
                invaderType = .A
            } else if row % 3 == 1 {
                invaderType = .B
            } else {
                invaderType = .C
            }
            
            let invaderPositionY = CGFloat(row) * (kInvaderSize.height * 2) + baseOrigin.y
            
            var invaderPosition = CGPointMake(baseOrigin.x, invaderPositionY)
            
            for var col = 1; col <= kInvaderColCount; col++ {
                let invader = self.makeInvaderOfType(invaderType)
                invader.position = invaderPosition
                self.addChild(invader)
                
                invaderPosition = CGPointMake(invaderPosition.x + kInvaderSize.width + kInvaderGridSpacing.width, invaderPositionY)
            }
        }
    }
    
    func setupShip() {
        
        let ship = SKNode()
        ship.name = kShipName
        
        makeShip(ship, size: CGSize(width: 200, height: 500))
        
        ship.position = CGPointMake(0,200)
        
        self.addChild(ship)
    }
    
    func makeShip(ship: SKNode, size: CGSize) {
        
        let box = SKShapeNode(rectOfSize: size)
        box.name = kBoundingBoxName
        box.fillColor = NSColor.greenColor()

        box.physicsBody = SKPhysicsBody(rectangleOfSize: box.frame.size)
        box.physicsBody!.dynamic = false
        box.physicsBody!.affectedByGravity = false
        box.physicsBody!.mass = 0.02
        box.physicsBody!.categoryBitMask = kShipCategory
        box.physicsBody!.contactTestBitMask = 0x0

        ship.addChild(box)

        //ship.physicsBody!.collisionBitMask = kSceneEdgeCategory
    }
    
    
    func setupHud() {
        
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = SKColor.greenColor()
        scoreLabel.text = String(format: "Score: %04u", 0)
        
        print(self.size.height)
        scoreLabel.position = CGPointMake(self.frame.size.width / 2, self.size.height - (40 + scoreLabel.frame.size.height/2))
        self.addChild(scoreLabel)
        
        let healthLabel = SKLabelNode(fontNamed: "Courier")
        
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 25
        
        healthLabel.fontColor = SKColor.greenColor()
        healthLabel.text = String(format: "Health: %.1f%%", self.shipHealth * 100.0)
        
        healthLabel.position = CGPointMake(self.frame.size.width / 2, self.size.height - (80 + healthLabel.frame.size.height / 2))
        self.addChild(healthLabel)
        
        let posLabel = SKLabelNode(fontNamed: "Courier")
        posLabel.name = "posLabel"
        posLabel.fontSize = 25
        posLabel.fontColor = SKColor.greenColor()
        posLabel.text = String(format: "Pos")
        posLabel.position = CGPointMake(self.frame.size.width / 2, 50)
        self.addChild(posLabel)
    }
    
    
    func makeBulletOfType(bulletType: BulletType) -> SKNode! {
        
        var bullet: SKNode!
        
        switch bulletType {
        case .ShipFired:
            bullet = SKSpriteNode(color: SKColor.greenColor(), size: kBulletSize)
            bullet.name = kShipFiredBulletName
            
            bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
            bullet.physicsBody!.dynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = kShipFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = kInvaderCategory
            bullet.physicsBody!.collisionBitMask = 0x0
            
        case .InvaderFired:
            bullet = SKSpriteNode(color: SKColor.magentaColor(), size: kBulletSize)
            bullet.name = kInvaderFiredBulletName
            
            bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
            bullet.physicsBody!.dynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = kInvaderFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = kShipCategory
            bullet.physicsBody!.collisionBitMask = 0x0
            
        default:
            bullet = nil
        }
        
        return bullet
    }
    
    
    // Scene Update
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if self.isGameOver() {
            self.endGame()
        }

        self.processContactsForUpdate(currentTime)
        
        self.moveInvadersForUpdate(currentTime)
        
        self.fireInvaderBulletsForUpdate(currentTime)
    }
    
    // Scene Update Helpers
    
    func moveInvadersForUpdate(currentTime: CFTimeInterval) {
        
        if (currentTime - self.timeOfLastMove < self.timePerMove) {
            return
        }
        
        // logic to change movement direction
        self.determineInvaderMovementDirection()
        
        enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            
            switch self.invaderMovementDirection {
            case .Down:
                node.position = CGPointMake(node.position.x, node.position.y + 10)
            case .Up:
                node.position = CGPointMake(node.position.x, node.position.y - 10)
            case .LeftThenDown, .LeftThenUp:
                node.position = CGPointMake(node.position.x - 10, node.position.y)
            case .None:
                break
            default:
                break
            }
            
            self.timeOfLastMove = currentTime
        }
    }
    
    override func keyDown(theEvent: NSEvent) {
        let key = theEvent.charactersIgnoringModifiers
        print("Key Pressed \(key)")
        
        if key == " " {
            self.fireShipBullets()
        }
        else if key == "R" {
            self.recalibrate()
        }
    }
    
    func fireInvaderBulletsForUpdate(currentTime: CFTimeInterval) {
        
        let existingBullet = self.childNodeWithName(kInvaderFiredBulletName)
        
        if existingBullet == nil {
            
            var allInvaders = Array<SKNode>()
            
            self.enumerateChildNodesWithName(kInvaderName) {
                node, stop in
                
                allInvaders.append(node)
            }
            
            if allInvaders.count > 0 {
                
                let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
                let invader = allInvaders[allInvadersIndex]
                let bullet = self.makeBulletOfType(.InvaderFired)
                bullet.position = CGPoint(x: invader.position.x, y: invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2)
                let bulletDestination = CGPoint(x: -(bullet.frame.size.width / 2), y: invader.position.y)
                self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 2.0, andSoundFileName: "InvaderBullet.wav")
            }
        }
    }
    
    func processContactsForUpdate(currentTime: CFTimeInterval) {
        
        for contact in self.contactQueue {
            self.handleContact(contact)
            
            if let index = (self.contactQueue as NSArray).indexOfObject(contact) as Int? {
                self.contactQueue.removeAtIndex(index)
            }
        }
    }
    
    // Invader Movement Helpers
    func adjustInvaderMovementToTimePerMove(newTimerPerMove: CFTimeInterval) {
        
        if newTimerPerMove <= 0 {
            return
        }
        
        let ratio: CGFloat = CGFloat(self.timePerMove / newTimerPerMove)
        self.timePerMove = newTimerPerMove
        
        enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            node.speed = node.speed * ratio
        }
    }
    
    func determineInvaderMovementDirection() {
        
        var proposedMovementDirection: InvaderMovementDirection = self.invaderMovementDirection
        
        enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            
            switch self.invaderMovementDirection {
                
            case .Down:
                if (CGRectGetMaxY(node.frame) >= node.scene!.size.height - 1.0) {
                    proposedMovementDirection = .LeftThenUp
                    
                    stop.memory = true
                }
            case .Up:
                if (CGRectGetMinY(node.frame) <= 1.0) {
                    proposedMovementDirection = .LeftThenDown
                    
                    stop.memory = true
                }
                
            case .LeftThenUp:
                proposedMovementDirection = .Up
                
                self.adjustInvaderMovementToTimePerMove(self.timePerMove * self.timePerMoveFactor)
                
                stop.memory = true
                
            case .LeftThenDown:
                proposedMovementDirection = .Down
                
                self.adjustInvaderMovementToTimePerMove(self.timePerMove * self.timePerMoveFactor)
                
                stop.memory = true
                
            default:
                break
                
            }
        }
        
        if (proposedMovementDirection != self.invaderMovementDirection) {
            self.invaderMovementDirection = proposedMovementDirection
        }
    }
    
    
    // Bullet Helpers
    
    func fireBullet(bullet: SKNode, toDestination destination:CGPoint, withDuration duration:CFTimeInterval, andSoundFileName soundName: String) {
        
        let bulletAction = SKAction.sequence([SKAction.moveTo(destination, duration: duration), SKAction.waitForDuration(3.0/60.0), SKAction.removeFromParent()])
        
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        bullet.runAction(SKAction.group([bulletAction, soundAction]))
        
        self.addChild(bullet)
    }
    
    func fireShipBullets() {
        
        let existingBullet = self.childNodeWithName(kShipFiredBulletName)
        
        if existingBullet == nil {
            
            if let ship = self.childNodeWithName(kShipName) {
                
                if let bullet = self.makeBulletOfType(.ShipFired) {
                    
                    bullet.position = CGPoint(x: ship.position.x + ship.frame.size.width/2 - bullet.frame.size.width / 2, y: ship.position.y)
                    
                    let bulletDestination = CGPoint(x: self.frame.size.width, y: bullet.position.y)
                    
                    self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav")
                    
                }
            }
        }
    }
    
    // HUD Helpers
    
    func adjustScoreBy(points: Int) {
        
        self.score += points
        
        let score = self.childNodeWithName(kScoreHudName) as! SKLabelNode
        
        score.text = String(format: "Score: %04u", self.score)
    }
    
    func adjustShipHealthBy(healthAdjustment: Float) {
        
        // 1
        self.shipHealth = max(self.shipHealth + healthAdjustment, 0)
        
        let health = self.childNodeWithName(kHealthHudName) as! SKLabelNode
        
        health.text = String(format: "Health: %.1f%%", self.shipHealth * 100)
        
    }
    
    // Physics Contact Helpers
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if contact as SKPhysicsContact? != nil {
            self.contactQueue.append(contact)
        }
    }
    
    func handleContact(contact: SKPhysicsContact) {
        
        // Ensure you haven't already handled this contact and removed its nodes
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil) {
            return
        }
        
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        
        if (nodeNames as NSArray).containsObject(kBoundingBoxName) && (nodeNames as NSArray).containsObject(kInvaderFiredBulletName) {
            
            // Invader bullet hit a ship
            self.runAction(SKAction.playSoundFileNamed("ShipHit.wav", waitForCompletion: false))
            
            self.adjustShipHealthBy(-0.334)
            
            if self.shipHealth <= 0.0 {
                
                contact.bodyA.node!.removeFromParent()
                contact.bodyB.node!.removeFromParent()
                
                let ship = self.childNodeWithName(kShipName)
                ship?.removeFromParent()
            } else {
                
                let ship = self.childNodeWithName(kShipName)
                
                ship!.alpha = CGFloat(self.shipHealth)
                
                // remove the bullet
                if  kBoundingBoxName == contact.bodyA.node?.name {
                    contact.bodyB.node!.removeFromParent()
                }
                else {
                    contact.bodyA.node!.removeFromParent()
                }
            }
            
        } else if (nodeNames as NSArray).containsObject(kInvaderName) && (nodeNames as NSArray).containsObject(kShipFiredBulletName) {
            
            // Ship bullet hit an invader
            self.runAction(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false))
            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
            
            self.adjustScoreBy(100)
        }
    }

    // Game End Helpers
    
    func isGameOver() -> Bool {
        
        let invader = self.childNodeWithName(kInvaderName)
        
        var invaderHasInvaded = false
        
        enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            
            if Float(CGRectGetMinX(node.frame)) <= self.kMinInvaderX {
                
                invaderHasInvaded = true
                stop.memory = true
            }
        }
        
        let ship = self.childNodeWithName(kShipName)
        
        return invader == nil || invaderHasInvaded || ship == nil
    }
    
    func endGame() {
        if !self.gameEnding {
            
            self.gameEnding = true
            
            let gameOverScene: GameOverScene = GameOverScene(size: self.size)
            
            view!.presentScene(gameOverScene, transition: SKTransition.doorsOpenHorizontalWithDuration(1.0))
        }
    }
    
    
    
}
