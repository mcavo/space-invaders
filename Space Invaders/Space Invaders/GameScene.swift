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
    
    let kProjectileVelocity = CGVector(dx: 0, dy: 100)
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        addSpaceInvaders()
        addSpaceShip()
        // *****
        motionManager.startAccelerometerUpdates()
        // *****
        }
    
    override func update(_ currentTime: TimeInterval) {
        processSpaceShipMotion(forUpdate: currentTime)
        updateProjectiles()
    }
    
    func updateProjectiles() {
        self.enumerateChildNodes(withName: "Projectile") {
            node, stop in
            node.physicsBody!.velocity = self.kProjectileVelocity
            if node.position.y > self.size.height - 2 * node.frame.size.height {
                node.removeFromParent()
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
            let projectile = Projectile(imageNamed: "Projectile")
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
        populateRow(atlasName:"SpaceInvader_1", row: 0)
        populateRow(atlasName:"SpaceInvader_1", row: 1)
        populateRow(atlasName:"SpaceInvader_2", row: 2)
        populateRow(atlasName:"SpaceInvader_2", row: 3)
        populateRow(atlasName:"SpaceInvader_3", row: 4)
    }
    
    func populateRow(atlasName: String, row: Int) {
        
        let delta = 0.75 * Double((spaceInvadersPerRow+1) % 2)
        let percentage = -(ceil(Double(spaceInvadersPerRow)/2.0 - 1) * 1.5 + delta)
        
        for inv in 0..<spaceInvadersPerRow {
            let frames = getSKTextureArrayFromAtlasName(atlasName: atlasName)
            let invader = SpaceInvader(imageTexture: frames[0])
            let positionX = CGFloat(Double(size.width * 0.5) + (percentage + 1.5 * Double(inv)) * Double(invader.size.width))
            let positionY = CGFloat(Double(size.height * 0.6) + Double(row) * 1.5 * Double(invader.size.height))
            invader.position = CGPoint(x: positionX, y: positionY)
            invader.name = kSpaceInvaderName
            invader.physicsBody?.categoryBitMask = PhysicsCategory.Invader
            invader.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
            invader.physicsBody?.collisionBitMask = PhysicsCategory.None
            addChild(invader)
            invader.run(SKAction.repeatForever(
                SKAction.animate(with: frames,
                                             timePerFrame: 0.1,
                                             resize: false,
                                             restore: true)),
                               withKey:"walkingInvader")
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
    func processSpaceShipMotion(forUpdate currentTime: CFTimeInterval) {
        if let ship = childNode(withName: kShipName) as? Ship {
            if let data = motionManager.accelerometerData {
                if fabs(data.acceleration.x) > 0.2 {
                    ship.physicsBody!.applyForce(CGVector(dx: 10 * CGFloat(data.acceleration.x), dy: 0))
                }
            }
        }
    }
    // *****
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        addProjectile()
    }
    
    func projectileDidCollideWithInvader(projectile: SKSpriteNode, invader: SKSpriteNode) {
        // TODO: Add Score
        print("Hit")
        projectile.removeFromParent()
        invader.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Invader != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            if let invader = firstBody.node as? SKSpriteNode, let
                projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithInvader(projectile: projectile, invader: invader)
            }
        }
        
    }
    
}
