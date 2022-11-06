//
//  OSCFilterAddressTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 26/07/2021.
//  Copyright © 2022 Sam Smallman. https://github.com/SammySmallman
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

class OSCFilterAddressTests: XCTestCase {

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
