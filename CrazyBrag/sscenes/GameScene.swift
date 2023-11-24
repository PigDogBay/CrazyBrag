//
//  GameScene.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 28/06/2023.
//

import SpriteKit

class GameScene: SKScene, GameListener {
    lazy var tableLayout = TableLayout(size: frame.size)
    lazy var boxGroup = BoxSprites(layout: self.tableLayout.boxLayout)
    var cardNodes = [CardSpriteNode]()
    
    private var lastGameUpdateTime = TimeInterval()
    private let gameUpdateFrequency = TimeInterval(floatLiteral: 1.0)

    let model = Model()
    
    private func setUpGame(){
        model.setUpGame()
        model.gameListener = self
    }
    
    func loadDeck(_ deck : Deck) -> [CardSpriteNode] {
        return deck.deck.map {
            CardSpriteNode(card: $0, cardSize: tableLayout.cardSize)
        }
    }
    func setUpDeck(_ cardNodes : [CardSpriteNode]){
        let pos = tableLayout.deckPosition
        var z : CGFloat = 10.0
        for card in cardNodes {
            card.position = pos
            card.zPosition = z
            z = z + 1
            addChild(card)
        }
    }
    
    func deal(to: CGPoint){
        let card = model.deck.deal()
        if let cardNode = cardNodes.first(where: {$0.playingCard == card}) {
            let moveAction = SKAction.move(to: to, duration: 0.1)
            cardNode.run(moveAction)
        }
    }
    
    
    override func didMove(to view: SKView) {
        addBackground(imageNamed: "treestump")
        setUpGame()
        self.cardNodes = loadDeck(model.deck)
        setUpDeck(cardNodes)
        
//        deal(to: tableLayout.cpuWestLayout.position1)
//        deal(to: tableLayout.cpuNorthWestLayout.position1)
//        deal(to: tableLayout.cpuNorthLayout.position1)
//        deal(to: tableLayout.cpuNorthEastLayout.position1)
//        deal(to: tableLayout.cpuEastLayout.position1)
//        deal(to: tableLayout.playerLayout.position1)
//        deal(to: tableLayout.boxLayout.position1)
        
        /*
         boxGroup.addCard(scene: self, card: PlayingCard(suit: .diamonds, rank: .jack))
         boxGroup.addCard(scene: self, card: PlayingCard(suit: .clubs, rank: .jack))
         boxGroup.addCard(scene: self, card: PlayingCard(suit: .spades, rank: .ace))
         addName(name: "Box", pos: tableLayout.boxLayout.namePos)
         
         addCard(midPoint: tableLayout.playerLayout.position1, z: 9, name: "KH")
         addCard(midPoint: tableLayout.playerLayout.position2, z: 10, name: "2D")
         addCard(midPoint: tableLayout.playerLayout.position3, z: 11, name: "3H")
         addLives(pos: tableLayout.playerLayout.livesPos)
         addName(name: "You", pos: tableLayout.playerLayout.namePos)
         
         addCard(midPoint: tableLayout.cpuWestLayout.position1, z: 9, name: "CardBack")
         addCard(midPoint: tableLayout.cpuWestLayout.position2, z: 10, name: "CardBack")
         addCard(midPoint: tableLayout.cpuWestLayout.position3, z: 11, name: "CardBack")
         addLives(pos: tableLayout.cpuWestLayout.livesPos)
         addName(name: "Matt", pos: tableLayout.cpuWestLayout.namePos)
         
         addCard(midPoint: tableLayout.cpuEastLayout.position1, z: 9, name: "CardBack")
         addCard(midPoint: tableLayout.cpuEastLayout.position2, z: 10, name: "CardBack")
         addCard(midPoint: tableLayout.cpuEastLayout.position3, z: 11, name: "CardBack")
         addLives(pos: tableLayout.cpuEastLayout.livesPos)
         addName(name: "Howie", pos: tableLayout.cpuEastLayout.namePos)
         
         addCard(midPoint: tableLayout.cpuNorthLayout.position1, z: 9, name: "CardBack")
         addCard(midPoint: tableLayout.cpuNorthLayout.position2, z: 10, name: "CardBack")
         addCard(midPoint: tableLayout.cpuNorthLayout.position3, z: 11, name: "CardBack")
         addLives(pos: tableLayout.cpuNorthLayout.livesPos)
         addName(name: "Leon", pos: tableLayout.cpuNorthLayout.namePos)
         
         addCard(midPoint: tableLayout.cpuNorthWestLayout.position1, z: 9, name: "CardBack")
         addCard(midPoint: tableLayout.cpuNorthWestLayout.position2, z: 10, name: "CardBack")
         addCard(midPoint: tableLayout.cpuNorthWestLayout.position3, z: 11, name: "CardBack")
         addLives(pos: tableLayout.cpuNorthWestLayout.livesPos)
         addName(name: "Christine", pos: tableLayout.cpuNorthWestLayout.namePos)
         
         addCard(midPoint: tableLayout.cpuNorthEastLayout.position1, z: 9, name: "CardBack")
         addCard(midPoint: tableLayout.cpuNorthEastLayout.position2, z: 10, name: "CardBack")
         addCard(midPoint: tableLayout.cpuNorthEastLayout.position3, z: 11, name: "CardBack")
         addLives(pos: tableLayout.cpuNorthEastLayout.livesPos)
         addName(name: "Bomber", pos: tableLayout.cpuNorthEastLayout.namePos)
         */
    }
    
    private func addName(name : String, pos : CGPoint){
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
    
    private func addLives(pos : CGPoint){
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
    
    //    private func addCard(midPoint : CGPoint, z: Int, name : String){
    //        let card = CardSpriteNode(imageNamed: name, cardSize: tableLayout.cardSize)
    //        card.name = name
    //        card.position = midPoint
    //        card.zPosition = CGFloat(integerLiteral: z)
    //        addChild(card)
    //    }
    
    
    
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
        let playerAction = SKAction.move(to: tableLayout.boxLayout.position3, duration: 0.2)
        let boxAction = SKAction.move(to: tableLayout.playerLayout.position1, duration: 0.2)
        playerCard?.run(playerAction)
        boxCard?.run(boxAction)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (currentTime - lastGameUpdateTime) > gameUpdateFrequency {
            model.updateState()
            lastGameUpdateTime = currentTime
        }
    }

    //
    //GameListener functions
    //
    
    let logger = GameUpdateLogger()
    func dealerSelected(dealer: Player) {
        logger.dealerSelected(dealer: dealer)
    }
    
    func dealingDone(dealtCards: [DealtCard]) {
        logger.dealingDone(dealtCards: dealtCards)
    }
    
    func turnStarted(player: Player, middle: PlayerHand) {
        logger.turnStarted(player: player, middle: middle)
        //Auto play for human
        if player.seat == 0 {
            model.school.humanAI.turn = Turn.all(downIndex: 0)
        }
    }
    
    func turnEnded(player: Player, middle: PlayerHand, turn: Turn) {
        logger.turnEnded(player: player, middle: middle, turn: turn)
    }
    
    func showHands(players: [Player]) {
        logger.showHands(players: players)
    }
    
    func roundEnded(losingPlayers: [Player]) {
        logger.roundEnded(losingPlayers: losingPlayers)
    }
    
    func pullThePeg(outPlayers: [Player]) {
        logger.pullThePeg(outPlayers: outPlayers)
    }
    
    func everyoneOutSoReplayRound() {
        logger.everyoneOutSoReplayRound()
    }
    
    func gameOver(winner: Player) {
        logger.gameOver(winner: winner)
    }
    
}
