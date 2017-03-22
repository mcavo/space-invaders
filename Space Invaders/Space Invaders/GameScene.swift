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
    static let Projectile: UInt32 = 0b10      // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let spaceInvadersPerRow = 8
    // *****
    let motionManager = CMMotionManager()
    // *****
    let kShipName = "SpaceShip"
    let kSpaceInvaderName = "SpaceInvader"
    let kScoreName = "Score"
    var kScore : Int = 0
    
    let kProjectileVelocity = 200
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        addGameStatus()
        addSpaceInvaders()
        addSpaceShip()
        // *****
        motionManager.startAccelerometerUpdates()
        // *****
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateSpaceShipMotion(forUpdate: currentTime)
        updateProjectiles()
        updateScore()
    }
    
    func updateProjectiles() {
        self.enumerateChildNodes(withName: "Projectile") {
            node, stop in
            if let projectile = node as? Projectile {
                projectile.physicsBody!.velocity = CGVector(dx: 0, dy: self.kProjectileVelocity * projectile.direction)
                if projectile.position.y > self.size.height - 2 * projectile.frame.size.height {
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
        let ship = Ship(imageNamed: "SpaceShip")
        ship.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        ship.name = kShipName
        // *****
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.frame.size)
        ship.physicsBody!.isDynamic = true
        ship.physicsBody!.affectedByGravity = false
        ship.physicsBody!.mass = 0.01
        ship.physicsBody!.allowsRotation = false
        // *****
        addChild(ship)
    }
    
    func addProjectile() {
        if let ship = childNode(withName: kShipName) {
            let projectile = Projectile(imageNamed: "Projectile", direction: 1)
            projectile.position = CGPoint(x: ship.position.x, y: ship.position.y + ship.frame.size.height * 0.5 + projectile.size.height)
            projectile.name = "Projectile"
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Invader
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            addChild(projectile)
        }
    }
    
    func addSpaceInvaders() {
        populateRow(atlasName:"SpaceInvader_1", points: 10, row: 0)
        populateRow(atlasName:"SpaceInvader_1", points: 10, row: 1)
        populateRow(atlasName:"SpaceInvader_2", points: 20, row: 2)
        populateRow(atlasName:"SpaceInvader_2", points: 20, row: 3)
        populateRow(atlasName:"SpaceInvader_3", points: 30, row: 4)
    }
    
    func populateRow(atlasName: String, points: Int, row: Int) {
        
        let delta = 0.75 * Double((spaceInvadersPerRow+1) % 2)
        let percentage = -(ceil(Double(spaceInvadersPerRow)/2.0 - 1) * 1.5 + delta)
        
        for inv in 0..<spaceInvadersPerRow {
            let frames = getSKTextureArrayFromAtlasName(atlasName: atlasName)
            let deathFrames : [SKTexture] = [SKTexture(imageNamed: "InvaderExplotion")]
            let invader = SpaceInvader(initTexture: frames[0], movingTextures: frames, deathTextures: deathFrames, points: points)
            let positionX = CGFloat(Double(size.width * 0.5) + (percentage + 1.5 * Double(inv)) * Double(invader.size.width))
            let positionY = CGFloat(Double(size.height * 0.6) + Double(row) * 1.5 * Double(invader.size.height))
            invader.position = CGPoint(x: positionX, y: positionY)
            invader.name = kSpaceInvaderName
            invader.physicsBody?.categoryBitMask = PhysicsCategory.Invader
            invader.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
            invader.physicsBody?.collisionBitMask = PhysicsCategory.None
            addChild(invader)
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
        }
        
    }
    
    func projectileDidCollideWithInvader(projectile: Projectile, invader: SpaceInvader) {
        kScore += invader.points
        projectile.removeFromParent()
        invader.startDeathAction()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        addProjectile()
    }
}
