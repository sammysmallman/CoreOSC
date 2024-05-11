//
//  OSCBundle.swift
//  CoreOSC
//
//  Created by Sam Smallman on 22/07/2021.
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

import Foundation

/// An OSC Bundle.
public struct OSCBundle: Sendable, Equatable {

    /// The bundles time tag used to indicate
    ///when it's contained elements should be invoked
    public var timeTag: OSCTimeTag

    /// The bundles elements. The contents are either `OSCMessage` or `OSCBundle`.
    ///
    /// - Note: A bundle may contain bundles.
    public var elements: [OSCPacket]

    /// An OSC Bundle.
    /// - Parameters:
    ///   - elements: The elements contained by the bundle.
    ///   - timeTag: The bundles `OSCTimeTag`.
    public init(_ elements: [OSCPacket] = [], timeTag: OSCTimeTag = .immediate) {
        self.timeTag = timeTag
        self.elements = elements
    }

    public static func == (lhs: OSCBundle, rhs: OSCBundle) -> Bool {
        guard lhs.timeTag == rhs.timeTag,
              lhs.elements.count == rhs.elements.count
        else { return false }
        for (index, element) in lhs.elements.enumerated() {
            switch element {
            case let .message(lhsMessage):
                guard case let .message(rhsMessage) = rhs.elements[index],
                      lhsMessage == rhsMessage else { return false }
                continue
            case let .bundle(lhsBundle):
                guard case let .bundle(rhsBundle) = rhs.elements[index],
                      lhsBundle == rhsBundle else { return false }
                continue
            }
        }
        return true
    }

    /// The OSC Packet data for the bundle.
    public func data() -> Data {
        var result = "#bundle".oscData
        result.append(timeTag.oscData)
        for element in elements {
            switch element {
            case let .message(message):
                let data = message.data()
                let size = withUnsafeBytes(of: Int32(data.count).bigEndian) { Data($0) }
                result.append(size)
                result.append(data)
            case let .bundle(bundle):
                let data = bundle.data()
                let size = withUnsafeBytes(of: Int32(data.count).bigEndian) { Data($0) }
                result.append(size)
                result.append(data)
            }
        }
        return result
    }

    /// Flatten the elements contained by the bundle, ignoring all `OSCTimeTag`'s.
    /// - Returns: An array of `OSCMessage`'s.
    public func flatten() -> [OSCMessage] {
        elements.reduce([OSCMessage]()) {
            switch $1 {
            case let .message(message):
                return $0 + [message]
            case let .bundle(bundle):
                return $0 + bundle.flatten()
            }
        }
    }

}
