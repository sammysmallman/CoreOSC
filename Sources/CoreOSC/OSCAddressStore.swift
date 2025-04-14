//
//  OSCAddressStore.swift
//  CoreOSC
//
//  Created by Sam Smallman on 23/12/2024.
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

/// A store of OSC Addresses that can be filtered by a server receiving an OSC Message.
public struct OSCAddressStore{

    /// A `Set` of OSC Addresses to filter on.
    public var addresses: Set<OSCAddress> = []

    /// A store of OSC Addresses that can be filtered by a server receiving an OSC Message.
    /// - Parameter addresses: A `Set` of OSC Addresses to filter on.
    public init(addresses: Set<OSCAddress> = []) {
        self.addresses = addresses
    }

    /// Returns a `Set` of `OSCAddress`s that match against the given `OSCMessage`.
    /// - Parameter message: An OSC Message to filter the store with.
    ///
    /// Each filter address is matched against the address pattern of the message.
    /// - Returns: An `Array` of `OSCAddress`'s.
    public func filter(with addressPattern: OSCAddressPattern) -> [OSCAddress] {
        addresses.compactMap {
            guard OSCMatch.match(
                addressPattern: addressPattern.fullPath,
                address: $0.fullPath
            ).match == .fullMatch else { return nil }
            return $0
        }
    }

    /// Returns the number of addresses that match against the given `OSCMessage`.
    /// - Parameter message: An OSC Message to filter the store with.
    ///
    /// Each address is matched against the address pattern of the message.
    public func count(with addressPattern: OSCAddressPattern) -> Int {
        filter(with: addressPattern).count
    }

}
