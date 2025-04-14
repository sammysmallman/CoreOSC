//
//  OSCAddressStoreTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 23/12/2024.
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

class OSCAddressStoreTests: XCTestCase {

    func testOSCAddressStoreOSCFilterAddressStore() {
        let address1 = try! OSCAddress("/core/osc/1")
        let address2 = try! OSCAddress("/core/osc/2")
        let address3 = try! OSCAddress("/core/osc/3")

        let store = OSCAddressStore(addresses: [address1, address2, address3])

        var message = OSCMessage(raw: "/core/osc/1")
        XCTAssertEqual(store.filter(with: message), [address1])
        XCTAssertEqual(store.count(with: message), 1)

        message = OSCMessage(raw: "/core/osc/2")
        XCTAssertEqual(store.filter(with: message), [address2])
        XCTAssertEqual(store.count(with: message), 1)

        message = OSCMessage(raw: "/core/osc/*")
        let addresses = store.filter(with: message)
        XCTAssertTrue(addresses.contains(address1))
        XCTAssertTrue(addresses.contains(address2))
        XCTAssertTrue(addresses.contains(address3))
        XCTAssertEqual(store.count(with: message), 3)
    }

}
