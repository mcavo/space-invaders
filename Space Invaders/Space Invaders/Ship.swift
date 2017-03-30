//
//  Ship.swift
//  Space Invaders
//
//  Created by María Victoria Cavo on 17/3/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import SpriteKit

class Ship: SKSpriteNode {
    
    var lives        : Int = 3
    
    var deathFrames  : [SKTexture] = [SKTexture(imageNamed: "SpaceShipExplotion")]
    var idleFrames   : [SKTexture] = []
    
    var start   : CGPoint = CGPoint(x: 0, y: 0)
    
    init(imageNamed: String, start : CGPoint) {
        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: imageTexture, color: UIColor.clear, size: imageTexture.size())
        self.start = start
        self.position = start
        self.idleFrames = [imageTexture]
        self.physicsBody = SKPhysicsBody(rectangleOf: imageTexture.size())
        self.physicsBody?.isDynamic = true
        self.physicsBody?.isResting = false
        self.physicsBody?.affectedByGravity = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startDeathAction() {
        lives -= 1
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        let actionShowExplotion = SKAction.animate(with: deathFrames, timePerFrame: 0.2)
        let actionSoundExplotion = SKAction.playSoundFileNamed("ShipHit.wav", waitForCompletion: false)
        let actionExplotion = SKAction.group([actionShowExplotion, actionSoundExplotion])
        if lives == 0 {
            let actionRemove = SKAction.removeFromParent()
            self.run(SKAction.sequence([actionExplotion, actionRemove]))
        } else {
            let actionRestartPosition = SKAction.move(to: start, duration: 0)
            let actionRestartLook = SKAction.animate(with: idleFrames, timePerFrame: 0.1)
            self.run(SKAction.sequence([actionExplotion, actionRestartPosition, actionRestartLook]))
        }
    }
    
}
