//
//  OSCMethodTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 10/08/2021.
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

class OSCMethodTests: XCTestCase {

    static var allTests = [
        ("testInternalInvokingOSCMethod", testInternalInvokingOSCMethod),
        ("testInvokingOSCMethodSucceeds", testInvokingOSCMethodSucceeds),
        ("testInvokingOSCMethodFails", testInvokingOSCMethodFails)
    ]

    func testInternalInvokingOSCMethod() {
        let addressString = "/core/osc"
        let address = try! OSCAddress(addressString)
        var value: Bool = false
        let method = OSCMethod(with: address, invokedAction: { message, _ in
            XCTAssertEqual(message.addressPattern.fullPath, addressString)
            XCTAssertEqual(message.arguments.count, 1)
            let boolValue = message.arguments.first as! Bool
            value = boolValue
        })
        let message = OSCMessage(raw: addressString, arguments: [true])
        method.invoke(message, nil)
        XCTAssertEqual(value, true)
    }
    
    func testInvokingOSCMethodSucceeds() {
        let addressString = "/core/osc"
        let address = try! OSCAddress(addressString)
        var value: Bool = false
        let method = OSCMethod(with: address, invokedAction: { message, _ in
            XCTAssertEqual(message.arguments.count, 1)
            let boolValue = message.arguments.first as! Bool
            value = boolValue
        })
        let message = OSCMessage(raw: addressString, arguments: [true])
        XCTAssertEqual(method.invoke(with: message), true)
        XCTAssertEqual(value, true)
    }
    
    func testInvokingOSCMethodFails() {
        let address = try! OSCAddress("/core/osc")
        var value: Bool = false
        let method = OSCMethod(with: address, invokedAction: { message, _ in
            XCTAssertEqual(message.arguments.count, 1)
            let boolValue = message.arguments.first as! Bool
            value = boolValue
        })
        let message = OSCMessage(raw: "/core/test", arguments: [true])
        XCTAssertEqual(method.invoke(with: message), false)
        XCTAssertEqual(value, false)
    }
    
    func testInvokingOSCMethodWithUserInfo() {
        let addressString = "/core/osc"
        let address = try! OSCAddress(addressString)
        let method = OSCMethod(with: address, invokedAction: { _, userInfo in
            XCTAssertEqual(userInfo?["bool"] as! Bool, true)
            XCTAssertEqual(userInfo?["string"] as! String, "test")
        })
        let message = OSCMessage(raw: addressString, arguments: [true])
        XCTAssertEqual(method.invoke(with: message, userInfo: ["bool":true, "string":"test"]), true)
    }

}

