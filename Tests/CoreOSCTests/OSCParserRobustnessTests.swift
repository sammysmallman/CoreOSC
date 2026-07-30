//
//  OSCParserRobustnessTests.swift
//  CoreOSCTests
//
//  Copyright © 2026 Sam Smallman. https://github.com/SammySmallman
//
//  This file is part of CoreOSC
//
//  CoreOSC is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Affero General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  CoreOSC is distributed in the hope that it will be useful
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Affero General Public License for more details.
//
//  You should have received a copy of the GNU Affero General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import CoreOSC

/// The parser consumes wire data, so it must throw on malformed or truncated
/// input, never trap. Several of these inputs previously crashed the process.
final class OSCParserRobustnessTests: XCTestCase {

    // MARK: - Truncated data

    func testEmptyDataThrows() {
        XCTAssertThrowsError(try OSCParser.packet(from: Data()))
    }

    func testTruncatedBundlePrefixThrows() {
        // "#b" — shorter than the 8-byte "#bundle\0" prefix. Previously trapped.
        XCTAssertThrowsError(try OSCParser.packet(from: Data([0x23, 0x62])))
    }

    func testBundleWithoutTimeTagThrows() {
        XCTAssertThrowsError(try OSCParser.packet(from: "#bundle".oscData))
    }

    func testAddressPatternWithoutTerminatorThrows() {
        XCTAssertThrowsError(try OSCParser.packet(from: Data([0x2F, 0x61])))
    }

    func testMessageMissingInt32PayloadThrows() {
        // "/a" + ",i" with no argument bytes. Previously trapped.
        let data = Data([0x2F, 0x61, 0x00, 0x00, 0x2C, 0x69, 0x00, 0x00])
        XCTAssertThrowsError(try OSCParser.packet(from: data))
    }

    func testMessageMissingFloat32PayloadThrows() {
        let data = Data([0x2F, 0x61, 0x00, 0x00, 0x2C, 0x66, 0x00, 0x00])
        XCTAssertThrowsError(try OSCParser.packet(from: data))
    }

    func testMessageMissingTimeTagPayloadThrows() {
        let data = Data([0x2F, 0x61, 0x00, 0x00, 0x2C, 0x74, 0x00, 0x00])
        XCTAssertThrowsError(try OSCParser.packet(from: data))
    }

    func testMessageWithTruncatedInt32PayloadThrows() {
        let data = Data([0x2F, 0x61, 0x00, 0x00, 0x2C, 0x69, 0x00, 0x00, 0x01, 0x02])
        XCTAssertThrowsError(try OSCParser.packet(from: data))
    }

    // MARK: - Hostile sizes

    func testNegativeBlobSizeThrows() {
        var data = Data([0x2F, 0x61, 0x00, 0x00, 0x2C, 0x62, 0x00, 0x00])
        data.append(Data([0xFF, 0xFF, 0xFF, 0xFF])) // blob size -1
        XCTAssertThrowsError(try OSCParser.packet(from: data))
    }

    func testOversizedBlobSizeThrows() {
        var data = Data([0x2F, 0x61, 0x00, 0x00, 0x2C, 0x62, 0x00, 0x00])
        data.append(Data([0x7F, 0xFF, 0xFF, 0xFF])) // blob size Int32.max
        XCTAssertThrowsError(try OSCParser.packet(from: data))
    }

    func testNegativeBundleElementSizeThrows() {
        var data = "#bundle".oscData
        data.append(OSCTimeTag.immediate.oscData)
        data.append(Data([0xFF, 0xFF, 0xFF, 0xFC])) // element size -4
        data.append(Data([0x2F, 0x61, 0x00, 0x00, 0x2C, 0x00, 0x00, 0x00]))
        XCTAssertThrowsError(try OSCParser.packet(from: data))
    }

    func testOversizedNestedBundleElementSizeThrows() {
        var data = "#bundle".oscData
        data.append(OSCTimeTag.immediate.oscData)
        data.append(Data([0x7F, 0xFF, 0xFF, 0xFF])) // element size Int32.max
        data.append("#bundle".oscData)
        data.append(OSCTimeTag.immediate.oscData)
        data.append(Data([0x00, 0x00, 0x00, 0x08])) // trailing content so the nested branch recurses
        data.append(Data([0x2F, 0x61, 0x00, 0x00]))
        XCTAssertThrowsError(try OSCParser.packet(from: data))
    }

    // MARK: - Recursion depth

    func testDeeplyNestedBundleThrows() {
        var bundle = OSCBundle([.message(OSCMessage(raw: "/deep"))])
        for _ in 0..<(OSCParser.maximumBundleDepth + 8) {
            bundle = OSCBundle([.bundle(bundle)])
        }
        XCTAssertThrowsError(try OSCParser.packet(from: bundle.data())) { error in
            XCTAssertEqual(error as? OSCParserError, .bundleTooDeep)
        }
    }

    func testNestedBundleWithinDepthLimitParses() {
        var bundle = OSCBundle([.message(OSCMessage(raw: "/deep"))])
        for _ in 0..<16 {
            bundle = OSCBundle([.bundle(bundle)])
        }
        XCTAssertNoThrow(try OSCParser.packet(from: bundle.data()))
    }

    // MARK: - Valid packets still round-trip

    func testMessageWithEveryArgumentTypeRoundTrips() throws {
        let message = OSCMessage(raw: "/round/trip", arguments: [
            .int32(42),
            .float32(3.25),
            .string("hello"),
            .blob(Data([0x01, 0x02, 0x03])),
            .true,
            .false,
            .nil,
            .impulse,
            .timeTag(OSCTimeTag(date: Date(timeIntervalSince1970: 1_000_000)))
        ])
        let parsed = try OSCParser.packet(from: message.data())
        guard case let .message(roundTripped) = parsed else {
            return XCTFail("Expected .message")
        }
        XCTAssertEqual(roundTripped, message)
    }

    func testNestedBundleRoundTrips() throws {
        let inner = OSCBundle([.message(OSCMessage(raw: "/inner", arguments: [.int32(1)]))])
        let outer = OSCBundle([
            .message(OSCMessage(raw: "/outer", arguments: [.string("first")])),
            .bundle(inner),
            .message(OSCMessage(raw: "/outer/again"))
        ])
        let parsed = try OSCParser.packet(from: outer.data())
        guard case let .bundle(roundTripped) = parsed else {
            return XCTFail("Expected .bundle")
        }
        XCTAssertEqual(roundTripped, outer)
    }

}
