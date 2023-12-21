//
//  ModelTests.swift
//  CardGamesTests
//
//  Created by Mark Bailey on 09/09/2022.
//

import XCTest
@testable import CrazyBrag

class ModelTests: XCTestCase, GameListener {
    private var everyoneOutSoReplayRoundCalled = false
    private var pullThePegCalled = false
    //MARK: - Game Listener Methods
    func dealerSelected(dealer: CrazyBrag.Player) {
        
    }
    
    func dealingDone(dealtCards: [CrazyBrag.DealtCard]) {
        
    }
    
    func reveal() {
        
    }
    
    func turnStarted(player: CrazyBrag.Player, middle: CrazyBrag.PlayerHand) {
        
    }
    
    func turnEnded(player: CrazyBrag.Player, middle: CrazyBrag.PlayerHand, turn: CrazyBrag.Turn) {
        
    }
    
    func showHands(players: [CrazyBrag.Player]) {
        
    }
    
    func roundEnded(losingPlayers: [CrazyBrag.Player]) {
        
    }
    
    func pullThePeg(outPlayers: [CrazyBrag.Player]) {
        pullThePegCalled = true
    }
    
    func everyoneOutSoReplayRound() {
        everyoneOutSoReplayRoundCalled = true
    }
    
    func gameOver(winner: CrazyBrag.Player) {
        
    }
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        everyoneOutSoReplayRoundCalled = false
        pullThePegCalled = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEverybodyOut1() throws {
        let model = Model()
        model.gameListener = self
        model.setUpGame(numberOfAIPlayers: 1)
        //Set up players with 1 life and similar hands so they both lose
        for player in model.school.players {
            player.lives = 1
        }
        Beehive345Run.forEach{ card in
            model.deck.remove(card: card)
            model.school.players[0].hand.receive(card: card)
        }
        Beehive345Run2.forEach{ card in
            model.deck.remove(card: card)
            model.school.players[1].hand.receive(card: card)
        }

        model.gameState = .scoreRound
        model.updateState()
        //Its a draw, so need to replay the hand
        XCTAssertTrue(everyoneOutSoReplayRoundCalled)
        XCTAssertFalse(pullThePegCalled)
    }
    
    private func computerMakeGame(model : Model, numberOfGames : Int){
        for _ in 1...numberOfGames {
            model.setUpGame(numberOfAIPlayers: 5)
            //remove human player
            model.school.players.remove(at: 0)
            while(model.gameState != .gameOver){
                model.updateState()
            }
            //Run game over state
            model.updateState()
        }
        model.school.getAllPlayers
            .sorted(by: {$0.gamesWon < $1.gamesWon})
            .forEach{print("\($0.name) \($0.gamesWon)")}
    }

    func testPlayAGame1(){
        let model = Model()
        let listener = GameUpdateLogger()
        model.gameListener = listener
        computerMakeGame(model: model, numberOfGames: 100)
        XCTAssertEqual(model.gameState, .gameOver)
        XCTAssertEqual(model.school.players.count, 1)
    }

}
