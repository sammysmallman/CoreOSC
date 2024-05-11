//
//  OSCAddressFilter.swift
//  CoreOSC
//
//  Created by Sam Smallman on 13/08/2021.
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

/// An object containing a set of OSC Methods to be invoked by a client after a filter process.
public struct OSCAddressFilter {
    
    /// The priority for which OSC Filter Methods are invoked first.
    public enum FilterPriority {
        /// Parts that match as raw strings are prioritised.
        /// OSC Filter Methods are sorted by the amount of `String` matches
        /// and will be invoked in that order.
        case string
        /// Parts that match with the wildcard "#" are prioritised.
        /// OSC Filter Methods sorted by the amount of "#" matches
        /// and will be invoked in that order.
        case wildcard
        /// There is no prioritization.
        /// OSC Filter Methods that match will be invoked in a random order.
        case none
    }
    
    /// The priority for which OSC Filter Methods are invoked first.
    public var priority: FilterPriority = .none
    
    /// A boolean value indicating whether only the first method matched should be invoked.
    public var invokeFirstOnly: Bool = false

    /// A `Set` of OSC Methods to be invoked by a client.
    public var methods: Set<OSCFilterMethod> = []

    /// An OSC Address Filter.
    /// - Parameter methods: A `Set` of OSC Methods the address filter should begin with.
    public init(methods: Set<OSCFilterMethod> = []) {
        self.methods = methods
    }
    
    /// Invoke the address filters methods with a message.
    /// - Parameters:
    ///   - message: An OSC Message to ivoke the methods with.
    ///   - userInfo: The user information dictionary stores any additional objects that the invoking action might use.
    ///
    /// Each methods filter address is matched against the address pattern of the message.
    /// When a full match has been found the method will be invoked with the given message.
    /// - Returns: A boolean value indicating whether any methods were invoked.
    public func invoke(with message: OSCMessage, userInfo: [AnyHashable : Any]? = nil) -> Bool {
        let filterMethods = methods(matching: message.addressPattern, priority: priority)
        guard !filterMethods.isEmpty else { return false }
        if invokeFirstOnly {
            filterMethods.first?.invoke(message, userInfo)
        } else {
            filterMethods.forEach { $0.invoke(message, userInfo) }
        }
        return true
    }
    
    /// Returns a `Set` of `OSCFilterMethods`s that match against the given `OSCAddressPattern`.
    /// - Parameters:
    ///   - addressPattern: An `OSCAddressPattern` to be matched against.
    ///   - priority: The priority for which the matched OSC Filter Methods should be sorted.
    /// - Returns: An `Array` of `OSCAddressPattern` to be invoked in that order.
    private func methods(matching addressPattern: OSCAddressPattern,
                         priority: FilterPriority = .none) -> [OSCFilterMethod] {
        var matchedAddresses = methods.map { OSCFilterMatch(method: $0) }
        // 1. The OSC Filter Address and the OSC Address Pattern contain the same number of parts; and
        let matchedAddressesWithEqualPartsCount = matchedAddresses.filter {
            addressPattern.parts.count == $0.method.filterAddress.parts.count
        }
        matchedAddresses = matchedAddressesWithEqualPartsCount
        // 2. Each part of the OSC Address Pattern matches the corresponding part of the OSC Filter Address.
        for (index, part) in addressPattern.parts.enumerated() {
            matchedAddressesWithEqualPartsCount.forEach { match in
                switch match.method.match(part: part, index: index) {
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
        case .none: return matchedAddresses.map { $0.method }
        case .string:
            let sorted = matchedAddresses
                .sorted { $0.strings > $1.strings }
                .map { $0.method }
            return sorted
        case .wildcard:
            let sorted = matchedAddresses
                .sorted { $0.wildcards > $1.wildcards }
                .map { $0.method }
            return sorted
        }
    }

}

extension OSCAddressFilter {
    
    /// An object that contains the current state of a filter match on a method.
    private class OSCFilterMatch: Equatable {
        
        /// The `OSCFilterMethod` that is being matched against.
        let method: OSCFilterMethod
        
        /// The number of raw string matches.
        var strings: Int = 0
        
        /// The number of wildcard "#" matches.
        var wildcards: Int = 0
        
        /// An `OSCFilterMatch`.
        /// - Parameters:
        ///   - method: An `OSCFilterMethod` that will be matched against an `OSCAddressPattern`.
        init(method: OSCFilterMethod) {
            self.method = method
        }

        static func == (lhs: OSCFilterMatch, rhs: OSCFilterMatch) -> Bool {
            return lhs.method.filterAddress == rhs.method.filterAddress
        }
    }
    
}
