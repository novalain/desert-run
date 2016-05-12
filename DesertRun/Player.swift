//
//  Player.swift
//  JoyStickControls
//
//  Created by Justin Dike on 5/4/15.
//  Copyright (c) 2015 CartoonSmart. All rights reserved.
//

import Foundation
import SpriteKit



class Player: SKSpriteNode {
    
   
    var jumpAction:SKAction?
    var runAction:SKAction?
    var glideAction:SKAction?

    
    var isJumping:Bool = false
    var isGliding:Bool = false
    var isRunning:Bool = true
    var isAttacking:Bool = false
    
    
    var jumpAmount:CGFloat = 0
    var maxJump:CGFloat = 20
    
    var minSpeed:CGFloat = 6
    
    var glideTime:NSTimeInterval = 2
    var slideTime:NSTimeInterval = 0.5
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init (imageNamed:String) {
        
        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: imageTexture, color:SKColor.clearColor(), size: imageTexture.size() )
        
        let body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: imageTexture.size().width / 2.25, center:CGPointMake(0, 0))
        body.dynamic = true
        body.affectedByGravity = true
        body.allowsRotation = false
        body.restitution = 0.0
        body.categoryBitMask = BodyType.player.rawValue
        body.contactTestBitMask = BodyType.deathObject.rawValue | BodyType.wheelObject.rawValue | BodyType.platformObject.rawValue | BodyType.ground.rawValue  | BodyType.water.rawValue | BodyType.moneyObject.rawValue
        body.collisionBitMask = BodyType.platformObject.rawValue | BodyType.ground.rawValue
        body.friction = 0.9 //0 is like glass, 1 is like sandpaper to walk on
        self.physicsBody = body
        
        
        setUpRun()
        setUpJump()
        setUpGlide()
        
        startRun()
        
        
    }
    
    func update() {
        
        if (isGliding == true) {
            
            self.position = CGPointMake(self.position.x + minSpeed, self.position.y - 0.4)
            
        } else {
            
            
            self.position = CGPointMake(self.position.x + minSpeed, self.position.y + jumpAmount)
            
        }
        
        
        
        
        
    }
    
    func setUpRun() {
        
        let atlas = SKTextureAtlas (named: "Ogre")
        
        var array = [String]()
        
        //or setup an array with exactly the sequential frames start from 1
        
        
        //was
        //  for var i=1; i <= 20; i++ {
        
        for i in 1 ... 20 {
        
       
            
            let nameString = String(format: "ogre_run%i", i)
            array.append(nameString)
            
        }
        
        //create another array this time with SKTexture as the type (textures being the .png images)
        var atlasTextures:[SKTexture] = []
        
        
        //was
        //for (var i = 0; i < array.count; i++ ) {
        
        for i in 0 ..< array.count{
            
            let texture:SKTexture = atlas.textureNamed( array[i] )
            atlasTextures.insert(texture, atIndex:i)
            
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/60, resize: true , restore:false )
        runAction =  SKAction.repeatActionForever(atlasAnimation)
        
        
        
    }
    
    
    func setUpJump() {
        
        let atlas = SKTextureAtlas (named: "Ogre")
        
        var array = [String]()
        
        //or setup an array with exactly the sequential frames start from 1
        
        //was
        //  for var i=1; i <= 9; i++ {
        
        for i in 1 ... 9 {
      
            let nameString = String(format: "ogre_jump%i", i)
            array.append(nameString)
            
        }
        
        //create another array this time with SKTexture as the type (textures being the .png images)
        var atlasTextures:[SKTexture] = []
        
        //was...
        //for (var i = 0; i < array.count; i++ ) {
        
        for i in 0 ..< array.count {
            
            let texture:SKTexture = atlas.textureNamed( array[i] )
            atlasTextures.insert(texture, atIndex:i)
            
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/20, resize: true , restore:false )
        jumpAction =  SKAction.repeatActionForever(atlasAnimation)
        
        
        
    }
    
    func setUpGlide() {
        
        let atlas = SKTextureAtlas (named: "Ogre")
        
        var array = [String]()
        
        //or setup an array with exactly the sequential frames start from 1
        //was
        //  for var i=1; i <= 12; i++ {
        
        for i in 1 ... 12 {
            
            let nameString = String(format: "ogre_slide%i", i)
            array.append(nameString)
            
        }
        
        //create another array this time with SKTexture as the type (textures being the .png images)
        var atlasTextures:[SKTexture] = []
        
        //was...
        //for (var i = 0; i < array.count; i++ ) {
        
        for i in 0 ..< array.count {
            
            let texture:SKTexture = atlas.textureNamed( array[i] )
            atlasTextures.insert(texture, atIndex:i)
            
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/20, resize: true , restore:false )
        glideAction =  SKAction.repeatActionForever(atlasAnimation)
        
        
        
    }
    
    
    
    
    
    
    func startRun(){
        
        isGliding = false
        isRunning = true
        isJumping = false
        
        self.removeActionForKey("jumpKey")
        self.removeActionForKey("glideKey")
        self.runAction(runAction! , withKey:"runKey")
        
    }
    func startJump(){
        
        self.removeActionForKey("runKey")
        self.runAction(jumpAction!, withKey:"jumpKey" )
        
        isGliding = false
        isRunning = false
        isJumping = true
        
        
    }
    
    func jump() {
        
        if ( isJumping == false && isGliding == false) {
            
                startJump()
            
                jumpAmount = maxJump
            
            let callAgain:SKAction = SKAction.runBlock(taperJump)
            let wait:SKAction = SKAction.waitForDuration(1/60)
            let seq:SKAction = SKAction.sequence([wait, callAgain])
            let `repeat`:SKAction = SKAction.repeatAction(seq, count: 20)
            let stop:SKAction = SKAction.runBlock(stopJump)
            let seq2:SKAction = SKAction.sequence([`repeat`, stop])
            
            self.runAction(seq2)
            
            
            
        }
        
    }
    
    
    func taperJump() {
        
        
        jumpAmount = jumpAmount * 0.9
        
    }
    
    
    func stopJump() {
        
        isJumping = false
        jumpAmount = 0
        
        if (isGliding == false) {
            
            startRun()
            
        }
        
        
    }
    
    
    
    
    func startGlide(){
        
        isJumping = false
        isRunning = false
        isGliding = true
        
        self.removeActionForKey("runKey")
        self.removeActionForKey("jumpKey")
        self.runAction(glideAction!, withKey:"glideKey")
        
    }
    
    
    func glide() {
        
        
        if (isGliding == false && isJumping == true) {
            
            startGlide()
            
            self.physicsBody?.dynamic = false
            
            let wait:SKAction = SKAction.waitForDuration(glideTime)
            let block:SKAction = SKAction.runBlock(stopGlide)
            let seq:SKAction = SKAction.sequence([wait, block])
            
            self.runAction(seq)
        
            
        } else {
            
            slide()
        }
        
        
    }
    
    
    func stopGlide() {
        
        self.physicsBody?.dynamic = true
        
        self.startRun()
        
    }
    
    
    func slide() {
        
        
        if (isRunning == true && isAttacking == false) {
            
            startGlide()
            
            isAttacking = true
            
            let wait:SKAction = SKAction.waitForDuration( slideTime)
            let block:SKAction = SKAction.runBlock(stopSlide)
            let seq:SKAction = SKAction.sequence([wait, block])
            
            self.runAction(seq)
            
            
        }
        
    }
    
    
    func stopSlide() {
        
        
        
        isAttacking = false
        
        startRun()
        
    }
    
    
}















