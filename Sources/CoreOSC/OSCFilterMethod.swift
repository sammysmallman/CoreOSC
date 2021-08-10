//
//  OSCAddressMethod.swift
//  CoreOSC
//
//  Created by Sam Smallman on 22/107/2021.
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

public enum OSCAddressPatternMatch {
    case string
    case different
    case wildcard
}

public struct OSCFilterMethod: Hashable, Equatable {

    public let address: OSCAddress
    public let completionHandler: (OSCMessage) -> Void

    public init(with address: OSCAddress, completionHandler: @escaping (OSCMessage) -> Void) {
        self.address = address
        self.completionHandler = completionHandler
    }

    public static func == (lhs: OSCFilterMethod, rhs: OSCFilterMethod) -> Bool {
        return lhs.address == rhs.address
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }

    // "/a/b/c/d/e" is equal to "/a/b/c/d/e" or "/a/b/c/d/*".
    public func match(part: String, atIndex index: Int) -> OSCAddressPatternMatch {
        guard address.parts.indices.contains(index) else { return .different }
        let match = address.parts[index]
        switch match {
        case part: return .string
        case "*": return .wildcard
        default: return .different
        }
    }

}
