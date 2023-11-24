//
//  SchoolTests.swift
//  CardGamesTests
//
//  Created by Mark Bailey on 26/09/2022.
//

import XCTest
@testable import CrazyBrag

final class SchoolTests: XCTestCase {

    func testDetermineLosingHands1() throws {
        let school = School()
        school.setUpPlayers()
        school.playerHowie.hand.hand = A23Trotter
        school.playerBomber.hand.hand = AKQRun
        school.playerLeon.hand.hand = AKJFlush
        school.playerChris.hand.hand = QQKPair
        school.playerGeordie.hand.hand = AAQPair
        school.playerHuman.hand.hand = A23Run
        school.resolveHands()
        let losers = school.determineLosingHands()
        XCTAssertEqual(losers?.count, 1)
        XCTAssertEqual(losers?.first?.name, school.playerChris.name)
        XCTAssertFalse(school.isPrialOut())
        XCTAssertEqual(school.highestScoringPlayer()?.name, school.playerHowie.name)
    }
    
    func testDetermineLosingHands2() throws {
        let school = School()
        school.setUpPlayers()
        school.playerHowie.hand.hand = AKQRun
        school.playerBomber.hand.hand = A23Trotter
        school.playerLeon.hand.hand = AKJFlush
        school.playerChris.hand.hand = AKJFlush
        school.playerGeordie.hand.hand = JQKRun
        school.playerHuman.hand.hand = A23Run
        school.resolveHands()
        let losers = school.determineLosingHands()
        XCTAssertEqual(losers?.count, 2)
        XCTAssertTrue(losers?.contains(where: {$0.name == school.playerChris.name}) ?? false)
        XCTAssertTrue(losers?.contains(where: {$0.name == school.playerLeon.name}) ?? false)
        XCTAssertFalse(school.isPrialOut())
        XCTAssertEqual(school.highestScoringPlayer()?.name, school.playerBomber.name)
    }

    //Prial out, everyone off
    func testDetermineLosingHands3() throws {
        let school = School()
        school.setUpPlayers()
        school.playerHowie.hand.hand = A23Trotter
        school.playerBomber.hand.hand = AKQRun
        school.playerLeon.hand.hand = AKJFlush
        school.playerChris.hand.hand = PrialOfAces
        school.playerGeordie.hand.hand = AAQPair
        school.playerHuman.hand.hand = A23Run
        school.resolveHands()
        let losers = school.determineLosingHands()
        XCTAssertEqual(losers?.count, 5)
        XCTAssertTrue(losers?.contains(where: {$0.name == school.playerHowie.name}) ?? false)
        XCTAssertTrue(losers?.contains(where: {$0.name == school.playerLeon.name}) ?? false)
        XCTAssertTrue(losers?.contains(where: {$0.name == school.playerBomber.name}) ?? false)
        XCTAssertTrue(school.isPrialOut())
        XCTAssertEqual(school.highestScoringPlayer()?.name, school.playerChris.name)
    }
    
    func testareAllPlayersOut1() throws {
        let school = School()
        school.setUpPlayers()
        school.players.forEach{$0.lives = 0}
        XCTAssertTrue(school.areAllPlayersOut())
    }
    
    func testSortPlayersInDealOrder1() throws {
        let school = School()
        school.setUpPlayers()
        school.dealer = school.players[0]
        let dealOrderPlayers = school.sortPlayersInDealOrder()
        XCTAssertEqual(dealOrderPlayers.count, 6)
        XCTAssertEqual(dealOrderPlayers[0].seat, 1)
        XCTAssertEqual(dealOrderPlayers[2].seat, 3)
        XCTAssertEqual(dealOrderPlayers[5].seat, 0)
    }
    func testSortPlayersInDealOrder2() throws {
        let school = School()
        school.setUpPlayers()
        school.dealer = school.players[2]
        let dealOrderPlayers = school.sortPlayersInDealOrder()
        XCTAssertEqual(dealOrderPlayers.count, 6)
        XCTAssertEqual(dealOrderPlayers[0].seat, 3)
        XCTAssertEqual(dealOrderPlayers[2].seat, 5)
        XCTAssertEqual(dealOrderPlayers[5].seat, 2)
    }
    
    func testSortPlayersInDealOrder3() throws {
        let school = School()
        school.setUpPlayers()
        school.dealer = school.players[5]
        let dealOrderPlayers = school.sortPlayersInDealOrder()
        XCTAssertEqual(dealOrderPlayers.count, 6)
        XCTAssertEqual(dealOrderPlayers[0].seat, 0)
        XCTAssertEqual(dealOrderPlayers[2].seat, 2)
        XCTAssertEqual(dealOrderPlayers[5].seat, 5)
    }
    func testSortPlayersInDealOrder4() throws {
        let school = School()
        school.setUpPlayers()
        school.players.removeAll(where: {$0.seat > 1})
        school.dealer = school.players[0]
        let dealOrderPlayers = school.sortPlayersInDealOrder()
        XCTAssertEqual(dealOrderPlayers.count, 2)
        XCTAssertEqual(dealOrderPlayers[0].seat, 1)
        XCTAssertEqual(dealOrderPlayers[1].seat, 0)
    }

}
