//
//  StartScene.swift
//  Cards
//
//  Created by Mark Bailey on 22/06/2023.
//

import Foundation
import SpriteKit

class StartScene: SKScene {
    let cardQH = CardSpriteNode(card: PlayingCard(suit: .hearts, rank: .queen), cardSize: CGSize(width: 100, height: 152))

    override func didMove(to view: SKView) {
        
        addBackground(imageNamed: "treestump")
        let topLabel = SKLabelNode(fontNamed: "QuentinCaps")
        topLabel.text = "Crazy Brag"
        topLabel.fontColor = SKColor.white
        topLabel.fontSize = 48
        topLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.4)
        addChild(topLabel)

        cardQH.position = CGPoint(x: frame.midX, y: 0)
        addChild(cardQH)
        
        let action = SKAction.move(by: CGVector(dx: 0, dy: frame.midY), duration: 1)
        cardQH.run(action)
        
        addStartButton()

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchNode = atPoint(location)
            switch touchNode.name {
            case "start button":
                let transition = SKTransition.doorway(withDuration: 1)
                view?.presentScene(GameScene(size: frame.size), transition: transition)
                break
            default:
                break
            }
        }
    }

    private func addBackground(imageNamed image : String){
        let background = SKSpriteNode(imageNamed: image)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1
        addChild(background)
    }
    
    private func addStartButton(){
        let label = SKLabelNode(fontNamed: "QuentinCaps")
        label.text = "DEAL"
        label.fontColor = SKColor.red
        label.fontSize = 36
        label.position = CGPoint(x: frame.midX, y: frame.height * 0.2 )
        label.zPosition = 10
        label.name="start button"
        addChild(label)

    }
}
