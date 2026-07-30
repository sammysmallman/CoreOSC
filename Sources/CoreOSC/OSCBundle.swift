//
//  OSCBundle.swift
//  CoreOSC
//
//  Created by Sam Smallman on 22/07/2021.
//  Copyright © 2021 Sam Smallman. https://github.com/SammySmallman
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

/// An OSC Bundle.
public struct OSCBundle: Sendable, Equatable, Codable {

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

    /// The OSC Packet data for the bundle.
    public func data() -> Data {
        var result = Data(capacity: oscEncodedSize)
        encode(into: &result)
        return result
    }

    /// The number of bytes `encode(into:)` appends for the bundle:
    /// "#bundle" and the time tag, then a 4-byte size prefix per element.
    var oscEncodedSize: Int {
        var size = 16
        for element in elements { size += 4 + element.oscEncodedSize }
        return size
    }

    /// Encodes the bundle's OSC data representation by appending it to the given buffer.
    ///
    /// Each element's size prefix is written as a placeholder and patched in
    /// place once the element's bytes are known, avoiding a size pass per element.
    /// - Parameter buffer: The buffer to append the bundle's bytes to.
    func encode(into buffer: inout Data) {
        "#bundle".encode(into: &buffer)
        timeTag.encode(into: &buffer)
        for element in elements {
            let sizeIndex = buffer.count
            buffer.append(contentsOf: [0, 0, 0, 0])
            element.encode(into: &buffer)
            let elementSize = Int32(buffer.count - sizeIndex - 4)
            withUnsafeBytes(of: elementSize.bigEndian) { bytes in
                buffer.replaceSubrange(sizeIndex ..< sizeIndex + 4, with: bytes.baseAddress!, count: 4)
            }
        }
    }

    /// Flatten the elements contained by the bundle, ignoring all `OSCTimeTag`'s.
    /// - Returns: An array of `OSCMessage`'s.
    public func flatten() -> [OSCMessage] {
        var messages: [OSCMessage] = []
        appendMessages(into: &messages)
        return messages
    }

    private func appendMessages(into messages: inout [OSCMessage]) {
        for element in elements {
            switch element {
            case let .message(message):
                messages.append(message)
            case let .bundle(bundle):
                bundle.appendMessages(into: &messages)
            }
        }
    }

}
