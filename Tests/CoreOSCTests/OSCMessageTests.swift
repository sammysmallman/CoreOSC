//
//  OSCMessageTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 05/08/2021.
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
    
    func testLargeStrings() throws {
        let message = try! OSCMessage(with: "/core", arguments: [CoreOSC.license])
        
        XCTAssertEqual(message.arguments.count, 1)
        let license1 = message.arguments[0] as! String
        XCTAssertTrue(license1.hasPrefix("Copyright © 2022 Sam Smallman. https://github.com/SammySmallman"))
        XCTAssertTrue(license1.hasSuffix("<https://www.gnu.org/licenses/why-not-lgpl.html>.\n"))
        
        let parsedPacket = try OSCParser.packet(from: message.data())
        let parsedMessage = parsedPacket as! OSCMessage
        
        XCTAssertEqual(parsedMessage.arguments.count, 1)
        let license2 = parsedMessage.arguments[0] as! String
        XCTAssertTrue(license2.hasPrefix("Copyright © 2022 Sam Smallman. https://github.com/SammySmallman"))
        XCTAssertTrue(license2.hasSuffix("<https://www.gnu.org/licenses/why-not-lgpl.html>.\n"))
    }

}
