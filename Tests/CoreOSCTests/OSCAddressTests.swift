//
//  OSCAddressTests.swift
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

class OSCAddressTests: XCTestCase {

    func testInitializingOSCAddressPatternSucceeds() {
        XCTAssertNoThrow(try OSCAddress("/core/osc"))
    }

    func testInitializingOSCAddressPatternFails() {
        XCTAssertThrowsError(try OSCAddress(""))
        XCTAssertThrowsError(try OSCAddress("/"))
        XCTAssertThrowsError(try OSCAddress("core/osc"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/ "))
        XCTAssertThrowsError(try OSCAddress("/core/osc/#"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/*"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/,"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/?"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/["))
        XCTAssertThrowsError(try OSCAddress("/core/osc/]"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/{"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/}"))
    }

    func testParts() throws {
        let address = try OSCAddress("/core/osc/address/pattern")
        XCTAssertEqual(address.parts.count, 4)
        XCTAssertEqual(address.parts[0], "core")
        XCTAssertEqual(address.parts[1], "osc")
        XCTAssertEqual(address.parts[2], "address")
        XCTAssertEqual(address.parts[3], "pattern")
    }

    func testMethodName() throws {
        let address = try OSCAddress("/core/osc/methodName")
        XCTAssertEqual(address.methodName, "methodName")
    }
    
    func testEvaluate() {
        XCTAssertEqual(OSCAddress.evaluate(with: "core/osc"), .failure(.forwardSlash))
        XCTAssertEqual(OSCAddress.evaluate(with: "/🥺"), .failure(.ascii))
        XCTAssertEqual(OSCAddress.evaluate(with: "/ "), .failure(.space))
        XCTAssertEqual(OSCAddress.evaluate(with: "/#"), .failure(.hash))
        XCTAssertEqual(OSCAddress.evaluate(with: "/*"), .failure(.asterisk))
        XCTAssertEqual(OSCAddress.evaluate(with: "/,"), .failure(.comma))
        XCTAssertEqual(OSCAddress.evaluate(with: "/?"), .failure(.questionMark))
        XCTAssertEqual(OSCAddress.evaluate(with: "/["), .failure(.openBracket))
        XCTAssertEqual(OSCAddress.evaluate(with: "/]"), .failure(.closeBracket))
        XCTAssertEqual(OSCAddress.evaluate(with: "/{"), .failure(.openCurlyBrace))
        XCTAssertEqual(OSCAddress.evaluate(with: "/}"), .failure(.closeCurlyBrace))
        XCTAssertEqual(OSCAddress.evaluate(with: "/core/osc"), .success("/core/osc"))
    }

}
