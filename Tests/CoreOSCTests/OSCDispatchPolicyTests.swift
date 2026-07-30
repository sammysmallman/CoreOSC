//
//  OSCDispatchPolicyTests.swift
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

final class OSCDispatchPolicyTests: XCTestCase {

    // MARK: - OSCMethod

    func testExactMethodInvokedByLiteralAddress() throws {
        var invoked = false
        let method = OSCMethod(with: try OSCAddress("/record/start"), dispatch: .exact) { _, _ in
            invoked = true
        }
        XCTAssertTrue(method.invoke(with: OSCMessage(raw: "/record/start")))
        XCTAssertTrue(invoked)
    }

    func testExactMethodRefusesMatchingWildcardPattern() throws {
        var invoked = false
        let method = OSCMethod(with: try OSCAddress("/record/start"), dispatch: .exact) { _, _ in
            invoked = true
        }
        XCTAssertFalse(method.invoke(with: OSCMessage(raw: "/record/*")))
        XCTAssertFalse(method.invoke(with: OSCMessage(raw: "/record/{start,stop}")))
        XCTAssertFalse(invoked)
    }

    func testExactMethodRefusesUniquelyResolvingWildcard() throws {
        // "/record/st*rt" matches only this method, but exact means literal equality.
        var invoked = false
        let method = OSCMethod(with: try OSCAddress("/record/start"), dispatch: .exact) { _, _ in
            invoked = true
        }
        XCTAssertFalse(method.invoke(with: OSCMessage(raw: "/record/st*rt")))
        XCTAssertFalse(invoked)
    }

    func testPatternMethodRemainsTheDefault() throws {
        var invoked = false
        let method = OSCMethod(with: try OSCAddress("/record/start")) { _, _ in
            invoked = true
        }
        XCTAssertEqual(method.dispatch, .pattern)
        XCTAssertTrue(method.invoke(with: OSCMessage(raw: "/record/*")))
        XCTAssertTrue(invoked)
    }

    // MARK: - OSCAddressSpace

    func testWildcardInvokesOnlyPatternMethodsInMixedAddressSpace() throws {
        var invocations: [String] = []
        let addressSpace = OSCAddressSpace(methods: [
            OSCMethod(with: try OSCAddress("/record/start"), dispatch: .exact) { _, _ in
                invocations.append("/record/start")
            },
            OSCMethod(with: try OSCAddress("/record/stop"), dispatch: .exact) { _, _ in
                invocations.append("/record/stop")
            },
            OSCMethod(with: try OSCAddress("/record/state")) { _, _ in
                invocations.append("/record/state")
            }
        ])
        addressSpace.invoke(with: OSCMessage(raw: "/record/*"))
        XCTAssertEqual(invocations, ["/record/state"])
        addressSpace.invoke(with: OSCMessage(raw: "/record/start"))
        XCTAssertEqual(invocations, ["/record/state", "/record/start"])
    }

    func testFanOutInvokesInAscendingFullPathOrder() throws {
        var invocations: [String] = []
        let addressSpace = OSCAddressSpace(methods: [
            OSCMethod(with: try OSCAddress("/settings/3")) { _, _ in invocations.append("3") },
            OSCMethod(with: try OSCAddress("/settings/1")) { _, _ in invocations.append("1") },
            OSCMethod(with: try OSCAddress("/settings/2")) { _, _ in invocations.append("2") }
        ])
        addressSpace.invoke(with: OSCMessage(raw: "/settings/*"))
        XCTAssertEqual(invocations, ["1", "2", "3"])
    }

}
