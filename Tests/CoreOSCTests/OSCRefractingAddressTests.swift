//
//  OSCRefractingAddressTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 26/07/2021.
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

class OSCRefractingAddressTests: XCTestCase {

    static var allTests = [
        ("testInitializingOSCRefractingAddressSucceeds", testInitializingOSCRefractingAddressSucceeds),
        ("testInitializingOSCRefractingAddressFails", testInitializingOSCRefractingAddressFails),
        ("testParts", testParts),
        ("testMethodName", testMethodName),
        ("testRefracting", testRefracting),
        ("testEvaluate", testEvaluate)
    ]

    func testInitializingOSCRefractingAddressSucceeds() {
        XCTAssertNoThrow(try OSCRefractingAddress("/core/#1/osc"))
        XCTAssertNoThrow(try OSCRefractingAddress("/#1"))
        XCTAssertNoThrow(try OSCRefractingAddress("//#1"))
        XCTAssertNoThrow(try OSCRefractingAddress("//#1/"))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/"))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/*"))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/,"))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/?"))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/["))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/]"))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/{"))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/}"))
    }

    func testInitializingOSCRefractingAddressFails() {
        XCTAssertThrowsError(try OSCRefractingAddress(""))
        XCTAssertThrowsError(try OSCRefractingAddress("/"))
        XCTAssertThrowsError(try OSCRefractingAddress("/#0"))
        XCTAssertThrowsError(try OSCRefractingAddress("core/osc"))
        XCTAssertThrowsError(try OSCRefractingAddress("/core/osc/#"))
        XCTAssertThrowsError(try OSCRefractingAddress("/core/osc/#100"))
        XCTAssertThrowsError(try OSCRefractingAddress("/core/osc/#1abc"))
    }

    func testParts() throws {
        let address = try OSCRefractingAddress("/core/#1/#2")
        XCTAssertEqual(address.parts.count, 3)
        XCTAssertEqual(address.parts[0], "core")
        XCTAssertEqual(address.parts[1], "#1")
        XCTAssertEqual(address.parts[2], "#2")
    }

    func testMethodName() throws {
        let address = try OSCRefractingAddress("/core/osc/#3")
        XCTAssertEqual(address.methodName, "#3")
    }
    
    func testRefracting() throws {
        let address = try OSCAddress("/core/osc/refracting/test")
        let refractingAddress1 = try OSCRefractingAddress("/core/#2/#4")
        var refractedAddress = try refractingAddress1.refract(address: address)
        XCTAssertEqual(refractedAddress.fullPath, "/core/osc/test")
        
        let refractingAddress2 = try OSCRefractingAddress("/#4/#3/#2/#1")
        refractedAddress = try refractingAddress2.refract(address: address)
        XCTAssertEqual(refractedAddress.fullPath, "/test/refracting/osc/core")
        
        let refractingAddress3 = try OSCRefractingAddress("/#3/#1/#4/#2")
        refractedAddress = try refractingAddress3.refract(address: address)
        XCTAssertEqual(refractedAddress.fullPath, "/refracting/core/test/osc")
        
        let refractingAddress4 = try OSCRefractingAddress("/core/osc/test")
        refractedAddress = try refractingAddress4.refract(address: address)
        XCTAssertEqual(refractedAddress.fullPath, "/core/osc/test")
        
        let refractingAddress5 = try OSCRefractingAddress("/core/osc/#5")
        XCTAssertThrowsError(try refractingAddress5.refract(address: address))
    }
    
    func testEvaluate() {
        XCTAssertEqual(OSCRefractingAddress.evaluate(with: "core/osc"), .failure(.forwardSlash))
        XCTAssertEqual(OSCRefractingAddress.evaluate(with: "/🥺"), .failure(.ascii))
        XCTAssertEqual(OSCRefractingAddress.evaluate(with: "/ "), .failure(.space))
        XCTAssertEqual(OSCRefractingAddress.evaluate(with: "/core/#1/osc"), .success("/core/#1/osc"))
    }

}
