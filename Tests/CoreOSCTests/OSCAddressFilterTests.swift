//
//  OSCAddressFilterTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 13/08/2021.
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

class OSCAddressFilterTests: XCTestCase {

    static var allTests = [
        ("testInvokingOSCAddressFilter", testInvokingOSCAddressFilter),
        ("testInvokingOSCAddressFilterStringPriority", testInvokingOSCAddressFilterStringPriority),
        ("testInvokingOSCAddressFilterWildcardPriority", testInvokingOSCAddressFilterWildcardPriority)
    ]

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
