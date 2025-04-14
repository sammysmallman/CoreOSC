//
//  OSCFilterAddressStore.swift
//  CoreOSC
//
//  Created by Sam Smallman on 12/12/2024.
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

/// A store of OSC Filter Addresses that can be filtered by a server receiving an OSC Message.
public struct OSCFilterAddressStore {

    /// The priority for which the store orders filtered addresses.
    public enum FilterPriority {
        /// Parts that match as raw strings are prioritised.
        /// OSC Filter Addresses are sorted by the amount of `String` matches.
        case string
        /// Parts that match with the wildcard "#" are prioritised.
        /// OSC Filter Addresses sorted by the amount of "#" matches.
        case wildcard
        /// There is no prioritization.
        case none
    }

    /// The priority for which OSC Filter Addresses are ordered.
    public var priority: FilterPriority = .none

    /// A `Set` of OSC Filter Addresses to filter on.
    public var addresses: Set<OSCFilterAddress> = []

    /// A store of OSC Filter Addresses that can be filtered by a server receiving an OSC Message.
    /// - Parameter addresses: A `Set` of OSC Filter Addresses to filter on.
    public init(addresses: Set<OSCFilterAddress> = []) {
        self.addresses = addresses
    }

    /// Returns a `Set` of `OSCFilterAddress`s that match against the given `OSCMessage`.
    /// - Parameter message: An OSC Message to filter the store with.
    ///
    /// Each filter address is matched against the address pattern of the message.
    /// - Returns: An `Array` of `OSCFilterAddress` ordered by priority.
    public func filter(with addressPattern: OSCAddressPattern) -> [OSCFilterAddress] {
        var matchedAddresses = addresses.map { OSCFilterStoreMatch(address: $0) }
        // 1. The OSC Filter Address and the OSC Address Pattern contain the same number of parts; and
        let matchedAddressesWithEqualPartsCount = matchedAddresses.filter {
            addressPattern.parts.count == $0.address.parts.count
        }
        matchedAddresses = matchedAddressesWithEqualPartsCount
        // 2. Each part of the OSC Address Pattern matches the corresponding part of the OSC Filter Address.
        for (index, part) in addressPattern.parts.enumerated() {
            matchedAddressesWithEqualPartsCount.forEach { match in
                switch match.address.match(part: part, index: index) {
                case .string:
                    match.strings += 1
                case .wildcard:
                    match.wildcards += 1
                case .different:
                    matchedAddresses = matchedAddresses.filter { match != $0 }
                }
            }
        }
        switch priority {
        case .none: return matchedAddresses.map { $0.address }
        case .string:
            let sorted = matchedAddresses
                .sorted { $0.strings > $1.strings }
                .map { $0.address }
            return sorted
        case .wildcard:
            let sorted = matchedAddresses
                .sorted { $0.wildcards > $1.wildcards }
                .map { $0.address }
            return sorted
        }
    }
    
    /// Returns the number of addresses that match against the given `OSCMessage`.
    /// - Parameter message: An OSC Message to filter the store with.
    ///
    /// Each filter address is matched against the address pattern of the message.
    public func count(with addressPattern: OSCAddressPattern) -> Int {
        var matchedAddresses = addresses
        // 1. The OSC Filter Address and the OSC Address Pattern contain the same number of parts; and
        let matchedAddressesWithEqualPartsCount = matchedAddresses.filter {
            addressPattern.parts.count == $0.parts.count
        }
        matchedAddresses = matchedAddressesWithEqualPartsCount
        // 2. Each part of the OSC Address Pattern matches the corresponding part of the OSC Filter Address.
        for (index, part) in addressPattern.parts.enumerated() {
            matchedAddressesWithEqualPartsCount.forEach { match in
                if case .different = match.match(part: part, index: index) {
                    matchedAddresses = matchedAddresses.filter { match != $0 }
                }
            }
        }
        return matchedAddresses.count
    }

}

extension OSCFilterAddressStore {

    /// An object that contains the current state of a filter match on an address.
    private class OSCFilterStoreMatch: Equatable {

        /// The `OSCFilterAddress` that is being matched against.
        let address: OSCFilterAddress

        /// The number of raw string matches.
        var strings: Int = 0

        /// The number of wildcard "#" matches.
        var wildcards: Int = 0

        /// An `OSCFilterStoreMatch`.
        /// - Parameters:
        ///   - address: An `OSCFilterAddress` that will be matched against an `OSCAddressPattern`.
        init(address: OSCFilterAddress) {
            self.address = address
        }

        static func == (lhs: OSCFilterStoreMatch, rhs: OSCFilterStoreMatch) -> Bool {
            return lhs.address == rhs.address
        }
    }

}
