//
//  OSCMessageTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 05/08/2021.
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

class OSCMessageTests: XCTestCase {

    static var allTests = [
        ("testInitializingRawOSCMessageSucceeds",
         testInitializingRawOSCMessageSucceeds),
        ("testInitializingOSCMessageWithStringSucceeds",
         testInitializingOSCMessageWithStringSucceeds),
        ("testInitializingOSCMessageWithStringFails",
         testInitializingOSCMessageWithStringFails),
        ("testInitializingOSCMessageWithOSCAddressPatternSucceeds",
         testInitializingOSCMessageWithOSCAddressPatternSucceeds),
        ("testReaddressWithStringSucceeds",
         testReaddressWithStringSucceeds),
        ("testReaddressWithStringFails",
         testReaddressWithStringFails),
        ("testReaddressWithOSCAddressPatternSucceeds",
         testReaddressWithOSCAddressPatternSucceeds),
        ("testMessageDataAndParsing",
         testMessageDataAndParsing),
        ("testPatternMatchingSucceeds",
         testPatternMatchingSucceeds),
        ("testPatternMatchingFails",
         testPatternMatchingFails)
    ]

    func testInitializingRawOSCMessageSucceeds() {
        let message = OSCMessage(raw: "/core/osc", arguments: [Int32(1),
                                                               Float32(3.142),
                                                               "Core OSC",
                                                               OSCTimeTag.immediate,
                                                               true,
                                                               false,
                                                               Data([0x01, 0x01]),
                                                               OSCArgument.nil,
                                                               OSCArgument.impulse])
        XCTAssertEqual(message.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message.typeTagString, "ifstTFbNI")
        XCTAssertEqual(message.arguments.count, 9)
        XCTAssertEqual(message.arguments[0] as! Int32, 1)
        XCTAssertEqual(message.arguments[1] as! Float32, 3.142)
        XCTAssertEqual(message.arguments[2] as! String, "Core OSC")
        XCTAssertEqual(message.arguments[3] as! OSCTimeTag, OSCTimeTag.immediate)
        XCTAssertEqual(message.arguments[4] as! Bool, true)
        XCTAssertEqual(message.arguments[5] as! Bool, false)
        XCTAssertEqual(message.arguments[6] as! Data, Data([0x01, 0x01]))
        XCTAssertEqual(message.arguments[7] as! OSCArgument, OSCArgument.nil)
        XCTAssertEqual(message.arguments[8] as! OSCArgument, OSCArgument.impulse)
    }
    
    func testInitializingOSCMessageWithStringSucceeds() throws {
        let message = try OSCMessage(with: "/core/osc", arguments: [Int32(1),
                                                              Float32(3.142),
                                                              "Core OSC",
                                                              OSCTimeTag.immediate,
                                                              true,
                                                              false,
                                                              Data([0x01, 0x01]),
                                                              OSCArgument.nil,
                                                              OSCArgument.impulse])
        XCTAssertEqual(message.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message.typeTagString, "ifstTFbNI")
        XCTAssertEqual(message.arguments.count, 9)
        XCTAssertEqual(message.arguments[0] as! Int32, 1)
        XCTAssertEqual(message.arguments[1] as! Float32, 3.142)
        XCTAssertEqual(message.arguments[2] as! String, "Core OSC")
        XCTAssertEqual(message.arguments[3] as! OSCTimeTag, OSCTimeTag.immediate)
        XCTAssertEqual(message.arguments[4] as! Bool, true)
        XCTAssertEqual(message.arguments[5] as! Bool, false)
        XCTAssertEqual(message.arguments[6] as! Data, Data([0x01, 0x01]))
        XCTAssertEqual(message.arguments[7] as! OSCArgument, OSCArgument.nil)
        XCTAssertEqual(message.arguments[8] as! OSCArgument, OSCArgument.impulse)
    }
    
    func testInitializingOSCMessageWithStringFails() throws {
        XCTAssertThrowsError(try OSCMessage(with: "/core/#"))
    }
    
    func testInitializingOSCMessageWithOSCAddressPatternSucceeds() throws {
        let addressPattern = try OSCAddressPattern("/core/osc")
        let message = OSCMessage(with: addressPattern, arguments: [Int32(1),
                                                             Float32(3.142),
                                                             "Core OSC",
                                                             OSCTimeTag.immediate,
                                                             true,
                                                             false,
                                                             Data([0x01, 0x01]),
                                                             OSCArgument.nil,
                                                             OSCArgument.impulse])
        XCTAssertEqual(message.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message.typeTagString, "ifstTFbNI")
        XCTAssertEqual(message.arguments.count, 9)
        XCTAssertEqual(message.arguments[0] as! Int32, 1)
        XCTAssertEqual(message.arguments[1] as! Float32, 3.142)
        XCTAssertEqual(message.arguments[2] as! String, "Core OSC")
        XCTAssertEqual(message.arguments[3] as! OSCTimeTag, OSCTimeTag.immediate)
        XCTAssertEqual(message.arguments[4] as! Bool, true)
        XCTAssertEqual(message.arguments[5] as! Bool, false)
        XCTAssertEqual(message.arguments[6] as! Data, Data([0x01, 0x01]))
        XCTAssertEqual(message.arguments[7] as! OSCArgument, OSCArgument.nil)
        XCTAssertEqual(message.arguments[8] as! OSCArgument, OSCArgument.impulse)
    }
    
    func testReaddressWithStringSucceeds() throws {
        var message = try OSCMessage(with: "/core/osc")
        try message.readdress(to: "/hello/world")
        XCTAssertEqual(message.addressPattern.fullPath, "/hello/world")
    }
    
    func testReaddressWithStringFails() throws {
        var message = try OSCMessage(with: "/core/osc")
        XCTAssertThrowsError(try message.readdress(to: "/hello/#"))
    }
    
    func testReaddressWithOSCAddressPatternSucceeds() throws {
        var message = try OSCMessage(with: "/core/osc")
        let addressPattern = try OSCAddressPattern("/hello/world")
        message.readdress(to: addressPattern)
        XCTAssertEqual(message.addressPattern.fullPath, addressPattern.fullPath)
    }
    
    func testMessageDataAndParsing() throws {
        let message = OSCMessage(raw: "/core/osc", arguments: [Int32(1),
                                                               Float32(3.142),
                                                               "Core OSC",
                                                               OSCTimeTag.immediate,
                                                               true,
                                                               false,
                                                               Data([0x01, 0x01, 0x01]),
                                                               OSCArgument.nil,
                                                               OSCArgument.impulse])
        let data = message.data()
        
        let packet = try OSCParser.packet(from: data) as? OSCMessage
        
        XCTAssertNotNil(packet)
        XCTAssertEqual(packet!.addressPattern.fullPath, message.addressPattern.fullPath)
        XCTAssertEqual(packet!.typeTagString, message.typeTagString)
        XCTAssertEqual(packet!.arguments.count, message.arguments.count)
        XCTAssertEqual(packet!.arguments[0] as! Int32, message.arguments[0] as! Int32)
        XCTAssertEqual(packet!.arguments[1] as! Float32, message.arguments[1] as! Float32)
        XCTAssertEqual(packet!.arguments[2] as! String, message.arguments[2] as! String)
        XCTAssertEqual(packet!.arguments[3] as! OSCTimeTag, message.arguments[3] as! OSCTimeTag)
        XCTAssertEqual(packet!.arguments[4] as! Bool, message.arguments[4] as! Bool)
        XCTAssertEqual(packet!.arguments[5] as! Bool, message.arguments[5] as! Bool)
        XCTAssertEqual(packet!.arguments[6] as! Data, message.arguments[6] as! Data)
        XCTAssertEqual(packet!.arguments[7] as! OSCArgument, message.arguments[7] as! OSCArgument)
        XCTAssertEqual(packet!.arguments[8] as! OSCArgument, message.arguments[8] as! OSCArgument)
    }
    
    func testPatternMatchingSucceeds() {
        let message = try! OSCMessage(with: "/core/osc")
        let address = try! OSCAddress("/core/osc")
        XCTAssertEqual(message.matches(address: address), .success(address))
    }
    
    func testPatternMatchingFails() {
        let message = try! OSCMessage(with: "/core")
        let address = try! OSCAddress("/core/osc")
        XCTAssertEqual(message.matches(address: address), .failure(.invalidPartCount))
    }

}
