//
//  RankTests.swift
//  CrazyBragTests
//
//  Created by Mark Bailey on 19/12/2023.
//

import XCTest
@testable import CrazyBrag

final class RankTests: XCTestCase {
    func testFlatten1() throws {
        XCTAssertEqual(Rank.unflatten(flattened: "A"), .ace)
        XCTAssertEqual(Rank.unflatten(flattened: "2"), .two)
        XCTAssertEqual(Rank.unflatten(flattened: "3"), .three)
        XCTAssertEqual(Rank.unflatten(flattened: "4"), .four)
        XCTAssertEqual(Rank.unflatten(flattened: "5"), .five)
        XCTAssertEqual(Rank.unflatten(flattened: "6"), .six)
        XCTAssertEqual(Rank.unflatten(flattened: "7"), .seven)
        XCTAssertEqual(Rank.unflatten(flattened: "8"), .eight)
        XCTAssertEqual(Rank.unflatten(flattened: "9"), .nine)
        XCTAssertEqual(Rank.unflatten(flattened: "T"), .ten)
        XCTAssertEqual(Rank.unflatten(flattened: "j"), .jack)
        XCTAssertEqual(Rank.unflatten(flattened: "Q"), .queen)
        XCTAssertEqual(Rank.unflatten(flattened: "k"), .king)
    }
    
    func testFlatten2() throws {
        XCTAssertNil(Rank.unflatten(flattened: ""))
        XCTAssertNil(Rank.unflatten(flattened: "X"))
        XCTAssertNil(Rank.unflatten(flattened: "f"))
        XCTAssertNil(Rank.unflatten(flattened: "ace"))
    }
}
