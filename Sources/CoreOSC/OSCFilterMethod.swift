//
//  OSCAddressMethod.swift
//  CoreOSC
//
//  Created by Sam Smallman on 13/08/2021.
//  Copyright © 2021 Sam Smallman. https://github.com/SammySmallman
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
    
    /// Match an `OSCAddressPattern`'s part against the corresponding part of the methods `OSCFilterAddress`.
    /// - Parameters:
    ///   - part: The `OSCAddressPatterns` part to match against.
    ///   - index: The index of the `OSCFilterAddress`'s part to match against.
    /// - Returns: A `OSCFilterPatternMatch` indicating the result of the match.
    internal func match(part: String, index: Int) -> OSCFilterPatternMatch {
        guard filterAddress.parts.indices.contains(index) else { return .different }
        let match = filterAddress.parts[index]
        switch match {
        case part: return .string
        case "#": return .wildcard
        default: return .different
        }
    }
    
}

extension OSCFilterMethod {
    
    /// The result of matching an `OSCAddressPattern`'s part against the corresponding
    /// `OSCFilterAddress`'s part.
    internal enum OSCFilterPatternMatch {
        /// The `OSCAddressPattern`'s part matches fully against the
        /// `OSCFilterAddress`'s part.
        case string
        /// The `OSCAddressPattern`'s part matches against the
        /// `OSCFilterAddress`'s part with the wildcard "#".
        case wildcard
        /// The `OSCAddressPattern`'s part does the match against
        /// `OSCFilterAddress`'s part.
        case different
    }
}
