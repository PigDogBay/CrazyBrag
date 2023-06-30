//
//  VariationOneDownTests.swift
//  CardGamesTests
//
//  Created by Mark Bailey on 07/10/2022.
//

import XCTest
@testable import CrazyBrag

final class VariationOneDownTests: XCTestCase {

    func testIsMiddleCardFaceUp1() throws {
        let rules = VariationOneDown()
        XCTAssertTrue(rules.isMiddleCardFaceUp(dealIndex: 1))
        XCTAssertTrue(rules.isMiddleCardFaceUp(dealIndex: 2))
        XCTAssertFalse(rules.isMiddleCardFaceUp(dealIndex: 3))
    }
    
    func testArrangeMiddle1() throws {
        let rules = VariationOneDown()
        let middle = PlayerHand(hand: [PlayingCard(suit: .clubs, rank: .queen, isDown: true),
                                       PlayingCard(suit: .spades, rank: .king, isDown: true),
                                       PlayingCard(suit: .spades, rank: .queen, isDown: true)])
        rules.arrangeMiddle(middle: middle, turn: .all())
        XCTAssertFalse(middle.hand[0].isDown)
        XCTAssertFalse(middle.hand[1].isDown)
        XCTAssertTrue(middle.hand[2].isDown)
    }

    //Player puts Queen of clubs into the middle and it is down, but the middle card they took is up
    func testArrangeMiddle2() throws {
        let rules = VariationOneDown()
        let middle = PlayerHand(hand: [PlayingCard(suit: .clubs, rank: .queen, isDown: true),
                                       PlayingCard(suit: .spades, rank: .king, isDown: false),
                                       PlayingCard(suit: .spades, rank: .queen, isDown: true)])
        let turn : Turn = .swap(hand: PlayingCard(suit: .clubs, rank: .queen, isDown: true),
                                middle: PlayingCard(suit: .hearts, rank: .two, isDown: false))
        
        rules.arrangeMiddle(middle: middle, turn: turn)
        XCTAssertFalse(middle.hand[0].isDown)
        XCTAssertFalse(middle.hand[1].isDown)
        XCTAssertTrue(middle.hand[2].isDown)
    }

    //Player puts Queen of spaces into the middle and takes two of hearts which was down
    func testArrangeMiddle3() throws {
        let rules = VariationOneDown()
        let middle = PlayerHand(hand: [PlayingCard(suit: .clubs, rank: .queen, isDown: false),
                                       PlayingCard(suit: .spades, rank: .king, isDown: false),
                                       PlayingCard(suit: .spades, rank: .queen, isDown: true)])
        let turn : Turn = .swap(hand: PlayingCard(suit: .spades, rank: .queen, isDown: true),
                                middle: PlayingCard(suit: .hearts, rank: .two, isDown: true))
        
        rules.arrangeMiddle(middle: middle, turn: turn)
        XCTAssertFalse(middle.hand[0].isDown)
        XCTAssertFalse(middle.hand[1].isDown)
        XCTAssertTrue(middle.hand[2].isDown)
    }

}
