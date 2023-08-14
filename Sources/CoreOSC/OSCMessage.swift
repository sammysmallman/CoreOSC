//
//  OSCMessage.swift
//  CoreOSC
//
//  Created by Sam Smallman on 22/07/2021.
//  Copyright © 2022 Sam Smallman. https://github.com/SammySmallman
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

/// An OSC Message.
public struct OSCMessage: OSCPacket, Equatable {

    public static func == (lhs: OSCMessage, rhs: OSCMessage) -> Bool {
        lhs.addressPattern == rhs.addressPattern &&
        lhs.typeTagString == rhs.typeTagString &&
        lhs.arguments.map { $0.oscData } == rhs.arguments.map { $0.oscData }
    }

    /// The OSC Address Pattern associated with the message that represents the full path to one
    /// or more OSC Methods through pattern matching.
    public private(set) var addressPattern: OSCAddressPattern
    
    /// A sequence of type tag characters corresponding exactly to the sequence of OSC Arguments in the message.
    public var typeTagString: String { "\(arguments.map { String($0.oscTypeTag) }.joined())" }
    
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
    public init(with addressPattern: String, arguments: [OSCArgumentProtocol] = []) throws {
        let fullPath = try OSCAddressPattern(addressPattern)
        self.init(with: fullPath, arguments: arguments)
    }

    /// An OSC Message.
    /// - Parameters:
    ///   - addressPattern: The messages OSC Address Pattern.
    ///   - arguments: The messages `Array` of arguments.
    public init(with addressPattern: OSCAddressPattern, arguments: [OSCArgumentProtocol] = []) {
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

    /// The OSC Packet data for the message.
    public func data() -> Data {
        var result = addressPattern.fullPath.oscData
        result.append(",\(typeTagString)".oscData)
        arguments.forEach { result.append($0.oscData) }
        return result
    }
    
    /// Pattern match the message against an OSC Address.
    /// - Parameter address: An OSC Address to be matched against.
    /// - Returns: A `Result` that represents either the given address matches, returning success,
    ///            or that the given address is invalid returning a failure containing the `OSCAddressError`.
    public func matches(address: OSCAddress) -> Result<OSCAddress, OSCAddressError> {
        guard addressPattern.parts.count == address.parts.count else {
            return .failure(.invalidPartCount)
        }
        if OSCMatch.match(addressPattern: addressPattern.fullPath,
                          address: address.fullPath).match == .fullMatch {
            return .success(address)
        } else {
            return .failure(.invalidAddress)
        }
    }

}
