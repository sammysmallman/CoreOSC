//
//  OSCPacket.swift
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

/// An OSC Packet, either an `OSCMessage` or `OSCBundle`.
@frozen public enum OSCPacket: Sendable, Equatable {
    /// An OSC Message.
    case message(OSCMessage)
    /// An OSC Bundle.
    case bundle(OSCBundle)

    /// The OSC data representation for the packet.
    public func data() -> Data {
        switch self {
        case let .message(message):
            return message.data()
        case let .bundle(bundle):
            return bundle.data()
        }
    }

}
