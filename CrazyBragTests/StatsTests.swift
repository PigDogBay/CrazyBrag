//
//  StatsTests.swift
//  CrazyBragTests
//
//  Created by Mark Bailey on 20/02/2024.
//

import XCTest
@testable import CrazyBrag

final class StatTests: XCTestCase {
    func testWinRate1() throws {
        let stats = Stats(played: 0, won: 0)
        XCTAssertEqual(stats.winRate,0.0)
    }
    func testWinRate2() throws {
        let stats = Stats(played: 20, won: 10)
        XCTAssertEqual(stats.winRate,0.5)
    }
    func testWinRateText1() throws {
        let stats = Stats(played: 0, won: 0)
        XCTAssertEqual(stats.winRateText,"0%")
    }
    func testWinRateText2() throws {
        let stats = Stats(played: 20, won: 5)
        XCTAssertEqual(stats.winRateText,"25%")
    }
    
    func testRank1() {
        var stats = Stats(played: 100, won: 0)
        XCTAssertEqual(stats.rank,"Cowpoke")
        stats = Stats(played: 100, won: 2)
        XCTAssertEqual(stats.rank,"Buckaroo")
        stats = Stats(played: 100, won: 100)
        XCTAssertEqual(stats.rank,"Card Sharp")
        stats = Stats(played: 100, won: 1000)
        XCTAssertEqual(stats.rank,"Card King")
    }
    func testRank2() {
        for i in 0...999 {
            let stats = Stats(played: 1000, won: i)
            XCTAssertNotEqual(stats.rank,"Card King")
        }
    }
}
