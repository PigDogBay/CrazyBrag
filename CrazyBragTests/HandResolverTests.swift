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

    ///Jokers follow the king in rank order, but the bad joker does not make a run
    func testJoker1(){
        let score = HandResolver(hand: [PlayingCard(suit: .clubs, rank: .queen),
                                        PlayingCard(suit: .spades, rank: .king),
                                        PlayingCard.badJoker]).createScore()
        XCTAssertEqual(score.type, .high)
    }

    ///A joker does not complete a flush, and the two jokers are not a pair
    func testJoker2(){
        let score = HandResolver(hand: [PlayingCard(suit: .spades, rank: .two),
                                        PlayingCard(suit: .spades, rank: .king),
                                        PlayingCard.badJoker]).createScore()
        XCTAssertEqual(score.type, .high)
    }

    ///A pair still counts alongside a joker, but the joker is the lowest kicker
    func testJoker3(){
        let withJoker = HandResolver(hand: [PlayingCard(suit: .hearts, rank: .seven),
                                            PlayingCard.badJoker,
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

    //MARK: - Good joker, wild

    private func score(_ c1 : String, _ c2 : String, _ c3 : String) -> BragHandScore {
        return HandResolver(hand: [c1, c2, c3].map{PlayingCard.unflatten(flattened: $0)!}).createScore()
    }

    ///A pair and the good joker is a prial
    func testGoodJokerPrial1(){
        XCTAssertEqual(score("kd", "gj", "kh"), HandResolver(hand: PrialOfKings).createScore())
        XCTAssertEqual(score("gj", "3c", "3s"), HandResolver(hand: PrialOfThrees).createScore())
        XCTAssertEqual(score("ac", "as", "gj"), HandResolver(hand: PrialOfAces).createScore())
    }

    ///Two suited cards that can make a run are a trotter
    func testGoodJokerTrotter1(){
        XCTAssertEqual(score("2d", "gj", "ad"), HandResolver(hand: A23Trotter).createScore())
        XCTAssertEqual(score("3d", "gj", "ad"), HandResolver(hand: A23Trotter).createScore())
        //QK makes AKQ, which beats JQK
        let akq = score("qs", "ks", "gj")
        XCTAssertEqual(akq.type, .trotter)
        XCTAssertGreaterThan(akq, HandResolver(hand: JQKTrotter).createScore())
        //the joker fills the gap
        XCTAssertEqual(score("js", "gj", "ks"), HandResolver(hand: JQKTrotter).createScore())
    }

    ///The joker goes on the top end of a run when it can
    func testGoodJokerRun1(){
        XCTAssertEqual(score("4c", "5d", "gj"), HandResolver(hand: Weetabix456Run).createScore())
        XCTAssertEqual(score("4c", "6d", "gj"), HandResolver(hand: Weetabix456Run).createScore())
        XCTAssertEqual(score("2c", "3d", "gj"), HandResolver(hand: A23Run).createScore())
        XCTAssertEqual(score("ac", "kd", "gj"), HandResolver(hand: AKQRun).createScore())
    }

    ///Two suited cards that cannot make a run are a flush, with the joker as the highest card available
    func testGoodJokerFlush1(){
        XCTAssertEqual(score("jd", "gj", "ad"), score("jd", "kd", "ad"))
        XCTAssertEqual(score("jd", "gj", "ad").type, .flush)
        //Holding the ace already, the joker is the king
        let flush = score("ah", "9h", "gj")
        XCTAssertEqual(flush.type, .flush)
        XCTAssertEqual(flush, score("ah", "9h", "kh"))
    }

    ///Otherwise the joker pairs the highest card
    func testGoodJokerPair1(){
        let pair2 = score("9c", "gj", "4d")
        XCTAssertEqual(pair2.type, .pair)
        XCTAssertEqual(pair2, score("9c", "9h", "4d"))
        let pair3 = score("ac", "gj", "7d")
        XCTAssertEqual(pair3, score("ac", "ah", "7d"))
    }

    ///Both jokers: the good joker pairs the other card, the bad joker is the lowest kicker
    func testGoodJokerWithBadJoker1(){
        let pair = score("7h", "gj", "bj")
        XCTAssertEqual(pair.type, .pair)
        XCTAssertGreaterThan(score("7h", "7d", "2c"), pair)
        XCTAssertGreaterThan(pair, score("6h", "6d", "ac"))
    }

    ///The scored hand holds the card the joker was played as
    func testGoodJokerPairRank1(){
        let resolver = HandResolver(hand: [PlayingCard.goodJoker,
                                           PlayingCard(suit: .clubs, rank: .nine),
                                           PlayingCard(suit: .diamonds, rank: .four)])
        XCTAssertEqual(resolver.pairRank, .nine)
        XCTAssertFalse(resolver.hand.contains(PlayingCard.goodJoker))
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
