//
//  GamePresenter.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 28/11/2023.
//

import Foundation

protocol GameView {
    func quit()
    func setZPosition(on card: PlayingCard, z : CGFloat)
    func setPosition(on card: PlayingCard, pos: CGPoint, duration : TimeInterval, delay : TimeInterval)
    func addName(name : String, pos : CGPoint)
    func turn(card: PlayingCard, isFaceUp : Bool)
    func addLives(name : String, pos : CGPoint)
    func addTableMat(seat : Int)
    func updateScore(player : Player)
    func updateDealer(player : Player)
    func removePlayer(player : Player)
    func highlight(player : Player, status : PlayerStatus)
    func show(message : String)
}

enum PlayerStatus {
    case ready, turn, played
}
    
class GamePresenter: GameListener {
    let tableLayout : TableLayout
    let model = Model()
    let logger = GameUpdateLogger()
    let isPhone : Bool
    var view : GameView? = nil
    private var lastGameUpdateTime = TimeInterval()
    private var gameUpdateFrequency : Double = 0.5
    ///Set to false if require player input
    private var canUpdateGame = true

    init(size : CGSize, isPhone : Bool){
        self.isPhone = isPhone
        if isPhone {
            tableLayout = IPhoneLayout(size: size)
        } else {
            tableLayout = IPadLayout(size: size)
        }
    }
    
    func setUpGame(view : GameView){
        self.view = view
        let numberOfPlayers = isPhone ? 4 : 5
        model.setUpGame(numberOfAIPlayers: numberOfPlayers)
        model.gameListener = self

        if !isPhone {
            view.addName(name: "Middle", pos: tableLayout.getNamePosition(seat: -1))
        }
        view.addTableMat(seat: -1)
        for player in model.school.players {
            view.addTableMat(seat: player.seat)
            view.addName(name: player.name, pos: tableLayout.getNamePosition(seat: player.seat))
            view.addLives(name: player.name, pos: tableLayout.getLivesPosition(seat: player.seat))
        }

    }
    
    func quit(){
        //remove strong reference to allow object to be de-allocated
        model.gameListener = nil
        view?.quit()
        view = nil
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
            view?.turn(card: dealt.card, isFaceUp: isFaceUp)
            view?.setZPosition(on: dealt.card, z: dealt.zPosition)
            view?.setPosition(on: dealt.card, pos: pos, duration: duration, delay: delay)
            delay = delay + 0.1
        }
    }
    
    private func showCards(in hand: PlayerHand){
        for card in hand.hand {
            view?.turn(card: card, isFaceUp: true)
            if (hand.hand.count != 3){
                fatalError("Hand does NOT contain 3 cards \(hand.hand.count)")
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
        var z = Layer.deck.rawValue
        for card in model.deck.deck{
            view?.setZPosition(on: card, z: z)
            view?.turn(card: card, isFaceUp: false)
            z = z + 1
            view?.setPosition(on: card, pos: pos, duration: 0.1, delay: 0)
        }
    }
    
    //MARK: - Touch handling
    
    func handleTouch(for card : PlayingCard){
        print("Node touched: \(card.display())")
        if let dealtCard = model.toTouchableCard(card: card){
            if model.selectedCards.contains(where: {$0.card == card}){
                deselectCard(dealtCard)
            } else if model.validate(selectedCard: dealtCard) {
                selectCard(dealtCard)
                checkIfFinishedTurn()
            }
        }
    }
    
    private func checkIfFinishedTurn(){
        var turn = model.checkIfSwapped()
        if turn == nil {
            turn = model.checkIfAllIn()
        }
        if turn != nil {
            model.school.humanAI.turn = turn
            canUpdateGame = true
            model.selectedCards.removeAll()
        }
    }

    private func selectCard(_ card : DealtCard){
        let offset = card.seat == 0 ? 50.0 : -50.0
        model.selectedCards.append(card)
        moveCard(dealt: card, yOffset: offset)
    }
    private func deselectCard(_ card : DealtCard){
        model.selectedCards.removeAll(where: {$0.card == card.card})
        moveCard(dealt: card, yOffset: 0)
    }
    
    private func moveCard(dealt : DealtCard, yOffset: Double){
        let pos = tableLayout.getPosition(dealt: dealt)
        let translation = CGAffineTransform(translationX: 0.0, y: yOffset)
        let moveTo = pos.applying(translation)
        view?.setPosition(on: dealt.card, pos: moveTo, duration: 0.2, delay: 0)
    }
    
    //MARK: - GameListener functions
    
    func dealerSelected(dealer: Player) {
        logger.dealerSelected(dealer: dealer)
        view?.show(message: "\(dealer.name)\nDealing")
        gameUpdateFrequency = 0.5
        view?.updateDealer(player: dealer)
        allCardsToDeck()
        for player in model.school.players {
            view?.highlight(player: player, status: .ready)
        }
    }
    
    func dealingDone(dealtCards: [DealtCard]) {
        logger.dealingDone(dealtCards: dealtCards)
        gameUpdateFrequency = 2.5
        positionCard(cards: dealtCards, duration: 0.1)
        showCards(in: model.school.playerHuman.hand)
    }
    
    func turnStarted(player: Player, middle: PlayerHand) {
        logger.turnStarted(player: player, middle: middle)
        gameUpdateFrequency = 1
        view?.highlight(player: player, status: .turn)
        //Auto play for human
        if player.seat == 0 {
            //Stop updating until player has taken their turn
            canUpdateGame = false
            //Player can now interact with the cards
            model.isPlayersTurn = true
            view?.show(message: "Your Turn")
        } else {
            view?.show(message: "\(player.name)'s\nTurn")
        }
    }
    
    func turnEnded(player: Player, middle: PlayerHand, turn: Turn) {
        gameUpdateFrequency = 2.5
        logger.turnEnded(player: player, middle: middle, turn: turn)
        model.isPlayersTurn = false
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
        view?.highlight(player: player, status: .played)
    }
    
    func showHands(players: [Player]) {
        view?.show(message: "End of Round")
        gameUpdateFrequency = 2.5
        logger.showHands(players: players)
        showAllHands()
    }
    
    func roundEnded(losingPlayers: [Player]) {
        logger.roundEnded(losingPlayers: losingPlayers)
        switch losingPlayers.count {
        case 0:
            view?.show(message: "")
        case 1:
            if losingPlayers[0].seat == 0{
                view?.show(message: "You lose a life")
            } else{
                view?.show(message: "\(losingPlayers.first?.name ?? "")\nLoses a life")
            }
        default:
            view?.show(message: "\(losingPlayers.count) Players\nLose a life")
        }
        for player in losingPlayers {
            view?.updateScore(player: player)
        }
    }
    
    func pullThePeg(outPlayers: [Player]) {
        logger.pullThePeg(outPlayers: outPlayers)
        switch outPlayers.count {
        case 0:
            view?.show(message: "")
        case 1:
            if outPlayers[0].seat == 0{
                view?.show(message: "You are out")
            } else{
                view?.show(message: "\(outPlayers.first?.name ?? "")\nIs Out")
            }
        default:
            view?.show(message: "\(outPlayers.count) Players\nAre Out")
        }
        for player in outPlayers {
            view?.removePlayer(player: player)
        }
    }
    
    func everyoneOutSoReplayRound() {
        logger.everyoneOutSoReplayRound()
    }
    
    func gameOver(winner: Player) {
        logger.gameOver(winner: winner)
        view?.show(message: "\(winner.name) is the Winner!")
    }
}
