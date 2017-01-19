
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
    var canSecondJump:Bool = true;
    var jumpAmount:CGFloat = 0
    var maxJump:CGFloat = 40
    var minSpeed:CGFloat = 13
    var glideTime:TimeInterval = 2
    var slideTime:TimeInterval = 0.5
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init (imageNamed:String) {
        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: imageTexture, color:SKColor.clear, size: imageTexture.size() )
        
        //let body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: imageTexture.size().width / 2.6, center:CGPointMake(0, -18))
        let body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: imageTexture.size().width / 2.6);
        body.isDynamic = true
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
        /*if (isGliding == true) {
            self.position = CGPointMake(self.position.x + minSpeed, self.position.y - 0.4)
        } else {
            self.position = CGPointMake(self.position.x + minSpeed, self.position.y + jumpAmount)
        }*/
        self.position.x += minSpeed;
    }
    
    func setUpRun() {
        let atlas = SKTextureAtlas (named: "Player")
        var atlasTextures:[SKTexture] = []
        
        for i in 0 ..< 9{
            let texture:SKTexture = atlas.textureNamed( String(format: "bro3_walk000%i", i+1))
            atlasTextures.insert(texture, at:i)
        }
        
        for i in 9 ..< 14{
            let texture:SKTexture = atlas.textureNamed( String(format: "bro3_walk00%i", i+1))
            atlasTextures.insert(texture, at:i)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/30, resize: true , restore:false )
        runAction =  SKAction.repeatForever(atlasAnimation)
    }
    
    func setUpFire() {
        let atlas = SKTextureAtlas (named: "Player")
        var atlasTextures:[SKTexture] = []
        
        for i in 0 ..< 9{
            let texture:SKTexture = atlas.textureNamed( String(format: "bro3_walk_and_fire000%i", i+1))
            atlasTextures.insert(texture, at:i)
        }
        
        for i in 9 ..< 14{
            let texture:SKTexture = atlas.textureNamed( String(format: "bro3_walk_and_fire00%i", i+1))
            atlasTextures.insert(texture, at:i)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/30, resize: true , restore:false )
        fireAction =  SKAction.repeat(atlasAnimation, count:1)
    }

    func setUpJump() {
        let atlas = SKTextureAtlas (named: "Player")
        //create an array with SKTexture as the type (textures being the .png images)
        var atlasTextures:[SKTexture] = []
        
        for i in 0 ..< 5 {
            let texture:SKTexture = atlas.textureNamed( String(format: "bro3_jump000%i", i+1))
            atlasTextures.insert(texture, at:i)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/10, resize: true , restore:false )
        jumpAction =  SKAction.repeatForever(atlasAnimation)
    }
    
    func setUpGlide() {
        let atlas = SKTextureAtlas (named: "Ogre")
        
        //create another array this time with SKTexture as the type (textures being the .png images)
        var atlasTextures:[SKTexture] = []
        
        for i in 0 ..< 12 {
            let texture:SKTexture = atlas.textureNamed( String(format: "ogre_slide%i", i+1))
            atlasTextures.insert(texture, at:i)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/20, resize: true , restore:false )
        glideAction =  SKAction.repeatForever(atlasAnimation)
    }
    
    func startRun(){
        isGliding = false
        isRunning = true
        isJumping = false
        isShooting = false;
        canSecondJump = true;
        
        self.removeAction(forKey: "jumpKey")
        self.removeAction(forKey: "glideKey")
        self.removeAction(forKey: "shootKey")
        self.run(runAction! , withKey:"runKey")
    }
    
    func startShoot(){
        isGliding = false;
        isRunning = false;
        isJumping = false;
        isShooting = true;
        
        self.removeAction(forKey: "runKey")
        self.run(fireAction!, withKey:"shootKey")
    }
    
    func stopShoot(){
        isShooting = false;
        startRun();
    }
    
    func shoot() -> Bool{
        if(!isShooting && !isGliding){
            startShoot();
            let wait:SKAction = SKAction.wait(forDuration: 0.3);
            let stop:SKAction = SKAction.run(stopShoot);
            let seq:SKAction = SKAction.sequence([wait, stop])
            self.run(seq);
            
            return true;
        }
        return false;
    }
    
    func startJump(){
        self.removeAction(forKey: "runKey")
        self.run(jumpAction!, withKey:"jumpKey" )
        
        isGliding = false
        isRunning = false
        isShooting = false;
        isJumping = true
    }
    
    // TODO: seems to be slowing down speed when jumping
    func jump() {
        if (isJumping == false && isGliding == false) {
            startJump()
           /* jumpAmount = maxJump
        
            let callAgain:SKAction = SKAction.runBlock(taperJump)
            let wait:SKAction = SKAction.waitForDuration(1/60)
            let seq:SKAction = SKAction.sequence([wait, callAgain])
            let `repeat`:SKAction = SKAction.repeatActionForever(seq)
            
            self.runAction(`repeat`, withKey: "taperJumpAction")
            
            let stop:SKAction = SKAction.runBlock(stopJump)
            let seq2:SKAction = SKAction.sequence([`repeat`, stop])
            
            self.runAction(seq2)*/
            self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 350));
        } else if (canSecondJump){
            self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 350));
            canSecondJump = false;
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
        
        self.removeAction(forKey: "runKey")
        self.removeAction(forKey: "jumpKey")
        self.run(glideAction!, withKey:"glideKey")
    }
    
    
    func glide() {
        if (isGliding == false && isJumping == true) {
            startGlide()
            self.physicsBody?.isDynamic = false
            let wait:SKAction = SKAction.wait(forDuration: glideTime)
            let block:SKAction = SKAction.run(stopGlide)
            let seq:SKAction = SKAction.sequence([wait, block])
            self.run(seq)
        } else {
            slide()
        }
    }
    
    
    func stopGlide() {
        self.physicsBody?.isDynamic = true
        self.startRun()
    }
    
    
    func slide() {
        if (isRunning == true && isAttacking == false) {
            startGlide()
            isAttacking = true
            let wait:SKAction = SKAction.wait( forDuration: slideTime)
            let block:SKAction = SKAction.run(stopSlide)
            let seq:SKAction = SKAction.sequence([wait, block])
            
            self.run(seq)
        }
    }
    
    func stopSlide() {
        isAttacking = false
        startRun()
    }
}















