//
//  OSCRefractingAddress.swift
//  CoreOSC
//
//  Created by Sam Smallman on 29/07/2021.
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

/// An object that represents an OSC Address Pattern to be refracted.
public struct OSCRefractingAddress: Hashable, Equatable {

    /// The full path to an OSC Method, including the refracting wildcard.
    public let fullPath: String

    /// The names of all the containers, in order, along the path from the root of the tree to the OSC Method, including the refracting wildcard.
    public let parts: [String]

    /// The name of the OSC Method the address is pointing to, including the refracting wildcard.
    public let methodName: String

    /// An OSC Refracting Address.
    ///
    /// An OSC Refracting Address begins with the character ‘/’ followed by the symbolic ASCII names of all the containers,
    /// in order, along the path from the root of the tree to the OSC Method, separated by forward slash characters,
    /// followed by the name of the OSC Method.
    ///
    /// Printable ASCII characters not allowed in names of OSC Methods or OSC Containers:
    /// - ' ' - Space
    ///
    /// Refracting allows for an OSC Address Patterns parts to be modified.
    /// e.g. The refracting address "/osc/#1/theory" would refract the address pattern
    /// "/core/osc/test" into "/osc/core/theory".
    ///
    /// The number after each hash e.g. "#1" within the refracting address denotes which part (not 0 indexed)
    /// to take from the given OSC Address Pattern.
    /// 
    /// - Parameter refractingAddress: The full path to an OSC Method.
    /// - Throws: `OSCAddressError` if the format of the given address is invalid.
    public init(_ refractingAddress: String) throws {
        let regex = "^\\/(?:(?:(?![ #])[\\x00-\\x7F])+|(?:(?<=\\/)#\\d?[1-9]|[1-9]0)(?=\\/|$))+$"
        if NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: refractingAddress) {
            self.fullPath = refractingAddress
            var addressParts = refractingAddress.components(separatedBy: "/")
            addressParts.removeFirst()
            self.parts = addressParts
            self.methodName = addressParts.last ?? ""
        } else {
            throw OSCAddressError.invalidAddress
        }
    }
    
    /// Refract an OSC Address.
    /// - Parameter address: An OSC Address to be refracted.
    /// - Throws: A `OSCAddressError` if the given address can not be refracted.
    /// - Returns: A new OSC Address that has been refracted.
    ///
    /// Refracting allows for an OSC Address Patterns parts to be modified.
    /// e.g. The refracting address "/osc/#1/theory" would refract the address pattern
    /// "/core/osc/test" into "/osc/core/theory".
    ///
    /// The number after each hash e.g. "#1" within the refracting address denotes which part (not 0 indexed)
    /// to take from the given OSC Address Pattern.
    public func refract(address: OSCAddressPattern) throws -> OSCAddressPattern {
        if parts.contains(where: { $0.hasPrefix("#") }) {
            var addressPattern = ""
            try parts.forEach { part in
                if part.hasPrefix("#") {
                    guard let number = Int(part.dropFirst()) else {
                        throw OSCAddressError.invalidAddress
                    }
                    guard number <= address.parts.count else {
                        throw OSCAddressError.invalidPartCount
                    }
                    addressPattern += "/\(address.parts[number - 1])"
                } else {
                    addressPattern += "/\(part)"
                }
            }
            return try OSCAddressPattern(addressPattern)
        } else {
            return try OSCAddressPattern(fullPath)
        }
    }
    
    /// Evaluate an OSC Refracting Address.
    /// - Parameter address: A `String` to be validated.
    /// - Returns: A `Result` that represents either the given string is valid, returning success,
    ///            or that the given string is invalid returning a failure containing the `OSCAddressError`.
    public static func evaluate(with address: String) -> Result<String, OSCAddressError> {
        guard address.hasPrefix("/") else { return .failure(.forwardSlash) }
        for character in address {
            guard character.isASCII == true else { return .failure(.ascii) }
            guard character != " " else { return .failure(.space) }
        }
        return .success(address)
    }
}
