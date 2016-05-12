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
    var levelUnitWidth:CGFloat = 0
    var levelUnitHeight:CGFloat = 0
    var theType:LevelType = LevelType.ground
    
    var xAmount:CGFloat = 1  //essentially this is our speed
    var direction:CGFloat = 1 //will be saved as either 1 or -1
    var numberOfObjectsInLevel:UInt32 = 0
    var offscreenCounter:Int = 0 //anytime an object goes offscreen we add to this, for resetting speed purposes
    var topSpeedgrass:UInt32 = 5
    var topSpeedWater:UInt32 = 2
    var maxObjectsInLevelUnit:UInt32 = 2
    
    var isFirstUnit:Bool = false
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override init () {
        
        super.init()
        
        

    }
    
    func setUpLevel(){
        
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
            
            
            if (isFirstUnit == false) {
                
                imageName = "Wild_West_Background3"
                theType = LevelType.water
            } else {
                
                imageName = "Wild_West_Background2"
                
            }
            
            
            
            
        }
        
        
    
        let theSize:CGSize = CGSizeMake(levelUnitWidth, levelUnitHeight)
        let tex:SKTexture = SKTexture(imageNamed: imageName)
        backgroundSprite = SKSpriteNode(texture: tex, color: SKColor.clearColor(), size: theSize)
        
        
        self.addChild(backgroundSprite)
        self.name = "levelUnit"
        
        self.position = CGPointMake(backgroundSprite.size.width / 2, 0)
        
        backgroundSprite.physicsBody = SKPhysicsBody(rectangleOfSize: backgroundSprite.size, center:CGPointMake(0, -backgroundSprite.size.height * 0.88))
        
         backgroundSprite.physicsBody!.dynamic = false
         backgroundSprite.physicsBody!.restitution = 0
        
        if (theType == LevelType.water) {
            
            backgroundSprite.physicsBody!.categoryBitMask = BodyType.water.rawValue
            backgroundSprite.physicsBody!.contactTestBitMask = BodyType.water.rawValue
            
            self.zPosition = 400
            
        } else if (theType == LevelType.ground){
            
            
            
            backgroundSprite.physicsBody!.categoryBitMask = BodyType.ground.rawValue
            backgroundSprite.physicsBody!.contactTestBitMask = BodyType.ground.rawValue
           
            
        }

        if ( isFirstUnit == false ) {
            
            createObstacle()
        }
        
        
        
    }
    
    func createObstacle() {
        
      
       
        
        numberOfObjectsInLevel = arc4random_uniform(maxObjectsInLevelUnit)
        numberOfObjectsInLevel = numberOfObjectsInLevel + 1 // so it can't be 0
        
        
            //was
           // for (var i = 0; i < Int(numberOfObjectsInLevel); i++) {
                
            for _ in 0 ..< Int(numberOfObjectsInLevel) {
                
                
                let obstacle:Object = Object()
                
                obstacle.theType = theType
                obstacle.levelUnitWidth = levelUnitWidth
                obstacle.levelUnitHeight = levelUnitHeight
                
                obstacle.createObject()
                addChild(obstacle)
                
                
            }
            
            
            
        }
        
    
    
    

    
}













