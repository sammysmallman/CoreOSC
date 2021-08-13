//
//  OSCFilterAddressTests.swift
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

class OSCFilterAddressTests: XCTestCase {

    static var allTests = [
        ("testInitializingOSCFilterAddressSucceeds", testInitializingOSCFilterAddressSucceeds),
        ("testInitializingOSCFilterAddressFails", testInitializingOSCFilterAddressFails),
        ("testParts", testParts),
        ("testMethodName", testMethodName),
        ("testEvaluate", testEvaluate)
    ]

    func testInitializingOSCFilterAddressSucceeds() {
        XCTAssertNoThrow(try OSCFilterAddress("/core/#/osc"))
        XCTAssertNoThrow(try OSCFilterAddress("/#"))
        XCTAssertNoThrow(try OSCFilterAddress("//#"))
        XCTAssertNoThrow(try OSCFilterAddress("//#/"))
        XCTAssertNoThrow(try OSCFilterAddress("/core/osc/"))
        XCTAssertNoThrow(try OSCFilterAddress("/core/osc/*"))
        XCTAssertNoThrow(try OSCFilterAddress("/core/osc/,"))
        XCTAssertNoThrow(try OSCFilterAddress("/core/osc/?"))
        XCTAssertNoThrow(try OSCFilterAddress("/core/osc/["))
        XCTAssertNoThrow(try OSCFilterAddress("/core/osc/]"))
        XCTAssertNoThrow(try OSCFilterAddress("/core/osc/{"))
        XCTAssertNoThrow(try OSCFilterAddress("/core/osc/}"))
    }

    func testInitializingOSCFilterAddressFails() {
        XCTAssertThrowsError(try OSCFilterAddress(""))
        XCTAssertThrowsError(try OSCFilterAddress("/"))
        XCTAssertThrowsError(try OSCFilterAddress("/ "))
        XCTAssertThrowsError(try OSCFilterAddress("/#0"))
        XCTAssertThrowsError(try OSCFilterAddress("core/osc"))
        XCTAssertThrowsError(try OSCFilterAddress("/core/osc/#100"))
        XCTAssertThrowsError(try OSCFilterAddress("/core/osc/#1abc"))
    }

    func testParts() throws {
        let address = try OSCFilterAddress("/core/osc/address")
        XCTAssertEqual(address.parts.count, 3)
        XCTAssertEqual(address.parts[0], "core")
        XCTAssertEqual(address.parts[1], "osc")
        XCTAssertEqual(address.parts[2], "address")
    }

    func testMethodName() throws {
        let address = try OSCFilterAddress("/core/osc/#")
        XCTAssertEqual(address.methodName, "#")
    }
    
    func testEvaluate() {
        XCTAssertEqual(OSCFilterAddress.evaluate(with: "core/osc"), .failure(.forwardSlash))
        XCTAssertEqual(OSCFilterAddress.evaluate(with: "/🥺"), .failure(.ascii))
        XCTAssertEqual(OSCFilterAddress.evaluate(with: "/ "), .failure(.space))
        XCTAssertEqual(OSCFilterAddress.evaluate(with: "/core/osc"), .success("/core/osc"))
    }

}
