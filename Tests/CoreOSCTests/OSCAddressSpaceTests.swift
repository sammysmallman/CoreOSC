//
//  OSCAddressSpaceTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 11/08/2021.
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

class OSCAddressSpaceTests: XCTestCase {

    static var allTests = [
        ("testInvokingOSCAddressSpace", testInvokingOSCAddressSpace)
    ]

    func testInvokingOSCAddressSpace() {
        let address1 = try! OSCAddress("/core/osc/1")
        var value1: Bool = false
        let method1 = OSCMethod(with: address1, invokedAction: { message, _ in
            let boolValue = message.arguments.first as! Bool
            value1 = boolValue
        })
        let address2 = try! OSCAddress("/core/osc/2")
        var value2: Bool = false
        let method2 = OSCMethod(with: address2, invokedAction: { message, _ in
            let boolValue = message.arguments.first as! Bool
            value2 = boolValue
        })
        let address3 = try! OSCAddress("/core/osc/3")
        var value3: Bool = false
        let method3 = OSCMethod(with: address3, invokedAction: { message, _ in
            let boolValue = message.arguments.first as! Bool
            value3 = boolValue
        })
        
        let addressSpace = OSCAddressSpace(methods: [method1, method2, method3])
        
        addressSpace.invoke(with: OSCMessage(raw: "/core/osc/1", arguments: [true]))
        XCTAssertEqual(value1, true)
        
        addressSpace.invoke(with: OSCMessage(raw: "/core/osc/2", arguments: [true]))
        XCTAssertEqual(value2, true)
        
        addressSpace.invoke(with: OSCMessage(raw: "/core/osc/3", arguments: [true]))
        XCTAssertEqual(value3, true)
    }

}
