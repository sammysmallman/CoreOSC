//
//  OSCPacketEncodingTests.swift
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

final class OSCPacketEncodingTests: XCTestCase {

    // MARK: - Reference encoder

    /// Encodes a message by stitching together each component's `oscData`,
    /// the shape of the implementation `encode(into:)` replaced. `oscData`
    /// remains the public per-argument representation, so agreement here
    /// proves `data()` is byte-identical to the previous implementation.
    private func referenceData(for message: OSCMessage) -> Data {
        var result = message.addressPattern.fullPath.oscData
        var typeTags = ","
        for argument in message.arguments { typeTags.append(argument.oscTypeTag) }
        result.append(typeTags.oscData)
        for argument in message.arguments { result.append(argument.oscData) }
        return result
    }

    /// Encodes a bundle with a `Data` per element and per size prefix, the
    /// shape of the implementation `encode(into:)` replaced.
    private func referenceData(for bundle: OSCBundle) -> Data {
        var result = "#bundle".oscData
        result.append(bundle.timeTag.oscData)
        for element in bundle.elements {
            let data: Data
            switch element {
            case let .message(message):
                data = referenceData(for: message)
            case let .bundle(innerBundle):
                data = referenceData(for: innerBundle)
            }
            let size = withUnsafeBytes(of: Int32(data.count).bigEndian) { Data($0) }
            result.append(size)
            result.append(data)
        }
        return result
    }

    // MARK: - Messages

    func testMessageWithEveryArgumentTypeMatchesReference() throws {
        let message = try OSCMessage(with: "/core/osc/encoding", arguments: [
            .int32(2_147_483_647),
            .int32(-1),
            .float32(3.142),
            .float32(-0.0),
            .string("Hello, world!"),
            .blob(Data([0x01, 0x02, 0x03, 0x04, 0x05])),
            .true,
            .false,
            .nil,
            .impulse,
            .timeTag(.immediate),
            .timeTag(OSCTimeTag(date: Date(timeIntervalSince1970: 1_234_567_890.5)))
        ])
        XCTAssertEqual(message.data(), referenceData(for: message))
    }

    func testMessageWithNoArgumentsMatchesReference() throws {
        let message = try OSCMessage(with: "/core/osc")
        XCTAssertEqual(message.data(), referenceData(for: message))
    }

    func testStringArgumentPaddingMatchesReferenceForEveryRemainder() throws {
        // Lengths 0 through 8 cover every padding branch, including the
        // 4-null pad when the UTF-8 count is already a multiple of 4.
        for length in 0...8 {
            let message = try OSCMessage(with: "/pad", arguments: [
                .string(String(repeating: "a", count: length))
            ])
            XCTAssertEqual(message.data(), referenceData(for: message), "length \(length)")
        }
    }

    func testMultiByteStringArgumentMatchesReference() throws {
        let message = try OSCMessage(with: "/pad", arguments: [.string("héllo wörld — 🎛")])
        XCTAssertEqual(message.data(), referenceData(for: message))
    }

    func testBlobArgumentPaddingMatchesReferenceForEveryRemainder() throws {
        // Sizes 0 through 8 cover every padding branch, including no padding
        // when the count is already a multiple of 4.
        for size in 0...8 {
            let message = try OSCMessage(with: "/pad", arguments: [
                .blob(Data(repeating: 0xAB, count: size))
            ])
            XCTAssertEqual(message.data(), referenceData(for: message), "size \(size)")
        }
    }

    func testAddressPatternLengthMatchesReferenceForEveryRemainder() throws {
        for length in 1...8 {
            let message = try OSCMessage(with: "/" + String(repeating: "a", count: length))
            XCTAssertEqual(message.data(), referenceData(for: message), "length \(length)")
        }
    }

    // MARK: - Bundles

    func testEmptyBundleMatchesReference() {
        let bundle = OSCBundle()
        XCTAssertEqual(bundle.data(), referenceData(for: bundle))
    }

    func testBundleWithMessagesMatchesReference() throws {
        let bundle = OSCBundle([
            .message(try OSCMessage(with: "/core/osc/1", arguments: [.int32(1), .string("one")])),
            .message(try OSCMessage(with: "/core/osc/2", arguments: [.float32(2.0), .blob(Data([0xFF]))]))
        ], timeTag: OSCTimeTag(date: Date(timeIntervalSince1970: 1_234_567_890.5)))
        XCTAssertEqual(bundle.data(), referenceData(for: bundle))
    }

    func testNestedBundleMatchesReference() throws {
        let inner = OSCBundle([
            .message(try OSCMessage(with: "/core/osc/4", arguments: [.string("deep")])),
            .bundle(OSCBundle())
        ])
        let bundle = OSCBundle([
            .message(try OSCMessage(with: "/core/osc/1", arguments: [.int32(1)])),
            .bundle(inner),
            .message(try OSCMessage(with: "/core/osc/2", arguments: [.true, .impulse]))
        ])
        XCTAssertEqual(bundle.data(), referenceData(for: bundle))
    }

    func testNestedBundleRoundTripsThroughParser() throws {
        let bundle = OSCBundle([
            .message(try OSCMessage(with: "/core/osc/1", arguments: [
                .int32(1),
                .float32(3.142),
                .string("Hello, world!"),
                .blob(Data([0x01, 0x02, 0x03])),
                .true,
                .false,
                .nil,
                .impulse
            ])),
            .bundle(OSCBundle([
                .message(try OSCMessage(with: "/core/osc/2", arguments: [.string("nested")]))
            ]))
        ])
        let packet = try OSCParser.packet(from: bundle.data())
        XCTAssertEqual(packet, .bundle(bundle))
    }

    // MARK: - Default implementation

    /// A conformance outside the package that implements only the original
    /// requirements, relying on the default `encode(into:)`.
    private struct LegacyArgument: OSCArgumentProtocol {
        var oscData: Data { Data([0xDE, 0xAD, 0xBE, 0xEF]) }
        var oscTypeTag: Character { "i" }
        func oscAnnotation(withType type: Bool) -> String { "legacy" }
    }

    func testDefaultEncodeAppendsOSCData() {
        var buffer = Data([0x00])
        LegacyArgument().encode(into: &buffer)
        XCTAssertEqual(buffer, Data([0x00, 0xDE, 0xAD, 0xBE, 0xEF]))
    }

    // MARK: - Capacity accounting

    func testEncodedSizeMatchesEncodedByteCount() throws {
        let message = try OSCMessage(with: "/core/osc/size", arguments: [
            .int32(1),
            .float32(3.142),
            .string("Hello"),
            .blob(Data(repeating: 0xAB, count: 6)),
            .true,
            .timeTag(.immediate)
        ])
        XCTAssertEqual(message.oscEncodedSize, message.data().count)
        let bundle = OSCBundle([
            .message(message),
            .bundle(OSCBundle([.message(message)]))
        ])
        XCTAssertEqual(bundle.oscEncodedSize, bundle.data().count)
    }

}
