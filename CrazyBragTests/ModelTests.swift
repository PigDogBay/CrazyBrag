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
    private var extraLifePlayer : CrazyBrag.Player? = nil
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
    
    func roundEnded(losingPlayers: [CrazyBrag.Player], extraLife: CrazyBrag.Player?) {
        extraLifePlayer = extraLife
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
        extraLifePlayer = nil
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
    
    ///Two players, the first is given a prial and the second a run, then the round is scored
    private func scorePrialRound(lookyLooky : Bool) -> Model {
        let model = Model()
        model.lookyLooky = lookyLooky
        model.gameListener = self
        model.setUpGame(numberOfAIPlayers: 1)
        //Take the cards out of the deck, as they are returned to it after the round is scored
        PrialOfKings.forEach{ card in
            model.deck.remove(card: card)
            model.school.players[0].hand.receive(card: card)
        }
        Beehive345Run.forEach{ card in
            model.deck.remove(card: card)
            model.school.players[1].hand.receive(card: card)
        }
        model.gameState = .scoreRound
        model.updateState()
        return model
    }

    func testLookyLookyExtraLife1() throws {
        let model = scorePrialRound(lookyLooky: true)
        XCTAssertEqual(model.school.players[0].lives, 4)
        //The other player is safe
        XCTAssertEqual(model.school.players[1].lives, 3)
        XCTAssertEqual(extraLifePlayer, model.school.players[0])
        XCTAssertEqual(model.gameState, .updateLives)
    }

    ///The second winning prial works as usual: no extra life and the other player loses a life
    func testLookyLookyExtraLife3() throws {
        let model = Model()
        model.lookyLooky = true
        model.gameListener = self
        model.setUpGame(numberOfAIPlayers: 1)
        model.school.players[0].hasHadExtraLife = true
        PrialOfKings.forEach{ card in
            model.deck.remove(card: card)
            model.school.players[0].hand.receive(card: card)
        }
        Beehive345Run.forEach{ card in
            model.deck.remove(card: card)
            model.school.players[1].hand.receive(card: card)
        }
        model.gameState = .scoreRound
        model.updateState()
        XCTAssertEqual(model.school.players[0].lives, 3)
        XCTAssertEqual(model.school.players[1].lives, 2)
        XCTAssertNil(extraLifePlayer)
    }

    ///Standard rules, no extra life for a prial
    func testLookyLookyExtraLife2() throws {
        let model = scorePrialRound(lookyLooky: false)
        XCTAssertEqual(model.school.players[0].lives, 3)
        XCTAssertEqual(model.school.players[1].lives, 2)
        XCTAssertNil(extraLifePlayer)
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

    ///Looky Looky rules: the computer players cope with the two jokers in the pack
    func testPlayAGame2(){
        let model = Model()
        model.lookyLooky = true
        let listener = GameUpdateLogger()
        model.gameListener = listener
        computerMakeGame(model: model, numberOfGames: 100)
        XCTAssertEqual(model.gameState, .gameOver)
        XCTAssertEqual(model.school.players.count, 1)
        XCTAssertEqual(model.deck.max, 54)
    }

    func testLookyLookyJokers1() throws {
        let model = Model()
        model.lookyLooky = true
        model.setUpGame(numberOfAIPlayers: 4)
        XCTAssertEqual(model.deck.count, 54)
        model.lookyLooky = false
        model.setUpGame(numberOfAIPlayers: 4)
        XCTAssertEqual(model.deck.count, 52)
    }

}
