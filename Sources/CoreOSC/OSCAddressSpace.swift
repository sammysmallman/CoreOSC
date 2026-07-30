//
//  OSCAddressSpace.swift
//  CoreOSC
//
//  Created by Sam Smallman on 10/08/2021.
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

/// A set of OSC Methods invoked by matching received messages against their addresses.
///
/// Wildcards in a received message's address pattern — "*", "?", "[]", "{}" — are pattern
/// matched against each method's fixed `OSCAddress`; every method that fully matches is invoked.
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
    ///   - message: An OSC Message to invoke the methods with.
    ///   - userInfo: Per-invocation context from the call site, passed through to every method the message invokes — for example, the destination a reply should be sent to.
    ///
    /// Each method's address is matched against the address pattern of the message
    /// according to the method's ``OSCDispatchPolicy``. Matched methods are invoked
    /// in ascending order of their full path.
    public func invoke(with message: OSCMessage, userInfo: [AnyHashable : Any]? = nil) {
        for method in methods.sorted(by: { $0.address.fullPath < $1.address.fullPath }) {
            _ = method.invoke(with: message, userInfo: userInfo)
        }
    }
    
}

