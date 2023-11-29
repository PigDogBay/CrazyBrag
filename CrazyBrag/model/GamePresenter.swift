//
//  GamePresenter.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 28/11/2023.
//

import Foundation

protocol GameView {
    func setZPosition(on card: PlayingCard, z : CGFloat)
    func setPosition(on card: PlayingCard, pos: CGPoint, delay : TimeInterval)
    func addName(name : String, pos : CGPoint)
    func turn(card: PlayingCard, isFaceUp : Bool)
    func addLives(name : String,pos : CGPoint)
    func updateScore(player : Player)
    func updateDealer(player : Player)
    func removePlayer(player : Player)
}
    
class GamePresenter: GameListener {
    let tableLayout : TableLayout
    let model = Model()
    let logger = GameUpdateLogger()
    let view : GameView
    var gameUpdateFrequency : Double = 0.5

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
    
    func update(){
        model.updateState()
    }
  
    private func positionCard(cards : [DealtCard]){
        var delay = 0.0
        for dealt in cards {
            let pos = tableLayout.getPosition(dealt: dealt)
            let isFaceUp = dealt.isMiddle && dealt.cardCount != 1
            view.turn(card: dealt.card, isFaceUp: isFaceUp)
            view.setZPosition(on: dealt.card, z: CGFloat(dealt.cardCount))
            view.setPosition(on: dealt.card, pos: pos, delay: delay)
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
            view.setPosition(on: card, pos: pos, delay: 0)
        }
    }

    
    ///
    ///GameListener functions
    ///
    
    func dealerSelected(dealer: Player) {
        gameUpdateFrequency = 0.5
        logger.dealerSelected(dealer: dealer)
        view.updateDealer(player: dealer)
        allCardsToDeck()
    }
    
    func dealingDone(dealtCards: [DealtCard]) {
        gameUpdateFrequency = 2.5
        logger.dealingDone(dealtCards: dealtCards)
        positionCard(cards: dealtCards)
        showCards(in: model.school.playerHuman.hand)
    }
    
    func turnStarted(player: Player, middle: PlayerHand) {
        gameUpdateFrequency = 1
        logger.turnStarted(player: player, middle: middle)
        //Auto play for human
        if player.seat == 0 {
            model.school.humanAI.turn = Turn.all(downIndex: 0)
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
        positionCard(cards: [p1,p2,p3,m1,m2,m3])
        if player.seat == 0{
            showCards(in: model.school.playerHuman.hand)
        }

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
