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
        topLabel.fontColor = SKColor.black
        topLabel.fontSize = 48
        topLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.5)
        topLabel.zPosition = Layer.messages.rawValue
        addChild(topLabel)

        cardQH.position = CGPoint(x: frame.midX, y: 0)
        cardQH.zPosition = Layer.card1.rawValue
        addChild(cardQH)
        
        let action = SKAction.move(by: CGVector(dx: 0, dy: frame.midY), duration: 1)
        cardQH.run(action)
        
        addStartButton()

    }

    private func startGame(){
        let transition = SKTransition.doorway(withDuration: 1)
        self.view?.presentScene(GameScene(size: self.frame.size), transition: transition)
    }

    private func addBackground(imageNamed image : String){
        let background = SKSpriteNode(imageNamed: image)
        background.anchorPoint = CGPoint(x: 1.0, y: 1.0)
        background.position = CGPoint(x: frame.maxX, y: frame.maxY)
        background.zPosition = Layer.background.rawValue
        addChild(background)
    }
    
    private func addStartButton(){
        let button = ButtonNode(label: "DEAL", fontSize: 36.0){ [weak self] in
            self?.startGame()
        }
        button.position = CGPoint(x: frame.midX, y: frame.height * 0.2 )
        button.zPosition = Layer.ui.rawValue
        addChild(button)
    }
}
