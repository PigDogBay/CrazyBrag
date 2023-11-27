//
//  HandGeneratorTests.swift
//  CardGamesTests
//
//  Created by Mark Bailey on 06/10/2022.
//

import XCTest
@testable import CrazyBrag

final class HandGeneratorTests: XCTestCase {

    ///Check that all 3 is a possibility
    func testGeneratePossibleTurns1() throws {
        let playerHand = PlayerHand(hand: QQKPair)
        let middle = PlayerHand(hand: KQTFlush)
        let generator = HandGenerator(playerHand: playerHand)
        let scoredTurns = generator.generatePossibleTurns(middle: middle)
        XCTAssertEqual(scoredTurns.count, 10)
        let count = scoredTurns.filter{$0.turn == Turn.all()}.count
        XCTAssertEqual(count, 1)
        let score = scoredTurns.filter{$0.turn == Turn.all()}.first?.score
        XCTAssertEqual(score, middle.score)
        let middleScore = scoredTurns.filter{$0.turn == Turn.all()}.first?.middleScore
        XCTAssertEqual(middleScore, playerHand.score)
    }

    ///Check that the prial has been found
    func testGeneratePossibleTurns2() throws {
        let playerHand = PlayerHand(hand: QQKPair)
        let middle = PlayerHand(hand: KQTFlush)
        let generator = HandGenerator(playerHand: playerHand)
        let scoredTurns = generator.generatePossibleTurns(middle: middle)
        let count = scoredTurns.filter{$0.turn == Turn.swap(hand: playerHand.hand[2], middle: middle.hand[1])}.count
        XCTAssertEqual(count, 1)
        let score = scoredTurns.filter{$0.turn == Turn.swap(hand: playerHand.hand[2], middle: middle.hand[1])}.first?.score
        XCTAssertEqual(score?.type, .prial)
        let middleScore = scoredTurns.filter{$0.turn == Turn.swap(hand: playerHand.hand[2], middle: middle.hand[1])}.first?.middleScore
        XCTAssertEqual(middleScore?.type, .pair)
    }
    
    func testGeneratePossibleTurnsFaceUpOnly1() throws {
        let playerHand = PlayerHand(hand: [PlayingCard(suit: .clubs, rank: .queen),
                                           PlayingCard(suit: .spades, rank: .king),
                                           PlayingCard(suit: .spades, rank: .queen)])
        let middle = PlayerHand(hand: [PlayingCard(suit: .hearts, rank: .queen, isDown: true),
                                       PlayingCard(suit: .spades, rank: .jack, isDown: false),
                                       PlayingCard(suit: .clubs, rank: .ace, isDown: false)])
        let generator = HandGenerator(playerHand: playerHand)
        let scoredTurns = generator.generatePossibleTurnsFaceUpOnly(middle: middle)
        XCTAssertEqual(scoredTurns.count, 6)
        let best = scoredTurns.max(by: {$0.score < $1.score})
        XCTAssertEqual(best?.score.type, .trotter)
        switch best!.turn {
        case .swap(hand: let hand, middle: let middle):
            XCTAssertEqual(middle.rank, .jack)
            XCTAssertEqual(hand.suit, .clubs)
        case .all:
            XCTFail()
        }
    }
    
    func testGeneratePotentialHands1() throws {
        let playerHand = PlayerHand(hand: [PlayingCard(suit: .clubs, rank: .ace),
                                           PlayingCard(suit: .spades, rank: .king),
                                           PlayingCard(suit: .spades, rank: .queen)])
        let middle = PlayerHand(hand: [PlayingCard(suit: .clubs, rank: .ace, isDown: false),
                                       PlayingCard(suit: .spades, rank: .jack, isDown: false),
                                       PlayingCard(suit: .hearts, rank: .five, isDown: true)])
        let generator = HandGenerator(playerHand: playerHand)
        let scoredTurns = generator.generatePotentialHands(middle: middle)
        XCTAssertEqual(scoredTurns.count, 6)
        let best = scoredTurns.max(by: {$0.score < $1.score})
        XCTAssertEqual(best?.score.type, .trotter)
        switch best!.turn {
        case .swap(hand: let hand, middle: let middle):
            XCTAssertEqual(hand.rank, .ace)
            XCTAssertEqual(middle.rank, .five)
        case .all:
            XCTFail()
        }
    }
    
    func testGeneratePotentialHands2() throws {
        let playerHand = PlayerHand(hand: [PlayingCard(suit: .clubs, rank: .ace),
                                           PlayingCard(suit: .spades, rank: .king),
                                           PlayingCard(suit: .spades, rank: .queen)])
        let middle = PlayerHand(hand: [PlayingCard(suit: .clubs, rank: .ace, isDown: false),
                                       PlayingCard(suit: .spades, rank: .jack, isDown: false),
                                       PlayingCard(suit: .hearts, rank: .five, isDown: true)])
        let generator = HandGenerator(playerHand: playerHand)
        let scoredTurns = generator.generatePotentialHands(middle: middle)
        XCTAssertEqual(1, scoredTurns.filter{$0.turn == .all(downIndex: 0)}.count)
        XCTAssertEqual(1, scoredTurns.filter{$0.turn == .all(downIndex: 1)}.count)
        XCTAssertEqual(1, scoredTurns.filter{$0.turn == .all(downIndex: 0)}.count)
        //test middle score
        let best = generator.generatePotentialHands(middle: middle)          
            .max(by: {$0.middleScore < $1.middleScore})
        XCTAssertEqual(best?.middleScore.type, .trotter)
        switch best!.turn {
        case .swap(hand: _, middle: _):
            XCTFail()
        case .all(downIndex: let downIndex):
            XCTAssertEqual(0, downIndex)
        }
    }
}
