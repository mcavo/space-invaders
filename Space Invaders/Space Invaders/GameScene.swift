//
//  GameScene.swift
//  Space Invaders
//
//  Created by María Victoria Cavo on 17/3/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//


import SpriteKit
import CoreMotion

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Invader   : UInt32 = 0b1       // 1
    static let SpaceShip : UInt32 = 0b10      // 2
    static let Projectile: UInt32 = 0b11      // 3
    static let SceneEdge : UInt32 = 0b100     // 4
    
    let kInvaderCategory: UInt32 = 0x1 << 0
    let kShipFiredBulletCategory: UInt32 = 0x1 << 1
    let kShipCategory: UInt32 = 0x1 << 2
    let kSceneEdgeCategory: UInt32 = 0x1 << 3
    let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4
    
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let kSpaceInvadersPerRow = 8
    // *****
    let motionManager = CMMotionManager()
    // *****
    let kShipName = "SpaceShip"
    let kSpaceInvaderName = "SpaceInvader"
    let kSpaceInvaderProjectileName = "SpaceInvaderProjectile"
    let kSpaceShipProjectileName = "SpaceShipProjectile"
    let kScoreName = "Score"
    var kScore : Int = 0
    
    let kInvaderVelocity = 10
    let kProjectileVelocity = 200
    
    var mapSpaceInvaders : [Int : [Int : SpaceInvader]] = [:]
    var amountOfInvadersPerCol : [Int : Int] = [:]
    
    var percentage = 0.0
    
    var spaceInvaderBulletAtScene : Bool = false
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        let delta = 0.75 * Double((kSpaceInvadersPerRow+1) % 2)
        percentage = -(ceil(Double(kSpaceInvadersPerRow)/2.0 - 1) * 1.5 + delta)
        physicsBody!.categoryBitMask = PhysicsCategory.SceneEdge
        addGameStatus()
        addSpaceInvaders()
        addSpaceShip()
        // *****
        motionManager.startAccelerometerUpdates()
        // *****
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateSpaceShipMotion(forUpdate: currentTime)
        updateSpaceInvaders()
        updateProjectiles()
        updateScore()
    }
    
    func updateSpaceInvaders() {
        if mapSpaceInvaders.isEmpty {
            addSpaceInvaders()
        }
        self.enumerateChildNodes(withName: kSpaceInvaderName) {
            node, stop in
            if let invader = node as? SpaceInvader {
                let maxRow = self.amountOfInvadersPerCol.keys.max()
                let minRow = self.amountOfInvadersPerCol.keys.min()
                let positionX = CGFloat(Double(self.size.width * 0.5) + (self.percentage + 1.5 * Double(invader.col)) * Double(invader.size.width))
                let positionXMax = CGFloat(Double(self.size.width * 0.5) + (self.percentage + 1.5 * Double(maxRow!)) * Double(invader.size.width))
                let positionXMin = CGFloat(Double(self.size.width * 0.5) + (self.percentage + 1.5 * Double(minRow!)) * Double(invader.size.width))
                
                invader.limitLeft = positionX - (positionXMin - invader.size.width)
                invader.limitRigth = positionX + self.size.width - invader.size.width - positionXMax
                //Check is inside bounds
                if invader.isOutsideLimits() {
                    invader.position.y -= invader.size.height
                    invader.direction *= -1
                    //Update velocity
                    invader.physicsBody!.velocity = CGVector(dx: self.kInvaderVelocity * invader.direction, dy: 0)
                }
            }
        }
        if !spaceInvaderBulletAtScene {
            
            spaceInvaderBulletAtScene = true
            let colToShoot = Int(arc4random_uniform(UInt32(mapSpaceInvaders.keys.count)))
            let rowToShoot = mapSpaceInvaders[colToShoot]?.keys.min()

            addSpaceInvaderProjectile(invader: (mapSpaceInvaders[colToShoot]?[rowToShoot!])!)
        }
        
    }
    
    func updateProjectiles() {
        self.enumerateChildNodes(withName: kSpaceShipProjectileName) {
            node, stop in
            if let projectile = node as? Projectile {
                if projectile.position.y > self.size.height - 2 * projectile.frame.size.height {
                    projectile.removeFromParent()
                }
            }
        }
        if spaceInvaderBulletAtScene {
            if let projectile = childNode(withName: kSpaceInvaderProjectileName) as? SKSpriteNode {
                if projectile.position.y <  2 * projectile.frame.size.height {
                    spaceInvaderBulletAtScene = false
                    projectile.removeFromParent()
                }
            }
        }
        
        if let ship = childNode(withName: kShipName) as? SKSpriteNode {
            if let data = motionManager.accelerometerData {
                if fabs(data.acceleration.x) > 0.2 {
                    ship.physicsBody!.applyForce(CGVector(dx: 10 * CGFloat(data.acceleration.x), dy: 0))
                }
            }
        }
    }
    
    func updateScore() {
        if let scoreLabel = childNode(withName: kScoreName) as? SKLabelNode {
            scoreLabel.text = String(format: "SCORE: %06u", kScore)
            scoreLabel.position = CGPoint(
                x: frame.size.width * 0.1 + scoreLabel.frame.size.width * 0.5,
                y: size.height - (40 + scoreLabel.frame.size.height/2)
            )
        }
    }
    
    func addGameStatus() {
        addScore()
        addLifes()
    }
    
    func addScore() {
        let scoreLabel = SKLabelNode(fontNamed: "PressStartK")
        scoreLabel.name = kScoreName
        scoreLabel.fontSize = 12
        scoreLabel.fontColor = SKColor.white
        scoreLabel.text = String(format: "SCORE: %06u", kScore)
        scoreLabel.position = CGPoint(
            x: frame.size.width * 0.1 + scoreLabel.frame.size.width * 0.5,
            y: size.height - (40 + scoreLabel.frame.size.height/2)
        )
        addChild(scoreLabel)
    }
    
    // TODO: Show lifes
    func addLifes() {
    }
    
    func addSpaceShip() {
        let ship = Ship(imageNamed: "SpaceShip", start: CGPoint(x: size.width * 0.5, y: size.height * 0.1))
        ship.name = kShipName
        // *****
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.frame.size)
        ship.physicsBody!.isDynamic = true
        ship.physicsBody!.affectedByGravity = false
        ship.physicsBody!.mass = 0.01
        ship.physicsBody!.allowsRotation = false
        ship.physicsBody!.categoryBitMask = PhysicsCategory.SpaceShip
        ship.physicsBody!.contactTestBitMask = 0x0
        ship.physicsBody!.collisionBitMask = PhysicsCategory.SceneEdge
        addChild(ship)
    }
    
    func addProjectile(imageNamed: String, direction : Int, shooter : SKNode) -> Projectile {
        let projectile = Projectile(imageNamed: imageNamed, direction: direction)
        var positionY : CGFloat = shooter.position.y
        positionY += CGFloat(direction) * shooter.frame.size.height * 0.5
        positionY += CGFloat(direction) * projectile.size.height
        projectile.position = CGPoint(x: shooter.position.x, y: positionY)
        projectile.physicsBody!.velocity = CGVector(dx: 0, dy: self.kProjectileVelocity * projectile.direction)
        return projectile
    }
    
    func addSpaceShipProjectile() {
        if let ship = childNode(withName: kShipName) {
            let projectile = addProjectile(imageNamed: "Projectile", direction: 1, shooter: ship)
            projectile.name = kSpaceShipProjectileName
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Invader
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            addChild(projectile)
            run(SKAction.playSoundFileNamed("ShipBullet.wav", waitForCompletion: false))
        }
    }
    
    func addSpaceInvaderProjectile(invader : SpaceInvader) {
        let projectile = addProjectile(imageNamed: "InvaderProjectile", direction: -1, shooter: invader)
        projectile.name = kSpaceInvaderProjectileName
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.SpaceShip
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        addChild(projectile)
        run(SKAction.playSoundFileNamed("ShipBullet.wav", waitForCompletion: false))
    }
    
    func addSpaceInvaders() {
        for i in 0..<kSpaceInvadersPerRow {
            amountOfInvadersPerCol[i] = 5
            mapSpaceInvaders[i] = [:]
        }
        populateRow(atlasName:"SpaceInvader_1", points: 10, row: 0)
        populateRow(atlasName:"SpaceInvader_1", points: 10, row: 1)
        populateRow(atlasName:"SpaceInvader_2", points: 20, row: 2)
        populateRow(atlasName:"SpaceInvader_2", points: 20, row: 3)
        populateRow(atlasName:"SpaceInvader_3", points: 30, row: 4)
        
    }
    
    func populateRow(atlasName: String, points: Int, row: Int) {
        
        for inv in 0..<kSpaceInvadersPerRow {
            let frames = getSKTextureArrayFromAtlasName(atlasName: atlasName)
            let deathFrames : [SKTexture] = [SKTexture(imageNamed: "InvaderExplotion")]
            let invader = SpaceInvader(initTexture: frames[0], movingTextures: frames, deathTextures: deathFrames, points: points)
            invader.size.width = 24.0
            invader.size.height = 16.0
            let positionX = CGFloat(Double(size.width * 0.5) + (percentage + 1.5 * Double(inv)) * Double(invader.size.width))
            let positionXMax = CGFloat(Double(size.width * 0.5) + (percentage + 1.5 * Double(kSpaceInvadersPerRow - 1)) * Double(invader.size.width))
            let positionXMin = CGFloat(Double(size.width * 0.5) + (percentage + 1.5 * Double(0)) * Double(invader.size.width))
            let positionY = CGFloat(Double(size.height * 0.6) + Double(row) * 1.5 * Double(invader.size.height))
            invader.position = CGPoint(x: positionX, y: positionY)
            invader.name = kSpaceInvaderName
            
            invader.limitLeft = positionX - (positionXMin - invader.size.width)
            invader.limitRigth = positionX + size.width - invader.size.width - positionXMax
            
            invader.col = inv
            invader.row = row
            
            invader.physicsBody?.categoryBitMask = PhysicsCategory.Invader
            invader.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
            invader.physicsBody?.collisionBitMask = PhysicsCategory.None
            invader.physicsBody?.velocity = CGVector(dx: self.kInvaderVelocity * invader.direction, dy: 0)
            addChild(invader)
            mapSpaceInvaders[invader.col]?[invader.row] = invader
            invader.startMoveAction()
        }
    }
    
    func getSKTextureArrayFromAtlasName(atlasName: String) -> [SKTexture] {
        let kAnimatedAtlas = SKTextureAtlas(named: atlasName)
        var kFrames = [SKTexture]()
        
        for kTexture in kAnimatedAtlas.textureNames {
            kFrames.append(kAnimatedAtlas.textureNamed(kTexture))
        }
        
        return kFrames
    }
    // *****
    func updateSpaceShipMotion(forUpdate currentTime: CFTimeInterval) {
        if let ship = childNode(withName: kShipName) as? Ship {
            if let data = motionManager.accelerometerData {
                if fabs(data.acceleration.x) > 0.2 {
                    ship.physicsBody!.applyForce(CGVector(dx: 10 * CGFloat(data.acceleration.x), dy: 0))
                }
            }
        }
    }
    // *****
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if ((firstBody.categoryBitMask & PhysicsCategory.Invader != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            if let invader = firstBody.node as? SpaceInvader, let
                projectile = secondBody.node as? Projectile {
                projectileDidCollideWithInvader(projectile: projectile, invader: invader)
            }
        } else if ((firstBody.categoryBitMask & PhysicsCategory.SpaceShip != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            if let ship = firstBody.node as? Ship, let
                projectile = secondBody.node as? Projectile {
                projectileDidCollideWithSpaceShip(projectile: projectile, ship: ship)
            }
        }
        
    }
    
    func projectileDidCollideWithSpaceShip(projectile: Projectile, ship: Ship) {
        projectile.removeFromParent()
        spaceInvaderBulletAtScene = false
        ship.startDeathAction()
    }
    
    func projectileDidCollideWithInvader(projectile: Projectile, invader: SpaceInvader) {
        kScore += invader.points
        projectile.removeFromParent()
        invader.physicsBody?.categoryBitMask = PhysicsCategory.None
        if amountOfInvadersPerCol[invader.col]! == 1 {
            amountOfInvadersPerCol.removeValue(forKey: invader.col)
        }
        else {
            amountOfInvadersPerCol[invader.col]! -= 1
        }
        mapSpaceInvaders[invader.col]!.removeValue(forKey: invader.row)
        if (mapSpaceInvaders[invader.col]?.isEmpty)! {
            mapSpaceInvaders.removeValue(forKey: invader.col)
        }
        invader.startDeathAction()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        addSpaceShipProjectile()
    }
}
