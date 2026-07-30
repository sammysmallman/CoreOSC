//
//  OSCMethod.swift
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

/// The way an OSC Method may be invoked by a received OSC Address Pattern.
public enum OSCDispatchPolicy: Sendable {
    /// Invoked by any matching address pattern, wildcards included — the OSC 1.0
    /// behaviour and the default.
    case pattern
    /// Invoked only when the received address pattern is literally equal to the
    /// method's address — wildcards never reach the method. Suited to imperative
    /// methods such as "/record/start", where a wildcard fanning out across
    /// mutually exclusive commands would leave the application in an unknown state.
    case exact
}

/// A closure paired with the OSC Address needed to invoke it: the potential destination
/// of an OSC Message and a point of control made available by invoking the method.
public struct OSCMethod: Hashable, Equatable {

    /// An object that represents the full path to this OSC Method in an OSC Address Space.
    public let address: OSCAddress

    /// The way the method may be invoked by a received OSC Address Pattern.
    public let dispatch: OSCDispatchPolicy

    /// A closure that is invoked by passing in an OSC Message.
    internal let invoke: (OSCMessage, [AnyHashable : Any]?) -> Void

    /// An OSC Method that can be invoked by an OSC Message.
    /// - Parameters:
    ///   - address: The full path to this OSC Method.
    ///   - dispatch: The way the method may be invoked by a received OSC Address Pattern.
    ///   - invokedAction: A closure that is invoked when the address pattern of an OSC Message matches against the given address. It receives the matched `OSCMessage` and an optional user information dictionary.
    ///
    /// The user information dictionary stores any additional objects that the invoking action might use.
    public init(with address: OSCAddress,
                dispatch: OSCDispatchPolicy = .pattern,
                invokedAction: @escaping (_ message: OSCMessage,
                                          _ userInfo: [AnyHashable : Any]?) -> Void) {
        self.address = address
        self.dispatch = dispatch
        self.invoke = invokedAction
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }

    public static func == (lhs: OSCMethod, rhs: OSCMethod) -> Bool {
        return lhs.address == rhs.address
    }

    /// Invoke the method.
    /// - Parameters:
    ///   - message:  An OSC Message to invoke the method with.
    ///   - userInfo: The user information dictionary stores any additional objects that the invoking action might use.
    /// - Returns: A boolean value indicating whether the method has been invoked.
    ///
    /// The message's address pattern is matched according to the method's ``dispatch``
    /// policy: pattern matched for `.pattern`, compared for literal equality for `.exact`.
    public func invoke(with message: OSCMessage, userInfo: [AnyHashable : Any]? = nil) -> Bool {
        switch dispatch {
        case .pattern:
            guard OSCMatch.match(addressPattern: message.addressPattern.fullPath,
                                 address: address.fullPath)
                    .match == .fullMatch else {
                return false
            }
        case .exact:
            guard message.addressPattern.fullPath == address.fullPath else {
                return false
            }
        }
        invoke(message, userInfo)
        return true
    }

}
