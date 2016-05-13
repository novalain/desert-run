//
//  Bullet.swift
//  DesertRun
//
//  Created by Michael Novén on 2016-05-13.
//  Copyright © 2016 CartoonSmart. All rights reserved.
//

import Foundation
import SpriteKit

class Bullet: SKNode {
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init (pos:CGPoint) {
    
        super.init();
        let bulletSprite = SKSpriteNode(imageNamed:"bullet")
        self.position = pos;
        
        self.addChild(bulletSprite)
        
        bulletSprite.xScale = 0.5;
        bulletSprite.yScale = 0.5;
        bulletSprite.physicsBody = SKPhysicsBody(circleOfRadius: bulletSprite.size.width / 2)
        bulletSprite.physicsBody!.categoryBitMask = BodyType.bullet.rawValue
        bulletSprite.physicsBody!.contactTestBitMask = BodyType.wheelObject.rawValue | BodyType.deathObject.rawValue
        bulletSprite.physicsBody!.friction = 1
        bulletSprite.physicsBody!.dynamic = false
        bulletSprite.physicsBody!.affectedByGravity = false
        bulletSprite.physicsBody!.restitution = 0.5
        bulletSprite.physicsBody!.allowsRotation = true
        self.zPosition = 102
        
    }
    
    
    func update(){
        
        self.position.x += 30;
        
    }
    
    

}

