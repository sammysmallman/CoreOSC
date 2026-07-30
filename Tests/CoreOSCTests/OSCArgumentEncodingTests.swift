//
//  OSCArgumentEncodingTests.swift
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

final class OSCArgumentEncodingTests: XCTestCase {

    private func decodeFloat32(_ data: Data) -> Float32 {
        let bits = data.withUnsafeBytes { $0.load(as: UInt32.self) }.bigEndian
        return Float32(bitPattern: bits)
    }

    private func decodeInt32(_ data: Data) -> Int32 {
        data.withUnsafeBytes { $0.load(as: Int32.self) }.bigEndian
    }

    // MARK: - Double / CGFloat truncate rather than zero

    func testDoubleEncodesTruncatedValue() {
        // Previously any double not exactly representable as a Float32
        // encoded as 0.0.
        XCTAssertEqual(decodeFloat32((3.14 as Double).oscData), 3.14, accuracy: 0.0001)
    }

    func testCGFloatEncodesTruncatedValue() {
        XCTAssertEqual(decodeFloat32((3.14 as CGFloat).oscData), 3.14, accuracy: 0.0001)
    }

    // MARK: - Int conversion

    func testOutOfRangeIntArgumentThrowsInsteadOfTrapping() {
        // Previously trapped in the Int32(value) conversion.
        XCTAssertThrowsError(try OSCMessage(
            with: "/probe",
            arguments: [Int(5_000_000_000)] as [any OSCArgumentProtocol]
        )) { error in
            XCTAssertEqual(error as? OSCArgumentError, .invalidArgument)
        }
    }

    func testInRangeIntArgumentConverts() throws {
        let message = try OSCMessage(
            with: "/probe",
            arguments: [Int(42)] as [any OSCArgumentProtocol]
        )
        XCTAssertEqual(message.arguments, [.int32(42)])
    }

    func testIntOscDataClampsAtBounds() {
        // Previously values out of Int32 range silently encoded as 0.
        XCTAssertEqual(decodeInt32(Int.max.oscData), Int32.max)
        XCTAssertEqual(decodeInt32(Int.min.oscData), Int32.min)
        XCTAssertEqual(decodeInt32(Int(7).oscData), 7)
    }

}
