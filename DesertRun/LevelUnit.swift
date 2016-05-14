//
//  LevelUnit.swift
//  EndlessWorlds
//
//  Created by Justin Dike on 5/27/15.
//  Copyright (c) 2015 CartoonSmart. All rights reserved.
//

import Foundation
import SpriteKit

class LevelUnit:SKNode {
    
    var imageName:String = ""
    var backgroundSprite:SKSpriteNode = SKSpriteNode()
    var width:CGFloat = 0
    var height:CGFloat = 0
    var type:LevelType = LevelType.ground
    
    var xAmount:CGFloat = 1  //essentially this is our speed
    var direction:CGFloat = 1 //will be saved as either 1 or -1
    var numberOfObjectsInLevel:UInt32 = 0
    var offscreenCounter:Int = 0 //anytime an object goes offscreen we add to this, for resetting speed purposes
    var maxObjectsInLevelUnit:UInt32 = 2
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init (width:CGFloat, height:CGFloat, xPos:CGFloat, yPos:CGFloat, isFirst:Bool) {
        
        super.init()
        
        zPosition = -1;
        position = CGPointMake(xPos, yPos);
        self.width = width;
        self.height = height;
        
        let diceRoll = arc4random_uniform(5)
        
        if (diceRoll == 0) {
            imageName = "Wild_West_Background1"
        } else if (diceRoll == 1) {
            imageName = "Wild_West_Background2"
        } else if (diceRoll == 2) {
            imageName = "Wild_West_Background1"
        } else if (diceRoll == 3) {
            imageName = "Wild_West_Background2"
        } else if (diceRoll == 4) {
            if (isFirst == false) {
                imageName = "Wild_West_Background3"
                type = LevelType.water
            } else {
                imageName = "Wild_West_Background2"
            }
        }
        
        let theSize:CGSize = CGSizeMake(width, height)
        let tex:SKTexture = SKTexture(imageNamed: imageName)
        backgroundSprite = SKSpriteNode(texture: tex, color: SKColor.clearColor(), size: theSize)
        
        self.addChild(backgroundSprite)
        self.name = "levelUnit"
        //self.position = CGPointMake(backgroundSprite.size.width / 2, 0)
        
        backgroundSprite.physicsBody = SKPhysicsBody(rectangleOfSize: backgroundSprite.size, center:CGPointMake(0, -backgroundSprite.size.height * 0.88))
        
        backgroundSprite.physicsBody!.dynamic = false
        backgroundSprite.physicsBody!.restitution = 0
        
        if (type == LevelType.water) {
            
            backgroundSprite.physicsBody!.categoryBitMask = BodyType.water.rawValue
            backgroundSprite.physicsBody!.contactTestBitMask = BodyType.water.rawValue
            zPosition = 400
            
        } else if (type == LevelType.ground){
            backgroundSprite.physicsBody!.categoryBitMask = BodyType.ground.rawValue
            backgroundSprite.physicsBody!.contactTestBitMask = BodyType.ground.rawValue
        }
        
        if ( isFirst == false ) {
            createObstacle()
        }

        
    }

    // create obstacles on level unit
    func createObstacle() {

        numberOfObjectsInLevel = arc4random_uniform(maxObjectsInLevelUnit) + 1 // shouldn't be zero
        
        for _ in 0 ..< Int(numberOfObjectsInLevel) {

            let obstacle:Object = Object(type: type, spreadWidth: width, spreadHeight: height)
            addChild(obstacle)
            
        }

        
    }

    
}













