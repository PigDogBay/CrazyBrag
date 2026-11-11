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

}
