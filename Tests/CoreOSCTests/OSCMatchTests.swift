//
//  OSCMatchTests.swift
//
//
//  Created by Sam Smallman on 26/07/2021.
//

import XCTest
@testable import CoreOSC

final class OSCMatchTests: XCTestCase {

    static var allTests = [
        ("testFullMatch", testFullMatch),
        ("testAsteriskMatch", testAsteriskMatch),
        ("testQuestionMarkMatch",testQuestionMarkMatch),
        ("testSquareBracketsMatch", testSquareBracketsMatch)
    ]

    func testFullMatch() {
        XCTAssertEqual(OSCMatch.match(pattern: "/core/osc",
                                      address: "/core/osc"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/core/osc".count,
                                       addressCharactersMatched: "/core/osc".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/a/b/c/d/e",
                                      address: "/a/b/c/d/e"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/a/b/c/d/e".count,
                                       addressCharactersMatched: "/a/b/c/d/e".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/a/b/c/d/e",
                                      address: "/a/b/c"),
                       OSCPatternMatch(match: .partialAddress,
                                       patternCharactersMatched: "/a/b/c".count,
                                       addressCharactersMatched: "/a/b/c".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/a/b/c",
                                      address: "/a/b/c/d/e"),
                       OSCPatternMatch(match: .partialPattern,
                                       patternCharactersMatched: "/a/b/c".count,
                                       addressCharactersMatched: "/a/b/c".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/core/osc",
                                      address: "/a/b/c"),
                       OSCPatternMatch(match: .unmatched,
                                       patternCharactersMatched: 1,
                                       addressCharactersMatched: 1))
    }
    
    func testAsteriskMatch() {
        XCTAssertEqual(OSCMatch.match(pattern: "/*",
                                      address: "/core"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/*".count,
                                       addressCharactersMatched: "/core".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/*/osc",
                                      address: "/core/osc"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/*/osc".count,
                                       addressCharactersMatched: "/core/osc".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/core/*",
                                      address: "/core/osc"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/core/*".count,
                                       addressCharactersMatched: "/core/osc".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/core/*/test/*/osc/*/core/*/test",
                                      address: "/core/osc/test/core/osc/test/core/osc/test"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/core/*/test/*/osc/*/core/*/test".count,
                                       addressCharactersMatched: "/core/osc/test/core/osc/test/core/osc/test".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/*a",
                                      address: "/corea"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/*a".count,
                                       addressCharactersMatched: "/corea".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/*a",
                                      address: "/coreb"),
                       OSCPatternMatch(match: .unmatched,
                                       patternCharactersMatched: "/*".count,
                                       addressCharactersMatched: "/core".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/*/b/c/d/e",
                                      address: "/a/b/c"),
                       OSCPatternMatch(match: .partialAddress,
                                       patternCharactersMatched: "/a/b/c".count,
                                       addressCharactersMatched: "/a/b/c".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/*/b/c",
                                      address: "/a/b/c/d/e"),
                       OSCPatternMatch(match: .partialPattern,
                                       patternCharactersMatched: "/a/b/c".count,
                                       addressCharactersMatched: "/a/b/c".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/*/1",
                                      address: "/core/osc"),
                       OSCPatternMatch(match: .unmatched,
                                       patternCharactersMatched: "/*/".count,
                                       addressCharactersMatched: "/core/".count))
    }
    
    func testQuestionMarkMatch() {
        XCTAssertEqual(OSCMatch.match(pattern: "/core/?",
                                      address: "/core/1"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/core/?".count,
                                       addressCharactersMatched: "/core/1".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/?o?e/?s?",
                                      address: "/core/osc"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/?o?e/?s?".count,
                                       addressCharactersMatched: "/core/osc".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/???????",
                                      address: "/core"),
                       OSCPatternMatch(match: .partialAddress,
                                       patternCharactersMatched: "/????".count,
                                       addressCharactersMatched: "/core".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/????",
                                      address: "/core/osc"),
                       OSCPatternMatch(match: .partialPattern,
                                       patternCharactersMatched: "/????".count,
                                       addressCharactersMatched: "/core".count))
        XCTAssertEqual(OSCMatch.match(pattern: "/?ore",
                                      address: "/corX"),
                       OSCPatternMatch(match: .unmatched,
                                       patternCharactersMatched: "/?or".count,
                                       addressCharactersMatched: "/cor".count))
    }
    
    func testSquareBracketsMatch() {
//        XCTAssertEqual(OSCMatch.match(pattern: "/core/[osc]", address: "/core/o"), 1)
//        XCTAssertEqual(OSCMatch.match(pattern: "/core/[osc]", address: "/core/s"), 1)
//        XCTAssertEqual(OSCMatch.match(pattern: "/core/[osc]", address: "/core/c"), 1)
//        XCTAssertEqual(OSCMatch.match(pattern: "/core/[osc]", address: "/core/a"), 0)
//        XCTAssertEqual(OSCMatch.match(pattern: "/core/[!osc]", address: "/core/osc"), 0)
//        XCTAssertEqual(OSCMatch.match(pattern: "/core/[!osc]", address: "/core/abc"), 2)
//        XCTAssertEqual(OSCMatch.match(pattern: "/core/[!osc]d", address: "/core/abcd"), 2)
    }

}
