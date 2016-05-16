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
    var fireAction:SKAction?
    
    var isJumping:Bool = false
    var isGliding:Bool = false
    var isRunning:Bool = true
    var isAttacking:Bool = false
    var isShooting:Bool = false;
    var jumpAmount:CGFloat = 0
    var maxJump:CGFloat = 25
    var minSpeed:CGFloat = 6
    var glideTime:NSTimeInterval = 2
    var slideTime:NSTimeInterval = 0.5
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init (imageNamed:String) {
        
        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: imageTexture, color:SKColor.clearColor(), size: imageTexture.size() )
        
        //let body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: imageTexture.size().width / 2.6, center:CGPointMake(0, -18))
        let body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: imageTexture.size().width / 2.6);
        body.dynamic = true
        body.affectedByGravity = true
        body.allowsRotation = false
        body.restitution = 0.0
        body.categoryBitMask = BodyType.player.rawValue
        body.contactTestBitMask = BodyType.deathObject.rawValue | BodyType.platformObject.rawValue | BodyType.ground.rawValue  | BodyType.water.rawValue | BodyType.moneyObject.rawValue
        body.collisionBitMask = BodyType.platformObject.rawValue | BodyType.ground.rawValue
        self.physicsBody = body;
        self.zPosition = 1000;
        
        // Set up actions for animations
        setUpRun()
        setUpJump()
        setUpGlide()
        setUpFire();
        
        // Start by running
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
        
        let atlas = SKTextureAtlas (named: "Player")
        var atlasTextures:[SKTexture] = []
        
        for i in 0 ..< 9{
            let texture:SKTexture = atlas.textureNamed( String(format: "bro3_walk000%i", i+1))
            atlasTextures.insert(texture, atIndex:i)
        }
        
        for i in 9 ..< 14{
            let texture:SKTexture = atlas.textureNamed( String(format: "bro3_walk00%i", i+1))
            atlasTextures.insert(texture, atIndex:i)
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/30, resize: true , restore:false )
        runAction =  SKAction.repeatActionForever(atlasAnimation)
        
    }
    
    func setUpFire() {
        
        let atlas = SKTextureAtlas (named: "Player")
        var atlasTextures:[SKTexture] = []
        
        for i in 0 ..< 9{
            let texture:SKTexture = atlas.textureNamed( String(format: "bro3_walk_and_fire000%i", i+1))
            atlasTextures.insert(texture, atIndex:i)
        }
        
        for i in 9 ..< 14{
            let texture:SKTexture = atlas.textureNamed( String(format: "bro3_walk_and_fire00%i", i+1))
            atlasTextures.insert(texture, atIndex:i)
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/30, resize: true , restore:false )
        fireAction =  SKAction.repeatAction(atlasAnimation, count:1)
        
    }
    
    
    func setUpJump() {
        
        let atlas = SKTextureAtlas (named: "Player")
        //create an array with SKTexture as the type (textures being the .png images)
        var atlasTextures:[SKTexture] = []
        
        for i in 0 ..< 5 {
            let texture:SKTexture = atlas.textureNamed( String(format: "bro3_jump000%i", i+1))
            atlasTextures.insert(texture, atIndex:i)
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/10, resize: true , restore:false )
        jumpAction =  SKAction.repeatActionForever(atlasAnimation)
        
    }
    
    func setUpGlide() {
        
        let atlas = SKTextureAtlas (named: "Ogre")
        
        //create another array this time with SKTexture as the type (textures being the .png images)
        var atlasTextures:[SKTexture] = []
        
        for i in 0 ..< 12 {
            let texture:SKTexture = atlas.textureNamed( String(format: "ogre_slide%i", i+1))
            atlasTextures.insert(texture, atIndex:i)
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/20, resize: true , restore:false )
        glideAction =  SKAction.repeatActionForever(atlasAnimation)
        
    }
    
    func startRun(){
        
        isGliding = false
        isRunning = true
        isJumping = false
        isShooting = false;
        
        self.removeActionForKey("jumpKey")
        self.removeActionForKey("glideKey")
        self.removeActionForKey("shootKey")
        self.runAction(runAction! , withKey:"runKey")
        
    }
    
    func startShoot(){
        
        isGliding = false;
        isRunning = false;
        isJumping = false;
        isShooting = true;
        
        self.removeActionForKey("runKey")
        self.runAction(fireAction!, withKey:"shootKey")
        
    }
    
    func stopShoot(){
        
        isShooting = false;
        startRun();
        
    }
    
    func shoot() -> Bool{
    
        
        if(!isShooting && !isJumping && isRunning == true && !isGliding){
            
            startShoot();
            let wait:SKAction = SKAction.waitForDuration(0.3);
            let stop:SKAction = SKAction.runBlock(stopShoot);
            let seq:SKAction = SKAction.sequence([wait, stop])
            self.runAction(seq);
            
            return true;
       
        }
        
        return false;
        
    }
    
    func startJump(){
        
        self.removeActionForKey("runKey")
        self.runAction(jumpAction!, withKey:"jumpKey" )
        
        isGliding = false
        isRunning = false
        isShooting = false;
        isJumping = true
        
        
    }
    
    // TODO: seems to be slowing down speed when jumping
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















