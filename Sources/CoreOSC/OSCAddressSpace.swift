//
//  OSCAddressSpace.swift
//  CoreOSC
//
//  Created by Sam Smallman on 10/08/2021.
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

/// A tree structure containing a set of OSC Methods to be invoked by a client.
public struct OSCAddressSpace {
    
    /// A `Set` of OSC Methods to be invoked by a client.
    public var methods: Set<OSCMethod>
    
    /// An OSC Address Space.
    /// - Parameter methods: A `Set` of OSC Methods the address space should begin with.
    public init(methods: Set<OSCMethod> = []) {
        self.methods = methods
    }
    
    /// Invoke the address spaces methods with a message.
    /// - Parameters:
    ///   - message: An OSC Message to ivoke the methods with.
    ///   - userInfo: The user information dictionary stores any additional objects that the invoking action might use.
    ///   
    /// Each methods address is pattern matched against the address pattern of the message.
    /// When a full match has been found the method will be invoked with the given message.
    ///
    /// The methods of the address space are unordered therefore invoked in any random order...
    public func invoke(with message: OSCMessage, userInfo: [AnyHashable : Any]? = nil) {
        for method in methods {
            if OSCMatch.match(addressPattern: message.addressPattern.fullPath,
                              address: method.address.fullPath)
                .match == .fullMatch {
                method.invoke(message, userInfo)
            }
        }
    }
    
}

