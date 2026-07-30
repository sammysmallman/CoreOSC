//
//  OSCMatchRobustnessTests.swift
//  CoreOSCTests
//
//  Copyright © 2026 Sam Smallman. https://github.com/SammySmallman
//
//  This file is part of CoreOSC
//
//  CoreOSC is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Affero General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  CoreOSC is distributed in the hope that it will be useful
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Affero General Public License for more details.
//
//  You should have received a copy of the GNU Affero General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import CoreOSC

/// Address patterns arrive raw off the wire, so the matcher must never trap,
/// however malformed the pattern or address. Every case here previously
/// crashed, or exercises a neighbouring malformed input that could.
final class OSCMatchRobustnessTests: XCTestCase {

    func testUnterminatedSquareBracketDoesNotMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/test/[a",
                                      address: "/test/a").match, .unmatched)
    }

    func testUnterminatedSquareBracketWithRangeDoesNotMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/test/[a-",
                                      address: "/test/a").match, .unmatched)
    }

    func testBareOpenBracketAtEndDoesNotMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/test/[",
                                      address: "/test/a").match, .unmatched)
    }

    func testBareNegatedBracketAtEndDoesNotMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/test/[!",
                                      address: "/test/a").match, .unmatched)
    }

    func testNonASCIIAddressAgainstRangePatternDoesNotMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/[a-z]",
                                      address: "/é").match, .unmatched)
    }

    func testNonASCIIPatternAgainstASCIIAddressDoesNotMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/[é-ü]",
                                      address: "/a").match, .unmatched)
    }

    func testNonASCIILiteralsStillMatchThemselves() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/tëst",
                                      address: "/tëst").match, .fullMatch)
    }

    func testCurlyBraceOptionLongerThanAddressDoesNotTrap() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/{foobar}",
                                      address: "/f").match, .unmatched)
    }

    func testCurlyBraceLaterShortOptionStillMatchesShortAddress() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/{foobar,f}",
                                      address: "/f").match, .fullMatch)
    }

    func testUnterminatedCurlyBraceDoesNotMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/{foo",
                                      address: "/foo").match, .unmatched)
    }

    func testBareOpenBraceAtEndDoesNotMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/test/{",
                                      address: "/test/a").match, .unmatched)
    }

    func testEmptyPatternDoesNotTrap() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "",
                                      address: "/test").match, .partialPattern)
    }

    func testEmptyAddressDoesNotTrap() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/test",
                                      address: "").match, .partialAddress)
    }

    func testEmptyPatternAndAddressMatch() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "",
                                      address: "").match, .fullMatch)
    }

    func testAddressShorterThanPatternAtEveryWildcard() {
        XCTAssertEqual(OSCMatch.match(addressPattern: "/test/[abc]x",
                                      address: "/test/a").match, .partialAddress)
        XCTAssertEqual(OSCMatch.match(addressPattern: "/test/?x",
                                      address: "/test/a").match, .partialAddress)
        XCTAssertEqual(OSCMatch.match(addressPattern: "/test/{a}x",
                                      address: "/test/a").match, .partialAddress)
    }

}
