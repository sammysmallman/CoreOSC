//
//  OSCFilterAddressStoreTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 12/12/2024.
//  Copyright © 2023 Sam Smallman. https://github.com/SammySmallman
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

class OSCFilterAddressStoreTests: XCTestCase {

    func testOSCFilterAddressStoreOSCFilterAddressStore() {
        let address = try! OSCFilterAddress("/core/osc/#")

        let store = OSCFilterAddressStore(addresses: [address])

        var message = OSCMessage(raw: "/core/osc/1")
        XCTAssertEqual(store.filter(with: message), [address])
        XCTAssertEqual(store.count(with: message), 1)

        message = OSCMessage(raw: "/core/osc/2")
        XCTAssertEqual(store.filter(with: message), [address])
        XCTAssertEqual(store.count(with: message), 1)

        message = OSCMessage(raw: "/core/osc/3")
        XCTAssertEqual(store.filter(with: message), [address])
        XCTAssertEqual(store.count(with: message), 1)
    }

    func testOSCFilterAddressStoreStringPriority() {
        let address1 = try! OSCFilterAddress("/#/osc/#")
        let address2 = try! OSCFilterAddress("/core/osc/test")
        let address3 = try! OSCFilterAddress("/core/#/test")

        var store = OSCFilterAddressStore(addresses: [address1, address2, address3])
        store.priority = .string

        let message = OSCMessage(raw: "/core/osc/test")
        XCTAssertEqual(store.filter(with: message), [address2, address3, address1])
        XCTAssertEqual(store.count(with: message), 3)
    }

    func testOSCFilterAddressStoreWildcardPriority() {
        let address1 = try! OSCFilterAddress("/#/osc/#")
        let address2 = try! OSCFilterAddress("/#/#/#")
        let address3 = try! OSCFilterAddress("/core/#/test")

        var store = OSCFilterAddressStore(addresses: [address1, address2, address3])
        store.priority = .wildcard

        let message = OSCMessage(raw: "/core/osc/test")
        XCTAssertEqual(store.filter(with: message), [address2, address1, address3])
        XCTAssertEqual(store.count(with: message), 3)
    }

}
