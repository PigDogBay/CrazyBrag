//
//  GameScene.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 28/06/2023.
//

import SpriteKit

class GameScene: SKScene, GameView {
    var cardNodes = [CardSpriteNode]()
    private var lastGameUpdateTime = TimeInterval()
    private let gameUpdateFrequency = TimeInterval(floatLiteral: 1.0)

    lazy var presenter  = GamePresenter(size: self.size, view: self)
    
    func createCardNodes() {
        cardNodes = presenter.model.deck.deck.map {
            CardSpriteNode(card: $0, cardSize: presenter.tableLayout.cardSize)
        }
        for card in cardNodes {
            addChild(card)
        }
    }
    
    override func didMove(to view: SKView) {
        addBackground(imageNamed: "treestump")
        createCardNodes()
        presenter.allCardsToDeck()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (currentTime - lastGameUpdateTime) > gameUpdateFrequency {
            presenter.update()
            lastGameUpdateTime = currentTime
        }
    }

    ///
    ///GameView:-
    ///

    func setZPosition(on card: PlayingCard, z: CGFloat) {
        if let cardNode = cardNodes.first(where: {$0.playingCard == card}) {
            cardNode.zPosition = z
        }
    }
    
    func setPosition(on card: PlayingCard, pos: CGPoint) {
        if let cardNode = cardNodes.first(where: {$0.playingCard == card}) {
            cardNode.position = pos
        }
    }
    
    func turn(card: PlayingCard, isFaceUp: Bool) {
        if let cardNode = cardNodes.first(where: {$0.playingCard == card}) {
            if isFaceUp {cardNode.faceUp()} else {cardNode.faceDown()}
        }
    }
    
     func addName(name : String, pos : CGPoint){
        let label = SKLabelNode(fontNamed: "HelveticaNeue")
        label.text = name
        label.fontColor = SKColor.white
        label.fontSize = 24
        label.verticalAlignmentMode = .bottom
        label.horizontalAlignmentMode = .left
        label.position = pos
        label.zPosition = 200
        addChild(label)
    }
    
    func addLives(pos : CGPoint){
        let label = SKLabelNode(fontNamed: "HelveticaNeue")
        label.text = "🔴🔴🔴"
        label.fontSize = 18
        label.verticalAlignmentMode = .bottom
        label.horizontalAlignmentMode = .right
        label.position = pos
        label.zPosition = 200
        addChild(label)
    }
    
    private func addBackground(imageNamed image : String){
        let background = SKSpriteNode(imageNamed: image)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1
        addChild(background)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchNode = atPoint(location)
            switch touchNode.name {
            case "KH":
                selectCard(name: "KH")
            case "AS":
                selectBoxCard(name: "AS")
            case "3H":
                swapCards()
            default:
                break
            }
        }
    }

    private func selectCard(name : String){
        let card = self.childNode(withName: name)
        let action = SKAction.move(by: CGVector(dx: 0, dy: 50), duration: 0.2)
        card?.run(action)
    }
    private func selectBoxCard(name : String){
        let card = self.childNode(withName: name)
        let action = SKAction.move(by: CGVector(dx: 0, dy: -50), duration: 0.2)
        card?.run(action){
            self.swapCards()
        }
    }
    
    private func swapCards(){
        let playerCard = self.childNode(withName: "KH")
        let boxCard = self.childNode(withName: "AS")
        let playerAction = SKAction.move(to: presenter.tableLayout.boxLayout.position3, duration: 0.2)
        let boxAction = SKAction.move(to: presenter.tableLayout.playerLayout.position1, duration: 0.2)
        playerCard?.run(playerAction)
        boxCard?.run(boxAction)
        
    }

}
