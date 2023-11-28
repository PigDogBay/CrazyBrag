//
//  GamePresenter.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 28/11/2023.
//

import Foundation


protocol GameView {
    func setZPosition(on card: PlayingCard, z : CGFloat)
    func setPosition(on card: PlayingCard, pos : CGPoint)
    func turn(card: PlayingCard, isFaceUp : Bool)
}

class GamePresenter: GameListener {
    let tableLayout : TableLayout
    let model = Model()
    let logger = GameUpdateLogger()
    let view : GameView

    init(size : CGSize, view : GameView){
        self.view = view
        tableLayout = TableLayout(size: size)
        model.setUpGame()
        model.gameListener = self
    }
    
    func update(){
        model.updateState()
    }
    
    private func positionCard(cards : [DealtCard]){
        for dealt in cards {
            let pos = tableLayout.getPosition(dealt: dealt)
            view.setPosition(on: dealt.card, pos: pos)
            let isFaceUp = dealt.isMiddle && dealt.cardCount != 1
            view.turn(card: dealt.card, isFaceUp: isFaceUp)
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
            view.setPosition(on: card, pos: pos)
            view.setZPosition(on: card, z: z)
            view.turn(card: card, isFaceUp: false)
            z = z + 1
        }
    }

    
    ///
    ///GameListener functions
    ///
    
    func dealerSelected(dealer: Player) {
        logger.dealerSelected(dealer: dealer)
        allCardsToDeck()
    }
    
    func dealingDone(dealtCards: [DealtCard]) {
        logger.dealingDone(dealtCards: dealtCards)
        positionCard(cards: dealtCards)
        showCards(in: model.school.playerHuman.hand)
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
        logger.showHands(players: players)
        showAllHands()
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
