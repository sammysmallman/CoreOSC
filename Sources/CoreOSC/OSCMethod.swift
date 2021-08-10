//
//  OSCMethod.swift
//  CoreOSC
//
//  Created by Sam Smallman on 10/08/2021.
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
public struct OSCMethod: Hashable, Equatable {
    
    /// An object that represents the full path to this OSC Method in an OSC Address Space.
    public let address: OSCAddress
    
    /// A closure that is invoked by passing in an OSC Message.
    internal let invoke: (OSCMessage) -> Void
    
    /// An OSC Method that can be invoked by an OSC Message.
    /// - Parameters:
    ///   - address: The full path to this OSC Method.
    ///   - invokedAction: A closure that is invoked when the address pattern of an OSC Message matches against the given address.
    ///   - message: `OSCMessage`
    public init(with address: OSCAddress, invokedAction: @escaping (_ message: OSCMessage) -> Void) {
        self.address = address
        self.invoke = invokedAction
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }
    
    public static func == (lhs: OSCMethod, rhs: OSCMethod) -> Bool {
        return lhs.address == rhs.address
    }
    
    /// Invoke the method.
    /// - Parameter message: An OSC Message to invoke the method with.
    /// - Returns: A boolean value indicating whether the method has been invoked.
    public func invoke(with message: OSCMessage) -> Bool {
        guard OSCMatch.match(addressPattern: message.addressPattern.fullPath,
                             address: address.fullPath)
                .match == .fullMatch else {
            return false
        }
        invoke(message)
        return true
    }
    
}
