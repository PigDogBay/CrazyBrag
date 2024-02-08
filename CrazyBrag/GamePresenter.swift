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
    func play(soundNamed : String)
    func continueButton(show : Bool)
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
    var gameUpdateFrequency : Double = 0.5
    private var playState : PlayState = NullState()

    init(size : CGSize, isPhone : Bool){
        self.isPhone = isPhone
        if isPhone {
            tableLayout = IPhoneLayout()
        } else {
            tableLayout = IPadLayout()
        }
    }
    
    func change(state : PlayState){
        self.playState.exit()
        self.playState = state
        state.enter()
    }
    
    func setUpGame(view : GameView){
        self.view = view
        let numberOfPlayers = isPhone ? 4 : 5
        model.setUpGame(numberOfAIPlayers: numberOfPlayers)
        model.gameListener = self
        change(state: AutoPlay(self))

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
    
    func continueGame(){
        change(state: CollectCards(self))
    }
    
    func quit(){
        //remove strong reference to allow object to be de-allocated
        model.gameListener = nil
        view?.quit()
        view?.play(soundNamed: "sad_whistle")
        view = nil
    }
    
    func update(_ currentTime: TimeInterval){
        if (currentTime - lastGameUpdateTime) > gameUpdateFrequency {
            playState.update()
            lastGameUpdateTime = currentTime
        }
    }
    
    private func autoPlay(){
        if let human = model.school.players.first(where: {$0.seat == 0}) {
            self.handleTouch(for: human.hand.hand[Int.random(in: 0...2)])
            self.handleTouch(for: model.middle.hand[Int.random(in: 0...2)])
        }
    }
  
    func positionCard(cards : [DealtCard], duration : TimeInterval){
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
    
    func showCards(in hand: PlayerHand){
        for card in hand.hand {
            view?.turn(card: card, isFaceUp: true)
            if (hand.hand.count != 3){
                fatalError("Hand does NOT contain 3 cards \(hand.hand.count)")
            }
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
            change(state: AutoPlay(self))
            model.selectedCards.removeAll()
        }
    }

    private func selectCard(_ card : DealtCard){
        let offset = card.seat == 0 ? 50.0 : -50.0
        model.selectedCards.append(card)
        view?.play(soundNamed: "card")
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
        change(state: DealerSelectedState(self, dealer: dealer))
    }
    
    func dealingDone(dealtCards: [DealtCard]) {
        logger.dealingDone(dealtCards: dealtCards)
        change(state: DealingDoneState(self, dealtCards: dealtCards))
    }
    
    func reveal() {
        logger.reveal()
        change(state: RevealState(self))
    }

    func turnStarted(player: Player, middle: PlayerHand) {
        logger.turnStarted(player: player, middle: middle)
        if player.seat == 0 {
            change(state: HumanTurnStartedState(self, player: player, middle: middle))
        } else {
            change(state: TurnStartedState(self, player: player, middle: middle))
        }
    }
    
    func turnEnded(player: Player, middle: PlayerHand, turn: Turn) {
        logger.turnEnded(player: player, middle: middle, turn: turn)
        change(state: TurnEndedState(self, player: player, middle: middle, turn: turn))
    }
    
    func showHands(players: [Player]) {
        logger.showHands(players: players)
        change(state: ShowHandsState(self, players: players))
    }
    
    func roundEnded(losingPlayers: [Player]) {
        logger.roundEnded(losingPlayers: losingPlayers)
        change(state: EndOfRoundState(self, losingPlayers: losingPlayers))
    }
    
    func pullThePeg(outPlayers: [Player]) {
        logger.pullThePeg(outPlayers: outPlayers)
        change(state: PullThePegState(self, outPlayers: outPlayers))
    }
    
    func everyoneOutSoReplayRound() {
        logger.everyoneOutSoReplayRound()
        change(state: EveryoneOutSoReplayRoundState(self))
    }
    
    func gameOver(winner: Player) {
        logger.gameOver(winner: winner)
        change(state: GameOverState(self, winner: winner))
    }
}
