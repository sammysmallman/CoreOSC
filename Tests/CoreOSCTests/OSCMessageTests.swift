//
//  OSCMessageTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 05/08/2021.
//  Copyright © 2021 Sam Smallman. https://github.com/SammySmallman
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

    func testInitializingRawOSCMessageSucceeds() {
        let message = OSCMessage(
            raw: "/core/osc",
            arguments: [
                .int32(1),
                .float32(3.142),
                .string("Core OSC"),
                .timeTag(.immediate),
                .true,
                .false,
                .blob(Data([0x01, 0x01])),
                .nil,
                .impulse
            ]
        )
        XCTAssertEqual(message.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message.typeTagString, "ifstTFbNI")
        XCTAssertEqual(message.arguments.count, 9)
        XCTAssertEqual(message.arguments[0], .int32(1))
        XCTAssertEqual(message.arguments[1], .float32(3.142))
        XCTAssertEqual(message.arguments[2], .string("Core OSC"))
        XCTAssertEqual(message.arguments[3], .timeTag(OSCTimeTag.immediate))
        XCTAssertEqual(message.arguments[4], .true)
        XCTAssertEqual(message.arguments[5], .false)
        XCTAssertEqual(message.arguments[6], .blob(Data([0x01, 0x01])))
        XCTAssertEqual(message.arguments[7], .nil)
        XCTAssertEqual(message.arguments[8], .impulse)
    }
    
    func testInitializingOSCMessageWithStringSucceeds() throws {
        let message = try OSCMessage(
            with: "/core/osc",
            arguments: [
                .int32(1),
                .float32(3.142),
                .string("Core OSC"),
                .timeTag(.immediate),
                .true,
                .false,
                .blob(Data([0x01, 0x01])),
                .nil,
                .impulse
            ]
        )
        XCTAssertEqual(message.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message.typeTagString, "ifstTFbNI")
        XCTAssertEqual(message.arguments.count, 9)
        XCTAssertEqual(message.arguments[0], .int32(1))
        XCTAssertEqual(message.arguments[1], .float32(3.142))
        XCTAssertEqual(message.arguments[2], .string("Core OSC"))
        XCTAssertEqual(message.arguments[3], .timeTag(OSCTimeTag.immediate))
        XCTAssertEqual(message.arguments[4], .true)
        XCTAssertEqual(message.arguments[5], .false)
        XCTAssertEqual(message.arguments[6], .blob(Data([0x01, 0x01])))
        XCTAssertEqual(message.arguments[7], .nil)
        XCTAssertEqual(message.arguments[8], .impulse)
    }
    
    func testInitializingOSCMessageWithStringFails() throws {
        XCTAssertThrowsError(try OSCMessage(with: "/core/#"))
    }
    
    func testInitializingOSCMessageWithOSCAddressPatternSucceeds() throws {
        let addressPattern = try OSCAddressPattern("/core/osc")
        let message = OSCMessage(
            with: addressPattern,
            arguments: [
                .int32(1),
                .float32(3.142),
                .string("Core OSC"),
                .timeTag(.immediate),
                .true,
                .false,
                .blob(Data([0x01, 0x01])),
                .nil,
                .impulse
            ]
        )
        XCTAssertEqual(message.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message.typeTagString, "ifstTFbNI")
        XCTAssertEqual(message.arguments.count, 9)
        XCTAssertEqual(message.arguments[0], .int32(1))
        XCTAssertEqual(message.arguments[1], .float32(3.142))
        XCTAssertEqual(message.arguments[2], .string("Core OSC"))
        XCTAssertEqual(message.arguments[3], .timeTag(OSCTimeTag.immediate))
        XCTAssertEqual(message.arguments[4], .true)
        XCTAssertEqual(message.arguments[5], .false)
        XCTAssertEqual(message.arguments[6], .blob(Data([0x01, 0x01])))
        XCTAssertEqual(message.arguments[7], .nil)
        XCTAssertEqual(message.arguments[8], .impulse)
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
        let message = OSCMessage(
            raw: "/core/osc",
            arguments: [
                .int32(1),
                .float32(3.142),
                .string("Core OSC"),
                .timeTag(.immediate),
                .true,
                .false,
                .blob(Data([0x01, 0x01, 0x01])),
                .nil,
                .impulse
            ]
        )
        let data = message.data()
        
        guard case let .message(packet) = try OSCParser.packet(from: data) else {
            XCTFail()
            return
        }

        XCTAssertEqual(packet.addressPattern.fullPath, message.addressPattern.fullPath)
        XCTAssertEqual(packet.typeTagString, message.typeTagString)
        XCTAssertEqual(packet.arguments.count, message.arguments.count)
        XCTAssertEqual(packet.arguments[0], message.arguments[0])
        XCTAssertEqual(packet.arguments[1], message.arguments[1])
        XCTAssertEqual(packet.arguments[2], message.arguments[2])
        XCTAssertEqual(packet.arguments[3], message.arguments[3])
        XCTAssertEqual(packet.arguments[4], message.arguments[4])
        XCTAssertEqual(packet.arguments[5], message.arguments[5])
        XCTAssertEqual(packet.arguments[6], message.arguments[6])
        XCTAssertEqual(packet.arguments[7], message.arguments[7])
        XCTAssertEqual(packet.arguments[8], message.arguments[8])
    }

    func testInvalidMessageDataParsing() throws {
        // Invalid space character
        let message1 = OSCMessage(raw: "/core/osc/[0- 1]")
        let data1 = message1.data()

        XCTAssertThrowsError(try OSCParser.packet(from: data1)) { error in
            XCTAssertEqual(error as! OSCParserError, OSCParserError.cantParseAddressPattern)
        }

        // Invalid hash character
        let message2 = OSCMessage(raw: "/core/osc/#")
        let data2 = message2.data()

        XCTAssertThrowsError(try OSCParser.packet(from: data2)) { error in
            XCTAssertEqual(error as! OSCParserError, OSCParserError.cantParseAddressPattern)
        }
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
        guard case let .string(license1) = message.arguments[0] else {
            fatalError("Missing LIcense")
        }
        XCTAssertTrue(license1.hasPrefix("Copyright © 2021 Sam Smallman. https://github.com/SammySmallman"))
        XCTAssertTrue(license1.hasSuffix("<https://www.gnu.org/licenses/why-not-lgpl.html>.\n"))
        
        let parsedPacket = try OSCParser.packet(from: message.data())

        guard case let .message(parsedMessage) = parsedPacket else {
            XCTFail()
            return
        }

        XCTAssertEqual(parsedMessage.arguments.count, 1)
        guard case let .string(license2) = parsedMessage.arguments[0] else {
            fatalError("Missing LIcense")
        }
        XCTAssertTrue(license2.hasPrefix("Copyright © 2021 Sam Smallman. https://github.com/SammySmallman"))
        XCTAssertTrue(license2.hasSuffix("<https://www.gnu.org/licenses/why-not-lgpl.html>.\n"))
    }

}
