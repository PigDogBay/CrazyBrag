//
//  PlayerTests.swift
//  CardGamesTests
//
//  Created by Mark Bailey on 06/10/2022.
//

import XCTest
@testable import CrazyBrag

final class PlayerTests: XCTestCase {

    ///Check there is no Strong Reference Cycle
    ///Remove weak in BestAI to make test fail
    func testARC1() throws {
        weak var weakPlayer : Player?
        weak var weakAI : AI?
        autoreleasepool{
            let bestAI = BestAI()
            let player = Player(name: "Chris", ai: bestAI)
            bestAI.player = player
            weakPlayer = player
            weakAI = bestAI
            XCTAssertNotNil(weakPlayer)
            XCTAssertNotNil(weakAI)
        }
        XCTAssertNil(weakPlayer)
        XCTAssertNil(weakAI)
    }
}
