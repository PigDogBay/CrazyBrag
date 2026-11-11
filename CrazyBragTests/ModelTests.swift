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
    private var roundLosers : [CrazyBrag.Player]? = nil
    private var actionResults = [CrazyBrag.TurnActionResult]()
    //MARK: - Game Listener Methods
    func dealerSelected(dealer: CrazyBrag.Player) {
        
    }
    
    func dealingDone(dealtCards: [CrazyBrag.DealtCard]) {
        
    }
    
    func reveal() {
        
    }
    
    func turnStarted(player: CrazyBrag.Player, middle: CrazyBrag.PlayerHand) {
        
    }
    
    func actionTaken(player: CrazyBrag.Player, action: CrazyBrag.TurnActionResult) {
        actionResults.append(action)
    }

    func turnEnded(player: CrazyBrag.Player, middle: CrazyBrag.PlayerHand, turn: CrazyBrag.Turn) {
        
    }
    
    func showHands(players: [CrazyBrag.Player]) {
        
    }
    
    func roundEnded(losingPlayers: [CrazyBrag.Player], extraLife: CrazyBrag.Player?) {
        extraLifePlayer = extraLife
        roundLosers = losingPlayers
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
        roundLosers = nil
        actionResults.removeAll()
    }

    override func tearDownWithError() throws {
        //Setting up a Looky Looky game switches this on for every hand that is scored
        HandRules.deucesWild = false
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

    ///Two players, the first with a prial (not their first) and the second with a trotter
    private func scorePrialAgainstTrotter(lookyLooky : Bool) -> Model {
        let model = Model()
        model.lookyLooky = lookyLooky
        model.gameListener = self
        model.setUpGame(numberOfAIPlayers: 1)
        model.school.players[0].hasHadExtraLife = true
        PrialOfKings.forEach{ card in
            model.deck.remove(card: card)
            model.school.players[0].hand.receive(card: card)
        }
        A23Trotter.forEach{ card in
            model.deck.remove(card: card)
            model.school.players[1].hand.receive(card: card)
        }
        model.gameState = .scoreRound
        model.updateState()
        return model
    }

    ///Bullet Proof: the trotter does not lose a life to the prial, the round ends with no losers
    func testLookyLookyBulletProof1() throws {
        let model = scorePrialAgainstTrotter(lookyLooky: true)
        XCTAssertEqual(model.school.players[0].lives, 3)
        XCTAssertEqual(model.school.players[1].lives, 3)
        XCTAssertEqual(roundLosers?.count, 0)
        XCTAssertNil(extraLifePlayer)
        XCTAssertEqual(model.gameState, .updateLives)
        XCTAssertFalse(everyoneOutSoReplayRoundCalled)
    }

    ///Standard rules, the trotter loses a life to the prial
    func testLookyLookyBulletProof2() throws {
        let model = scorePrialAgainstTrotter(lookyLooky: false)
        XCTAssertEqual(model.school.players[1].lives, 2)
        XCTAssertEqual(roundLosers?.count, 1)
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

    //MARK: - Looky Looky actions

    ///A game dealt and stepped on to the first player's turn, waiting for them to make their move
    private func startTurn(lookyLooky : Bool) -> Model {
        let model = Model()
        model.lookyLooky = lookyLooky
        model.gameListener = self
        model.setUpGame(numberOfAIPlayers: 4)
        //select dealer, deal, reveal, turn start
        for _ in 1...4 {
            model.updateState()
        }
        XCTAssertEqual(model.gameState, .turnEnd)
        return model
    }

    ///Two of the three actions can be taken, each only once
    func testActions1() throws {
        let model = startTurn(lookyLooky: true)
        TurnAction.allCases.forEach{ XCTAssertTrue(model.canTake(action: $0)) }
        XCTAssertNotNil(model.takeLooky())
        XCTAssertFalse(model.canTake(action: .looky))
        XCTAssertNil(model.takeLooky())
        XCTAssertTrue(model.canTake(action: .stashHand))
        XCTAssertTrue(model.takeStashHand())
        //That is two, so the third is not allowed
        XCTAssertFalse(model.canTake(action: .changeMiddle))
        XCTAssertFalse(model.takeChangeMiddle(card: model.middle.hand[1]))
        XCTAssertEqual(actionResults.count, 2)
        XCTAssertEqual(model.actionsTaken, [.looky, .stashHand])
    }

    ///No actions in a standard game, nor before a turn has started
    func testActions2() throws {
        let model = startTurn(lookyLooky: false)
        TurnAction.allCases.forEach{ XCTAssertFalse(model.canTake(action: $0)) }
        XCTAssertNil(model.takeLooky())
        XCTAssertFalse(model.takeStashHand())
        XCTAssertTrue(actionResults.isEmpty)

        let model2 = Model()
        model2.lookyLooky = true
        model2.setUpGame(numberOfAIPlayers: 4)
        TurnAction.allCases.forEach{ XCTAssertFalse(model2.canTake(action: $0)) }
    }

    ///Looky gives the face down card, the first card of the middle
    func testActionLooky1() throws {
        let model = startTurn(lookyLooky: true)
        XCTAssertEqual(model.takeLooky(), model.middle.hand[0])
    }

    ///Stash hand: three new cards, the old ones are back in the deck
    func testActionStashHand1() throws {
        let model = startTurn(lookyLooky: true)
        let player = model.currentPlayer!
        let old = player.hand.hand
        let deckCount = model.deck.count
        XCTAssertTrue(model.takeStashHand())
        XCTAssertEqual(player.hand.hand.count, 3)
        old.forEach{
            XCTAssertFalse(player.hand.hand.contains($0))
            XCTAssertTrue(model.deck.deck.contains($0))
        }
        XCTAssertEqual(model.deck.count, deckCount)
        guard case .stashHand(let discarded, let dealt) = actionResults[0] else {
            return XCTFail()
        }
        XCTAssertEqual(discarded, old)
        XCTAssertEqual(dealt.map{$0.card}, player.hand.hand)
        XCTAssertEqual(dealt.map{$0.seat}, [player.seat, player.seat, player.seat])
    }

    ///Change a middle card: the new card takes the old card's place
    func testActionChangeMiddle1() throws {
        let model = startTurn(lookyLooky: true)
        let old = model.middle.hand
        let deckCount = model.deck.count
        XCTAssertTrue(model.takeChangeMiddle(card: old[1]))
        XCTAssertEqual(model.middle.hand.count, 3)
        XCTAssertEqual(model.middle.hand[0], old[0])
        XCTAssertNotEqual(model.middle.hand[1], old[1])
        XCTAssertEqual(model.middle.hand[2], old[2])
        XCTAssertTrue(model.deck.deck.contains(old[1]))
        XCTAssertEqual(model.deck.count, deckCount)
        guard case .changeMiddle(let discarded, let dealt) = actionResults[0] else {
            return XCTFail()
        }
        XCTAssertEqual(discarded, old[1])
        XCTAssertEqual(dealt.card, model.middle.hand[1])
        XCTAssertEqual(dealt.cardCount, 2)
        XCTAssertTrue(dealt.isMiddle)
    }

    ///A card that is not in the middle cannot be changed, and the action is not used up
    func testActionChangeMiddle2() throws {
        let model = startTurn(lookyLooky: true)
        XCTAssertFalse(model.takeChangeMiddle(card: model.currentPlayer!.hand.hand[0]))
        XCTAssertTrue(model.canTake(action: .changeMiddle))
        //The face down card can be changed
        let down = model.middle.hand[0]
        XCTAssertTrue(model.takeChangeMiddle(card: down))
        XCTAssertNotEqual(model.middle.hand[0], down)
    }

    ///The actions are available again on the next player's turn, and the round still ends with a full deck
    func testActions3() throws {
        let model = startTurn(lookyLooky: true)
        XCTAssertTrue(model.takeStashHand())
        XCTAssertTrue(model.takeChangeMiddle(card: model.middle.hand[2]))
        //If it is the human player's turn their move has to be supplied
        model.school.humanAI.turn = .all(downIndex: 0)
        let first = model.currentPlayer!
        model.updateState()
        XCTAssertEqual(model.gameState, .turnStart)
        model.updateState()
        XCTAssertNotEqual(model.currentPlayer, first)
        TurnAction.allCases.forEach{ XCTAssertTrue(model.canTake(action: $0)) }
        XCTAssertTrue(model.actionsTaken.isEmpty)
        //Play out the round, the cards are counted when they are stashed
        while model.gameState != .updateLives && model.gameState != .selectDealer {
            model.updateState()
        }
        XCTAssertEqual(model.deck.count, 54)
    }

    func testLookyLookyJokers1() throws {
        let model = Model()
        model.lookyLooky = true
        model.setUpGame(numberOfAIPlayers: 4)
        XCTAssertEqual(model.deck.count, 54)
        XCTAssertTrue(HandRules.deucesWild)
        model.lookyLooky = false
        model.setUpGame(numberOfAIPlayers: 4)
        XCTAssertEqual(model.deck.count, 52)
        XCTAssertFalse(HandRules.deucesWild)
    }

}
