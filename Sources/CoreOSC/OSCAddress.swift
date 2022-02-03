//
//  OSCAddress.swift
//  CoreOSC
//
//  Created by Sam Smallman on 26/07/2021.
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

/// An object that represents the full path to an OSC Method in an OSC Address Space.
public struct OSCAddress: Hashable, Equatable {

    /// The full path to an OSC Method.
    public let fullPath: String

    /// The names of all the containers, in order, along the path from the root of the tree to the OSC Method.
    public let parts: [String]

    /// The name of the OSC Method the address is pointing to.
    public let methodName: String

    /// An OSC Address.
    ///
    /// An OSC Address begins with the character ‘/’ followed by the symbolic ASCII names of all the containers,
    /// in order, along the path from the root of the tree to the OSC Method, separated by forward slash characters,
    /// followed by the name of the OSC Method.
    ///
    /// Printable ASCII characters not allowed in names of OSC Methods or OSC Containers:
    /// - ' ' - Space
    /// - \# - Hash
    /// - \* - Asterisk
    /// - ,  - Comma
    /// - /  - Forward Slash
    /// - ? - Question Mark
    /// - [ - Open Bracket
    /// - ] - Close Bracket
    /// - { - Open Curly Brace
    /// - } - Close Curly Brace
    /// 
    /// - Parameter address: The full path to an OSC Method.
    /// - Throws: `OSCAddressError` if the format of the given address is invalid.
    public init(_ address: String) throws {
        let regex = "^\\/(?:(?![ #*,?\\[\\]\\{\\}])[\\x00-\\x7F])+$"
        if NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: address) {
            self.fullPath = address
            var addressParts = address.components(separatedBy: "/")
            addressParts.removeFirst()
            self.parts = addressParts
            self.methodName = addressParts.last ?? ""
        } else {
            throw OSCAddressError.invalidAddress
        }
    }
    
    /// Evaluate an OSC Address.
    /// - Parameter address: A `String` to be validated.
    /// - Returns: A `Result` that represents either the given string is valid, returning success,
    ///            or that the given string is invalid returning a failure containing the `OSCAddressError`.
    public static func evaluate(with address: String) -> Result<String, OSCAddressError> {
        guard address.hasPrefix("/") else { return .failure(.forwardSlash) }
        for character in address {
            guard character.isASCII == true else { return .failure(.ascii) }
            guard character != " " else { return .failure(.space) }
            guard character != "#" else { return .failure(.hash) }
            guard character != "*" else { return .failure(.asterisk) }
            guard character != "," else { return .failure(.comma) }
            guard character != "?" else { return .failure(.questionMark) }
            guard character != "[" else { return .failure(.openBracket) }
            guard character != "]" else { return .failure(.closeBracket) }
            guard character != "{" else { return .failure(.openCurlyBrace) }
            guard character != "}" else { return .failure(.closeCurlyBrace) }
        }
        return .success(address)
    }
    
}
