//
//  OSCMatch.swift
//  CoreOSC
//
//  Created by Sam Smallman on 31/07/2021.
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

/// An object that represents the result of matching an OSC Address Pattern against an OSC Address.
public struct OSCPatternMatch: Equatable {

    public enum Matching: Int {
        
        /// The pattern and address failed to match.
        case unmatched = 0
        
        /// A partial match where all OSC Address characters were matched,
        /// but there still remained OSC Address Pattern characters.
        case partialAddress
        
        /// A partial match where all OSC Address Pattern characters were matched,
        /// but there still remained OSC Address characters.
        case partialPattern
        
        /// A full match of all OSC Address Pattern and OSC Address characters.
        case fullMatch
        
    }
    
    /// The result of matching an OSC Address Pattern with an OSC Address.
    public let match: Matching
    
    /// The number of OSC Address Pattern characters successfully matched.
    public let patternCharactersMatched: Int
    
    /// The number of OSC Address characters successfully matched.
    public let addressCharactersMatched: Int
    
    /// An object that represents the result of matching an OSC Address Pattern against an OSC Address.
    /// - Parameters:
    ///   - match: The result of matching an OSC Address Pattern with an OSC Address.
    ///   - patternCharactersMatched: The number of OSC Address Pattern characters successfully matched.
    ///   - addressCharactersMatched: The number of OSC Address characters successfully matched.
    public init(match: OSCPatternMatch.Matching,
                patternCharactersMatched: Int,
                addressCharactersMatched: Int) {
        self.match = match
        self.patternCharactersMatched = patternCharactersMatched
        self.addressCharactersMatched = addressCharactersMatched
    }
}

/// A helper object for OSC Address Pattern and OSC Address matching operations.
public struct OSCMatch {
    
    /// Match an OSC Address Pattern against an OSC Address.
    /// - Parameters:
    ///   - pattern: An OSC Address Pattern.
    ///   - address: An OSC Address.
    /// - Returns: A `OSCPatchMatch` indicating whether the two given values match and to what extent.
    public static func match(pattern: String, address: String) -> OSCPatternMatch {
        
        if pattern.compare(address, options: .literal) == .orderedSame {
            return OSCPatternMatch(match: .fullMatch,
                                   patternCharactersMatched: pattern.count,
                                   addressCharactersMatched: address.count)
        }

        var patternCharacterOffset: String.Index = address.startIndex
        var addressCharacterOffset: String.Index = pattern.startIndex
        while patternCharacterOffset != pattern.endIndex &&
              addressCharacterOffset != address.endIndex {
            if pattern[patternCharacterOffset] == "*" {
                if matchAsterisk(pattern: pattern,
                                 patternCharacterOffset: &patternCharacterOffset,
                                 address: address,
                                 addressCharacterOffset: &addressCharacterOffset) == false {
                    return OSCPatternMatch(match: .unmatched,
                                           patternCharactersMatched: pattern.distance(from: pattern.startIndex,
                                                                                      to: patternCharacterOffset),
                                           addressCharactersMatched: address.distance(from: address.startIndex,
                                                                                      to: addressCharacterOffset))
                }
                while patternCharacterOffset != pattern.endIndex &&
                      pattern[patternCharacterOffset] != "/" {
                    patternCharacterOffset = pattern.index(after: patternCharacterOffset)
                }
                while addressCharacterOffset != address.endIndex &&
                      address[addressCharacterOffset] != "/" {
                    addressCharacterOffset = address.index(after: addressCharacterOffset)
                }
            } else if address[addressCharacterOffset] == "*" {
                while patternCharacterOffset != pattern.endIndex &&
                      pattern[patternCharacterOffset] != "/" {
                    patternCharacterOffset = pattern.index(after: patternCharacterOffset)
                }
                while addressCharacterOffset != address.endIndex &&
                      address[addressCharacterOffset] != "/" {
                    addressCharacterOffset = address.index(after: addressCharacterOffset)
                }
            } else {
                let match = matchCharacters(pattern: pattern,
                                            patternCharacterOffset: &patternCharacterOffset,
                                            address: address,
                                            addressCharacterOffset: &addressCharacterOffset)
                if match == false {
                    if patternCharacterOffset != pattern.endIndex &&
                       pattern.index(after: patternCharacterOffset) == pattern.endIndex &&
                       pattern[patternCharacterOffset] == "]" {
                        return OSCPatternMatch(match: .unmatched,
                                               patternCharactersMatched: pattern.distance(from: pattern.startIndex,
                                                                                          to: pattern.endIndex),
                                               addressCharactersMatched: address.distance(from: address.startIndex,
                                                                                          to: addressCharacterOffset))
                    } else {
                        return OSCPatternMatch(match: .unmatched,
                                               patternCharactersMatched: pattern.distance(from: pattern.startIndex,
                                                                                          to: patternCharacterOffset),
                                               addressCharactersMatched: address.distance(from: address.startIndex,
                                                                                          to: addressCharacterOffset))
                    }
                }
                if patternCharacterOffset != pattern.endIndex  {
                    patternCharacterOffset = pattern.index(after: patternCharacterOffset)
                }
                if addressCharacterOffset != address.endIndex {
                    addressCharacterOffset = address.index(after: addressCharacterOffset)
                }
            }
        }

        var match = OSCPatternMatch.Matching.unmatched.rawValue
        
        if addressCharacterOffset == address.endIndex {
            match |= OSCPatternMatch.Matching.partialAddress.rawValue
        }
    
        if patternCharacterOffset == pattern.endIndex {
            match |= OSCPatternMatch.Matching.partialPattern.rawValue
        }

        guard let matching = OSCPatternMatch.Matching(rawValue: match) else {
            // It shouldn't be possible to get to here but just incase...
            return OSCPatternMatch(match: .unmatched,
                                   patternCharactersMatched: 0,
                                   addressCharactersMatched: 0)
        }
        
        return OSCPatternMatch(match: matching,
                               patternCharactersMatched:
                                pattern.distance(from: pattern.startIndex,
                                                 to: patternCharacterOffset),
                               addressCharactersMatched:
                                matching == .fullMatch ?
                                address.count :
                                address.distance(from: address.startIndex,
                                                 to: addressCharacterOffset))
    }
    
    /// Matches characters from the given offsets onwards using the asterisk wildcard.
    /// - Parameters:
    ///   - pattern: An OSC Address Pattern.
    ///   - patternCharacterOffset: A `String.Index` of the first character in the OSC Address Pattern to begin matching from.
    ///   - address: An OSC Address.
    ///   - addressCharacterOffset: A `String.Index` of the first character in the OSC Address to begin matching from.
    /// - Returns: A Boolean value indicating whether the pattern from the given offset matches using an asterisk wildcard up to the next forward slash, or end of string.
    private static func matchAsterisk(pattern: String,
                                      patternCharacterOffset: inout String.Index,
                                      address: String,
                                      addressCharacterOffset: inout String.Index) -> Bool {
        var numberOfAsterisks = 0
        if addressCharacterOffset == address.endIndex { return false }
        while addressCharacterOffset != address.endIndex &&
              address[addressCharacterOffset] != "/" {
            addressCharacterOffset = address.index(after: addressCharacterOffset)
        }
        while patternCharacterOffset != pattern.endIndex &&
              pattern[patternCharacterOffset] != "/" {
            if pattern[patternCharacterOffset] == "*" {
                numberOfAsterisks += 1
            }
            patternCharacterOffset = pattern.index(after: patternCharacterOffset)
        }

        patternCharacterOffset = pattern.index(before: patternCharacterOffset)
        addressCharacterOffset = address.index(before: addressCharacterOffset)
        switch numberOfAsterisks {
        case 1:
            var casePatternCharacterOffset: String.Index = patternCharacterOffset
            var caseAddressCharacterOffsetStart: String.Index = addressCharacterOffset
            while pattern[casePatternCharacterOffset] != "*" {
                if matchCharacters(pattern: pattern,
                                   patternCharacterOffset: &casePatternCharacterOffset,
                                   address: address,
                                   addressCharacterOffset: &caseAddressCharacterOffsetStart) == false {
                    return false
                }
            }
            break
        default: return false
        }
        return true
    }
    
    /// Matches characters from the given offsets onwards.
    /// - Parameters:
    ///   - pattern: An OSC Address Pattern.
    ///   - patternCharacterOffset: A `String.Index` of the first character in the OSC Address Pattern to begin matching from.
    ///   - address: An OSC Address.
    ///   - addressCharacterOffset: A `String.Index` of the first character in the OSC Address to begin matching from.
    /// - Returns: A Boolean value indicating whether the pattern from the given offset matches against the given OSC Address from the given offset.
    private static func matchCharacters(pattern: String,
                                        patternCharacterOffset: inout String.Index,
                                        address: String,
                                        addressCharacterOffset: inout String.Index) -> Bool {
        switch pattern[patternCharacterOffset] {
        case "[":
            return matchSquareBracket(pattern: pattern,
                                      patternCharacterOffset: &patternCharacterOffset,
                                      address: address,
                                      addressCharacterOffset: &addressCharacterOffset)
        case "{":
            return matchCurlyBrace(pattern: pattern,
                                   patternCharacterOffset: &patternCharacterOffset,
                                   address: address,
                                   addressCharacterOffset: &addressCharacterOffset)
        case "?": return true
        default:
            return pattern[patternCharacterOffset] == address[addressCharacterOffset]
        }
    }
    
    /// Matches characters from the given offsets onwards using the square brackets wildcards.
    /// - Parameters:
    ///   - pattern: An OSC Address Pattern.
    ///   - patternCharacterOffset: A `String.Index` of the first character in the OSC Address Pattern to begin matching from.
    ///   - address: An OSC Address.
    ///   - addressCharacterOffset: A `String.Index` of the first character in the OSC Address to begin matching from.
    /// - Returns: A Boolean value indicating whether the pattern from the given offset matches against the given OSC Address from the given offset.
    private static func matchSquareBracket(pattern: String,
                                           patternCharacterOffset: inout String.Index,
                                           address: String,
                                           addressCharacterOffset: inout String.Index) -> Bool {
        patternCharacterOffset = pattern.index(after: patternCharacterOffset)
        var val: Bool = true
        if pattern[patternCharacterOffset] == "!" {
            patternCharacterOffset = pattern.index(after: patternCharacterOffset)
            val = false
        }
        var matched: Bool = !val
        while patternCharacterOffset != pattern.endIndex &&
              pattern[patternCharacterOffset] != "]" {
            if pattern[pattern.index(after: patternCharacterOffset)] == "-" {
                if address[addressCharacterOffset].asciiValue! >= pattern[patternCharacterOffset].asciiValue! &&
                   address[addressCharacterOffset].asciiValue! <= pattern[pattern.index(patternCharacterOffset,
                                                                                        offsetBy: 2)].asciiValue! {
                    matched = val
                    while patternCharacterOffset != pattern.endIndex &&
                          pattern[patternCharacterOffset] != "]" {
                        patternCharacterOffset = pattern.index(after: patternCharacterOffset)
                    }
                    break
                } else {
                    patternCharacterOffset = pattern.index(patternCharacterOffset, offsetBy: 3)
                }
            } else {
                if pattern[patternCharacterOffset] == address[addressCharacterOffset] {
                    matched = val
                    while patternCharacterOffset != pattern.endIndex &&
                          pattern[patternCharacterOffset] != "]" {
                        patternCharacterOffset = pattern.index(after: patternCharacterOffset)
                    }
                    break
                }
                patternCharacterOffset = pattern.index(after: patternCharacterOffset)
            }
        }
        return matched
    }
    
    /// Matches characters from the given offsets onwards using the curly braces wildcards.
    /// - Parameters:
    ///   - pattern: An OSC Address Pattern.
    ///   - patternCharacterOffset: A `String.Index` of the first character in the OSC Address Pattern to begin matching from.
    ///   - address: An OSC Address.
    ///   - addressCharacterOffset: A `String.Index` of the first character in the OSC Address to begin matching from.
    /// - Returns: A Boolean value indicating whether the pattern from the given offset matches against the given OSC Address from the given offset.
    private static func matchCurlyBrace(pattern: String,
                                        patternCharacterOffset: inout String.Index,
                                        address: String,
                                        addressCharacterOffset: inout String.Index) -> Bool {
        let startIndex = patternCharacterOffset
        patternCharacterOffset = pattern.index(after: patternCharacterOffset)
        var offset = patternCharacterOffset
        while offset != pattern.endIndex &&
              pattern[offset] != "}" &&
              pattern[offset] != "/" {
            while offset != pattern.endIndex &&
                  pattern[offset] != "}" &&
                  pattern[offset] != "/" &&
                  pattern[offset] != "," {
                offset = pattern.index(after: offset)
            }
            let distance = pattern.distance(from: patternCharacterOffset, to: offset)
            let subPattern = pattern[patternCharacterOffset..<pattern.index(patternCharacterOffset, offsetBy: distance)]
            let subAddress = address[addressCharacterOffset..<address.index(addressCharacterOffset, offsetBy: distance)]
            if subPattern == subAddress {
                while offset != pattern.endIndex &&
                      pattern[offset] != "}" &&
                      pattern[offset] != "/" {
                    offset = pattern.index(after: offset)
                }
                patternCharacterOffset = offset
                addressCharacterOffset = address.index(addressCharacterOffset, offsetBy: distance - 1)
                return true
            } else {
                offset = pattern.index(after: offset)
                patternCharacterOffset = offset
            }
        }
        patternCharacterOffset = startIndex
        return false
    }
}
