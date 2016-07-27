
import Foundation
import SpriteKit

class Bullet: SKNode {
    
    let bulletSpeed:CGFloat = 20;
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init (pos:CGPoint) {
    
        super.init();
        let bulletSprite = SKSpriteNode(imageNamed:"bullet")
        self.position = pos;
        
        self.addChild(bulletSprite)
        
        bulletSprite.xScale = 0.4;
        bulletSprite.yScale = 0.4;
        bulletSprite.physicsBody = SKPhysicsBody(circleOfRadius: bulletSprite.size.width / 2)
        bulletSprite.physicsBody!.categoryBitMask = BodyType.bullet.rawValue
        bulletSprite.physicsBody!.contactTestBitMask = BodyType.wheelObject.rawValue | BodyType.deathObject.rawValue | BodyType.enemy.rawValue
        bulletSprite.physicsBody!.friction = 1
        bulletSprite.physicsBody!.dynamic = true
        bulletSprite.physicsBody!.affectedByGravity = false
        bulletSprite.physicsBody!.restitution = 0
        bulletSprite.physicsBody!.allowsRotation = true
        self.zPosition = 102
        
    }
    
    
    func update(){
        
        self.position.x += bulletSpeed;
        
    }
    
    

}

