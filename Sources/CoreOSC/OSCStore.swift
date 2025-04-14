//
//  OSCStore.swift
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

/// A store of addresses that can be filtered by a server receiving an OSC Message.
@frozen public enum OSCStore {
    /// A store of OSC Addresses that can be filtered by a server receiving an OSC Message.
    case address(OSCAddressStore)
    /// A store of OSC Filter Addresses that can be filtered by a server receiving an OSC Message.
    case filter(OSCFilterAddressStore)

    /// A store of OSC Addresses that can be filtered by a server receiving an OSC Message.
    /// - Parameter addresses: A `Set` of OSC Addresses to filter on.
    public static func address(_ addresses: Set<OSCAddress> ) -> Self {
        .address(.init(addresses: addresses))
    }

    /// A store of OSC Filter Addresses that can be filtered by a server receiving an OSC Message.
    /// - Parameter addresses: A `Set` of OSC Filter Addresses to filter on.
    public static func filter(_ addresses: Set<OSCFilterAddress>) -> Self {
        .filter(.init(addresses: addresses))
    }

    /// Returns the number of addresses that match against the given `OSCMessage` in the store.
    /// - Parameter addressPattern: An OSC Message to filter the store with.
    public func count(with addressPattern: OSCAddressPattern) -> Int {
        switch self {
        case let .address(store):
            store.count(with: addressPattern)
        case let .filter(store):
            store.count(with: addressPattern)
        }
    }

}
