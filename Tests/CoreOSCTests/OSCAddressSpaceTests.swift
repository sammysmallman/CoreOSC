//
//  OSCAddressSpaceTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 11/08/2021.
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
