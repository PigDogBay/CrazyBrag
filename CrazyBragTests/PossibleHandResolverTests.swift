//
//  PossibleHandResolverTests.swift
//  CardGamesTests
//
//  Created by Mark Bailey on 06/10/2022.
//

import XCTest
@testable import CrazyBrag

final class PossibleHandResolverTests: XCTestCase {

    func testPrial1() throws {
        let resolver = PossibleHandResolver(hand: [PlayingCard(suit: .clubs, rank: .ace),
                                                   PlayingCard(suit: .spades, rank: .ace)])
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .prial)
    }
    
    func testTrotter1() throws {
        let resolver = PossibleHandResolver(hand: [PlayingCard(suit: .clubs, rank: .nine),
                                                   PlayingCard(suit: .clubs, rank: .seven)])
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .trotter)
    }

    func testRun1() throws {
        let resolver = PossibleHandResolver(hand: [PlayingCard(suit: .clubs, rank: .queen),
                                                   PlayingCard(suit: .spades, rank: .king)])
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .run)
    }
    
    func testRun2() throws {
        let resolver = PossibleHandResolver(hand: [PlayingCard(suit: .clubs, rank: .ace),
                                                   PlayingCard(suit: .spades, rank: .three)])
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .run)
    }
    
    func testRun3() throws {
        let resolver = PossibleHandResolver(hand: [PlayingCard(suit: .clubs, rank: .king),
                                                   PlayingCard(suit: .spades, rank: .jack)])
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .run)
    }

    func testFlush1() throws {
        let resolver = PossibleHandResolver(hand: [PlayingCard(suit: .spades, rank: .king),
                                                   PlayingCard(suit: .spades, rank: .two)])
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .flush)
    }
   
    func testHigh1() throws {
        let resolver = PossibleHandResolver(hand: [PlayingCard(suit: .clubs, rank: .king),
                                                   PlayingCard(suit: .spades, rank: .two)])
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .high)
    }

    func testScoringPrial1(){
        //Possible prial of 3's is scored lower than 4
        XCTAssertGreaterThan(
            PossibleHandResolver(hand: Array(PrialOfFours[0...1])).createScore(),
            PossibleHandResolver(hand: Array(PrialOfThrees[0...1])).createScore())
        XCTAssertGreaterThan(
            PossibleHandResolver(hand: Array(PrialOfAces[0...1])).createScore(),
            PossibleHandResolver(hand: Array(PrialOfKings[0...1])).createScore())
        XCTAssertGreaterThan(
            PossibleHandResolver(hand: Array(PrialOfKings[0...1])).createScore(),
            PossibleHandResolver(hand: Array(StateExpress[0...1])).createScore())
    }
    
    //Test runs are scored by highest cards, AKQ is better than A23
    func testScoringRun1(){
        XCTAssertGreaterThan(
            PossibleHandResolver(hand: [PlayingCard(suit: .clubs, rank: .ace),
                                PlayingCard(suit: .spades, rank: .queen)]).createScore(),
            PossibleHandResolver(hand: [PlayingCard(suit: .clubs, rank: .ace),
                                PlayingCard(suit: .spades, rank: .two)]).createScore())
    }
    
    //Test runs are scored by highest cards, 34 is better than 23
    func testScoringRun2(){
        XCTAssertGreaterThan(
            PossibleHandResolver(hand: [PlayingCard(suit: .clubs, rank: .three),
                                PlayingCard(suit: .spades, rank: .four)]).createScore(),
            PossibleHandResolver(hand: [PlayingCard(suit: .clubs, rank: .two),
                                PlayingCard(suit: .spades, rank: .three)]).createScore())
    }
    //Test runs are scored by highest cards, KQ is better than KJ
    func testScoringRun3(){
        XCTAssertGreaterThan(
            PossibleHandResolver(hand: [PlayingCard(suit: .clubs, rank: .king),
                                PlayingCard(suit: .spades, rank: .queen)]).createScore(),
            PossibleHandResolver(hand: [PlayingCard(suit: .clubs, rank: .king),
                                PlayingCard(suit: .spades, rank: .jack)]).createScore())
    }

    func testScoringFlush1(){
        XCTAssertGreaterThan(
            PossibleHandResolver(hand: [PlayingCard(suit: .clubs, rank: .ace),
                                PlayingCard(suit: .clubs, rank: .four)]).createScore(),
            PossibleHandResolver(hand: [PlayingCard(suit: .spades, rank: .king),
                                PlayingCard(suit: .spades, rank: .four)]).createScore())
    }

    func testScoringFlush2(){
        XCTAssertGreaterThan(
            PossibleHandResolver(hand: [PlayingCard(suit: .clubs, rank: .ace),
                                PlayingCard(suit: .clubs, rank: .ten)]).createScore(),
            PossibleHandResolver(hand: [PlayingCard(suit: .spades, rank: .ace),
                                PlayingCard(suit: .spades, rank: .nine)]).createScore())
    }

}
