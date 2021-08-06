//
//  OSCMatchTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 26/07/2021.
//  Copyright © 2021 Sam Smallman. https://github.com/SammySmallman
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import XCTest
@testable import CoreOSC

final class OSCMatchTests: XCTestCase {

    static var allTests = [
        ("testStandardFullMatch", testStandardFullMatch),
        ("testStandardPartialAddressMatch", testStandardPartialAddressMatch),
        ("testStandardPartialPatternMatch", testStandardPartialPatternMatch),
        ("testStandardUnmatched", testStandardUnmatched),
        ("testAsteriskFullMatch", testAsteriskFullMatch),
        ("testAsteriskPartialAddressMatch", testAsteriskPartialAddressMatch),
        ("testAsteriskPartialPatternMatch", testAsteriskPartialPatternMatch),
        ("testAsteriskUnmatched", testAsteriskUnmatched),
        ("testQuestionMarkFullMatch", testQuestionMarkFullMatch),
        ("testQuestionMarkPartialAddressMatch", testQuestionMarkPartialAddressMatch),
        ("testQuestionMarkPartialPatternMatch", testQuestionMarkPartialPatternMatch),
        ("testQuestionMarkUnmatched",testQuestionMarkUnmatched),
        ("testSquareBracketsFullMatch", testSquareBracketsFullMatch),
        ("testNotSquareBracketsFullMatch", testNotSquareBracketsFullMatch),
        ("testSquareBracketsRangeFullMatch", testSquareBracketsRangeFullMatch),
        ("testNotSquareBracketsRangeFullMatch", testNotSquareBracketsRangeFullMatch),
        ("testSquareBracketsPartialAddressMatch", testSquareBracketsPartialAddressMatch),
        ("testNotSquareBracketsPartialAddressMatch", testNotSquareBracketsPartialAddressMatch),
        ("testSquareBracketsRangePartialAddressMatch", testSquareBracketsRangePartialAddressMatch),
        ("testNotSquareBracketsRangePartialAddressMatch", testNotSquareBracketsRangePartialAddressMatch),
        ("testSquareBracketsPartialPatternMatch", testSquareBracketsPartialPatternMatch),
        ("testNotSquareBracketsPartialPatternMatch", testNotSquareBracketsPartialPatternMatch),
        ("testSquareBracketsRangePartialPatternMatch", testSquareBracketsRangePartialPatternMatch),
        ("testNotSquareBracketsRangePartialPatternMatch", testNotSquareBracketsRangePartialPatternMatch),
        ("testSquareBracketsUnmatched", testSquareBracketsUnmatched),
        ("testNotSquareBracketsUnmatched", testNotSquareBracketsUnmatched),
        ("testSquareBracketsRangeUnmatched", testSquareBracketsRangeUnmatched),
        ("testNotSquareBracketsRangeUnmatched", testNotSquareBracketsRangeUnmatched),
        ("testCurlyBracesFullMatch", testCurlyBracesFullMatch),
        ("testCurlyBracesPartialAddressMatch", testCurlyBracesPartialAddressMatch),
        ("testCurlyBracesPartialPatternMatch", testCurlyBracesPartialPatternMatch),
        ("testCurlyBraceUnmatched", testCurlyBraceUnmatched),
        ("testAllWildcardsFullMatch", testAllWildcardsFullMatch)
    ]
    
    // MARK: - Standard OSC Address Pattern Tests
    
    func testStandardFullMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/a/b/c/d/e",
                                      address: "/a/b/c/d/e"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/a/b/c/d/e".count,
                                       addressCharactersMatched: "/a/b/c/d/e".count))
    }
    
    func testStandardPartialAddressMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/a/b/c/d/e",
                                      address: "/a/b/c"),
                       OSCPatternMatch(match: .partialAddress,
                                       patternCharactersMatched: "/a/b/c".count,
                                       addressCharactersMatched: "/a/b/c".count))
    }
    
    func testStandardPartialPatternMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/a/b/c",
                                      address: "/a/b/c/d/e"),
                       OSCPatternMatch(match: .partialPattern,
                                       patternCharactersMatched: "/a/b/c".count,
                                       addressCharactersMatched: "/a/b/c".count))
    }

    func testStandardUnmatched() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/a/b/c",
                                      address: "/d/e/f"),
                       OSCPatternMatch(match: .unmatched,
                                       patternCharactersMatched: "/".count,
                                       addressCharactersMatched: "/".count))
    }
    
    // MARK: - Asterisk Wildcard OSC Address Pattern Tests
    
    func testAsteriskFullMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/*/*/*",
                                      address: "/abc/def/hij"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/*/*/*".count,
                                       addressCharactersMatched: "/abc/def/hij".count))
    }
    
    func testAsteriskPartialAddressMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/*/b/c/d/e",
                                      address: "/a/b/c"),
                       OSCPatternMatch(match: .partialAddress,
                                       patternCharactersMatched: "/a/b/c".count,
                                       addressCharactersMatched: "/a/b/c".count))
    }
    
    func testAsteriskPartialPatternMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/*/b/c",
                                      address: "/a/b/c/d/e"),
                       OSCPatternMatch(match: .partialPattern,
                                       patternCharactersMatched: "/a/b/c".count,
                                       addressCharactersMatched: "/a/b/c".count))
    }
    
    func testAsteriskUnmatched() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/*/abc",
                                      address: "/abc/def"),
                       OSCPatternMatch(match: .unmatched,
                                       patternCharactersMatched: "/*/".count,
                                       addressCharactersMatched: "/abc/".count))
    }
    
    // MARK: - Question Mark Wildcard OSC Address Pattern Tests
    
    func testQuestionMarkFullMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/?b?d/?f?",
                                      address: "/abcd/efg"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/?b?d/?f?".count,
                                       addressCharactersMatched: "/abcd/efg".count))
    }
    
    func testQuestionMarkPartialAddressMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/???????",
                                      address: "/abc"),
                       OSCPatternMatch(match: .partialAddress,
                                       patternCharactersMatched: "/???".count,
                                       addressCharactersMatched: "/abc".count))
    }
    
    func testQuestionMarkPartialPatternMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/???",
                                      address: "/abc/def"),
                       OSCPatternMatch(match: .partialPattern,
                                       patternCharactersMatched: "/???".count,
                                       addressCharactersMatched: "/abc".count))
    }
    
    func testQuestionMarkUnmatched() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/?bcd",
                                      address: "/abcX"),
                       OSCPatternMatch(match: .unmatched,
                                       patternCharactersMatched: "/?bc".count,
                                       addressCharactersMatched: "/abc".count))
    }
    
    // MARK: - Square Brackets Wildcard OSC Address Pattern Tests
    
    func testSquareBracketsFullMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/[abc]def/[hij]klm",
                                      address: "/adef/iklm"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/[abc]def/[hij]klm".count,
                                       addressCharactersMatched: "/adef/iklm".count))
    }
    
    func testNotSquareBracketsFullMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/[!abc]abc/[!hij]hij",
                                      address: "/dabc/lhij"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/[!abc]abc/[!hij]hij".count,
                                       addressCharactersMatched: "/dabc/lhij".count))
    }
    
    func testSquareBracketsRangeFullMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/[a-c]def/[g-i]jkl",
                                      address: "/bdef/hjkl"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/[a-c]def/[g-i]jkl".count,
                                       addressCharactersMatched: "/bdef/hjkl".count))
    }
    
    func testNotSquareBracketsRangeFullMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/[!a-c]abc/[!h-j]hij",
                                      address: "/dabc/lhij"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/[!a-c]abc/[!h-j]hij".count,
                                       addressCharactersMatched: "/dabc/lhij".count))
    }
    
    func testSquareBracketsPartialAddressMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/[abc]/def",
                                      address: "/b/"),
                       OSCPatternMatch(match: .partialAddress,
                                       patternCharactersMatched: "/[abc]/".count,
                                       addressCharactersMatched: "/b/".count))
    }
    
    func testNotSquareBracketsPartialAddressMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/[!abc]/def",
                                      address: "/e/"),
                       OSCPatternMatch(match: .partialAddress,
                                       patternCharactersMatched: "/[!abc]/".count,
                                       addressCharactersMatched: "/b/".count))
    }
    
    func testSquareBracketsRangePartialAddressMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/[a-c]/def",
                                      address: "/b/"),
                       OSCPatternMatch(match: .partialAddress,
                                       patternCharactersMatched: "/[a-c]/".count,
                                       addressCharactersMatched: "/b/".count))
    }
    
    func testNotSquareBracketsRangePartialAddressMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/[!a-c]/def",
                                      address: "/e/"),
                       OSCPatternMatch(match: .partialAddress,
                                       patternCharactersMatched: "/[!a-c]/".count,
                                       addressCharactersMatched: "/b/".count))
    }
    
    func testSquareBracketsPartialPatternMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/abc/[def]",
                                      address: "/abc/def"),
                       OSCPatternMatch(match: .partialPattern,
                                       patternCharactersMatched: "/abc/[def]".count,
                                       addressCharactersMatched: "/abc/d".count))
    }
    
    func testNotSquareBracketsPartialPatternMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/abc/[!def]",
                                      address: "/abc/abc"),
                       OSCPatternMatch(match: .partialPattern,
                                       patternCharactersMatched: "/abc/[!def]".count,
                                       addressCharactersMatched: "/abc/a".count))
    }
    
    func testSquareBracketsRangePartialPatternMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/abc/[d-f]",
                                      address: "/abc/def"),
                       OSCPatternMatch(match: .partialPattern,
                                       patternCharactersMatched: "/abc/[d-f]".count,
                                       addressCharactersMatched: "/abc/d".count))
    }
    
    func testNotSquareBracketsRangePartialPatternMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/abc/[!d-f]",
                                      address: "/abc/abc"),
                       OSCPatternMatch(match: .partialPattern,
                                       patternCharactersMatched: "/abc/[!d-f]".count,
                                       addressCharactersMatched: "/abc/a".count))
    }
    
    func testSquareBracketsUnmatched() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/abc/[def]",
                                      address: "/abc/a"),
                       OSCPatternMatch(match: .unmatched,
                                       patternCharactersMatched: "/abc/[def]".count,
                                       addressCharactersMatched: "/abc/".count))
    }
    
    func testNotSquareBracketsUnmatched() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/abc/[!def]",
                                      address: "/abc/d"),
                       OSCPatternMatch(match: .unmatched,
                                       patternCharactersMatched: "/abc/[!def]".count,
                                       addressCharactersMatched: "/abc/".count))
    }
    
    func testSquareBracketsRangeUnmatched() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/abc/[d-f]",
                                      address: "/abc/a"),
                       OSCPatternMatch(match: .unmatched,
                                       patternCharactersMatched: "/abc/[d-f]".count,
                                       addressCharactersMatched: "/abc/".count))
    }
    
    func testNotSquareBracketsRangeUnmatched() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/abc/[!d-f]",
                                      address: "/abc/d"),
                       OSCPatternMatch(match: .unmatched,
                                       patternCharactersMatched: "/abc/[!d-f]".count,
                                       addressCharactersMatched: "/abc/".count))
    }
    
    // MARK: - Curly Braces Wildcard OSC Address Pattern Tests
    
    func testCurlyBracesFullMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/{abc,def}def/{ghi,jkl}ghi",
                                      address: "/abcdef/jklghi"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/{abc,def}def/{ghi,jkl}ghi".count,
                                       addressCharactersMatched: "/abcdef/jklghi".count))
    }
    
    func testCurlyBracesPartialAddressMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/{abc,def}/{ghi,jkl}",
                                      address: "/abc"),
                       OSCPatternMatch(match: .partialAddress,
                                       patternCharactersMatched: "/{abc,def}".count,
                                       addressCharactersMatched: "/abc".count))
    }
    
    func testCurlyBracesPartialPatternMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/{abc,def}",
                                      address: "/abc/def"),
                       OSCPatternMatch(match: .partialPattern,
                                       patternCharactersMatched: "/{abc,def}".count,
                                       addressCharactersMatched: "/abc".count))
    }
    
    func testCurlyBraceUnmatched() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/{abc,def}/{ghi,jkl}",
                                      address: "/abc/mno"),
                       OSCPatternMatch(match: .unmatched,
                                       patternCharactersMatched: "/{abc,def}/".count,
                                       addressCharactersMatched: "/abc/".count))
    }
    
    // MARK: - All Wildcards OSC Address Pattern Tests
    
    func testAllWildcardsFullMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/core/???/*/[a-z][a-z][a-z][a-z][a-z]/{abc,def}",
                                      address: "/core/osc/hello/world/abc"),
                       OSCPatternMatch(match: .fullMatch,
                                       patternCharactersMatched: "/core/???/*/[a-z][a-z][a-z][a-z][a-z]/{abc,def}".count,
                                       addressCharactersMatched: "/core/osc/hello/world/abc".count))
    }

}
