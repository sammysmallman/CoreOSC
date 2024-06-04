//
//  OSCFilterAddress.swift
//  CoreOSC
//
//  Created by Sam Smallman on 13/08/2021.
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

/// An object that represents an OSC Address Pattern to be filtered.
public struct OSCFilterAddress: Hashable, Equatable {

    /// The full path to an OSC Method, including the filter wildcard.
    public let fullPath: String

    /// The names of all the containers, in order, along the path from the root of the tree to the OSC Method, including the filter wildcard.
    public let parts: [String]

    /// The name of the OSC Method the address is pointing to, including the filter wildcard.
    public let methodName: String

    /// An OSC Filter Address.
    ///
    /// An OSC Filter Address begins with the character ‘/’ followed by the symbolic ASCII names of all the containers,
    /// in order, along the path from the root of the tree to the OSC Method, separated by forward slash characters,
    /// followed by the name of the OSC Method.
    ///
    /// Printable ASCII characters not allowed in names of OSC Methods or OSC Containers:
    /// - ' ' - Space
    ///
    /// Filtering allows for multiple OSC Address Patterns to invoke a single method when they match against an OSC Filter Address.
    /// An OSC Filter Address uses the "#" wildcard to omit certain parts from the match. Instead of building an OSC Address Space that
    /// contains all the varies OSC Addresses, an OSC Address Filter can be used to capture multiple OSC Address Patterns
    /// using a single OSC Filter Address.
    ///
    /// For example, the filter address "/core/osc/#" would invoke a method when receiving the following address patterns (not complete list):
    /// - "/core/osc/1"
    /// - "/core/osc/2"
    /// - "/core/osc/3"
    ///
    /// - Parameter filterAddress: The full path to an OSC Filter Method.
    /// - Throws: `OSCAddressError` if the format of the given address is invalid.
    public init(_ filterAddress: String) throws {
        let regex = "^\\/(?:(?:(?![ #])[\\x00-\\x7F])+|(?:(?<=\\/)#)(?=\\/|$))+$"
        if NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: filterAddress) {
            self.fullPath = filterAddress
            var addressParts = filterAddress.components(separatedBy: "/")
            addressParts.removeFirst()
            self.parts = addressParts
            self.methodName = addressParts.last ?? ""
        } else {
            throw OSCAddressError.invalidAddress
        }
    }
    
    /// Evaluate an OSC Filter Address.
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
