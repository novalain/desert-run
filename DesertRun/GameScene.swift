//
//  GameScene.swift
//  EndlessWorlds
//
//  Created by Justin Dike on 5/20/15.
//  Copyright (c) 2015 CartoonSmart. All rights reserved.
//

import SpriteKit


enum BodyType:UInt32 {
    
    case player = 1
    case platformObject = 2
    case deathObject = 4
    case wheelObject = 8
    case ground = 16
    case water = 32
    case moneyObject = 64
    
}



enum LevelType:UInt32 {
    
    case ground, water
    
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let swipeRightRec = UISwipeGestureRecognizer()
    
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    
    
    var levelUnitCounter:CGFloat = 0
    var levelUnitWidth:CGFloat = 0
    var levelUnitHeight:CGFloat = 0
    var initialUnits:Int = 2

    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0
    let worldNode:SKNode = SKNode()
    let thePlayer:Player = Player(imageNamed: "ogre_run1")
    
    let loopingBG:SKSpriteNode = SKSpriteNode(imageNamed: "Looping_BG")
    let loopingBG2:SKSpriteNode = SKSpriteNode(imageNamed: "Looping_BG")
   
    
    var levelUnitCurrentlyOn:LevelUnit?
    
    var isDead:Bool = false
   
    var onPlatform:Bool = false
    var currentPlatform:SKSpriteNode?
    
    
    let startingPosition:CGPoint = CGPointMake(50, 0)
    
   
    
    
   // var nodeToMove:Object?
    // var moveInProgress:Bool = false
    
    
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        
        swipeRightRec.addTarget(self, action:#selector(GameScene.swipedRight))
        swipeRightRec.direction = .Right
        self.view!.addGestureRecognizer(swipeRightRec)
        
        
        swipeUpRec.addTarget(self, action: #selector(GameScene.swipedUp))
        swipeUpRec.direction = .Up
        self.view!.addGestureRecognizer(swipeUpRec)
        
        swipeDownRec.addTarget(self, action: #selector(GameScene.swipedDown))
        swipeDownRec.direction = .Down
        self.view!.addGestureRecognizer(swipeDownRec)
        
        
        self.backgroundColor = SKColor.whiteColor()
        screenWidth = self.view!.bounds.width
        screenHeight = self.view!.bounds.height
        
        levelUnitWidth = screenWidth
        levelUnitHeight = screenHeight
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx:-1, dy:-9.8)
        
    
        self.anchorPoint = CGPointMake(0.5, 0.5)
       
       addChild(worldNode)
        
        worldNode.addChild(thePlayer)
        thePlayer.position = startingPosition
        thePlayer.zPosition = 101
        
       addLevelUnits()
        
        
        addChild(loopingBG)
        addChild(loopingBG2)
        
        loopingBG.zPosition = -200
        loopingBG2.zPosition = -200
        
        loopingBG.yScale = 1.1
        loopingBG2.yScale = 1.1
        
        
        startLoopingBackground()
       
    }
    
    
    func startLoopingBackground(){
        
       resetLoopingBackground()
        
        let move:SKAction = SKAction.moveByX(-loopingBG2.size.width, y: 0, duration: 20)
        let moveBack:SKAction = SKAction.moveByX(loopingBG2.size.width, y: 0, duration: 0)
        let seq:SKAction = SKAction.sequence([move, moveBack])
        let `repeat`:SKAction = SKAction.repeatActionForever(seq)
        
        loopingBG.runAction(`repeat`)
        loopingBG2.runAction(`repeat`)
        
        
    }
    
    
    
    
    func swipedRight(){
        
        
        thePlayer.glide()
        
        
    }
    
  
    
    func swipedDown(){
        
      
        if (thePlayer.isGliding == true) {
            
             thePlayer.stopGlide()
        } else if (onPlatform == true){
            
            thePlayer.stopGlide()
            currentPlatform?.physicsBody = nil
            
        }
        
        
        // also later we will setup dropping through a platform
        
    }
    
    
    func swipedUp(){
        
       
         thePlayer.jump()
        
    }

    
    
    func resetLevel(){
        
        worldNode.enumerateChildNodesWithName("levelUnit" ) {
            node, stop in
            
            node.removeFromParent()
            
            
        }
        
        
       levelUnitCounter = 0
        addLevelUnits()
        
        
    }
    
    
   
    
    
    func addLevelUnits(){
        
        // was...
        // for (var i = 0; i < initialUnits; i += 1) {
        
        for _ in 0 ..< initialUnits {
        
        
            
            createLevelUnit()
           
        }
        
        
        
    }
    
    
    
    
    func createLevelUnit() {
        
        let yLocation:CGFloat = 0
        let xLocation:CGFloat = levelUnitCounter * levelUnitWidth
        
        
        let levelUnit:LevelUnit = LevelUnit()
        worldNode.addChild(levelUnit)
        levelUnit.zPosition = -1
        levelUnit.levelUnitWidth = levelUnitWidth
        levelUnit.levelUnitHeight = levelUnitHeight
        
        if (levelUnitCounter < 2) {
            
            levelUnit.isFirstUnit = true
        }
        
         
        levelUnit.setUpLevel()
        
        levelUnit.position = CGPointMake( xLocation , yLocation)
        
       levelUnitCounter++
        
        
    }
    
    
    
    
   
    
    
    func clearNodes(){
        
        
        var nodeCount:Int = 0
        
        worldNode.enumerateChildNodesWithName("levelUnit") {
            node, stop in
            
            
            let nodeLocation:CGPoint = self.convertPoint(node.position, fromNode: self.worldNode)
            
            if ( nodeLocation.x < -(self.screenWidth / 2) - self.levelUnitWidth ) {
                
                node.removeFromParent()
                
                
            }  else {
                
                nodeCount += 1
                
                
            }
            
        
            
        }
        
        print( "levelUnits in the scene is \(nodeCount)")
        
        
    }
    
    
   
    
    
    
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        
        let nextTier:CGFloat = (levelUnitCounter * levelUnitWidth) - (CGFloat(initialUnits) * levelUnitWidth)
        
        if (thePlayer.position.x > nextTier) {
            
            createLevelUnit()
        }
        
        

        
        clearNodes()
        
        

        
        if ( isDead == false) {
            
            thePlayer.update()
            
        }
        
        
        
    }
    
    
    override func didSimulatePhysics() {
        

        self.centerOnNode(thePlayer)
        
       
        
        
    }
    
    
   
    
    
    
    func centerOnNode(node:SKNode) {
        
        let cameraPositionInScene:CGPoint = self.convertPoint(node.position, fromNode: worldNode)
        worldNode.position = CGPoint(x: worldNode.position.x - cameraPositionInScene.x , y:0 )
        
      
        
    }
    
    
    
    
    
 
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        
       // let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        
        
  
        /// deathObject and player
        
        
        if (contact.bodyA.categoryBitMask == BodyType.player.rawValue  && contact.bodyB.categoryBitMask == BodyType.deathObject.rawValue ) {
            
            if (thePlayer.isAttacking == false) {
            
            killPlayer()
                
            } else {
                
                contact.bodyB.node?.parent!.removeFromParent()
            }
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.deathObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.player.rawValue ) {
            
            
            if (thePlayer.isAttacking == false) {
                
                killPlayer()
                
            } else {
                
                contact.bodyA.node?.parent!.removeFromParent()
            }
            
        }
        
        
        /// wheelObject and player
        
        
        if (contact.bodyA.categoryBitMask == BodyType.player.rawValue  && contact.bodyB.categoryBitMask == BodyType.wheelObject.rawValue ) {
            
            killPlayer()
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.wheelObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.player.rawValue ) {
            
            
            killPlayer()
            
        }
        
        /// water and player
        
        
        if (contact.bodyA.categoryBitMask == BodyType.player.rawValue  && contact.bodyB.categoryBitMask == BodyType.water.rawValue ) {
            
            killPlayer()
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.water.rawValue  && contact.bodyB.categoryBitMask == BodyType.player.rawValue ) {
            
            
            killPlayer()
            
        }
        
        // make sure two death objects aren't too close to each other
        
        
        if (contact.bodyA.categoryBitMask == BodyType.deathObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.deathObject.rawValue ) {
            
            
            contact.bodyA.node?.parent!.removeFromParent()
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.deathObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.deathObject.rawValue ) {
            
            
            contact.bodyA.node?.parent!.removeFromParent()
            
        }
        
        
        // make sure two wheelObjects aren't on each other
        
        
        
        if (contact.bodyA.categoryBitMask == BodyType.wheelObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.wheelObject.rawValue ) {
            
            
            contact.bodyA.node?.parent!.removeFromParent()
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.wheelObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.wheelObject.rawValue ) {
            
            
            contact.bodyA.node?.parent!.removeFromParent()
            
        }
        
        // make sure if wheel hits death object the wheel is destroyed
        
        
        if (contact.bodyA.categoryBitMask == BodyType.wheelObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.deathObject.rawValue ) {
            
            
            contact.bodyB.node?.parent!.removeFromParent()
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.deathObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.wheelObject.rawValue ) {
            
            
            contact.bodyA.node?.parent!.removeFromParent()
            
        }
        
        
        
        // collect Money
        
        
        if (contact.bodyA.categoryBitMask == BodyType.moneyObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.player.rawValue ) {
            
            
            contact.bodyA.node?.parent!.removeFromParent()
            
            // insert code to tally up variable for collecting money
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.player.rawValue  && contact.bodyB.categoryBitMask == BodyType.moneyObject.rawValue ) {
            
            
            contact.bodyB.node?.parent!.removeFromParent()
            
            // insert code to tally up variable for collecting money
            
        }

        
        // switch body to non dynamic
        
        
        if (contact.bodyA.categoryBitMask == BodyType.ground.rawValue  && contact.bodyB.categoryBitMask == BodyType.deathObject.rawValue ) {
            
            
            contact.bodyB.node?.physicsBody!.dynamic = false
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.deathObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.ground.rawValue ) {
            
            
            contact.bodyA.node?.physicsBody!.dynamic = false
            
        }
        
        
        // if the player hits the ground....
        
        
        if (contact.bodyA.categoryBitMask == BodyType.ground.rawValue  && contact.bodyB.categoryBitMask == BodyType.player.rawValue ) {
            
            
            thePlayer.physicsBody?.dynamic = true
            if ( thePlayer.isRunning == false) {
                
                thePlayer.startRun()
                
            }
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.player.rawValue  && contact.bodyB.categoryBitMask == BodyType.ground.rawValue ) {
            
            
            thePlayer.physicsBody?.dynamic = true
            if ( thePlayer.isRunning == false) {
                
                thePlayer.startRun()
                
            }
            
        }
        
        
        // destroy object if it goes in water
        
        
        if (contact.bodyA.categoryBitMask == BodyType.deathObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.water.rawValue ) {
            
            
            contact.bodyA.node?.parent!.removeFromParent()
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.water.rawValue  && contact.bodyB.categoryBitMask == BodyType.deathObject.rawValue ) {
            
            
            contact.bodyB.node?.parent!.removeFromParent()
            
        }
        
        
        // destroy object if it goes in water
        
        
        if (contact.bodyA.categoryBitMask == BodyType.wheelObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.water.rawValue ) {
            
            
            contact.bodyA.node?.parent!.removeFromParent()
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.water.rawValue  && contact.bodyB.categoryBitMask == BodyType.wheelObject.rawValue ) {
            
            
            contact.bodyB.node?.parent!.removeFromParent()
            
        }
        
        
        //// check if on Platform Object
        
        if (contact.bodyA.categoryBitMask == BodyType.player.rawValue  && contact.bodyB.categoryBitMask == BodyType.platformObject.rawValue ) {
            
            onPlatform = true
            currentPlatform =  contact.bodyB.node! as? SKSpriteNode
            
            thePlayer.physicsBody?.dynamic = true
            
            if ( thePlayer.isRunning == false) {
                
                thePlayer.startRun()
                
            }
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.platformObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.player.rawValue ) {
            
            onPlatform = true
            currentPlatform =  contact.bodyA.node! as? SKSpriteNode
            
            thePlayer.physicsBody?.dynamic = true
            
            if ( thePlayer.isRunning == false) {
                
                thePlayer.startRun()
                
            }
            
        }
        
        
        
        
        
    }
    
    

    
    
    
    
    
 
    func didEndContact(contact: SKPhysicsContact) {
        
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch (contactMask) {
            
            
            
        case BodyType.platformObject.rawValue | BodyType.player.rawValue:
            
           onPlatform = false 
            
           
            
        default:
            return
            
            
        }
    }

    
    
    func killPlayer() {
        
        
        if ( isDead == false) {
            
            isDead = true
            
            loopingBG.removeAllActions()
            loopingBG2.removeAllActions()
            
            thePlayer.physicsBody!.dynamic = false
            
            let fadeOut:SKAction = SKAction.fadeAlphaTo(0, duration: 0.2)
            let move:SKAction = SKAction.moveTo(startingPosition, duration: 0.0)
            let block:SKAction = SKAction.runBlock(revivePlayer)
            let seq:SKAction = SKAction.sequence([fadeOut, move, block])
            
            thePlayer.runAction(seq)
            
            
            let fadeOutBG:SKAction = SKAction.fadeAlphaTo(0, duration: 0.2)
            let blockBG:SKAction = SKAction.runBlock(resetLoopingBackground)
            let fadeInBG:SKAction = SKAction.fadeAlphaTo(1, duration: 0.2)
            let seqBG:SKAction = SKAction.sequence([fadeOutBG, blockBG, fadeInBG])
            loopingBG.runAction(seqBG)
            loopingBG2.runAction(seqBG)
            
            
            
        }
        
        
        
    }
    
    func revivePlayer() {
      
        //will fade out worldNode and reset the level with new units
        
        
        let fadeOut:SKAction = SKAction.fadeAlphaTo(0, duration: 0.2)
        let block:SKAction = SKAction.runBlock(resetLevel)
        let fadeIn:SKAction = SKAction.fadeAlphaTo(1, duration: 0.2)
        let seq:SKAction = SKAction.sequence([fadeOut, block, fadeIn])
        worldNode.runAction(seq)
        
        
        // fade in player and revive
        
        let wait:SKAction = SKAction.waitForDuration(1)
        let fadeIn2:SKAction = SKAction.fadeAlphaTo(1, duration: 0.2)
        let block2:SKAction = SKAction.runBlock(noLongerDead)
        let seq2:SKAction = SKAction.sequence([wait , fadeIn2, block2])
        thePlayer.runAction(seq2)
        
    }
    
    
    
    func noLongerDead() {
        
        isDead = false
        
        thePlayer.startRun()

        startLoopingBackground()
        
        thePlayer.physicsBody!.dynamic = true
        
    }
    
    
    func resetLoopingBackground(){
        
        loopingBG.position = CGPointMake(0, 0)
        loopingBG2.position = CGPointMake(loopingBG2.size.width - 3, 0)
        
    }
    
    
    
}











