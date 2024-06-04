//
//  OSCMatch.swift
//  CoreOSC
//
//  Created by Sam Smallman on 31/07/2021.
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

/// A helper object for OSC Address Pattern and OSC Address matching operations.
public enum OSCMatch {
    
    /// Match an OSC Address Pattern against an OSC Address.
    /// - Parameters:
    ///   - addressPattern: An OSC Address Pattern.
    ///   - address: An OSC Address.
    /// - Returns: A `OSCPatchMatch` indicating whether the two given values match and to what extent.
    public static func match(addressPattern: String, address: String) -> OSCPatternMatch {
        
        if addressPattern.compare(address, options: .literal) == .orderedSame {
            return OSCPatternMatch(match: .fullMatch,
                                   patternCharactersMatched: addressPattern.count,
                                   addressCharactersMatched: address.count)
        }

        var patternCharacterOffset: String.Index = address.startIndex
        var addressCharacterOffset: String.Index = addressPattern.startIndex
        while patternCharacterOffset != addressPattern.endIndex &&
              addressCharacterOffset != address.endIndex {
            if addressPattern[patternCharacterOffset] == "*" {
                if matchAsterisk(pattern: addressPattern,
                                 patternCharacterOffset: &patternCharacterOffset,
                                 address: address,
                                 addressCharacterOffset: &addressCharacterOffset) == false {
                    return OSCPatternMatch(match: .unmatched,
                                           patternCharactersMatched: addressPattern.distance(from: addressPattern.startIndex,
                                                                                             to: patternCharacterOffset),
                                           addressCharactersMatched: address.distance(from: address.startIndex,
                                                                                      to: addressCharacterOffset))
                }
                while patternCharacterOffset != addressPattern.endIndex &&
                      addressPattern[patternCharacterOffset] != "/" {
                    patternCharacterOffset = addressPattern.index(after: patternCharacterOffset)
                }
                while addressCharacterOffset != address.endIndex &&
                      address[addressCharacterOffset] != "/" {
                    addressCharacterOffset = address.index(after: addressCharacterOffset)
                }
            } else if address[addressCharacterOffset] == "*" {
                while patternCharacterOffset != addressPattern.endIndex &&
                      addressPattern[patternCharacterOffset] != "/" {
                    patternCharacterOffset = addressPattern.index(after: patternCharacterOffset)
                }
                while addressCharacterOffset != address.endIndex &&
                      address[addressCharacterOffset] != "/" {
                    addressCharacterOffset = address.index(after: addressCharacterOffset)
                }
            } else {
                let match = matchCharacters(pattern: addressPattern,
                                            patternCharacterOffset: &patternCharacterOffset,
                                            address: address,
                                            addressCharacterOffset: &addressCharacterOffset)
                if match == false {
                    if patternCharacterOffset != addressPattern.endIndex &&
                        addressPattern.index(after: patternCharacterOffset) == addressPattern.endIndex &&
                        addressPattern[patternCharacterOffset] == "]" {
                        return OSCPatternMatch(match: .unmatched,
                                               patternCharactersMatched: addressPattern.distance(from: addressPattern.startIndex,
                                                                                                 to: addressPattern.endIndex),
                                               addressCharactersMatched: address.distance(from: address.startIndex,
                                                                                          to: addressCharacterOffset))
                    } else {
                        return OSCPatternMatch(match: .unmatched,
                                               patternCharactersMatched: addressPattern.distance(from: addressPattern.startIndex,
                                                                                                 to: patternCharacterOffset),
                                               addressCharactersMatched: address.distance(from: address.startIndex,
                                                                                          to: addressCharacterOffset))
                    }
                }
                if patternCharacterOffset != addressPattern.endIndex  {
                    patternCharacterOffset = addressPattern.index(after: patternCharacterOffset)
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
    
        if patternCharacterOffset == addressPattern.endIndex {
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
                                addressPattern.distance(from: addressPattern.startIndex,
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
    /// - Returns: A boolean value indicating whether the pattern from the given offset matches using an asterisk wildcard up to the next forward slash, or end of string.
    private static func matchAsterisk(pattern: String,
                                      patternCharacterOffset: inout String.Index,
                                      address: String,
                                      addressCharacterOffset: inout String.Index) -> Bool {
        if addressCharacterOffset == address.endIndex { return false }
        // Move address index up to next "/"
        while addressCharacterOffset != address.endIndex &&
              address[addressCharacterOffset] != "/" {
            addressCharacterOffset = address.index(after: addressCharacterOffset)
        }
        // Move pattern index up to next "/"
        while patternCharacterOffset != pattern.endIndex &&
              pattern[patternCharacterOffset] != "/" {
            patternCharacterOffset = pattern.index(after: patternCharacterOffset)
        }

        // TODO: Match patterns backwards if the last character before the "/" is not a "*"
        return true
    }
    
    /// Matches characters from the given offsets onwards.
    /// - Parameters:
    ///   - pattern: An OSC Address Pattern.
    ///   - patternCharacterOffset: A `String.Index` of the first character in the OSC Address Pattern to begin matching from.
    ///   - address: An OSC Address.
    ///   - addressCharacterOffset: A `String.Index` of the first character in the OSC Address to begin matching from.
    /// - Returns: A boolean value indicating whether the pattern from the given offset matches against the given OSC Address from the given offset.
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
    /// - Returns: A boolean value indicating whether the pattern from the given offset matches against the given OSC Address from the given offset.
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
                if address[addressCharacterOffset].asciiValue! >= pattern[patternCharacterOffset].asciiValue!,
                   let index = pattern.index(patternCharacterOffset, offsetBy: 2, limitedBy: pattern.index(before: pattern.endIndex)),
                   address[addressCharacterOffset].asciiValue! <= pattern[index].asciiValue! {
                    matched = val
                    while patternCharacterOffset != pattern.endIndex &&
                          pattern[patternCharacterOffset] != "]" {
                        patternCharacterOffset = pattern.index(after: patternCharacterOffset)
                    }
                    break
                } else if let index = pattern.index(patternCharacterOffset, offsetBy: 3, limitedBy: pattern.index(before: pattern.endIndex)) {
                    patternCharacterOffset = index
                } else {
                    return false
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
    /// - Returns: A boolean value indicating whether the pattern from the given offset matches against the given OSC Address from the given offset.
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
                if pattern.endIndex == pattern.index(patternCharacterOffset, offsetBy: distance) || pattern[offset] != "}" {
                    patternCharacterOffset = startIndex
                    return false
                }
                addressCharacterOffset = address.index(addressCharacterOffset, offsetBy: distance - 1)
                patternCharacterOffset = offset
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
