//
//  GameScene.swift
//  Space Invaders
//
//  Created by María Victoria Cavo on 17/3/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//


import SpriteKit

class GameScene: SKScene {
    
    let spaceInvadersPerRow = 8
    //let motionManager = CMMotionManager()
    
    let kShipName = "SpaceShip"
    let kSpaceInvaderName = "SpaceInvader"
    let kscoreName = "Score"
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        addSpaceInvaders()
        addSpaceShip()
        //motionManager.startAccelerometerUpdates()
        
        }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    func addSpaceShip() {
        let ship = Ship(imageNamed: "SpaceShip")
        ship.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        ship.name = kShipName
        addChild(ship)
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
    
}
