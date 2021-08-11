//
//  OSCAddressSpace.swift
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

