//
//  OSCAddressFilterTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 13/08/2021.
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

class OSCAddressFilterTests: XCTestCase {

    func testInvokingOSCAddressFilter() {
        let address1 = try! OSCFilterAddress("/core/osc/#")
        var value: Int = 0
        let method = OSCFilterMethod(with: address1, invokedAction: { _, _ in
            value += 1
        })
        
        let addressFilter = OSCAddressFilter(methods: [method])
        
        _ = addressFilter.invoke(with: OSCMessage(raw: "/core/osc/1"))
        XCTAssertEqual(value, 1)
        
        _ = addressFilter.invoke(with: OSCMessage(raw: "/core/osc/2"))
        XCTAssertEqual(value, 2)
        
        _ = addressFilter.invoke(with: OSCMessage(raw: "/core/osc/3"))
        XCTAssertEqual(value, 3)
    }
    
    func testInvokingOSCAddressFilterStringPriority() {
        var messages: [String] = []
        let address1 = try! OSCFilterAddress("/#/osc/#")
        var value1: Bool = false
        let method1 = OSCFilterMethod(with: address1, invokedAction: { _, _ in
            value1 = true
            messages.append("3")
        })
        let address2 = try! OSCFilterAddress("/core/osc/test")
        var value2: Bool = false
        let method2 = OSCFilterMethod(with: address2, invokedAction: { _, _ in
            value2 = true
            messages.append("1")
        })
        let address3 = try! OSCFilterAddress("/core/#/test")
        var value3: Bool = false
        let method3 = OSCFilterMethod(with: address3, invokedAction: { _, _ in
            value3 = true
            messages.append("2")
        })
        
        var addressFilter = OSCAddressFilter(methods: [method1, method2, method3])
        addressFilter.priority = .string
        
        _ = addressFilter.invoke(with: OSCMessage(raw: "/core/osc/test"))
        XCTAssertEqual(value1, true)
        XCTAssertEqual(value2, true)
        XCTAssertEqual(value3, true)
        XCTAssertEqual(messages, ["1", "2", "3"])
    }
    
    func testInvokingOSCAddressFilterWildcardPriority() {
        var messages: [String] = []
        let address1 = try! OSCFilterAddress("/#/osc/#")
        var value1: Bool = false
        let method1 = OSCFilterMethod(with: address1, invokedAction: { _, _ in
            value1 = true
            messages.append("2")
        })
        let address2 = try! OSCFilterAddress("/#/#/#")
        var value2: Bool = false
        let method2 = OSCFilterMethod(with: address2, invokedAction: { _, _ in
            value2 = true
            messages.append("1")
        })
        let address3 = try! OSCFilterAddress("/core/#/test")
        var value3: Bool = false
        let method3 = OSCFilterMethod(with: address3, invokedAction: { _, _ in
            value3 = true
            messages.append("3")
        })
        
        var addressFilter = OSCAddressFilter(methods: [method1, method2, method3])
        addressFilter.priority = .wildcard
        
        _ = addressFilter.invoke(with: OSCMessage(raw: "/core/osc/test"))
        XCTAssertEqual(value1, true)
        XCTAssertEqual(value2, true)
        XCTAssertEqual(value3, true)
        XCTAssertEqual(messages, ["1", "2", "3"])
    }

}
