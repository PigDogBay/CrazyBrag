//
//  Model.swift
//  CardGames
//
//  Created by Mark Bailey on 09/09/2022.
//

import Foundation


enum GameState {
    case setUp, selectDealer, deal, reveal, turnStart, turnEnd, showHands, scoreRound, updateLives, gameOver
}

class Model {
    let deck = Deck()
    let middle = PlayerHand()
    let school = School()
    var gameState : GameState = .setUp
    weak var gameListener : GameListener? = nil
    private var nextPlayer : Player? = nil
    var selectedCards = [DealtCard]()
    var isPlayersTurn = false

    func updateState(){
        switch gameState {
        case .setUp:
            setUpGame(numberOfAIPlayers: 5)
        case .selectDealer:
            school.nextDealer()
            deck.shuffle()
            gameListener?.dealerSelected(dealer: school.dealer!)
            gameState = .deal
        case .deal:
            let dealt = deal()
            gameState = .reveal
            //Next Player will be moved on in turnStart
            nextPlayer = school.dealer
            gameListener?.dealingDone(dealtCards: dealt)
        case .reveal:
            reveal()
        case .turnStart:
            turnStart()
        case .turnEnd:
            turnEnd()
        case .showHands:
            showHands()
        case .scoreRound:
            scoreRound()
            stashAll()
        case .updateLives:
            updateLives()
        case .gameOver:
            gameOver()
        }
    }
    
    func setUpGame(numberOfAIPlayers : Int){
        deck.createDeck()
        deck.shuffle()
        school.setUpPlayers(numberOfAIPlayers: numberOfAIPlayers)
        gameState = .selectDealer
    }
    
    func stashAll(){
        do {
            try school.stashCards(deck: deck)
            try deck.receive(cards: middle.stash())
            assert(deck.count==52, "Dropped a card")
        } catch CardErrors.CardAlreadyInThePack(let card){
            print("ERROR: Card already in the pack \(card)")
            assertionFailure("Duplicate card")
        } catch {
            print(error)
            assertionFailure(error.localizedDescription)
        }
    }
    
    private func deal() -> [DealtCard]{
        var dealActions = [DealtCard]()
        //Deal 3 cards each and 3 in the middle
        for i in 1...3 {
            school.sortPlayersInDealOrder().forEach{
                let card = deck.deal()
                dealActions.append(DealtCard(seat: $0.seat, card: card, cardCount: i))
                $0.hand.receive(card: card)
            }
            let card = deck.deal()
            middle.receive(card: card)
            dealActions.append(DealtCard(card: card, cardCount: i))
        }
        school.playerHuman.hand.show()
        return dealActions
    }
    
    private func reveal(){
        gameListener?.reveal()
        gameState = .turnStart
    }
    
    private func turnStart(){
        nextPlayer = school.nextPlayer(current: nextPlayer!)
        gameListener?.turnStarted(player: nextPlayer!, middle: middle)
        gameState = .turnEnd
    }
        
    private func turnEnd(){
        let turn = nextPlayer?.play(middle: middle)
        gameListener?.turnEnded(player: nextPlayer!, middle: middle, turn: turn!)
        //Dealer is last player
        gameState = nextPlayer == school.dealer ? .showHands : .turnStart
    }

    private func showHands(){
        school.showAllHands()
        gameListener?.showHands(players: school.players)
        gameState = .scoreRound
    }

    /// Find losing hand and lose player a life
    private func scoreRound(){
        school.resolveHands()
        gameState = .updateLives
        if let losingPlayers = school.determineLosingHands(){
            losingPlayers.forEach{
                $0.lives = $0.lives - 1
            }
            if school.areAllPlayersOut() {
                //Oops no one won, so play another round
                school.reinstatePlayers()
                //Don't update lives, start another deal
                gameListener?.everyoneOutSoReplayRound()
                gameState = .selectDealer
            } else {
                gameListener?.roundEnded(losingPlayers: losingPlayers)
            }
        }
    }
    
    private func updateLives(){
        let pegPullers = school.playersWithNoLivesLeft()
        school.removePlayersWithNoLivesLeft()
        //Notify view of which players are out
        gameListener?.pullThePeg(outPlayers: pegPullers)
        gameState = isGameWon() ? .gameOver : .selectDealer
    }
    
    private func isGameWon() -> Bool{
        return school.players.count < 2
    }
    
    private func gameOver(){
        if let winner = school.players.first {
            winner.gamesWon += 1
            gameListener?.gameOver(winner: winner)
        }
    }
    
    /// If the card is can be interacted with by the user, converts the PlayingCard into DealtCard
    func toTouchableCard(card : PlayingCard) -> DealtCard?{
        if let playerCard = toDealtCard(card: card, playerHand: school.playerHuman.hand, seat: 0){
            return playerCard
        }
        if let middleCard = toDealtCard(card: card, playerHand: middle, seat: -1){
            return middleCard
        }
        return nil
    }
    
    private func toDealtCard(card : PlayingCard, playerHand : PlayerHand, seat : Int) -> DealtCard?{
        if let index = playerHand.hand.firstIndex(of: card) {
            let dealtCard = DealtCard(seat: seat, card: card, cardCount: index+1)
            return dealtCard
        }
        return nil
    }
    
    func checkIfAllIn() -> Turn?{
        if selectedCards.filter({!$0.isMiddle}).count == 3 {
            //Player has selected all of their cards to throw in
            //The first card selected is down
            if let down = selectedCards.first(where: {!$0.isMiddle}){
                if let index = school.playerHuman.hand.hand.firstIndex(of: down.card){
                    return Turn.all(downIndex: index)
                }
            }
        }
        return nil
    }
    
    func checkIfSwapped() -> Turn?{
        guard selectedCards.count == 2,
            let playerCard = selectedCards.first(where: {!$0.isMiddle}),
            let middleCard = selectedCards.first(where: {$0.isMiddle}) else {
            return nil
        }
        return Turn.swap(hand: playerCard.card, middle: middleCard.card)
    }
    
    ///Check if the players selection is valid
    ///Returns true if valid, false invalid
    func validate(selectedCard card: DealtCard) -> Bool{
        //Only allow selection when it is the player's turn
        if !isPlayersTurn {
            return false
        }
        let middleCount = selectedCards.filter{$0.isMiddle}.count
        let handCount = selectedCards.count - middleCount
        //Only 1 card in the middle can be selected
        if card.isMiddle && middleCount>0{
            return false
        }
        //Cannot select the middle if two hand cards already selected
        if card.isMiddle && handCount == 2{
            return false
        }
        return true
    }
}
