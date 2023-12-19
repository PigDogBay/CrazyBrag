//
//  PlayingCardTests.swift
//  CrazyBragTests
//
//  Created by Mark Bailey on 19/12/2023.
//

import XCTest
@testable import CrazyBrag

final class PlayingCardTests: XCTestCase {

    func testFlatten1() throws {
        XCTAssertEqual(PlayingCard.unflatten(flattened: "AH"), PlayingCard(suit: .hearts, rank: .ace))
        XCTAssertEqual(PlayingCard.unflatten(flattened: "jd"), PlayingCard(suit: .diamonds, rank: .jack))
    }
                       
    func testFlatten2() throws {
        XCTAssertNil(PlayingCard.unflatten(flattened: ""))
        XCTAssertNil(PlayingCard.unflatten(flattened: "HA"))
        XCTAssertNil(PlayingCard.unflatten(flattened: "Ax"))
        XCTAssertNil(PlayingCard.unflatten(flattened: "xH"))
        XCTAssertNil(PlayingCard.unflatten(flattened: "AHA"))
    }
}
