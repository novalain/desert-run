//
//  Object.swift
//  JoyStickControls
//
//  Created by Justin Dike on 5/4/15.
//  Copyright (c) 2015 CartoonSmart. All rights reserved.
//

import Foundation
import SpriteKit

class Object: SKNode {
    
    var objectSprite:SKSpriteNode = SKSpriteNode()
    var imageName:String = ""
   
    var type:LevelType!;
    var spreadWidth:CGFloat = 0
    var spreadHeight:CGFloat = 0
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init (type:LevelType, spreadWidth:CGFloat, spreadHeight:CGFloat) {
        super.init()
        self.type = type
        self.spreadWidth = spreadWidth
        self.spreadHeight = spreadHeight
        createObject();
    }

    func createObject() {
        
        if (type == LevelType.water) {
            imageName = "Platform"
        } else {
            
            let rand = arc4random_uniform(5) // no platform atm
            
            if ( rand == 0) {
                imageName = "Wheel"
            } else if ( rand == 1) {
                imageName = "Barrel"
            } else if ( rand == 2) {
                imageName = "Cactus"
            } else if ( rand == 3) {
                imageName = "Rock"
            } else if ( rand == 4) {
                imageName = "Money";
            } else if (rand == 5){
                imageName = "Platform"
            } else if ( rand == 6) {
                // increase liklihood of another platform
                imageName = "Platform"
            }
        }
        
        objectSprite = SKSpriteNode(imageNamed:imageName)
        
        self.addChild(objectSprite)
        
        if ( imageName == "Platform") {
            
            let newSize:CGSize = CGSizeMake(objectSprite.size.width, 10)
            
            objectSprite.physicsBody = SKPhysicsBody(rectangleOfSize: newSize, center:CGPointMake(0, 50))
            objectSprite.physicsBody!.categoryBitMask = BodyType.platformObject.rawValue
           
            objectSprite.physicsBody!.friction = 1
            objectSprite.physicsBody!.dynamic = false
            objectSprite.physicsBody!.affectedByGravity = false
            objectSprite.physicsBody!.restitution = 0.0
            objectSprite.physicsBody!.allowsRotation = false
            
            if ( type == LevelType.water) {
                self.position = CGPointMake(0, -110)
            } else {
                let rand = arc4random_uniform(2)
                if ( rand == 0) {
                    self.position = CGPointMake(0, -110)
                } else if ( rand == 1) {
                    self.position = CGPointMake(0, -50)
                }
            }
            
            let randX = arc4random_uniform(UInt32(spreadWidth))
            self.position = CGPointMake( 0,  self.position.y)
            
            
        } else if ( imageName == "Wheel") {
            
            objectSprite.physicsBody = SKPhysicsBody(circleOfRadius: objectSprite.size.width / 2)
            objectSprite.physicsBody!.categoryBitMask = BodyType.wheelObject.rawValue
            objectSprite.physicsBody!.contactTestBitMask = BodyType.wheelObject.rawValue | BodyType.deathObject.rawValue | BodyType.water.rawValue
            objectSprite.physicsBody!.friction = 1
            objectSprite.physicsBody!.dynamic = true
            objectSprite.physicsBody!.affectedByGravity = true
            objectSprite.physicsBody!.restitution = 0.5
            objectSprite.physicsBody!.allowsRotation = true
            
            let randX = arc4random_uniform(UInt32(spreadWidth))
            self.position = CGPointMake( CGFloat(randX) - (spreadWidth / 3),  self.position.y)
            
        } else if ( imageName == "Money") {
            
            objectSprite.xScale = 1.5;
            objectSprite.yScale = 1.5;
            objectSprite.physicsBody = SKPhysicsBody(circleOfRadius: objectSprite.size.width / 2)
            objectSprite.physicsBody!.categoryBitMask = BodyType.moneyObject.rawValue
            
            objectSprite.physicsBody!.friction = 1
            objectSprite.physicsBody!.dynamic = true
            objectSprite.physicsBody!.affectedByGravity = true
            objectSprite.physicsBody!.restitution = 0.0
            objectSprite.physicsBody!.allowsRotation = true
            
            let randX = arc4random_uniform(UInt32(spreadWidth))
            self.position = CGPointMake( CGFloat(randX) - (spreadWidth / 3),  0)
            
        } else {
            
            if(imageName == "Barrel"){
                objectSprite.xScale = 1.75;
                objectSprite.yScale = 1.75;
                
            }
            
            objectSprite.physicsBody = SKPhysicsBody(circleOfRadius: objectSprite.size.width / 1.8)
            objectSprite.physicsBody!.categoryBitMask = BodyType.deathObject.rawValue
            objectSprite.physicsBody!.contactTestBitMask = BodyType.deathObject.rawValue | BodyType.ground.rawValue | BodyType.wheelObject.rawValue | BodyType.water.rawValue
            
            objectSprite.physicsBody!.friction = 1
            objectSprite.physicsBody!.dynamic = true
            objectSprite.physicsBody!.affectedByGravity = true
            objectSprite.physicsBody!.restitution = 0.0
            objectSprite.physicsBody!.allowsRotation = false
            
            let randX = arc4random_uniform(UInt32(spreadWidth))
            self.position = CGPointMake( CGFloat(randX) - (spreadWidth / 2),  self.position.y)
            
        }

        self.zPosition = 102
        self.name = "obstacle"
        
    }

    
}





