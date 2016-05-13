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
    case bullet = 128
    
}

enum LevelType:UInt32 {
    
    case ground, water
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    let tapRec = UITapGestureRecognizer();
    
    let worldNode:SKNode = SKNode()
    let thePlayer:Player = Player(imageNamed: "bro_walk0001") // fix
    var playerBullet = Bullet(pos: CGPointMake(5000, 5000)); // ugly, not spawn on screen until shot

    let loopingBG:SKSpriteNode = SKSpriteNode(imageNamed: "Looping_BG")
    let loopingBG2:SKSpriteNode = SKSpriteNode(imageNamed: "Looping_BG")
    
    var levelUnitCounter:CGFloat = 0
    var levelUnitWidth:CGFloat = 0
    var levelUnitHeight:CGFloat = 0
    var initialUnits:Int = 2
    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0
    var levelUnitCurrentlyOn:LevelUnit?
    var isDead:Bool = false
    var onPlatform:Bool = false
    var currentPlatform:SKSpriteNode?
    
    let playerStartingPos:CGPoint = CGPointMake(50, 0)

    override func didMoveToView(view: SKView) {
        
        setUpSwipeHandlers();
        
        self.backgroundColor = SKColor.whiteColor()
        screenWidth = self.view!.bounds.width
        screenHeight = self.view!.bounds.height
        
        levelUnitWidth = screenWidth
        levelUnitHeight = screenHeight
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx:-0.5, dy:-9.8)
        
        // Move origin to center
        self.anchorPoint = CGPointMake(0.5, 0.5)
       
        addChild(worldNode)
        
        worldNode.addChild(thePlayer)
        thePlayer.position = playerStartingPos
        thePlayer.zPosition = 101
        
        populateLevelUnits()
        worldNode.addChild(playerBullet);
        
        addChild(loopingBG)
        addChild(loopingBG2)
        
        loopingBG.zPosition = -200
        loopingBG2.zPosition = -200
        
        // ugly, for iphone 6 plus
        loopingBG.yScale = 1.1
        loopingBG2.yScale = 1.1
        
        startLoopingBackground()
       
    }
    
    func setUpSwipeHandlers(){
        
        tapRec.addTarget(self, action:#selector(GameScene.tap))
        self.view!.addGestureRecognizer(tapRec);
        
        swipeRightRec.addTarget(self, action:#selector(GameScene.swipedRight))
        swipeRightRec.direction = .Right
        self.view!.addGestureRecognizer(swipeRightRec)
        
        swipeUpRec.addTarget(self, action: #selector(GameScene.swipedUp))
        swipeUpRec.direction = .Up
        self.view!.addGestureRecognizer(swipeUpRec)
        
        swipeDownRec.addTarget(self, action: #selector(GameScene.swipedDown))
        swipeDownRec.direction = .Down
        self.view!.addGestureRecognizer(swipeDownRec)
        
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
    
    func tap(){
        
        //if(playerBullet == nil){
            
        playerBullet.position.x = thePlayer.position.x + 50;
        playerBullet.position.y = thePlayer.position.y;
        thePlayer.shoot();
        
        //}
        
    }

    func swipedRight(){ thePlayer.glide() }
    
    func swipedDown(){
        
        if (thePlayer.isGliding == true) {
             thePlayer.stopGlide()
        } else if (onPlatform == true){
            thePlayer.stopGlide()
            currentPlatform?.physicsBody = nil
        }
        
    }
    
    func swipedUp(){ thePlayer.jump() }
    
    func resetLevel(){
        
        worldNode.enumerateChildNodesWithName("levelUnit" ) {
            node, stop in
            node.removeFromParent()
        }
    
        levelUnitCounter = 0
        populateLevelUnits()
    
    }

    func populateLevelUnits(){
        
        for _ in 0 ..< initialUnits {
            createLevelUnit()
        }
        
    }
    
    func createLevelUnit() {
        
        let levelUnit:LevelUnit!;
        
        if (levelUnitCounter < 2) {
            levelUnit = LevelUnit(width:levelUnitWidth, height:levelUnitHeight, xPos: levelUnitCounter*levelUnitWidth, yPos:0, isFirst:true);
        } else {
            levelUnit = LevelUnit(width:levelUnitWidth, height:levelUnitHeight, xPos: levelUnitCounter*levelUnitWidth, yPos:0, isFirst:false);
        }
        
        levelUnitCounter++
        worldNode.addChild(levelUnit)
        
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
        
       //print( "levelUnits in the scene is \(nodeCount)")
        
    }

    // call before render each frame
    override func update(currentTime: CFTimeInterval) {
        
        // declare where next
        let nextTierPos:CGFloat = (levelUnitCounter * levelUnitWidth) - (CGFloat(initialUnits) * levelUnitWidth)
        
        // If player position has reached over next tier, create a new level unit
        if (thePlayer.position.x > nextTierPos) {
            createLevelUnit()
        }
        
        // todo, might be slow to do this every frame
        clearNodes()
    
        if ( !isDead ) {
            thePlayer.update()
        }
        
        //if(playerBullet != nil){
        
            /*if(!intersectsNode(playerBullet)){
                
                
                print("Destroy");
                playerBullet.removeFromParent();
                playerBullet = nil;
            
            } else {*/
            playerBullet.update();
            //}
            
        //}
        
        self.centerOnNode(thePlayer)
        
    }


    func centerOnNode(node:SKNode) {
        
        // convert to this camera
        let cameraPositionInScene:CGPoint = self.convertPoint(node.position, fromNode: worldNode)
        worldNode.position = CGPoint(x: worldNode.position.x - cameraPositionInScene.x - 180 , y:0 )
        
    }
    
    // Handle all the collision
    func didBeginContact(contact: SKPhysicsContact) {
        
        
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
        }
        
        // make sure two wheelObjects aren't on each other
        if (contact.bodyA.categoryBitMask == BodyType.wheelObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.wheelObject.rawValue ) {
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
            if ( thePlayer.isRunning == false && thePlayer.isShooting == false) {
                thePlayer.startRun()
            }
            
        } else if (contact.bodyA.categoryBitMask == BodyType.player.rawValue  && contact.bodyB.categoryBitMask == BodyType.ground.rawValue ) {

            thePlayer.physicsBody?.dynamic = true
            if ( thePlayer.isRunning == false && thePlayer.isShooting == false)  {
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
            
            if ( thePlayer.isRunning == false && thePlayer.isShooting == false) {
                thePlayer.startRun()
            }
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.platformObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.player.rawValue ) {
            
            onPlatform = true
            currentPlatform =  contact.bodyA.node! as? SKSpriteNode
            
            thePlayer.physicsBody?.dynamic = true
            
            if ( thePlayer.isRunning == false && thePlayer.isShooting == false) {
                thePlayer.startRun()
            }
            
        }

    }
    
    // Physics contact ends
    func didEndContact(contact: SKPhysicsContact) {

        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    
        switch (contactMask) {

            case BodyType.platformObject.rawValue | BodyType.player.rawValue:
                onPlatform = false
                break;

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
            
            // fade out plaeyer
            
            let fadeOut:SKAction = SKAction.fadeAlphaTo(0, duration: 0.2)
            let move:SKAction = SKAction.moveTo(playerStartingPos, duration: 0.0)
            let block:SKAction = SKAction.runBlock(revivePlayer)
            let seq:SKAction = SKAction.sequence([fadeOut, move, block])
            
            thePlayer.runAction(seq)
            
            // fade out BG
            
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




