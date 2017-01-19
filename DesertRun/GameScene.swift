
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
    case enemy = 256
}

enum LevelType:UInt32 {
    case ground, water
}

var enemyRunAction:SKAction?; // Only wanna create this once

class GameScene: SKScene, SKPhysicsContactDelegate {
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    let tapRec = UITapGestureRecognizer();
    
    let worldNode:SKNode = SKNode()
    let thePlayer:Player = Player(imageNamed: "bro3_walk0001") // fix
    var playerBullet:Bullet?;
    
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
    var enemyDieAction:SKAction?;
    var bulletExplodeAction:SKAction?;
    var enemyShot:Bool = false;
    var deathObjectShot:Bool = false;
    
    let playerStartingPos:CGPoint = CGPoint(x: 50, y: 0)
    var scoreLabel:SKLabelNode!;
    
    var score:Int = 0 {
        didSet{
            scoreLabel.text = "Score \(score)";
        }
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.white
        screenWidth = self.view!.bounds.width
        screenHeight = self.view!.bounds.height
        
        setUpSwipeHandlers();
        setUpText();
        
        levelUnitWidth = screenWidth
        levelUnitHeight = screenHeight
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx:-0.3, dy:-8.8)
        
        // Move origin to center
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        addChild(worldNode)
        
        worldNode.addChild(thePlayer)
        thePlayer.position = playerStartingPos
        thePlayer.zPosition = 101
        
        populateLevelUnits()
        
        setUpEnemyDieAnimation();
        setUpEnemyRunAnimation();
        setUpBulletExplodeAnimation();
        
        addChild(loopingBG)
        addChild(loopingBG2)
        
        loopingBG.zPosition = -200
        loopingBG2.zPosition = -200
        
        // ugly, for iphone 6 plus
        loopingBG.yScale = 1.1
        loopingBG2.yScale = 1.1
        
        startLoopingBackground()
    }
    
    func setUpText() {
        scoreLabel = SKLabelNode(fontNamed :"AmericanTypeWriter")
        scoreLabel.text = "Score: 0";
        scoreLabel.fontColor = SKColor.black;
        scoreLabel.horizontalAlignmentMode = .right;
        
        //scoreLabel.position = worldNode.convertPoint(CGPointMake(-100, 50), fromNode: self)
        scoreLabel.position = CGPoint(x: -screenWidth/2 + 150, y: screenHeight/2 - 50);
        
        print(scoreLabel.position);
        
        //let nodeLocation:CGPoint = self.convertPoint(node.position, fromNode: self.worldNode)
        self.addChild(scoreLabel);
    }
    
    func setUpBulletExplodeAnimation(){
        let atlas = SKTextureAtlas (named: "Explode")
        var atlasTextures:[SKTexture] = []
        
        for i in 0 ..< 9{
            let texture:SKTexture = atlas.textureNamed( String(format: "ring_blast000%i", i+1))
            atlasTextures.insert(texture, at:i)
        }
        
        for i in 9 ..< 13{
            let texture:SKTexture = atlas.textureNamed( String(format: "ring_blast00%i", i+1))
            atlasTextures.insert(texture, at:i)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/30, resize: true , restore:false )
        bulletExplodeAction =  SKAction.repeat(atlasAnimation, count:1)
    }
    
    func setUpEnemyRunAnimation(){
        let atlas = SKTextureAtlas (named: "Enemy")
        var atlasTextures:[SKTexture] = []
        
        for i in 0 ..< 7{
            let texture:SKTexture = atlas.textureNamed( String(format: "bro4_run000%i", i+1))
            atlasTextures.insert(texture, at:i)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/15, resize: true , restore:false )
        enemyRunAction =  SKAction.repeatForever(atlasAnimation)
    }
    
    func setUpEnemyDieAnimation(){
        let atlas = SKTextureAtlas (named: "Enemy")
        var atlasTextures:[SKTexture] = []
        
        for i in 0 ..< 9{
            let texture:SKTexture = atlas.textureNamed( String(format: "bro4_defeated000%i", i+1))
            atlasTextures.insert(texture, at:i)
        }
        
        for i in 9 ..< 22{
            let texture:SKTexture = atlas.textureNamed( String(format: "bro4_defeated00%i", i+1))
            atlasTextures.insert(texture, at:i)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/30, resize: true , restore:false )
        enemyDieAction =  SKAction.repeat(atlasAnimation, count:1)
    }
    
    func setUpSwipeHandlers(){
        tapRec.addTarget(self, action:#selector(GameScene.tap))
        self.view!.addGestureRecognizer(tapRec);
        
        swipeRightRec.addTarget(self, action:#selector(GameScene.swipedRight))
        swipeRightRec.direction = .right
        self.view!.addGestureRecognizer(swipeRightRec)
        
        swipeUpRec.addTarget(self, action: #selector(GameScene.swipedUp))
        swipeUpRec.direction = .up
        self.view!.addGestureRecognizer(swipeUpRec)
        
        swipeDownRec.addTarget(self, action: #selector(GameScene.swipedDown))
        swipeDownRec.direction = .down
        self.view!.addGestureRecognizer(swipeDownRec)
    }
    
    func startLoopingBackground(){
        resetLoopingBackground()
        
        let move:SKAction = SKAction.moveBy(x: -loopingBG2.size.width, y: 0, duration: 20)
        let moveBack:SKAction = SKAction.moveBy(x: loopingBG2.size.width, y: 0, duration: 0)
        let seq:SKAction = SKAction.sequence([move, moveBack])
        let `repeat`:SKAction = SKAction.repeatForever(seq)
        
        loopingBG.run(`repeat`)
        loopingBG2.run(`repeat`)
    }
    
    func tap(){
        if(playerBullet == nil && thePlayer.shoot() == true){
            playerBullet = Bullet(pos: CGPoint(x: thePlayer.position.x + 50, y: thePlayer.position.y));
            worldNode.addChild(playerBullet!);
        }
    }
    
    /* Not used anymore */
    func swipedRight(){
        //thePlayer.glide()
    }
    
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
        worldNode.enumerateChildNodes(withName: "levelUnit" ) {
            node, stop in
            node.removeFromParent()
        }
        
        levelUnitCounter = 0
        score = 0;
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
        
        levelUnitCounter += 1
        worldNode.addChild(levelUnit)
    }
    
    func clearNodes(){
        var nodeCount:Int = 0
        
        worldNode.enumerateChildNodes(withName: "levelUnit") {
            node, stop in
            let nodeLocation:CGPoint = self.convert(node.position, from: self.worldNode)
            
            if ( nodeLocation.x < -(self.screenWidth / 2) - self.levelUnitWidth ) {
                node.removeFromParent()
            }  else {
                nodeCount += 1
            }
        }
        //print( "levelUnits in the scene is \(nodeCount)")
    }
    
    // call before render each frame
    override func update(_ currentTime: TimeInterval) {
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
 
        if(playerBullet != nil){
            if(playerBullet!.position.x > (levelUnitWidth + thePlayer.position.x - 150)){
                playerBullet!.removeFromParent();
                playerBullet = nil;
            } else {
                playerBullet!.update();
            }
        }
        self.centerOnNode(thePlayer)
    }

    func centerOnNode(_ node:SKNode) {
        // convert to this camera
        let cameraPositionInScene:CGPoint = self.convert(node.position, from: worldNode)
        worldNode.position = CGPoint(x: worldNode.position.x - cameraPositionInScene.x - screenWidth/2 + 100 , y:0 )
    }
    
    // Handle all the collision
    func didBegin(_ contact: SKPhysicsContact) {
        // bullet and whatever
        if(contact.bodyA.categoryBitMask == BodyType.bullet.rawValue || contact.bodyB.categoryBitMask == BodyType.bullet.rawValue){
            
            if(contact.bodyB.categoryBitMask == BodyType.enemy.rawValue ){
                
                // Remove bullet
                contact.bodyA.node?.parent!.removeFromParent();
                
                /*contact.bodyB.node!.physicsBody!.dynamic = false;                 contact.bodyB.node!.physicsBody!.collisionBitMask = 0;
contact.bodyB.node!.physicsBody!.contactTestBitMask = 0;*/
                //enemyShot = true;
                
                //contact.bodyB.node?.physicsBody = nil;
                contact.bodyB.node!.physicsBody!.categoryBitMask = 0;
            
                contact.bodyB.node!.run(enemyDieAction!, completion: {
                    contact.bodyB.node?.parent!.removeFromParent();
                    self.enemyShot = false;
                });
                
            } else if(contact.bodyA.categoryBitMask == BodyType.enemy.rawValue ){
                
                // Remove bullet
                contact.bodyB.node?.parent!.removeFromParent();
                //contact.bodyA.node!.runAction(enemyDieAction!);
                //contact.bodyA.node!.physicsBody!.dynamic = false;
                //contact.bodyA.node!.physicsBody!.collisionBitMask = 0;
                //contact.bodyB.node!.physicsBody!.contactTestBitMask = 0;
                //contact.bodyA.node?.physicsBody = nil;
                //enemyShot = true;
                contact.bodyA.node!.physicsBody!.categoryBitMask = 0;
                
                contact.bodyA.node!.run(enemyDieAction!, completion: {
                    contact.bodyA.node?.parent!.removeFromParent();
                    //self.enemyShot = false;
                });
            } else {
                // Just remove if not enemy
                //deathObjectShot = true;
                
                if(contact.bodyA.categoryBitMask == BodyType.bullet.rawValue){
                  
                    contact.bodyB.node!.physicsBody!.categoryBitMask = 0;
                    contact.bodyB.node!.run(bulletExplodeAction!, completion:{
                        contact.bodyB.node!.removeFromParent();
                        //self.deathObjectShot = false;
                    })
                    
                    contact.bodyA.node?.parent!.removeFromParent();
                    playerBullet = nil;
                } else{
                    contact.bodyA.node!.physicsBody!.categoryBitMask = 0;
                    
                    contact.bodyA.node!.run(bulletExplodeAction!, completion:{
                        contact.bodyA.node!.removeFromParent();
                        //self.deathObjectShot = false;
                    })
                    
                    contact.bodyB.node?.parent!.removeFromParent();
                    playerBullet = nil;
                }
            }
        }
        
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
        
        /// enemyObject and player, instant death
        if (contact.bodyA.categoryBitMask == BodyType.player.rawValue  && contact.bodyB.categoryBitMask == BodyType.enemy.rawValue) {
            killPlayer()
        } else if (contact.bodyA.categoryBitMask == BodyType.enemy.rawValue  && contact.bodyB.categoryBitMask == BodyType.player.rawValue) {
            killPlayer()
        }
        
        // make sure two enemy objects aren't too close to each other
        if (contact.bodyA.categoryBitMask == BodyType.enemy.rawValue  && contact.bodyB.categoryBitMask == BodyType.enemy.rawValue ) {
            contact.bodyA.node?.parent!.removeFromParent()
        }
        
        /// water and player
        if (contact.bodyA.categoryBitMask == BodyType.player.rawValue  && contact.bodyB.categoryBitMask == BodyType.water.rawValue ) {
            killPlayer()
        } else if (contact.bodyA.categoryBitMask == BodyType.water.rawValue  && contact.bodyB.categoryBitMask == BodyType.player.rawValue ) {
            killPlayer()
        }
        
        // water and enemy
        if (contact.bodyA.categoryBitMask == BodyType.enemy.rawValue && contact.bodyB.categoryBitMask == BodyType.water.rawValue){
            contact.bodyA.node?.parent!.removeFromParent();
        } else if (contact.bodyB.categoryBitMask == BodyType.water.rawValue && contact.bodyA.categoryBitMask == BodyType.enemy.rawValue){
            contact.bodyA.node?.parent!.removeFromParent();
        }
        
        // make sure two death objects aren't too close to each other
        if (contact.bodyA.categoryBitMask == BodyType.deathObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.deathObject.rawValue ) {
            contact.bodyA.node?.parent!.removeFromParent()
        }
        
        // make sure if enemy hits death object the wheel is destroyed
        if (contact.bodyA.categoryBitMask == BodyType.enemy.rawValue  && contact.bodyB.categoryBitMask == BodyType.deathObject.rawValue ) {
            contact.bodyB.node?.parent!.removeFromParent()
        } else if (contact.bodyA.categoryBitMask == BodyType.deathObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.enemy.rawValue ) {
            contact.bodyA.node?.parent!.removeFromParent()
        }
        
        // collect Money
        if (contact.bodyA.categoryBitMask == BodyType.moneyObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.player.rawValue ) {
            contact.bodyA.node?.parent!.removeFromParent()
            // insert code to tally up variable for collecting money
            
        } else if (contact.bodyA.categoryBitMask == BodyType.player.rawValue  && contact.bodyB.categoryBitMask == BodyType.moneyObject.rawValue ) {
            
            contact.bodyB.node?.parent!.removeFromParent()
            // insert code to tally up variable for collecting money
            score+=1;
        }
        
        // switch body to non dynamic
        if (contact.bodyA.categoryBitMask == BodyType.ground.rawValue  && contact.bodyB.categoryBitMask == BodyType.deathObject.rawValue ) {
            contact.bodyB.node?.physicsBody!.isDynamic = false
        } else if (contact.bodyA.categoryBitMask == BodyType.deathObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.ground.rawValue ) {
            contact.bodyA.node?.physicsBody!.isDynamic = false
        }
        
        // if the player hits the ground....
        if (contact.bodyA.categoryBitMask == BodyType.ground.rawValue  && contact.bodyB.categoryBitMask == BodyType.player.rawValue ) {
            thePlayer.physicsBody?.isDynamic = true
            if (thePlayer.isRunning == false && thePlayer.isShooting == false) {
                thePlayer.startRun()
            }
            
        } else if (contact.bodyA.categoryBitMask == BodyType.player.rawValue  && contact.bodyB.categoryBitMask == BodyType.ground.rawValue ) {
            
            thePlayer.physicsBody?.isDynamic = true
            if (thePlayer.isRunning == false && thePlayer.isShooting == false)  {
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
            
            thePlayer.physicsBody?.isDynamic = true
            
            if ( thePlayer.isRunning == false && thePlayer.isShooting == false) {
                thePlayer.startRun()
            }
            
        } else if (contact.bodyA.categoryBitMask == BodyType.platformObject.rawValue  && contact.bodyB.categoryBitMask == BodyType.player.rawValue ) {
            
            onPlatform = true
            currentPlatform =  contact.bodyA.node! as? SKSpriteNode
            
            thePlayer.physicsBody?.isDynamic = true
            
            if ( thePlayer.isRunning == false && thePlayer.isShooting == false) {
                thePlayer.startRun()
            }
        }
    }
    
    // Physics contact ends
    func didEnd(_ contact: SKPhysicsContact) {
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
        if (isDead == false) {
            isDead = true
            
            loopingBG.removeAllActions()
            loopingBG2.removeAllActions()
            
            thePlayer.physicsBody!.isDynamic = false
            
            // fade out plaeyer
            
            let fadeOut:SKAction = SKAction.fadeAlpha(to: 0, duration: 0.2)
            let move:SKAction = SKAction.move(to: playerStartingPos, duration: 0.0)
            let block:SKAction = SKAction.run(revivePlayer)
            let seq:SKAction = SKAction.sequence([fadeOut, move, block])
            
            thePlayer.run(seq)
            
            // fade out BG
            
            let fadeOutBG:SKAction = SKAction.fadeAlpha(to: 0, duration: 0.2)
            let blockBG:SKAction = SKAction.run(resetLoopingBackground)
            let fadeInBG:SKAction = SKAction.fadeAlpha(to: 1, duration: 0.2)
            let seqBG:SKAction = SKAction.sequence([fadeOutBG, blockBG, fadeInBG])
            loopingBG.run(seqBG)
            loopingBG2.run(seqBG)
        }
    }
    
    func revivePlayer() {
        //will fade out worldNode and reset the level with new units
        let fadeOut:SKAction = SKAction.fadeAlpha(to: 0, duration: 0.2)
        let block:SKAction = SKAction.run(resetLevel)
        let fadeIn:SKAction = SKAction.fadeAlpha(to: 1, duration: 0.2)
        let seq:SKAction = SKAction.sequence([fadeOut, block, fadeIn])
        worldNode.run(seq)
        
        // fade in player and revive
        let wait:SKAction = SKAction.wait(forDuration: 1)
        let fadeIn2:SKAction = SKAction.fadeAlpha(to: 1, duration: 0.2)
        let block2:SKAction = SKAction.run(noLongerDead)
        let seq2:SKAction = SKAction.sequence([wait , fadeIn2, block2])
        thePlayer.run(seq2)
    }
    
    func noLongerDead() {
        isDead = false
        thePlayer.startRun()
        startLoopingBackground()
        thePlayer.physicsBody!.isDynamic = true
    }
    
    
    func resetLoopingBackground(){
        loopingBG.position = CGPoint(x: 0, y: 0)
        loopingBG2.position = CGPoint(x: loopingBG2.size.width - 3, y: 0)
    }
}
