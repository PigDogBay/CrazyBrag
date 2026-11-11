//
//  HandResolverTests.swift
//  CardGamesTests
//
//  Created by Mark Bailey on 11/09/2022.
//

import XCTest
@testable import CrazyBrag

class HandResolverTests: XCTestCase {
    
    func testScoringPrial1(){
        XCTAssertGreaterThan(
            HandResolver(hand: PrialOfThrees).createScore(),
            HandResolver(hand: PrialOfAces).createScore())
        XCTAssertGreaterThan(
            HandResolver(hand: PrialOfAces).createScore(),
            HandResolver(hand: PrialOfKings).createScore())
        XCTAssertGreaterThan(
            HandResolver(hand: PrialOfKings).createScore(),
            HandResolver(hand: StateExpress).createScore())
    }


    //MARK: - Jokers

    ///Jokers follow the king in rank order, but do not make a run
    func testJoker1(){
        let score = HandResolver(hand: [PlayingCard(suit: .clubs, rank: .queen),
                                        PlayingCard(suit: .spades, rank: .king),
                                        PlayingCard.goodJoker]).createScore()
        XCTAssertEqual(score.type, .high)
        let score2 = HandResolver(hand: [PlayingCard(suit: .spades, rank: .king),
                                         PlayingCard.goodJoker,
                                         PlayingCard.badJoker]).createScore()
        XCTAssertEqual(score2.type, .high)
    }

    ///A joker does not complete a flush, and the two jokers are not a pair
    func testJoker2(){
        let score = HandResolver(hand: [PlayingCard(suit: .spades, rank: .two),
                                        PlayingCard(suit: .spades, rank: .king),
                                        PlayingCard.badJoker]).createScore()
        XCTAssertEqual(score.type, .high)
        let score2 = HandResolver(hand: [PlayingCard(suit: .hearts, rank: .seven),
                                         PlayingCard.goodJoker,
                                         PlayingCard.badJoker]).createScore()
        XCTAssertEqual(score2.type, .high)
    }

    ///A pair still counts alongside a joker, but the joker is the lowest kicker
    func testJoker3(){
        let withJoker = HandResolver(hand: [PlayingCard(suit: .hearts, rank: .seven),
                                            PlayingCard.goodJoker,
                                            PlayingCard(suit: .clubs, rank: .seven)]).createScore()
        let withTwo = HandResolver(hand: [PlayingCard(suit: .hearts, rank: .seven),
                                          PlayingCard(suit: .diamonds, rank: .two),
                                          PlayingCard(suit: .clubs, rank: .seven)]).createScore()
        XCTAssertEqual(withJoker.type, .pair)
        XCTAssertGreaterThan(withTwo, withJoker)
    }

    ///A joker is the lowest card in a high hand
    func testJoker4(){
        let withJoker = HandResolver(hand: [PlayingCard(suit: .hearts, rank: .nine),
                                            PlayingCard(suit: .clubs, rank: .king),
                                            PlayingCard.badJoker]).createScore()
        let withTwo = HandResolver(hand: [PlayingCard(suit: .hearts, rank: .nine),
                                          PlayingCard(suit: .clubs, rank: .king),
                                          PlayingCard(suit: .diamonds, rank: .two)]).createScore()
        XCTAssertGreaterThan(withTwo, withJoker)
    }

    func testScoringTrotter1(){
        XCTAssertGreaterThan(
            HandResolver(hand: A23Trotter).createScore(),
            HandResolver(hand: JQKTrotter).createScore())
    }

    func testScoringRun1(){
        XCTAssertGreaterThan(
            HandResolver(hand: A23Run).createScore(),
            HandResolver(hand: AKQRun).createScore())
        XCTAssertGreaterThan(
            HandResolver(hand: AKQRun).createScore(),
            HandResolver(hand: JQKRun).createScore())
        XCTAssertGreaterThan(
            HandResolver(hand: Weetabix456Run).createScore(),
            HandResolver(hand: Beehive345Run).createScore())
        XCTAssertGreaterThan(
            HandResolver(hand: JQKRun).createScore(),
            HandResolver(hand: Beehive345Run).createScore())
    }

    func testScoringFlush1(){
        XCTAssertGreaterThan(
            HandResolver(hand: AKJFlush).createScore(),
            HandResolver(hand: KJTFlush).createScore())
        XCTAssertGreaterThan(
            HandResolver(hand: KQTFlush).createScore(),
            HandResolver(hand: KJTFlush).createScore())
        XCTAssertGreaterThan(
            HandResolver(hand: KJTFlush).createScore(),
            HandResolver(hand: KJ9Flush).createScore())
    }

    func testScoringPair1(){
        XCTAssertGreaterThan(
            HandResolver(hand: AAQPair).createScore(),
            HandResolver(hand: QQAPair).createScore())
        XCTAssertGreaterThan(
            HandResolver(hand: QQAPair).createScore(),
            HandResolver(hand: QQKPair).createScore())
    }
    
    func testScoringHigh1() {
        XCTAssertGreaterThan(
            HandResolver(hand: A42High).createScore(),
            HandResolver(hand: KQ3High).createScore())
        XCTAssertGreaterThan(
            HandResolver(hand: KQ3High).createScore(),
            HandResolver(hand: KQ2High).createScore())
    }
    
    func testScoringHandTypes1() {
        XCTAssertGreaterThan(
            HandResolver(hand: PrialOfAces).createScore(),
            HandResolver(hand: JQKTrotter).createScore())
        XCTAssertGreaterThan(
            HandResolver(hand: JQKTrotter).createScore(),
            HandResolver(hand: JQKRun).createScore())
        XCTAssertGreaterThan(
            HandResolver(hand: A23Run).createScore(),
            HandResolver(hand: KJTFlush).createScore())
        XCTAssertGreaterThan(
            HandResolver(hand: KJTFlush).createScore(),
            HandResolver(hand: QQKPair).createScore())
        XCTAssertGreaterThan(
            HandResolver(hand: QQKPair).createScore(),
            HandResolver(hand: KQ2High).createScore())
    }

    func testPrial1() throws {
        let resolver = HandResolver(hand: PrialOfAces)
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .prial)
    }

    func testTrotter1() throws {
        let resolver = HandResolver(hand: JQKTrotter)
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .trotter)
    }

    func testRun1() throws {
        let resolver = HandResolver(hand: JQKRun)
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .run)
    }
    
    func testRun2() throws {
        let resolver = HandResolver(hand: A23Run)
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .run)
    }
    
    func testRun3() throws {
        let resolver = HandResolver(hand: AKQRun)
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .run)
    }

    func testFlush1() throws {
        let resolver = HandResolver(hand: KJTFlush)
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .flush)
    }
    
    func testPair1() throws {
        let resolver = HandResolver(hand: QQKPair)
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .pair)
    }
    
    func testHigh1() throws {
        let resolver = HandResolver(hand: KQ2High)
        let score = resolver.createScore()
        XCTAssertEqual(score.type, .high)
    }


}
