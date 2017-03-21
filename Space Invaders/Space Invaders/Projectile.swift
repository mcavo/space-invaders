//
//  Projectile.swift
//  Space Invaders
//
//  Created by María Victoria Cavo on 21/3/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import SpriteKit

class Projectile : SKSpriteNode {
    
    init(imageNamed: String) {
        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: imageTexture, color: UIColor.clear, size: imageTexture.size())
        self.physicsBody = SKPhysicsBody(rectangleOf: imageTexture.size())
        self.physicsBody?.isDynamic = true
        self.physicsBody?.isResting = false
        self.physicsBody?.affectedByGravity = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
