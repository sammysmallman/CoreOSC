//
//  OSCAddress.swift
//  CoreOSC
//
//  Created by Sam Smallman on 26/07/2021.
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
    /// - \# - Number Sign
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
        let pattern = "^\\/(?:(?![ #*,?\\[\\]\\{\\}])[\\x00-\\x7F])+(?<!\\/)$"
        if NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: address) {
            self.fullPath = address
            var addressParts = address.components(separatedBy: "/")
            addressParts.removeFirst()
            self.parts = addressParts
            self.methodName = addressParts.last ?? ""
        } else {
            throw OSCAddressError.invalidAddress
        }
    }
}
