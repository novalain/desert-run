
import Foundation
import SpriteKit

class Object: SKNode {
    var objectSprite:SKSpriteNode = SKSpriteNode()
    var imageName:String = ""
    
    var type:LevelType!;
    var spreadWidth:CGFloat = 0
    var spreadHeight:CGFloat = 0
    //var enemyRunAction:SKAction?;

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
    
    func setUpEnemyRun() {
        let atlas = SKTextureAtlas (named: "Enemy")
        var atlasTextures:[SKTexture] = []
        
        for i in 0 ..< 7{
            let texture:SKTexture = atlas.textureNamed( String(format: "bro4_run000%i", i+1))
            atlasTextures.insert(texture, at:i)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/15, resize: true , restore:false )
        enemyRunAction =  SKAction.repeatForever(atlasAnimation)
    }
    
    /*func playEnemyDie(){
     
     self.objectSprite.removeActionForKey("enemyRun")
     self.objectSprite.runAction(enemyDieAction! , withKey:"runKey")
     
     }*/
    
    func createObject() {
        if (type == LevelType.water) {
            imageName = "Platform"
        } else {
            let rand = arc4random_uniform(5) // no platform atm
            
            if ( rand == 0) {
                imageName = "Barrel"
            } else if ( rand == 1) {
                imageName = "Cactus"
            } else if ( rand == 2) {
                imageName = "Rock"
            } else if ( rand == 3) {
                imageName = "Money"
            } else if ( rand == 4) {
                imageName = "bro4_run0001";
                //setUpEnemyRun();
            }
            /*else if (rand == 5){
             imageName = "Platform"
             } else if ( rand == 6) {
             // increase liklihood of another platform
             imageName = "Platform"
             }*/
        }
        
        objectSprite = SKSpriteNode(imageNamed:imageName)
        
        self.addChild(objectSprite)
        
        if (imageName == "Platform") {
            let newSize:CGSize = CGSize(width: objectSprite.size.width, height: 10)
            
            objectSprite.physicsBody = SKPhysicsBody(rectangleOf: newSize, center:CGPoint(x: 0, y: 50))
            objectSprite.physicsBody!.categoryBitMask = BodyType.platformObject.rawValue
            
            objectSprite.physicsBody!.friction = 1
            objectSprite.physicsBody!.isDynamic = false
            objectSprite.physicsBody!.affectedByGravity = false
            objectSprite.physicsBody!.restitution = 0.0
            objectSprite.physicsBody!.allowsRotation = false
            
            if ( type == LevelType.water) {
                self.position = CGPoint(x: 0, y: -110)
            } else {
                let rand = arc4random_uniform(2)
                if ( rand == 0) {
                    self.position = CGPoint(x: 0, y: -110)
                } else if ( rand == 1) {
                    self.position = CGPoint(x: 0, y: -50)
                }
            }
            
            //let randX = arc4random_uniform(UInt32(spreadWidth))
            self.position = CGPoint( x: 0,  y: self.position.y)
        } else if (imageName == "Money") {
            objectSprite.xScale = 1.5;
            objectSprite.yScale = 1.5;
            objectSprite.physicsBody = SKPhysicsBody(circleOfRadius: objectSprite.size.width / 2)
            objectSprite.physicsBody!.categoryBitMask = BodyType.moneyObject.rawValue
            
            objectSprite.physicsBody!.friction = 1
            objectSprite.physicsBody!.isDynamic = true
            objectSprite.physicsBody!.affectedByGravity = true
            objectSprite.physicsBody!.restitution = 0.0
            objectSprite.physicsBody!.allowsRotation = true
            
            let randX = arc4random_uniform(UInt32(spreadWidth))
            self.position = CGPoint( x: CGFloat(randX) - (spreadWidth / 3),  y: 0)
        } else if ( imageName == "bro4_run0001"){
            objectSprite.physicsBody = SKPhysicsBody(circleOfRadius: objectSprite.size.width / 2.6)
            objectSprite.physicsBody!.categoryBitMask = BodyType.enemy.rawValue
            objectSprite.physicsBody!.contactTestBitMask = BodyType.deathObject.rawValue | BodyType.water.rawValue | BodyType.enemy.rawValue | BodyType.player.rawValue
            objectSprite.physicsBody!.collisionBitMask = BodyType.deathObject.rawValue | BodyType.water.rawValue | BodyType.ground.rawValue | BodyType.moneyObject.rawValue
            objectSprite.xScale = objectSprite.xScale * -1;
            objectSprite.zPosition = -100;
            
            objectSprite.physicsBody!.friction = 0;
            objectSprite.physicsBody!.isDynamic = true
            objectSprite.physicsBody!.affectedByGravity = true
            objectSprite.physicsBody!.restitution = 0.0
            objectSprite.physicsBody!.allowsRotation = false
            
            let randX = arc4random_uniform(UInt32(spreadWidth))
            self.position = CGPoint( x: CGFloat(randX) - (spreadWidth / 3),  y: 0)
            objectSprite.run(enemyRunAction!, withKey:"enemyRun");
        } else {
            if(imageName == "Barrel"){
                objectSprite.xScale = 1.75;
                objectSprite.yScale = 1.75;
            } else if (imageName == "Cactus"){
                objectSprite.xScale = 0.85;
                objectSprite.yScale = 0.85;
            }
            
            objectSprite.physicsBody = SKPhysicsBody(circleOfRadius: objectSprite.size.width / 1.8)
            objectSprite.physicsBody!.categoryBitMask = BodyType.deathObject.rawValue
            objectSprite.physicsBody!.contactTestBitMask = BodyType.deathObject.rawValue | BodyType.ground.rawValue | BodyType.water.rawValue
            
            objectSprite.physicsBody!.friction = 1
            objectSprite.physicsBody!.isDynamic = true
            objectSprite.physicsBody!.affectedByGravity = true
            objectSprite.physicsBody!.restitution = 0.0
            objectSprite.physicsBody!.allowsRotation = false
            
            let randX = arc4random_uniform(UInt32(spreadWidth))
            self.position = CGPoint( x: CGFloat(randX) - (spreadWidth / 2),  y: self.position.y)
            
        }
        self.zPosition = 102
        self.name = "obstacle"
    }
}





