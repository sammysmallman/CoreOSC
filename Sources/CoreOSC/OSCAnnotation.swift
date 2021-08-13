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

public class OSCAnnotation {

    public enum OSCAnnotationStyle {
        // Equals/Comma Seperated Arguments: /an/address/pattern=1,3.142,"A string argument with spaces",String
        case equalsComma
        // Spaces Seperated Arguments: /an/address/pattern 1 3.142 "A string argument with spaces" String
        case spaces

        var regex: String {
            switch self {
            case .equalsComma:
                return "^(\\/[^ \\#*,?\\[\\]{}=]+)((?:=\"[^\"]+\")|(?:=[^\\s\",]+)){0,1}((?:(?:,\"[^\"]+\")|(?:,[^\\s\"=,]+))*)"
            case .spaces:
                return "^(\\/(?:[^ \\#*,?\\[\\]{}]+))((?:(?: \"[^\"]+\")|(?: (?:[^\\s\"])+))*)"
            }
        }

        var separator: String {
            switch self {
            case .equalsComma: return ","
            case .spaces: return " "
            }
        }
    }

    public static func isValid(annotation: String, with style: OSCAnnotationStyle = .spaces) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", style.regex).evaluate(with: annotation)
    }

    public static func message(for annotation: String,
                               with style: OSCAnnotationStyle = .spaces) -> OSCMessage? {
        switch style {
        case .equalsComma:
            return equalsCommaMessage(for: annotation)
        case .spaces:
            do {
                let matches = try NSRegularExpression(pattern: style.regex)
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
                return try? OSCMessage(String(address), arguments: arguments)
            } catch {
                return nil
            }
        }
    }

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
            return try? OSCMessage(String(address), arguments: arguments)
        } catch {
            return nil
        }
    }

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

    private func isNumeric(character: Character) -> Bool {
        return Double("\(character)") != nil
    }

    private func isNumeric(string: String) -> Bool {
        return Double(string) != nil
    }

}
