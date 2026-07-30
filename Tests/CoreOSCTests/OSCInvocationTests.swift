//
//  OSCInvocationTests.swift
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

final class OSCInvocationTests: XCTestCase {

    private func tag(seconds: UInt32, fraction: UInt32) -> OSCTimeTag {
        var data = Data()
        data.append(bigEndian: seconds)
        data.append(bigEndian: fraction)
        return OSCTimeTag(data: data)!
    }

    // MARK: - Comparable

    func testTimeTagsOrderBySecondsThenFraction() {
        XCTAssertLessThan(tag(seconds: 1, fraction: 0), tag(seconds: 1, fraction: 1))
        XCTAssertLessThan(tag(seconds: 1, fraction: UInt32.max), tag(seconds: 2, fraction: 0))
        XCTAssertFalse(tag(seconds: 2, fraction: 0) < tag(seconds: 2, fraction: 0))
    }

    func testImmediateSortsBeforeEveryRealTime() {
        let future = OSCTimeTag(date: Date(timeIntervalSince1970: 1_234_567_890))
        XCTAssertLessThan(OSCTimeTag.immediate, future)
        XCTAssertLessThan(OSCTimeTag.immediate, tag(seconds: 0, fraction: 2))
    }

    // MARK: - Bare messages

    func testBareMessageBecomesSingleImmediateInvocation() throws {
        let message = try OSCMessage(with: "/core/osc")
        let invocations = OSCPacket.message(message).invocations()
        XCTAssertEqual(invocations, [OSCInvocation(timeTag: .immediate, messages: [message])])
    }

    // MARK: - Bundles

    func testImmediateBundlePreservesBundleOrder() throws {
        let messages = [
            try OSCMessage(with: "/core/osc/1"),
            try OSCMessage(with: "/core/osc/2"),
            try OSCMessage(with: "/core/osc/3")
        ]
        let bundle = OSCBundle(messages.map { .message($0) })
        let invocations = OSCPacket.bundle(bundle).invocations()
        XCTAssertEqual(invocations, [OSCInvocation(timeTag: .immediate, messages: messages)])
    }

    func testNestedBundlesSplitIntoGroupsSortedByTag() throws {
        let first = tag(seconds: 100, fraction: 0)
        let second = tag(seconds: 200, fraction: 0)
        let message1 = try OSCMessage(with: "/core/osc/1")
        let message2 = try OSCMessage(with: "/core/osc/2")
        let message3 = try OSCMessage(with: "/core/osc/3")
        // The later-tagged bundle sits between the enclosing bundle's own messages.
        let bundle = OSCBundle([
            .message(message1),
            .bundle(OSCBundle([.message(message2)], timeTag: second)),
            .message(message3)
        ], timeTag: first)
        XCTAssertEqual(OSCPacket.bundle(bundle).invocations(), [
            OSCInvocation(timeTag: first, messages: [message1, message3]),
            OSCInvocation(timeTag: second, messages: [message2])
        ])
    }

    func testEarlierNestedTagClampsUpToEnclosingTag() throws {
        let earlier = tag(seconds: 100, fraction: 0)
        let later = tag(seconds: 200, fraction: 0)
        let message1 = try OSCMessage(with: "/core/osc/1")
        let message2 = try OSCMessage(with: "/core/osc/2")
        let bundle = OSCBundle([
            .message(message1),
            .bundle(OSCBundle([.message(message2)], timeTag: earlier))
        ], timeTag: later)
        XCTAssertEqual(OSCPacket.bundle(bundle).invocations(), [
            OSCInvocation(timeTag: later, messages: [message1, message2])
        ])
    }

    func testImmediateNestedInFutureBundleClampsUpToEnclosingTag() throws {
        let future = tag(seconds: 100, fraction: 0)
        let message = try OSCMessage(with: "/core/osc")
        let bundle = OSCBundle([
            .bundle(OSCBundle([.message(message)], timeTag: .immediate))
        ], timeTag: future)
        XCTAssertEqual(OSCPacket.bundle(bundle).invocations(), [
            OSCInvocation(timeTag: future, messages: [message])
        ])
    }

    func testSiblingBundlesWithEqualTagsMergeInTraversalOrder() throws {
        let shared = tag(seconds: 100, fraction: 0)
        let message1 = try OSCMessage(with: "/core/osc/1")
        let message2 = try OSCMessage(with: "/core/osc/2")
        let bundle = OSCBundle([
            .bundle(OSCBundle([.message(message1)], timeTag: shared)),
            .bundle(OSCBundle([.message(message2)], timeTag: shared))
        ])
        XCTAssertEqual(OSCPacket.bundle(bundle).invocations(), [
            OSCInvocation(timeTag: shared, messages: [message1, message2])
        ])
    }

    func testEmptyBundleProducesNoInvocations() {
        XCTAssertEqual(OSCPacket.bundle(OSCBundle()).invocations(), [])
        let nested = OSCBundle([.bundle(OSCBundle())], timeTag: tag(seconds: 100, fraction: 0))
        XCTAssertEqual(OSCPacket.bundle(nested).invocations(), [])
    }

}
