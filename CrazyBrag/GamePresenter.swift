//
//  GamePresenter.swift
//  CrazyBrag
//
//  Created by Mark Bailey on 28/11/2023.
//

import Foundation

enum PlayerStatus {
    case ready, turn, played
}

///How a Looky Looky action button is shown
enum ActionButtonState {
    ///The action cannot be taken at the moment
    case disabled
    case enabled
    ///The button has been pressed and is waiting for the player to pick a card
    case selected
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
    ///Looky Looky rules: the player has pressed the change a middle card button and now has to pick the card
    private(set) var isChoosingMiddleCard = false

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
        let settings = Settings()
        model.lookyLooky = settings.lookyLooky
        model.setUpGame(numberOfAIPlayers: numberOfPlayers)
        model.gameListener = self
        model.updateState()
        //increase game count
        settings.gamesPlayed = settings.gamesPlayed + 1

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
        model.updateState()
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
    
    func autoPlay(){
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
    
    //MARK: - Touch handling
    
    func handleTouch(for card : PlayingCard){
        print("Node touched: \(card.display())")
        if isChoosingMiddleCard {
            //The touch picks the middle card to change
            if model.middle.hand.contains(card) {
                isChoosingMiddleCard = false
                model.takeChangeMiddle(card: card)
                view?.show(message: "Your Turn")
                refreshActionButtons()
            }
            return
        }
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
            model.updateState()
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
    
    private func deselectAllCards(){
        for card in model.selectedCards {
            moveCard(dealt: card, yOffset: 0)
        }
        model.selectedCards.removeAll()
    }

    //MARK: - Looky Looky actions

    ///The player has pressed one of the action buttons
    func handleAction(_ action : TurnAction){
        guard model.isPlayersTurn else {
            return
        }
        switch action {
        case .looky:
            cancelChoosingMiddleCard()
            model.takeLooky()
        case .stashHand:
            cancelChoosingMiddleCard()
            if model.canTake(action: .stashHand) {
                deselectAllCards()
                model.takeStashHand()
            }
        case .changeMiddle:
            if isChoosingMiddleCard {
                //Pressing the button again cancels
                cancelChoosingMiddleCard()
            } else if model.canTake(action: .changeMiddle) {
                deselectAllCards()
                isChoosingMiddleCard = true
                view?.play(soundNamed: "card")
                view?.show(message: "Pick a middle\ncard to change")
            }
        }
        refreshActionButtons()
    }

    private func cancelChoosingMiddleCard(){
        if isChoosingMiddleCard {
            isChoosingMiddleCard = false
            view?.show(message: "Your Turn")
        }
    }

    ///Show which of the actions the human player can take right now
    func refreshActionButtons(){
        if !model.isPlayersTurn {
            isChoosingMiddleCard = false
        }
        for action in TurnAction.allCases {
            var state = ActionButtonState.disabled
            if isChoosingMiddleCard && action == .changeMiddle {
                state = .selected
            } else if model.isPlayersTurn && model.canTake(action: action) {
                state = .enabled
            }
            view?.setActionButton(action: action, state: state)
        }
    }

    ///Stashed cards go back to the deck, face down
    private func discard(cards : [PlayingCard]){
        for card in cards {
            view?.turn(card: card, isFaceUp: false)
            view?.discard(card: card, pos: tableLayout.deckPosition, duration: 0.4)
        }
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
    
    ///Not a new play state, the turn carries on once the action has been shown
    func actionTaken(player: Player, action: TurnActionResult) {
        logger.actionTaken(player: player, action: action)
        let isHuman = player.seat == 0
        view?.play(soundNamed: "card")
        if !isHuman {
            //Leave time to read what the computer player is doing before their next step
            gameUpdateFrequency = 1.5
        }
        switch action {
        case .looky(card: let card):
            if isHuman {
                //Only the human player gets to see the card, it is turned back over when their turn ends
                view?.turn(card: card, isFaceUp: true)
            } else {
                view?.show(message: "\(player.name)\nLooky Looky")
            }
        case .stashHand(discarded: let discarded, dealt: let dealt):
            discard(cards: discarded)
            positionCard(cards: dealt, duration: 0.3)
            if isHuman {
                showCards(in: player.hand)
            } else {
                view?.show(message: "\(player.name)\nStashes hand")
            }
        case .changeMiddle(discarded: let discarded, dealt: let dealt):
            discard(cards: [discarded])
            positionCard(cards: [dealt], duration: 0.3)
            if !isHuman {
                view?.show(message: "\(player.name)\nChanges a card")
            }
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
    
    func roundEnded(losingPlayers: [Player], extraLife: Player?) {
        logger.roundEnded(losingPlayers: losingPlayers, extraLife: extraLife)
        change(state: EndOfRoundState(self, losingPlayers: losingPlayers, extraLife: extraLife))
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
