//
//  PlayerHandTests.swift
//  CardGamesTests
//
//  Created by Mark Bailey on 29/09/2022.
//

import XCTest
@testable import CrazyBrag

final class PlayerHandTests: XCTestCase {
    
    func testShowHide1() throws {
        let playerHand = PlayerHand(hand: QQKPair)
        playerHand.show()
        XCTAssertFalse(playerHand.hand[0].isDown)
        XCTAssertFalse(playerHand.hand[1].isDown)
        XCTAssertFalse(playerHand.hand[2].isDown)
        playerHand.hide()
        XCTAssertTrue(playerHand.hand[0].isDown)
        XCTAssertTrue(playerHand.hand[1].isDown)
        XCTAssertTrue(playerHand.hand[2].isDown)
    }
}
