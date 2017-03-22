//
//  SpaceInvader.swift
//  Space Invaders
//
//  Created by María Victoria Cavo on 17/3/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import SpriteKit

class SpaceInvader : SKSpriteNode {
    
    var points : Int = 0
    var movingFrames : [SKTexture]
    var deathFrames : [SKTexture]
    
    init(initTexture: SKTexture, movingTextures: [SKTexture], deathTextures: [SKTexture], points: Int) {
        self.points = points
        self.movingFrames = movingTextures
        self.deathFrames = deathTextures
        super.init(texture: initTexture, color: UIColor.clear, size: initTexture.size())
        self.physicsBody = SKPhysicsBody(rectangleOf: initTexture.size())
        self.physicsBody?.isDynamic = true
        self.physicsBody?.isResting = false
        self.physicsBody?.affectedByGravity = false
        //self.physicsBody?.velocity = CGVector(dx: 8, dy: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startMoveAction() {
        self.run(SKAction.repeatForever(
            SKAction.animate(with: movingFrames,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true)),
                    withKey:"movingInvader")
    }
    
    func startDeathAction() {
        self.removeAction(forKey: "movingInvader")
        let actionShowExplotion = SKAction.animate(with: deathFrames, timePerFrame: 0.2)
        let actionRemove = SKAction.removeFromParent()
        self.run(SKAction.sequence([actionShowExplotion, actionRemove]))
    }
    

}
