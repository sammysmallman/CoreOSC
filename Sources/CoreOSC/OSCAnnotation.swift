//
//  OSCAnnotation.swift
//  CoreOSC
//
//  Created by Sam Smallman on 22/07/2021.
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

/// A human readable/writable representation of an OSC Packet.
public struct OSCAnnotation {

    /// An OSC annotation style.
    public enum OSCAnnotationStyle {
        /// Equals/Comma Seperated Arguments: /an/address/pattern=1,3.142,"A string argument with spaces",aStringArgumentWithoutSpace
        case equalsComma
        /// Spaces Seperated Arguments: /an/address/pattern 1 3.142 "A string argument with spaces" aStringArgumentWithoutSpace
        case spaces

        /// The regular expression for the `OSCAnnotationStyle`.
        var regex: String {
            switch self {
            case .equalsComma:
                return "^(\\/[^ \\#*,?\\[\\]{}=]+)((?:=\"[^\"]+\")|(?:=[^\\s\",]+)){0,1}((?:(?:,\"[^\"]+\")|(?:,[^\\s\"=,]+))*)"
            case .spaces:
                return "^(\\/(?:[^ \\#*,?\\[\\]{}]+))((?:(?: \"[^\"]+\")|(?: (?:[^\\s\"])+))*)"
            }
        }

        /// The character that seperates the OSCArguments in the OSC annotation.
        var separator: String {
            switch self {
            case .equalsComma: return ","
            case .spaces: return " "
            }
        }
    }

    /// Evaluate an OSC annotation.
    /// - Parameters:
    ///     - annotation: A `String` to be validated.
    ///     - style: The `OSCAnnotationStyle` of the given `String` annotation.
    /// - Returns: A boolean value indicating whether any the given string is a valid OSC annotation.
    public static func evaluate(_ annotation: String,
                                style: OSCAnnotationStyle = .spaces) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", style.regex).evaluate(with: annotation)
    }
    
    /// Returns an `OSCMessage` from a valid OSC annotation.
    /// - Parameters:
    ///   - annotation: A `String` OSC annotation to be converted.
    ///   - style: The `OSCAnnotationStyle` of the given `String` annotation.
    /// - Returns: An `OSCMessage`or nil if the given OSC annotation was invalid.
    public static func message(for annotation: String,
                               style: OSCAnnotationStyle = .spaces) -> OSCMessage? {
        switch style {
        case .equalsComma:
            return equalsCommaMessage(for: annotation)
        case .spaces:
            return spacesMessage(for: annotation)
        }
    }
    
    /// Returns an `OSCMessage` from a valid OSC equals/comma style annotation.
    /// - Parameter annotation: A `String` OSC annotation to be converted.
    /// - Returns: An `OSCMessage`or nil if the given OSC annotation was invalid.
    private static func equalsCommaMessage(for annotation: String) -> OSCMessage? {
        do {
            let matches = try NSRegularExpression(pattern: OSCAnnotationStyle.equalsComma.regex)
                .matches(in: annotation,
                         range: annotation.nsrange)
            // There should only be one match. Range at index 1 will always be the address pattern.
            // If there are arguments these will be found at index 2,
            // prefaced with "=" and index 3 if there are more than one argument.
            var arguments: [OSCArgumentProtocol] = []
            guard let match = matches.first, match.range == annotation.nsrange,
                  let address = annotation.substring(with: match.range(at: 1)) else { return nil }
            if var argumentString = annotation.substring(with: match.range(at: 2)) {
                // remove the "="
                argumentString.removeFirst()
                if let moreArguments = annotation.substring(with: match.range(at: 3)) {
                    argumentString += moreArguments
                }
                let argumentComponents = argumentString.components(separatedBy: ",")
                for argument in argumentComponents {
                    if let decimal = Decimal(string: argument) {
                        if decimal.isZero || (decimal.isNormal && decimal.exponent >= 0),
                           let int = Int32(argument) {
                            arguments.append(int)
                        } else if let float = Float32(argument) {
                            arguments.append(float)
                        }
                    } else {
                        switch argument {
                        case "true":
                            arguments.append(true)
                        case "false":
                            arguments.append(false)
                        case "nil":
                            arguments.append(OSCArgument.nil)
                        case "impulse":
                            arguments.append(OSCArgument.impulse)
                        default:
                            // If the argument is prefaced with quotation marks,
                            // the regex dictates the argument should close with them.
                            // Remove the quotation marks.
                            if argument.first == "\"" {
                                var quoationMarkArgument = argument
                                quoationMarkArgument.removeFirst()
                                quoationMarkArgument.removeLast()
                                arguments.append(quoationMarkArgument)
                            } else {
                                arguments.append(argument)
                            }
                        }

                    }
                }
            }
            return try? OSCMessage(with: String(address), arguments: arguments)
        } catch {
            return nil
        }
    }
    
    /// Returns an `OSCMessage` from a valid OSC spaces style annotation.
    /// - Parameter annotation: A `String` OSC annotation to be converted.
    /// - Returns: An `OSCMessage`or nil if the given OSC annotation was invalid.
    private static func spacesMessage(for annotation: String) -> OSCMessage? {
        do {
            let matches = try NSRegularExpression(pattern: OSCAnnotationStyle.spaces.regex)
                .matches(in: annotation,
                         range: annotation.nsrange)
            // There should only be one match. Range at index 1 will always be the address pattern.
            // Range at index 2 will be the argument string prefaced with " "
            var arguments: [OSCArgumentProtocol] = []
            guard let match = matches.first, match.range == annotation.nsrange,
                  let address = annotation.substring(with: match.range(at: 1)),
                  let argumentString = annotation.substring(with: match.range(at: 2)) else {
                return nil
            }
            let components = argumentString.components(separatedBy: "\"")
            var argumentsArray: [String] = []
            for (index, component) in components.enumerated() {
                if index % 2 != 0 {
                    argumentsArray.append(component)
                } else {
                    let arguments = component.split(separator: " ",
                                                    omittingEmptySubsequences: true)
                    for element in arguments {
                        argumentsArray.append(String(element))
                    }
                }
            }
            for argument in argumentsArray {
                if let decimal = Decimal(string: argument) {
                    if decimal.isZero || (decimal.isNormal && decimal.exponent >= 0), let int = Int32(argument) {
                        arguments.append(int)
                    } else if let float = Float32(argument) {
                        arguments.append(float)
                    }
                } else {
                    switch argument {
                    case "true":
                        arguments.append(true)
                    case "false":
                        arguments.append(false)
                    case "nil":
                        arguments.append(OSCArgument.nil)
                    case "impulse":
                        arguments.append(OSCArgument.impulse)
                    default:
                        // If the argument is prefaced with quotation marks,
                        // the regex dictates the argument should close with them.
                        // Remove the quotation marks.
                        if argument.first == "\"" {
                            var quoationMarkArgument = argument
                            quoationMarkArgument.removeFirst()
                            quoationMarkArgument.removeLast()
                            arguments.append(quoationMarkArgument)
                        } else {
                            arguments.append(argument)
                        }
                    }
                }
            }
            return try? OSCMessage(with: String(address), arguments: arguments)
        } catch {
            return nil
        }
    }
    
    /// Returns an annotation of the given `OSCMessage`.
    /// - Parameters:
    ///   - message: an `OSCMessage` to be annotated.
    ///   - style: The `OSCAnnotationStyle` the annotation should take.
    ///   - type: Whether the annotation should include type tag flags in the annotation or not.
    /// - Returns: An OSC annotation.
    public static func annotation(for message: OSCMessage, style: OSCAnnotationStyle = .spaces, type: Bool = true) -> String {
        var string = message.addressPattern.fullPath
        if message.arguments.isEmpty == false {
            switch style {
            case .equalsComma:
                string += "="
                string += message.arguments
                    .map { $0.oscAnnotation(withType: type) }
                    .joined(separator: style.separator)
            case .spaces:
                string += style.separator
                string += message.arguments
                    .map { $0.oscAnnotation(withType: type) }
                    .joined(separator: style.separator)
            }
        }
        return string
    }

}
