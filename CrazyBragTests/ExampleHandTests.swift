//
//  ExampleHandTests.swift
//  CrazyBragTests
//
//  Created by Mark Bailey on 19/12/2023.
//

import XCTest
@testable import CrazyBrag

final class ExampleHandTests: XCTestCase {

    func testFlattened1() throws {
        let actual = ExampleHand.unflatten(flattened: "2h,2c,jd,Dogs,pair")
        XCTAssertEqual(actual?.name, "Dogs")
        XCTAssertEqual(actual?.type, .pair)
        XCTAssertEqual(actual?.hand[0], PlayingCard(suit: .hearts, rank: .two))
        XCTAssertEqual(actual?.hand[1], PlayingCard(suit: .clubs, rank: .two))
        XCTAssertEqual(actual?.hand[2], PlayingCard(suit: .diamonds, rank: .jack))
    }
    
    func testFlattened2() throws {
        XCTAssertNil(ExampleHand.unflatten(flattened: ""))
        XCTAssertNil(ExampleHand.unflatten(flattened: "2h,2c,jd,Dogs"))
        XCTAssertNil(ExampleHand.unflatten(flattened: "2x,2c,jd,Dogs,pair"))
    }
    
    func testExamples1() throws {
        let examples = ExampleHand.examples()
        XCTAssertEqual(examples.count,35)
        for example in examples {
            XCTAssertFalse(example.name.isEmpty)
            XCTAssertEqual(example.hand.count, 3)
        }
    }
}
