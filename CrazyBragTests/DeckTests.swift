//
//  DeckTests.swift
//  CardGamesTests
//
//  Created by Mark Bailey on 05/10/2022.
//

import XCTest
@testable import CrazyBrag

class DeckTests: XCTestCase {
    
    func testCreateDeck1() throws {
        let deck = Deck()
        deck.createDeck()
        XCTAssertEqual(deck.count, 52)
    }
    
    func testDeal1() throws {
        let deck = Deck()
        deck.createDeck()
        let card = deck.deal()
        XCTAssertEqual(deck.count, 51)
    }
    
    func testDeal2() throws {
        let deck = Deck()
        deck.createDeck()
        deck.shuffle()
        let card = deck.deal(dealUp: true)
    }

    func testReceive1() throws {
        let deck = Deck()
        deck.createDeck()
        let card = deck.deal()
        try deck.receive(cards: [card])
        XCTAssertEqual(deck.count, 52)
    }

    func testReceive2() throws {
        let deck = Deck()
        deck.createDeck()
        let card = deck.deal()
        try deck.receive(cards: [card])
        XCTAssertThrowsError(try deck.receive(cards: [card])){error in
            guard case CardErrors.CardAlreadyInThePack(let doppleGanger) = error else {
                return XCTFail()
            }
            XCTAssertEqual(doppleGanger, card)
        }
        XCTAssertEqual(deck.count, 52)
    }
    
    func testCut1() throws {
        let deck = Deck()
        deck.createDeck()
        deck.cut(numberOfCards: 21)
        XCTAssertEqual(deck.count, 21)
    }
    func testCut2() throws {
        let deck = Deck()
        deck.createDeck()
        deck.cut(numberOfCards: 0)
        XCTAssertEqual(deck.count, 0)
    }
    func testCut3() throws {
        let deck = Deck()
        deck.createDeck()
        deck.cut(numberOfCards: 1000)
        XCTAssertEqual(deck.count, 52)
    }

}
