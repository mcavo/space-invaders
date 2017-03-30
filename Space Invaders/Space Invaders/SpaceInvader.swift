//
//  SpaceInvader.swift
//  Space Invaders
//
//  Created by María Victoria Cavo on 17/3/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import SpriteKit

struct Direction {
    static let Right     : Int = 1
    static let Left      : Int = -1
}

class SpaceInvader : SKSpriteNode {
    
    var points       : Int = 0
    var movingFrames : [SKTexture]
    var deathFrames  : [SKTexture]
    var direction    : Int = Direction.Right
    var limitLeft    : CGFloat = 0.0
    var limitRigth   : CGFloat = 0.0
    
    var row          : Int = 0
    var col          : Int = 0
    
    init(initTexture: SKTexture, movingTextures: [SKTexture], deathTextures: [SKTexture], points: Int) {
        self.points = points
        self.movingFrames = movingTextures
        self.deathFrames = deathTextures
        super.init(texture: initTexture, color: UIColor.clear, size: initTexture.size())
        self.physicsBody = SKPhysicsBody(rectangleOf: initTexture.size())
        self.physicsBody?.isDynamic = true
        self.physicsBody?.isResting = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.angularDamping = 0.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startMoveAction() {
        self.run(SKAction.repeatForever(
            SKAction.animate(with: movingFrames,
                             timePerFrame: 0.1,
                             resize: true,
                             restore: true)),
                    withKey:"movingInvader")
    }
    
    func startDeathAction() {
        self.removeAction(forKey: "movingInvader")
        let actionShowExplotion = SKAction.animate(with: deathFrames, timePerFrame: 0.2)
        let actionSoundExplotion = SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false)
        let actionRemove = SKAction.removeFromParent()
        let actionExplotion = SKAction.group([actionShowExplotion, actionSoundExplotion])
        self.run(SKAction.sequence([actionExplotion, actionRemove]))
    }
    
    func isOutsideLimits() -> Bool {
        switch self.direction {
        case Direction.Right:
            return self.position.x > self.limitRigth
        default:
            return self.position.x < self.limitLeft
        }
    }

}
