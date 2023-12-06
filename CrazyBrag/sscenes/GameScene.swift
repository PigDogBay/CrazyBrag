//
//  GameScene.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 28/06/2023.
//

import SpriteKit

class GameScene: SKScene, GameView {
    
    var cardNodes = [CardSpriteNode]()
    var scoreNodes = [SKLabelNode]()
    let dealerTokenNode =  SKLabelNode(fontNamed: "HelveticaNeue")
    let messageNode = MessageNode()
    
    private var lastGameUpdateTime = TimeInterval()

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
        addDealer()
        createCardNodes()
        presenter.allCardsToDeck()
        messageNode.position = presenter.tableLayout.message
        addChild(messageNode)
        for i in -1...5 {
            addTableMat(seat: i)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        presenter.update(currentTime)
    }

    //MARK: - GameView

    func setZPosition(on card: PlayingCard, z: CGFloat) {
        if let cardNode = cardNodes.first(where: {$0.playingCard == card}) {
            cardNode.zPosition = z
        }
    }
    
    func setPosition(on card: PlayingCard, pos: CGPoint, duration : TimeInterval, delay : TimeInterval) {
        if let cardNode = cardNodes.first(where: {$0.playingCard == card}) {
            let action = SKAction.move(to: pos, duration: duration)
            cardNode.run(SKAction.sequence([SKAction.wait(forDuration: delay), action]))
        }
    }

    func turn(card: PlayingCard, isFaceUp: Bool) {
        if let cardNode = cardNodes.first(where: {$0.playingCard == card}) {
            if isFaceUp {cardNode.faceUp()} else {cardNode.faceDown()}
        }
    }
    
    func updateScore(player : Player){
        if let node = scoreNodes.first(where: {$0.name == player.name}) {
            switch player.lives {
            case 1:
                node.text = "🔴"
            case 2:
                node.text = "🔴🔴"
            case 3:
                node.text = "🔴🔴🔴"
            default:
                node.text = ""
            }
            
            if player.lives != 3{
                showExplosion(pos: node.position)
                highlightLoser(player: player)
            }
        }
    }
    
    func updateDealer(player: Player) {
        let pos = presenter.tableLayout.getDealerPosition(seat: player.seat)
        dealerTokenNode.run(SKAction.move(to: pos, duration: 0.5))
    }
    
    func removePlayer(player : Player) {
        self.childNode(withName: "name \(player.name)")?.removeFromParent()
        self.childNode(withName: "table mat \(player.seat)")?.removeFromParent()
    }
    
    func highlight(player: Player, status : PlayerStatus) {
        guard let node = self.childNode(withName: "table mat \(player.seat)") as? SKShapeNode
        else { return }
        switch status {
        case .ready:
            node.strokeColor = .clear
            node.fillColor = .gray
            node.alpha = 0.25
            node.glowWidth = 0.0
        case .turn:
            node.strokeColor = .green
            node.fillColor = .green
            node.glowWidth = 5.0
            node.alpha = 0.55
        case .played:
            node.strokeColor = .clear
            node.fillColor = .red
            node.alpha = 0.25
            node.glowWidth = 0.0
        }
    }

     func addName(name : String, pos : CGPoint){
         let label = SKLabelNode(fontNamed: "HelveticaNeue")
         label.name = "name \(name)"
         label.text = name
         label.fontColor = SKColor.white
         label.fontSize = 24
         label.verticalAlignmentMode = .bottom
         label.horizontalAlignmentMode = .left
         label.position = pos
         label.zPosition = 200
         addChild(label)
    }
    
    func addLives(name : String, pos : CGPoint){
        let label = SKLabelNode(fontNamed: "HelveticaNeue")
        label.name = name
        label.text = "🔴🔴🔴"
        label.fontSize = 18
        label.verticalAlignmentMode = .bottom
        label.horizontalAlignmentMode = .right
        label.position = pos
        label.zPosition = 200
        addChild(label)
        scoreNodes.append(label)
    }
    
    func addTableMat(seat : Int){
        let frame = presenter.tableLayout.getFrame(seat: seat).insetBy(dx: -8.0, dy: -8.0)
        let node = SKShapeNode(rect: frame, cornerRadius: 20.0)
        node.name = "table mat \(seat)"
        node.fillColor = .gray
        node.strokeColor = .clear
        node.alpha = 0.5
        node.zPosition = Layer.tableMat.rawValue
        addChild(node)
    }
    
    func show(message: String) {
        messageNode.show(message: message)
    }
    
    //MARK: - Misc

    private func addBackground(imageNamed image : String){
        let background = SKSpriteNode(imageNamed: image)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = Layer.background.rawValue
        addChild(background)
    }
    
    private func addDealer(){
        dealerTokenNode.name = "dealer"
        dealerTokenNode.text = "⭐️"
        dealerTokenNode.fontSize = 36
        dealerTokenNode.verticalAlignmentMode = .bottom
        dealerTokenNode.horizontalAlignmentMode = .right
        dealerTokenNode.position = presenter.tableLayout.getDealerPosition(seat: 0)
        dealerTokenNode.zPosition = Layer.ui.rawValue
        addChild(dealerTokenNode)
    }
    
    private func highlightLoser(player : Player){
        guard let node = self.childNode(withName: "table mat \(player.seat)") as? SKShapeNode
        else { return }
        let action = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let action2 = SKAction.fadeAlpha(to: 0.2, duration: 0.25)
        let seq = SKAction.sequence([action, action2])
        node.run(SKAction.repeat(seq, count: 5))
    }
    

    private func showExplosion(pos : CGPoint){
        if let explosion = SKEmitterNode(fileNamed: "Explosion")
        {
            explosion.numParticlesToEmit = 100
            explosion.position = pos
            addChild(explosion)
            let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
            explosion.run(removeAfterDead)
        }
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            if let cardNode = atPoint(location) as? CardSpriteNode {
                presenter.handleTouch(for: cardNode.playingCard)
            }
        }
    }
}
