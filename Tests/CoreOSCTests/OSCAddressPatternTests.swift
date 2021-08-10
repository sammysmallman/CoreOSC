//
//  OSCAddressPatternTests.swift
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

class OSCAddressPatternTests: XCTestCase {

    static var allTests = [
        ("testInitializingOSCAddressPatternSucceeds", testInitializingOSCAddressPatternSucceeds),
        ("testInitializingOSCAddressPatternFails", testInitializingOSCAddressPatternFails),
        ("testParts", testParts),
        ("testMethodName", testMethodName),
        ("testEvaluate", testEvaluate)
    ]

    func testInitializingOSCAddressPatternSucceeds() {
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc"))
        XCTAssertNoThrow(try OSCAddressPattern("//osc"))
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/*"))
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/,"))
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/?"))
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/["))
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/]"))
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/{"))
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/}"))
    }

    func testInitializingOSCAddressPatternFails() {
        XCTAssertThrowsError(try OSCAddressPattern(""))
        XCTAssertThrowsError(try OSCAddressPattern("/"))
        XCTAssertThrowsError(try OSCAddressPattern("core/osc"))
        XCTAssertThrowsError(try OSCAddressPattern("/core/osc/#"))
        XCTAssertThrowsError(try OSCAddressPattern("/core/osc/ "))
    }

    func testParts() throws {
        let address = try OSCAddressPattern("/core/osc/address")
        XCTAssertEqual(address.parts.count, 3)
        XCTAssertEqual(address.parts[0], "core")
        XCTAssertEqual(address.parts[1], "osc")
        XCTAssertEqual(address.parts[2], "address")
    }

    func testMethodName() throws {
        let address = try OSCAddressPattern("/core/osc/methodName")
        XCTAssertEqual(address.methodName, "methodName")
    }
    
    func testEvaluate() {
        XCTAssertEqual(OSCAddressPattern.evaluate(with: "core/osc"), .failure(.forwardSlash))
        XCTAssertEqual(OSCAddressPattern.evaluate(with: "/🥺"), .failure(.ascii))
        XCTAssertEqual(OSCAddressPattern.evaluate(with: "/ "), .failure(.space))
        XCTAssertEqual(OSCAddressPattern.evaluate(with: "/#"), .failure(.hash))
        XCTAssertEqual(OSCAddressPattern.evaluate(with: "/core/osc"), .success("/core/osc"))
    }

}
