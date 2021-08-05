//
//  OSCMessage.swift
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

/// An OSC Message.
public struct OSCMessage: OSCPacket {
    
    /// The OSC Address Pattern associated with the message that represents the full path to one
    /// or more OSC Methods through pattern matching.
    public private(set) var addressPattern: OSCAddressPattern
    
    /// A sequence of type tag characters corresponding exactly to the sequence of OSC Arguments in the message.
    var typeTagString: String { ",\(arguments.map { String($0.oscTypeTag) }.joined())" }
    
    /// The `Array` of arguments associated with the message.
    public let arguments: [OSCArgumentProtocol]
    
    /// An OSC Message from a raw OSC Address Pattern.
    /// - Parameters:
    ///   - addressPattern: The message's OSC Address Pattern.
    ///   - arguments: The message's `Array` of arguments.
    internal init(raw addressPattern: String, arguments: [OSCArgumentProtocol] = []) {
        let fullPath = OSCAddressPattern(raw: addressPattern)
        self.addressPattern = fullPath
        self.arguments = arguments
    }
    
    /// An OSC Message.
    /// - Parameters:
    ///   - addressPattern: The messages OSC Address Pattern.
    ///   - arguments: The messages `Array` of arguments.
    /// - Throws: An `OSCAddressError` if the given `addressPattern` can not be initialized as a `OSCAddressPattern`.
    public init(_ addressPattern: String, arguments: [OSCArgumentProtocol] = []) throws {
        let fullPath = try OSCAddressPattern(addressPattern)
        self.init(fullPath, arguments: arguments)
    }

    /// An OSC Message.
    /// - Parameters:
    ///   - addressPattern: The messages OSC Address Pattern.
    ///   - arguments: The messages `Array` of arguments.
    public init(_ addressPattern: OSCAddressPattern, arguments: [OSCArgumentProtocol] = []) {
        self.addressPattern = addressPattern
        self.arguments = arguments
    }
    
    /// Readdress the message to a new OSC Address Pattern.
    /// - Parameter addressPattern: The new OSC Address Pattern.
    /// - Throws: An `OSCAddressError` if the given `addressPattern` can not be initialized as a `OSCAddressPattern`.
    public mutating func readdress(to addressPattern: String) throws {
        let fullPath = try OSCAddressPattern(addressPattern)
        self.addressPattern = fullPath
    }

    /// Readdress the message to a new OSC Address Pattern.
    /// - Parameter addressPattern: The new OSC Address Pattern.
    public mutating func readdress(to addressPattern: OSCAddressPattern) {
        self.addressPattern = addressPattern
    }

    /// The messages OSC Packet data.
    public func data() -> Data {
        var result = addressPattern.fullPath.oscData
        result.append(typeTagString.oscData)
        arguments.forEach { result.append($0.oscData) }
        return result
    }
    
    /// Pattern match the message against an OSC Address.
    /// - Parameter address: An OSC Address to be matched against.
    /// - Returns: A boolean value that indicates whether the given OSC Address matches against the message or not.
    func matches(address: OSCAddress) -> Bool {
        guard addressPattern.parts.count == address.parts.count else {
            return false
        }
        return OSCMatch.match(pattern: addressPattern.fullPath,
                              address: address.fullPath)
            .match == .fullMatch
    }

}
