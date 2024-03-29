//
//  GameScene.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 28/06/2023.
//

import SpriteKit

class GameScene: SKScene, GameView, DialogView {
    
    private let dealerTokenNode =  SKLabelNode(fontNamed: "HelveticaNeue")
    private let messageNode : MessageNode
    private let presenter  : GamePresenter
    private var cardNodes = [CardSpriteNode]()
    private var scoreNodes = [SKLabelNode]()
    private var lastGameUpdateTime = TimeInterval()

#if DEBUG
    deinit{
        print("GameScene DEINIT")
    }
#endif
    
    override init(size: CGSize) {
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        self.presenter = GamePresenter(size: size, isPhone: isPhone)
        self.messageNode = MessageNode(fontSize: presenter.tableLayout.fonts.statusFontSize)
        super.init(size: presenter.tableLayout.size)
        self.scaleMode = .fill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.presenter.setUpGame(view: self)
        addBackground(imageNamed: "treestump")
        addDealer()
        createCardNodes()
        messageNode.position = presenter.tableLayout.message
        addChild(messageNode)
        addBackButton()
    }
    
    override func update(_ currentTime: TimeInterval) {
        presenter.update(currentTime)
    }


    //MARK: - GameView
    
    func quit(){
        removeAllActions()
        let transition = SKTransition.doorway(withDuration: 1)
        view?.presentScene(StartScene(), transition: transition)
    }

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
                node.text = "💛"
            case 2:
                node.text = "💛💛"
            case 3:
                node.text = "💛💛💛"
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
        let f = presenter.tableLayout.getFrame(seat: player.seat)
        showFire(pos: CGPoint(x: f.midX, y: f.minY))
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
            let bigger = SKAction.scale(to: 1.2, duration: 0.25)
            let smaller = SKAction.scale(to: 1.0, duration: 0.25)
            node.run(SKAction.sequence([bigger,smaller]))
        case .played:
            node.strokeColor = .clear
            node.fillColor = .red
            node.alpha = 0.25
            node.glowWidth = 0.0
        }
    }

     func addName(name : String, pos : CGPoint){
         let label = SKLabelNode(fontNamed: "QuentinCaps")
         label.name = "name \(name)"
         label.text = name
         label.fontColor = SKColor.black
         label.fontSize = presenter.tableLayout.fonts.nameFontSize
         label.verticalAlignmentMode = .bottom
         label.horizontalAlignmentMode = .left
         label.position = pos
         label.zPosition = Layer.ui.rawValue
         addChild(label)
    }
    
    func addLives(name : String, pos : CGPoint){
        let label = SKLabelNode(fontNamed: "HelveticaNeue")
        label.name = name
        label.text = "💛💛💛"
        label.fontSize = presenter.tableLayout.fonts.livesFontSize
        label.verticalAlignmentMode = .bottom
        label.horizontalAlignmentMode = .right
        label.position = pos
        label.zPosition = Layer.ui.rawValue
        addChild(label)
        scoreNodes.append(label)
    }
    
    func addTableMat(seat : Int){
        let frame = presenter.tableLayout.getFrame(seat: seat).insetBy(dx: -8.0, dy: -8.0)
        //Center on the middle of the frame so that scale animation will be centred
        let node = SKShapeNode(rectOf: frame.size, cornerRadius: 20.0)
        node.position = CGPoint(x: frame.midX, y: frame.midY)
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
    
    func play(soundNamed : String) {
        run(SKAction.playSoundFileNamed(soundNamed, waitForCompletion: false))
    }
    
    func continueButton(show : Bool) {
        if !show {
            childNode(withName: "continue")?.removeFromParent()
            return
        }
        let button = ButtonNode(label: "Continue", fontSize: presenter.tableLayout.fonts.buttonFontSize){ [weak self] in
            self?.presenter.continueGame()
        }
        button.name = "continue"
        button.position = presenter.tableLayout.continueButton
        button.zPosition = Layer.continueButton.rawValue
        button.attract()
        button.fillColor = UIColor(named: "ContinueButton")!
        addChild(button)
    }

    //MARK: - Misc

    private func createCardNodes() {
        cardNodes = presenter.model.deck.deck.map {
            CardSpriteNode(card: $0, cardSize: presenter.tableLayout.cardSize)
        }
        for card in cardNodes {
            card.position = presenter.tableLayout.deckPosition
            addChild(card)
        }
    }
    
    private func addBackground(imageNamed image : String){
        let background = SKSpriteNode(imageNamed: image)
        background.anchorPoint = CGPoint(x: 1.0, y: 1.0)
        background.position = CGPoint(x: frame.maxX, y: frame.maxY)
        background.zPosition = Layer.background.rawValue
        addChild(background)
    }
    
    private func addDealer(){
        dealerTokenNode.name = "dealer"
        dealerTokenNode.text = "⭐️"
        dealerTokenNode.fontSize = presenter.tableLayout.fonts.dealerFontSize
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
    

    private func showFire(pos : CGPoint){
        if let explosion = SKEmitterNode(fileNamed: "Fire")
        {
            explosion.numParticlesToEmit = 500
            explosion.position = pos
            explosion.zPosition = Layer.particles.rawValue
            addChild(explosion)
            let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
            explosion.run(removeAfterDead)
        }
    }
    
    private func showExplosion(pos : CGPoint){
        if let explosion = SKEmitterNode(fileNamed: "Explosion")
        {
            explosion.numParticlesToEmit = 200
            explosion.position = pos
            explosion.zPosition = Layer.particles.rawValue
            addChild(explosion)
            let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
            explosion.run(removeAfterDead)
        }
    }
    
    private func addBackButton(){
        let button = ButtonNode(label: "QUIT", fontSize: presenter.tableLayout.fonts.buttonFontSize){ [weak self] in
            self?.presenter.quit()
        }
        button.position = presenter.tableLayout.backButton
        button.zPosition = Layer.ui.rawValue
        addChild(button)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let node = atPoint(location)
            if let cardNode = node as? CardSpriteNode {
                presenter.handleTouch(for: cardNode.playingCard)
            }
        }
    }
    
    ///DialogView:-
    
    func showMessage(title : String, message: String) {
        let dialogNode = DialogNode()
        dialogNode.name = "dialog "+title
        dialogNode.zPosition = 1000
        dialogNode.display(title: title, message: message)
        addChild(dialogNode)
    }

}
