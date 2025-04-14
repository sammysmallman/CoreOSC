//
//  OSCAddressMethod.swift
//  CoreOSC
//
//  Created by Sam Smallman on 13/08/2021.
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

/// The potential destination of an OSC Message and a point of control made available by invoking the method.
public struct OSCFilterMethod: Hashable, Equatable {
    
    /// An object that represents the full path to this OSC Method in an OSC Address Filter.
    public let filterAddress: OSCFilterAddress
    
    /// A closure that is invoked by passing in an OSC Message.
    internal let invoke: (OSCMessage, [AnyHashable : Any]?) -> Void
    
    /// An OSC Method that can be invoked by an OSC Message.
    /// - Parameters:
    ///   - filterAddress: The full path to this OSC Method.
    ///   - invokedAction: A closure that is invoked when the address pattern of an OSC Message matches against the given address.
    ///   - message: `OSCMessage`
    ///   - userInfo: `[AnyHashable : Any]`?
    ///
    /// The user information dictionary stores any additional objects that the invoking action might use.
    public init(with filterAddress: OSCFilterAddress,
                invokedAction: @escaping (_ message: OSCMessage,
                                          _ userInfo: [AnyHashable : Any]?) -> Void) {
        self.filterAddress = filterAddress
        self.invoke = invokedAction
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(filterAddress)
    }
    
    public static func == (lhs: OSCFilterMethod, rhs: OSCFilterMethod) -> Bool {
        return lhs.filterAddress == rhs.filterAddress
    }
    
}
