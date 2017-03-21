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
    
    init(imageTexture: SKTexture, points: Int) {
        self.points = points
        super.init(texture: imageTexture, color: UIColor.clear, size: imageTexture.size())
        self.physicsBody = SKPhysicsBody(rectangleOf: imageTexture.size())
        self.physicsBody?.isDynamic = true
        self.physicsBody?.isResting = false
        self.physicsBody?.affectedByGravity = false
        //self.physicsBody?.velocity = CGVector(dx: 8, dy: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
