//
//  OSCInvocation.swift
//  CoreOSC
//
//  Created by Sam Smallman on 30/07/2026.
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

import Foundation

/// An atomic group of messages sharing one invocation time.
///
/// OSC 1.0 requires the messages of a bundle to be invoked atomically at the
/// bundle's time tag; an invocation is one such group, produced by
/// `OSCPacket.invocations()`.
public struct OSCInvocation: Sendable, Equatable {

    /// The time at which the messages should be invoked.
    public let timeTag: OSCTimeTag

    /// The messages to invoke, in bundle order.
    public let messages: [OSCMessage]

    /// An atomic group of messages sharing one invocation time.
    /// - Parameters:
    ///   - timeTag: The time at which the messages should be invoked.
    ///   - messages: The messages to invoke, in bundle order.
    public init(timeTag: OSCTimeTag, messages: [OSCMessage]) {
        self.timeTag = timeTag
        self.messages = messages
    }

}

extension OSCPacket {

    /// Flattens the packet into time-ordered atomic invocation groups.
    ///
    /// A bare message becomes a single immediate invocation. A bundle contributes
    /// one group per effective time tag, preserving bundle order within each group.
    /// A nested bundle's time tag earlier than its enclosing bundle's is clamped up
    /// to the enclosing tag — senders that violate the OSC 1.0 monotonicity rule
    /// are repaired rather than failed.
    /// - Returns: An `Array` of `OSCInvocation`s ordered by ascending time tag.
    public func invocations() -> [OSCInvocation] {
        var groups: [OSCTimeTag: [OSCMessage]] = [:]
        collect(into: &groups, enclosingTag: .immediate)
        return groups.keys.sorted().map { OSCInvocation(timeTag: $0, messages: groups[$0]!) }
    }

    /// Accumulates the packet's messages into groups keyed by effective time tag.
    /// - Parameters:
    ///   - groups: The groups accumulated so far.
    ///   - enclosingTag: The effective time tag of the enclosing bundle.
    private func collect(into groups: inout [OSCTimeTag: [OSCMessage]], enclosingTag: OSCTimeTag) {
        switch self {
        case let .message(message):
            groups[enclosingTag, default: []].append(message)
        case let .bundle(bundle):
            let effectiveTag = max(bundle.timeTag, enclosingTag)
            for element in bundle.elements {
                element.collect(into: &groups, enclosingTag: effectiveTag)
            }
        }
    }

}
