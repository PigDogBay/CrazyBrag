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
        for player in model.school.players {
            player.lives = 0
        }
        model.gameState = .updateLives
        model.updateState()
        XCTAssertTrue(everyoneOutSoReplayRoundCalled)
        XCTAssertFalse(pullThePegCalled)
    }

}
