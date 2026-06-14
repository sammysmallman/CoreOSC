//
//  OSCCodableTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 14/06/2026.
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

/// Verifies the synthesised `Codable` conformances round-trip every OSC type
/// through `JSONEncoder`/`JSONDecoder` without loss.
final class OSCCodableTests: XCTestCase {

    private func assertRoundTrip<Value: Codable & Equatable>(
        _ value: Value,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(Value.self, from: data)
        XCTAssertEqual(value, decoded, file: file, line: line)
    }

    func testOSCArgumentRoundTrips() throws {
        try assertRoundTrip(OSCArgument.int32(42))
        try assertRoundTrip(OSCArgument.float32(3.142))
        try assertRoundTrip(OSCArgument.string("Core OSC"))
        try assertRoundTrip(OSCArgument.blob(Data([0x01, 0x02, 0x03])))
        try assertRoundTrip(OSCArgument.true)
        try assertRoundTrip(OSCArgument.false)
        try assertRoundTrip(OSCArgument.nil)
        try assertRoundTrip(OSCArgument.impulse)
        try assertRoundTrip(OSCArgument.timeTag(.immediate))
    }

    func testOSCTimeTagRoundTrips() throws {
        try assertRoundTrip(OSCTimeTag.immediate)
        try assertRoundTrip(OSCTimeTag(date: Date(timeIntervalSince1970: 1_700_000_000)))
    }

    func testOSCAddressPatternRoundTrips() throws {
        try assertRoundTrip(try OSCAddressPattern("/core/osc/1"))
        try assertRoundTrip(OSCAddressPattern(raw: "/core/osc/*"))
    }

    func testOSCMessageRoundTrips() throws {
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
        try assertRoundTrip(message)
    }

    func testOSCBundleAndPacketRoundTrip() throws {
        let bundle = OSCBundle(
            [
                .message(OSCMessage(raw: "/core/osc/1", arguments: [.int32(1)])),
                .bundle(OSCBundle([
                    .message(OSCMessage(raw: "/core/osc/2", arguments: [.string("nested")]))
                ]))
            ],
            timeTag: .immediate
        )
        try assertRoundTrip(bundle)
        try assertRoundTrip(OSCPacket.bundle(bundle))
        try assertRoundTrip(OSCPacket.message(OSCMessage(raw: "/core/osc", arguments: [.true])))
    }
}
