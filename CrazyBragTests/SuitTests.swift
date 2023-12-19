//
//  SuitTests.swift
//  CrazyBragTests
//
//  Created by Mark Bailey on 19/12/2023.
//

import XCTest
@testable import CrazyBrag

final class SuitTests: XCTestCase {
    func testFlatten1() throws {
        XCTAssertEqual(Suit.unflatten(flattened: "C"), .clubs)
        XCTAssertEqual(Suit.unflatten(flattened: "d"), .diamonds)
        XCTAssertEqual(Suit.unflatten(flattened: "H"), .hearts)
        XCTAssertEqual(Suit.unflatten(flattened: "s"), .spades)
    }
    
    func testFlatten2() throws {
        XCTAssertNil(Suit.unflatten(flattened: ""))
        XCTAssertNil(Suit.unflatten(flattened: "x"))
        XCTAssertNil(Suit.unflatten(flattened: "2"))
        XCTAssertNil(Suit.unflatten(flattened: "spades"))
    }
}
