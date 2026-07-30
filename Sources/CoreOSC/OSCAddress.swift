//
//  OSCAddress.swift
//  CoreOSC
//
//  Created by Sam Smallman on 26/07/2021.
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

/// An object that represents the full path to an OSC Method in an OSC Address Space.
public struct OSCAddress: Hashable, Equatable, Sendable, Codable {

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
        // Semantics identical to the previous per-init NSPredicate regex
        // "^\\/(?:(?![ #*,?\\[\\]\\{\\}])[\\x00-\\x7F])+$": a leading "/",
        // at least one further character, all ASCII, and none of the wildcard
        // or reserved characters — validated in a single byte pass without
        // compiling a regular expression.
        let bytes = address.utf8
        guard bytes.count >= 2, bytes.first == 0x2F else {
            throw OSCAddressError.invalidAddress
        }
        for byte in bytes.dropFirst() {
            guard byte <= 0x7F else { throw OSCAddressError.invalidAddress }
            switch byte {
            case 0x20, // Space - ' '
                 0x23, // Hash - #
                 0x2A, // Asterisk - *
                 0x2C, // Comma - ,
                 0x3F, // Question Mark - ?
                 0x5B, // Open Bracket - [
                 0x5D, // Close Bracket - ]
                 0x7B, // Open Curly Brace - {
                 0x7D: // Close Curly Brace - }
                throw OSCAddressError.invalidAddress
            default:
                break
            }
        }
        self.fullPath = address
        var addressParts = address.components(separatedBy: "/")
        addressParts.removeFirst()
        self.parts = addressParts
        self.methodName = addressParts.last ?? ""
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
