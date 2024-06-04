//
//  OSCAddressPatternTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 26/07/2021.
//  Copyright © 2021 Sam Smallman. https://github.com/SammySmallman
//
// This file is part of CoreOSC
//
// CoreOSC is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// CoreOSC is distributed in the hope that it will be useful
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import CoreOSC

class OSCAddressPatternTests: XCTestCase {

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
