//
//  OSCRefractingAddress.swift
//  CoreOSC
//
//  Created by Sam Smallman on 29/07/2021.
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
    
    public func refract(address: OSCAddress) throws -> OSCAddress {
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
            return try OSCAddress(addressPattern)
        } else {
            return try OSCAddress(fullPath)
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
