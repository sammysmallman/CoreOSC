//
//  OSCFilterMethodTests.swift
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

class OSCFilterMethodTests: XCTestCase {

    static var allTests = [
        ("testInternalInvokingOSCFilterMethod", testInternalInvokingOSCFilterMethod),
        ("testInternalInvokingOSCFilterMethodSucceeds", testInternalInvokingOSCFilterMethodSucceeds),
        ("testInternalInvokingOSCMethodWithUserInfo", testInternalInvokingOSCMethodWithUserInfo)
    ]

    func testInternalInvokingOSCFilterMethod() {
        let addressString = "/core/osc"
        let address = try! OSCFilterAddress(addressString)
        var value: Bool = false
        let method = OSCFilterMethod(with: address, invokedAction: { message, _ in
            XCTAssertEqual(message.addressPattern.fullPath, addressString)
            XCTAssertEqual(message.arguments.count, 1)
            let boolValue = message.arguments.first as! Bool
            value = boolValue
        })
        let message = OSCMessage(raw: addressString, arguments: [true])
        method.invoke(message, nil)
        XCTAssertEqual(value, true)
    }
    
    func testInternalInvokingOSCFilterMethodSucceeds() {
        let addressString = "/core/osc"
        let address = try! OSCFilterAddress(addressString)
        var value: Bool = false
        let method = OSCFilterMethod(with: address, invokedAction: { message, _ in
            XCTAssertEqual(message.arguments.count, 1)
            let boolValue = message.arguments.first as! Bool
            value = boolValue
        })
        let message = OSCMessage(raw: addressString, arguments: [true])
        method.invoke(message, nil)
        XCTAssertEqual(value, true)
    }
    
    func testInternalInvokingOSCMethodWithUserInfo() {
        let addressString = "/core/osc"
        let address = try! OSCFilterAddress(addressString)
        let method = OSCFilterMethod(with: address, invokedAction: { _, userInfo in
            XCTAssertEqual(userInfo?["bool"] as! Bool, true)
            XCTAssertEqual(userInfo?["string"] as! String, "test")
        })
        let message = OSCMessage(raw: addressString, arguments: [true])
        method.invoke(message, ["bool":true, "string":"test"])
    }

}
