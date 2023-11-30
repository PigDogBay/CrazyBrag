//
//  GamePresenter.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 28/11/2023.
//

import Foundation

protocol GameView {
    func setZPosition(on card: PlayingCard, z : CGFloat)
    func setPosition(on card: PlayingCard, pos: CGPoint, duration : TimeInterval, delay : TimeInterval)
    func addName(name : String, pos : CGPoint)
    func turn(card: PlayingCard, isFaceUp : Bool)
    func addLives(name : String,pos : CGPoint)
    func updateScore(player : Player)
    func updateDealer(player : Player)
    func removePlayer(player : Player)
    func highlight(player : Player, status : PlayerStatus)
}

enum PlayerStatus {
    case ready, turn, played
}
    
class GamePresenter: GameListener {
    let tableLayout : TableLayout
    let model = Model()
    let logger = GameUpdateLogger()
    let view : GameView
    private var lastGameUpdateTime = TimeInterval()
    private var gameUpdateFrequency : Double = 0.5
    ///Set to false if require player input
    private var canUpdateGame = true

    init(size : CGSize, view : GameView){
        self.view = view
        tableLayout = TableLayout(size: size)
        model.setUpGame()
        model.gameListener = self

        view.addName(name: "Box", pos: tableLayout.boxLayout.namePos)
        for player in model.school.players {
            view.addName(name: player.name, pos: tableLayout.getNamePosition(seat: player.seat))
            view.addLives(name: player.name, pos: tableLayout.getLivesPosition(seat: player.seat))
        }
    }
    
    func update(_ currentTime: TimeInterval){
        if (currentTime - lastGameUpdateTime) > gameUpdateFrequency {
            if canUpdateGame {
                model.updateState()
            }
            lastGameUpdateTime = currentTime
        }
    }
  
    private func positionCard(cards : [DealtCard], duration : TimeInterval){
        var delay = 0.0
        for dealt in cards {
            let pos = tableLayout.getPosition(dealt: dealt)
            let isFaceUp = dealt.isMiddle && dealt.cardCount != 1
            view.turn(card: dealt.card, isFaceUp: isFaceUp)
            view.setZPosition(on: dealt.card, z: CGFloat(dealt.cardCount))
            view.setPosition(on: dealt.card, pos: pos, duration: duration, delay: delay)
            delay = delay + 0.1
        }
    }
    
    private func showCards(in hand: PlayerHand){
        for card in hand.hand {
            view.turn(card: card, isFaceUp: true)
            if (hand.hand.count != 3){
                print("WHY???")
            }
        }
    }
    
    private func showAllHands(){
        for player in model.school.getAllPlayers{
            showCards(in: player.hand)
        }
    }
    
    func allCardsToDeck(){
        let pos = tableLayout.deckPosition
        var z : CGFloat = 10.0
        for card in model.deck.deck{
            view.setZPosition(on: card, z: z)
            view.turn(card: card, isFaceUp: false)
            z = z + 1
            view.setPosition(on: card, pos: pos, duration: 0.1, delay: 0)
        }
    }
    
    func handledTouch(atNodeNamed name : String){
        print("Node touched: \(name)")
    }
    
    ///
    ///GameListener functions
    ///
    
    func dealerSelected(dealer: Player) {
        gameUpdateFrequency = 0.5
        logger.dealerSelected(dealer: dealer)
        view.updateDealer(player: dealer)
        allCardsToDeck()
        for player in model.school.players {
            view.highlight(player: player, status: .ready)
        }
    }
    
    func dealingDone(dealtCards: [DealtCard]) {
        gameUpdateFrequency = 2.5
        logger.dealingDone(dealtCards: dealtCards)
        positionCard(cards: dealtCards, duration: 0.1)
        showCards(in: model.school.playerHuman.hand)
    }
    
    func turnStarted(player: Player, middle: PlayerHand) {
        logger.turnStarted(player: player, middle: middle)
        gameUpdateFrequency = 1
        view.highlight(player: player, status: .turn)
        //Auto play for human
        if player.seat == 0 {
            //Stop updating until player has taken their turn
            canUpdateGame = false
        }
    }
    
    func turnEnded(player: Player, middle: PlayerHand, turn: Turn) {
        gameUpdateFrequency = 2.5
        logger.turnEnded(player: player, middle: middle, turn: turn)
        let p1 = DealtCard(seat: player.seat, card: player.hand.hand[0], cardCount: 1)
        let p2 = DealtCard(seat: player.seat, card: player.hand.hand[1], cardCount: 2)
        let p3 = DealtCard(seat: player.seat, card: player.hand.hand[2], cardCount: 3)
        let m1 = DealtCard(card: middle.hand[0], cardCount: 1)
        let m2 = DealtCard(card: middle.hand[1], cardCount: 2)
        let m3 = DealtCard(card: middle.hand[2], cardCount: 3)
        positionCard(cards: [p1,p2,p3,m1,m2,m3], duration: 0.5)
        if player.seat == 0{
            showCards(in: model.school.playerHuman.hand)
        }
        view.highlight(player: player, status: .played)
    }
    
    func showHands(players: [Player]) {
        gameUpdateFrequency = 2.5
        logger.showHands(players: players)
        showAllHands()
    }
    
    func roundEnded(losingPlayers: [Player]) {
        logger.roundEnded(losingPlayers: losingPlayers)
        for player in losingPlayers {
            view.updateScore(player: player)
        }
    }
    
    func pullThePeg(outPlayers: [Player]) {
        logger.pullThePeg(outPlayers: outPlayers)
        for player in outPlayers {
            view.removePlayer(player: player)
        }
    }
    
    func everyoneOutSoReplayRound() {
        logger.everyoneOutSoReplayRound()
    }
    
    func gameOver(winner: Player) {
        logger.gameOver(winner: winner)
    }

    
}
