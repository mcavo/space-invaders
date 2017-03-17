import SpriteKit

class GameScene: SKScene {
    
    let spaceInvadersPerRow = 8
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        populateSpaceInvaders()
    }
    
    func populateSpaceInvaders() {
        populateRow(invaderTexture:"SpaceInvader_1_0", row: 0)
        populateRow(invaderTexture:"SpaceInvader_1_0", row: 1)
        populateRow(invaderTexture:"SpaceInvader_2_0", row: 2)
        populateRow(invaderTexture:"SpaceInvader_2_0", row: 3)
        populateRow(invaderTexture:"SpaceInvader_3_0", row: 4)
    }
    
    func populateRow(invaderTexture: String, row: Int) {
        
        let delta = 0.75 * Double((spaceInvadersPerRow+1) % 2)
        let percentage = -(ceil(Double(spaceInvadersPerRow)/2.0 - 1) * 1.5 + delta)
        
        print(delta)
        print(percentage)
        
        for inv in 0..<spaceInvadersPerRow {
            let invader = SKSpriteNode(imageNamed: invaderTexture)
            let positionX = CGFloat(Double(size.width * 0.5) + (percentage + 1.5 * Double(inv)) * Double(invader.size.width))
            let positionY = CGFloat(Double(size.height * 0.6) + Double(row) * 1.5 * Double(invader.size.height))
            invader.position = CGPoint(x: positionX, y: positionY)
            addChild(invader)
        }
        
    }
}
