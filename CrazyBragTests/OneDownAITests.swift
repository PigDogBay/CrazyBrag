//
//  OneDownAITests.swift
//  CrazyBragTests
//
//  Created by Mark Bailey on 19/12/2023.
//

import XCTest
@testable import CrazyBrag

final class OneDownAITests: XCTestCase {
    
    func setHand(_ player : Player, card1: String, card2: String, card3: String){
        guard let c1 = PlayingCard.unflatten(flattened: card1),
              let c2 = PlayingCard.unflatten(flattened: card2),
              let c3 = PlayingCard.unflatten(flattened: card3) else {
            XCTFail("Bad card")
            return
        }
        _ = player.hand.stash()
        player.hand.receive(card: c1)
        player.hand.receive(card: c2)
        player.hand.receive(card: c3)
    }
    
    private func checkAITurn(playerCards : [String], middleCards : [String], expected : Turn) {
        let ai = OneDownAI()
        let player = Player(name: "HAL", ai: ai)
        setHand(player, card1: playerCards[0], card2: playerCards[1], card3: playerCards[2])
        let middleHand = createMiddle(card1: middleCards[0], card2: middleCards[1], card3: middleCards[2])!
        let actual = ai.play(middle: middleHand)
        XCTAssertEqual(expected, actual, "\(expected.display()) != \(actual.display())")
    }
    
    private func createTurn(player : String, middle : String) -> Turn {
        let playerCard = PlayingCard.unflatten(flattened: player)!
        let middleCard = PlayingCard.unflatten(flattened: middle)!
        return Turn.swap(hand: playerCard, middle: middleCard)
    }
    
    func createMiddle(card1: String, card2: String, card3: String) -> PlayerHand?{
        guard let c1 = PlayingCard.unflatten(flattened: card1),
              let c2 = PlayingCard.unflatten(flattened: card2),
              let c3 = PlayingCard.unflatten(flattened: card3) else {
            return nil
        }
        return PlayerHand(hand: [c1,c2,c3])
    }
    
    func printTurns(player: PlayerHand, middle : PlayerHand){
        return HandGenerator(playerHand: player)
            .generatePossibleTurnsFaceUpOnly(middle: middle)
            .forEach {
                print($0.display())
            }
    }
    
    func testGoForMiddle1() throws {
        checkAITurn(playerCards: ["qd","qh","2s"],
                    middleCards: ["5h","3d","7c"],
                    expected: createTurn(player: "2s", middle: "5h"))
    }
    
    //Player can get a flush
    func testDontGoForMiddle1() throws {
        checkAITurn(playerCards: ["qd","qh","2d"],
                    middleCards: ["5h","3d","7c"],
                    expected: createTurn(player: "qh", middle: "3d"))
    }
    
    func testBetterPair1() throws {
        checkAITurn(playerCards: ["as","qd","qh"],
                    middleCards: ["5h","3d","ac"],
                    expected: createTurn(player: "qd", middle: "ac"))
    }
    
    func testBetterPair2() throws {
        checkAITurn(playerCards: ["qs","3d","qh"],
                    middleCards: ["5h","ad","ac"],
                    expected: .all(downIndex: 1))
    }

    func testBait1() throws {
        checkAITurn(playerCards: ["qs","qh","3d"],
                    middleCards: ["5h","ad","ac"],
                    expected: .all(downIndex: 2))
    }
    func testBait2() throws {
        checkAITurn(playerCards: ["3d","qs","qh"],
                    middleCards: ["5h","ad","ac"],
                    expected: .all(downIndex: 0))
    }
    func testOneSuit1() throws {
        checkAITurn(playerCards: ["3s","4s","qh"],
                    middleCards: ["5h","ad","ac"],
                    expected: .all(downIndex: 2))
    }
    func testOneSuit2() throws {
        checkAITurn(playerCards: ["3s","qh","4s"],
                    middleCards: ["5h","ad","ac"],
                    expected: .all(downIndex: 1))
    }
    func testOneSuit3() throws {
        checkAITurn(playerCards: ["qh","7s","4s"],
                    middleCards: ["5h","ad","ac"],
                    expected: .all(downIndex: 0))
    }

    func testWorsePairInMiddle1() throws {
        checkAITurn(playerCards: ["qs","qh","6d"],
                    middleCards: ["5h","jd","jc"],
                    expected: createTurn(player: "6d", middle: "5h"))
    }
    
    //Player should take the facedown card
    func testPrialInHand1() throws {
        checkAITurn(playerCards: ["qc","qd","qh"],
                    middleCards: ["5h","3d","ac"],
                    expected: createTurn(player: "qc", middle: "5h"))
    }
    
    //Player should try for a better prial of aces
    func testPrialInHand2() throws {
        checkAITurn(playerCards: ["qc","qd","qh"],
                    middleCards: ["5h","ad","ac"],
                    expected: .all(downIndex: 2))
    }
    
    //Player should take the queen
    func testPrialInHand3() throws {
        checkAITurn(playerCards: ["qc","qd","qh"],
                    middleCards: ["ah","ad","qs"],
                    expected: createTurn(player: "qc", middle: "qs"))
    }
    
    func testTakeTheBait1() throws {
        checkAITurn(playerCards: ["qc","kd","ah"],
                    middleCards: ["ah","2d","2s"],
                    expected: .all(downIndex: 0))
    }
    
    func testFlush1() throws {
        checkAITurn(playerCards: ["qc","kh","ah"],
                    middleCards: ["ah","2h","2s"],
                    expected: createTurn(player: "qc", middle: "2h"))
    }
    
    func testRun1() throws {
        checkAITurn(playerCards: ["qc","kh","ah"],
                    middleCards: ["as","2h","jd"],
                    expected: createTurn(player: "ah", middle: "jd"))
    }

    func testTrotter1() throws {
        checkAITurn(playerCards: ["qc","kc","ad"],
                    middleCards: ["ah","as","jc"],
                    expected: createTurn(player: "ad", middle: "jc"))
    }

    func testPrial1() throws {
        checkAITurn(playerCards: ["qc","kc","kd"],
                    middleCards: ["ah","ac","ks"],
                    expected: createTurn(player: "qc", middle: "ks"))
    }
    
    func testPotential1() throws {
        checkAITurn(playerCards: ["qc","kc","ad"],
                    middleCards: ["2s","3s","4s"],
                    expected: createTurn(player: "ad", middle: "2s"))
    }

    func testPotential2() throws {
        checkAITurn(playerCards: ["2s","3s","4s"],
                    middleCards: ["7d","kc","qc"],
                    expected: .all(downIndex: 0))
    }

    func testPotential3() throws {
        checkAITurn(playerCards: ["7d","ks","qd"],
                    middleCards: ["2s","3c","8c"],
                    expected: createTurn(player: "7d", middle: "2s"))
    }
    //MARK: - Good joker

    ///The joker makes a run with the three, better than gambling on the down card
    func testGoodJokerRun1() throws {
        checkAITurn(playerCards: ["gj","qh","2s"],
                    middleCards: ["5h","3d","7c"],
                    expected: createTurn(player: "qh", middle: "3d"))
    }

    ///A higher pair than the joker would make is showing next to the joker, so take all three
    func testGoodJokerTakeAll1() throws {
        checkAITurn(playerCards: ["9d","5h","2s"],
                    middleCards: ["5h","gj","kc"],
                    expected: Turn.all(downIndex: 0))
    }

    ///The joker makes a pair of kings, go for the down card with the odd card, not the joker
    func testGoodJokerGoForMiddle1() throws {
        checkAITurn(playerCards: ["gj","kh","6s"],
                    middleCards: ["5h","2d","9c"],
                    expected: createTurn(player: "6s", middle: "5h"))
    }

    ///Pick up the good joker when it is showing
    func testGoodJokerTakeIt1() throws {
        checkAITurn(playerCards: ["9d","qh","2s"],
                    middleCards: ["5h","gj","7c"],
                    expected: createTurn(player: "2s", middle: "gj"))
    }

    ///A pair is showing, but swapping one card makes the same pair and keeps the joker
    func testGoodJokerKeepIt1() throws {
        checkAITurn(playerCards: ["gj","9h","4s"],
                    middleCards: ["5h","qd","qc"],
                    expected: createTurn(player: "4s", middle: "qd"))
    }

    ///Holding a prial made with the joker, a card has to go: not the joker
    func testGoodJokerPrial1() throws {
        checkAITurn(playerCards: ["gj","9h","9s"],
                    middleCards: ["5h","2d","6c"],
                    expected: createTurn(player: "9h", middle: "5h"))
    }

    ///Holding a prial made with the joker, swapping for the ten leaves a trotter
    func testGoodJokerPrial2() throws {
        checkAITurn(playerCards: ["gj","9h","9s"],
                    middleCards: ["5h","th","6c"],
                    expected: createTurn(player: "9s", middle: "th"))
    }

    //MARK: - Looky Looky actions

    override func tearDown() {
        HandRules.deucesWild = false
    }

    private func checkAIAction(playerCards : [String], middleCards : [String], available : [TurnAction] = TurnAction.allCases,
                               looked : Bool = false, expected : ActionChoice?) {
        let ai = OneDownAI()
        let player = Player(name: "HAL", ai: ai)
        setHand(player, card1: playerCards[0], card2: playerCards[1], card3: playerCards[2])
        let middleHand = createMiddle(card1: middleCards[0], card2: middleCards[1], card3: middleCards[2])!
        if looked {
            ai.lookedAt(card: middleHand.hand[0])
        }
        let actual = ai.chooseAction(middle: middleHand, available: available)
        XCTAssertEqual(expected, actual)
    }

    private func change(_ card : String) -> ActionChoice {
        return .changeMiddle(card: PlayingCard.unflatten(flattened: card)!)
    }

    ///A hand going nowhere is stashed straightaway
    func testActionStash1() throws {
        checkAIAction(playerCards: ["kh","7d","3s"], middleCards: ["5h","9c","jc"], expected: .stashHand)
    }

    ///Not if a pair can be made with a card that is showing
    func testActionStash2() throws {
        checkAIAction(playerCards: ["kh","7d","3s"], middleCards: ["5h","kc","9d"], expected: .looky)
        checkAIAction(playerCards: ["kh","7d","3s"], middleCards: ["5h","kc","9d"], available: [.stashHand, .changeMiddle],
                      looked: true, expected: nil)
    }

    ///Going to take the middle anyway, so nothing to lose by trying a new hand first
    func testActionStash3() throws {
        checkAIAction(playerCards: ["kh","kd","3s"], middleCards: ["ah","ac","ad"], available: [.stashHand, .changeMiddle],
                      looked: true, expected: .stashHand)
    }

    ///Promising hand, the cards showing do not help
    func testActionLooky1() throws {
        checkAIAction(playerCards: ["kh","qh","3s"], middleCards: ["5h","9c","6d"], expected: .looky)
    }

    ///Holding a pair, look for the prial
    func testActionLooky2() throws {
        checkAIAction(playerCards: ["kh","kd","3s"], middleCards: ["5h","9c","6d"], expected: .looky)
    }

    ///A pair is showing in the middle
    func testActionLooky3() throws {
        checkAIAction(playerCards: ["kh","7d","3s"], middleCards: ["5h","9c","9d"], available: [.looky, .changeMiddle], expected: .looky)
    }

    ///A run can already be made, look anyway
    func testActionLooky4() throws {
        checkAIAction(playerCards: ["kh","qd","3s"], middleCards: ["5h","jc","7d"], expected: .looky)
    }

    ///Looked and the down card is no help, change the higher of the cards showing
    func testActionChange1() throws {
        checkAIAction(playerCards: ["kh","qh","3s"], middleCards: ["5d","9c","6d"], available: [.stashHand, .changeMiddle],
                      looked: true, expected: change("9c"))
    }

    ///Taking the king for a pair, so change the other card
    func testActionChange2() throws {
        checkAIAction(playerCards: ["kh","qh","3s"], middleCards: ["5d","kc","6d"], available: [.stashHand, .changeMiddle],
                      looked: true, expected: change("6d"))
    }

    ///Taking a nine as a better kicker breaks up the pair showing, change the other nine for a chance of the prial
    func testActionChange3() throws {
        checkAIAction(playerCards: ["kh","kd","3s"], middleCards: ["5d","9c","9d"], available: [.stashHand, .changeMiddle],
                      looked: true, expected: change("9d"))
    }

    ///Spite: taking the down card for a prial, don't leave the pair of nines for the next player
    func testActionChange4() throws {
        checkAIAction(playerCards: ["kh","kd","3s"], middleCards: ["ks","9c","9d"], available: [.stashHand, .changeMiddle],
                      looked: true, expected: change("9c"))
    }

    ///Nothing left to do
    func testActionNone1() throws {
        checkAIAction(playerCards: ["kh","qh","3s"], middleCards: ["5d","9c","6d"], available: [.stashHand],
                      looked: true, expected: nil)
        checkAIAction(playerCards: ["kh","qh","3s"], middleCards: ["5d","9c","6d"], available: [], expected: nil)
    }

    ///Having looked, the AI plays with the down card known
    func testPlayAfterLooky1() throws {
        let ai = OneDownAI()
        let player = Player(name: "HAL", ai: ai)
        setHand(player, card1: "kh", card2: "qh", card3: "3s")
        let middleHand = createMiddle(card1: "jh", card2: "9c", card3: "6d")!
        ai.lookedAt(card: middleHand.hand[0])
        XCTAssertEqual(ai.play(middle: middleHand), createTurn(player: "3s", middle: "jh"))
    }

    /**
     Plays Looky Looky games between computer players that take the actions and players that do not,
     to see what the actions are worth. Not a test, rename to testTournament to run it.
     */
    func tournament() throws {
        var wins = [true : 0, false : 0]
        let games = 3000
        for _ in 1...games {
            let model = Model()
            model.lookyLooky = true
            model.setUpGame(numberOfAIPlayers: 5)
            let players : [Player] = (0..<6).map{
                let ai = OneDownAI()
                ai.usesActions = $0 % 2 == 0
                return Player(name: "P\($0)", ai: ai)
            }.shuffled()
            for (seat, player) in players.enumerated() {
                player.seat = seat
            }
            model.school.players = players
            model.school.dealer = players.randomElement()
            var steps = 0
            while model.gameState != .gameOver && steps < 100000 {
                model.updateState()
                steps += 1
            }
            XCTAssertEqual(model.gameState, .gameOver)
            let winner = model.school.players.first!.ai as! OneDownAI
            wins[winner.usesActions]! += 1
        }
        print("TOURNAMENT actions: \(wins[true]!) no actions: \(wins[false]!) of \(games)")
    }

}
