//
//  Model.swift
//  CardGames
//
//  Created by Mark Bailey on 09/09/2022.
//

import Foundation


enum GameState {
    case setUp, selectDealer, deal, turnStart, turnEnd, scoreRound, updateLives, gameOver
}

class Model {
    
    let deck = Deck()
    let middle = PlayerHand()
    let school = School()
    var gameState : GameState = .setUp
    var gameListener : GameListener? = nil
    var nextPlayer : Player? = nil
    var rules : GameVariation = VariationAllUp()
//    var rules : GameVariation = VariationOneDown()

    func computerMakeGame(){
        for _ in 1...1000 {
            while(gameState != .gameOver){
                updateState()
            }
            gameOver()
            gameState = .setUp
        }
        school.getAllPlayers
            .sorted(by: {$0.gamesWon < $1.gamesWon})
            .forEach{printStats($0)}
    }
    
    func printStats(_ player : Player){
        print("\(player.name) \(player.gamesWon)")
    }
    
    
    func updateState(){
        switch gameState {
        case .setUp:
            setUpGame()
        case .selectDealer:
            school.nextDealer()
            deck.shuffle()
            gameListener?.dealerSelected(dealer: school.dealer!)
            gameState = .deal
        case .deal:
            deal()
            gameState = .turnStart
            nextPlayer = school.dealer
            gameListener?.dealingDone()
        case .turnStart:
            turnStart()
        case .turnEnd:
            turnEnd()
        case .scoreRound:
            scoreRound()
            gameState = .updateLives
        case .updateLives:
            stashAll()
            updateLives()
        case .gameOver:
            gameOver()
        }
    }
    
    func setUpGame(){
        deck.createDeck()
        deck.shuffle()
        school.setUpPlayers()
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
    
    func deal(){
        //Deal 3 cards each and 3 in the middle
        for i in 1...3 {
            school.players.forEach{
                $0.hand.receive(card: deck.deal())
            }
            middle.receive(card: deck.deal(dealUp: rules.isMiddleCardFaceUp(dealIndex: i)))
        }
        school.playerHuman.hand.show()
    }
    
    func turnStart(){
        nextPlayer = school.nextPlayer(current: nextPlayer!)
        gameListener?.turnStarted(player: nextPlayer!, middle: middle)
        gameState = .turnEnd
    }
        
    func turnEnd(){
        let turn = nextPlayer?.play(middle: middle)
        rules.arrangeMiddle(middle: middle, turn: turn!)
        gameListener?.turnEnded(player: nextPlayer!, middle: middle, turn: turn!)
        //Dealer is last player
        gameState = nextPlayer == school.dealer ? .scoreRound : .turnStart
    }
    
    /// Find losing hand and lose player a life
    func scoreRound(){
        school.showAllHands()
        gameListener?.showHands(players: school.players)
        school.resolveHands()
        if let losingPlayers = school.determineLosingHands(){
            losingPlayers.forEach{
                $0.lives = $0.lives - 1
            }
            gameListener?.roundEnded(losingPlayers: losingPlayers)
        }
    }
    func updateLives(){
        let pegPullers = school.playersWithNoLivesLeft()
        gameListener?.pullThePeg(outPlayers: pegPullers)
        school.removePlayersWithNoLivesLeft()
        if school.areAllPlayersOut() {
            //Oops no one won, so play another round
            school.reinstatePlayers()
            gameListener?.everyoneOutSoReplayRound()
        }
        gameState = isGameWon() ? .gameOver : .selectDealer
    }
    
    func isGameWon() -> Bool{
        return school.players.count < 2
    }
    
    func gameOver(){
        if let winner = school.players.first {
            winner.gamesWon += 1
            gameListener?.gameOver(winner: winner)
        }
    }
}
