//
//  OSCMatch.swift
//  CoreOSC
//
//  Created by Sam Smallman on 31/07/2021.
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

/// A helper object for OSC Address Pattern and OSC Address matching operations.
///
/// Matching operates on UTF-8 bytes with bounds-checked integer indices: the OSC
/// address namespace is defined as ASCII, byte comparison preserves literal
/// semantics for any input, and malformed patterns or addresses — unterminated
/// brackets or braces, non-ASCII bytes, length mismatches — fail the match
/// rather than trapping. The character counts reported by ``OSCPatternMatch``
/// are UTF-8 byte counts, which are identical to character counts for the
/// ASCII inputs the OSC specification allows.
public enum OSCMatch {

    private static let asterisk = UInt8(ascii: "*")
    private static let slash = UInt8(ascii: "/")
    private static let questionMark = UInt8(ascii: "?")
    private static let openBracket = UInt8(ascii: "[")
    private static let closeBracket = UInt8(ascii: "]")
    private static let openBrace = UInt8(ascii: "{")
    private static let closeBrace = UInt8(ascii: "}")
    private static let exclamationMark = UInt8(ascii: "!")
    private static let minus = UInt8(ascii: "-")
    private static let comma = UInt8(ascii: ",")

    /// Match an OSC Address Pattern against an OSC Address.
    /// - Parameters:
    ///   - addressPattern: An OSC Address Pattern.
    ///   - address: An OSC Address.
    /// - Returns: A `OSCPatternMatch` indicating whether the two given values match and to what extent.
    public static func match(addressPattern: String, address: String) -> OSCPatternMatch {
        var patternString = addressPattern
        var addressString = address
        // withUTF8 exposes the string's UTF-8 bytes without copying for
        // natively stored strings - matching allocates nothing.
        return patternString.withUTF8 { pattern in
            addressString.withUTF8 { target in
                match(pattern: pattern, target: target)
            }
        }
    }

    private static func match(pattern: UnsafeBufferPointer<UInt8>,
                              target: UnsafeBufferPointer<UInt8>) -> OSCPatternMatch {
        if pattern.count == target.count,
           pattern.count == 0 || memcmp(pattern.baseAddress!, target.baseAddress!, pattern.count) == 0 {
            return OSCPatternMatch(match: .fullMatch,
                                   patternCharactersMatched: pattern.count,
                                   addressCharactersMatched: target.count)
        }

        var patternIndex = 0
        var addressIndex = 0
        while patternIndex < pattern.count && addressIndex < target.count {
            if pattern[patternIndex] == asterisk {
                if matchAsterisk(pattern: pattern,
                                 patternIndex: &patternIndex,
                                 address: target,
                                 addressIndex: &addressIndex) == false {
                    return OSCPatternMatch(match: .unmatched,
                                           patternCharactersMatched: patternIndex,
                                           addressCharactersMatched: addressIndex)
                }
                while patternIndex < pattern.count &&
                      pattern[patternIndex] != slash {
                    patternIndex += 1
                }
                while addressIndex < target.count &&
                      target[addressIndex] != slash {
                    addressIndex += 1
                }
            } else if target[addressIndex] == asterisk {
                while patternIndex < pattern.count &&
                      pattern[patternIndex] != slash {
                    patternIndex += 1
                }
                while addressIndex < target.count &&
                      target[addressIndex] != slash {
                    addressIndex += 1
                }
            } else {
                let match = matchBytes(pattern: pattern,
                                       patternIndex: &patternIndex,
                                       address: target,
                                       addressIndex: &addressIndex)
                if match == false {
                    if patternIndex + 1 == pattern.count &&
                        pattern[patternIndex] == closeBracket {
                        return OSCPatternMatch(match: .unmatched,
                                               patternCharactersMatched: pattern.count,
                                               addressCharactersMatched: addressIndex)
                    } else {
                        return OSCPatternMatch(match: .unmatched,
                                               patternCharactersMatched: patternIndex,
                                               addressCharactersMatched: addressIndex)
                    }
                }
                if patternIndex < pattern.count {
                    patternIndex += 1
                }
                if addressIndex < target.count {
                    addressIndex += 1
                }
            }
        }

        var match = OSCPatternMatch.Matching.unmatched.rawValue

        if addressIndex == target.count {
            match |= OSCPatternMatch.Matching.partialAddress.rawValue
        }

        if patternIndex == pattern.count {
            match |= OSCPatternMatch.Matching.partialPattern.rawValue
        }

        guard let matching = OSCPatternMatch.Matching(rawValue: match) else {
            // It shouldn't be possible to get to here but just incase...
            return OSCPatternMatch(match: .unmatched,
                                   patternCharactersMatched: 0,
                                   addressCharactersMatched: 0)
        }
        return OSCPatternMatch(match: matching,
                               patternCharactersMatched: patternIndex,
                               addressCharactersMatched:
                                matching == .fullMatch ? target.count : addressIndex)
    }

    /// Matches bytes from the given offsets onwards using the asterisk wildcard.
    /// - Parameters:
    ///   - pattern: An OSC Address Pattern.
    ///   - patternIndex: The offset of the first byte in the OSC Address Pattern to begin matching from.
    ///   - address: An OSC Address.
    ///   - addressIndex: The offset of the first byte in the OSC Address to begin matching from.
    /// - Returns: A boolean value indicating whether the pattern from the given offset matches using an asterisk wildcard up to the next forward slash, or end of string.
    private static func matchAsterisk(pattern: UnsafeBufferPointer<UInt8>,
                                      patternIndex: inout Int,
                                      address: UnsafeBufferPointer<UInt8>,
                                      addressIndex: inout Int) -> Bool {
        if addressIndex == address.count { return false }
        // Move address index up to next "/"
        while addressIndex < address.count &&
              address[addressIndex] != slash {
            addressIndex += 1
        }
        // Move pattern index up to next "/"
        while patternIndex < pattern.count &&
              pattern[patternIndex] != slash {
            patternIndex += 1
        }

        // TODO: Match patterns backwards if the last character before the "/" is not a "*"
        return true
    }

    /// Matches bytes from the given offsets onwards.
    /// - Parameters:
    ///   - pattern: An OSC Address Pattern.
    ///   - patternIndex: The offset of the first byte in the OSC Address Pattern to begin matching from.
    ///   - address: An OSC Address.
    ///   - addressIndex: The offset of the first byte in the OSC Address to begin matching from.
    /// - Returns: A boolean value indicating whether the pattern from the given offset matches against the given OSC Address from the given offset.
    private static func matchBytes(pattern: UnsafeBufferPointer<UInt8>,
                                   patternIndex: inout Int,
                                   address: UnsafeBufferPointer<UInt8>,
                                   addressIndex: inout Int) -> Bool {
        switch pattern[patternIndex] {
        case openBracket:
            return matchSquareBracket(pattern: pattern,
                                      patternIndex: &patternIndex,
                                      address: address,
                                      addressIndex: &addressIndex)
        case openBrace:
            return matchCurlyBrace(pattern: pattern,
                                   patternIndex: &patternIndex,
                                   address: address,
                                   addressIndex: &addressIndex)
        case questionMark: return true
        default:
            return pattern[patternIndex] == address[addressIndex]
        }
    }

    /// Matches bytes from the given offsets onwards using the square brackets wildcards.
    /// - Parameters:
    ///   - pattern: An OSC Address Pattern.
    ///   - patternIndex: The offset of the first byte in the OSC Address Pattern to begin matching from.
    ///   - address: An OSC Address.
    ///   - addressIndex: The offset of the first byte in the OSC Address to begin matching from.
    /// - Returns: A boolean value indicating whether the pattern from the given offset matches against the given OSC Address from the given offset.
    private static func matchSquareBracket(pattern: UnsafeBufferPointer<UInt8>,
                                           patternIndex: inout Int,
                                           address: UnsafeBufferPointer<UInt8>,
                                           addressIndex: inout Int) -> Bool {
        patternIndex += 1
        guard patternIndex < pattern.count else { return false }
        var val = true
        if pattern[patternIndex] == exclamationMark {
            patternIndex += 1
            val = false
            guard patternIndex < pattern.count else { return false }
        }
        var matched = !val
        while patternIndex < pattern.count &&
              pattern[patternIndex] != closeBracket {
            if patternIndex + 1 < pattern.count &&
               pattern[patternIndex + 1] == minus {
                // Two bytes separated by a minus sign indicate a range,
                // e.g. "[a-z]", compared in ASCII collating sequence.
                if patternIndex + 2 < pattern.count,
                   address[addressIndex] >= pattern[patternIndex],
                   address[addressIndex] <= pattern[patternIndex + 2] {
                    matched = val
                    while patternIndex < pattern.count &&
                          pattern[patternIndex] != closeBracket {
                        patternIndex += 1
                    }
                    break
                } else if patternIndex + 3 < pattern.count {
                    patternIndex += 3
                } else {
                    return false
                }
            } else {
                if pattern[patternIndex] == address[addressIndex] {
                    matched = val
                    while patternIndex < pattern.count &&
                          pattern[patternIndex] != closeBracket {
                        patternIndex += 1
                    }
                    break
                }
                patternIndex += 1
            }
        }
        // A bracketed list that never closes is malformed and cannot match.
        guard patternIndex < pattern.count else { return false }
        return matched
    }

    /// Matches bytes from the given offsets onwards using the curly braces wildcards.
    /// - Parameters:
    ///   - pattern: An OSC Address Pattern.
    ///   - patternIndex: The offset of the first byte in the OSC Address Pattern to begin matching from.
    ///   - address: An OSC Address.
    ///   - addressIndex: The offset of the first byte in the OSC Address to begin matching from.
    /// - Returns: A boolean value indicating whether the pattern from the given offset matches against the given OSC Address from the given offset.
    private static func matchCurlyBrace(pattern: UnsafeBufferPointer<UInt8>,
                                        patternIndex: inout Int,
                                        address: UnsafeBufferPointer<UInt8>,
                                        addressIndex: inout Int) -> Bool {
        let startIndex = patternIndex
        patternIndex += 1
        var offset = patternIndex
        while offset < pattern.count &&
              pattern[offset] != closeBrace &&
              pattern[offset] != slash {
            while offset < pattern.count &&
                  pattern[offset] != closeBrace &&
                  pattern[offset] != slash &&
                  pattern[offset] != comma {
                offset += 1
            }
            let length = offset - patternIndex
            // An option longer than the remaining address cannot match;
            // move on and try the next option in the list.
            if addressIndex + length <= address.count,
               pattern[patternIndex..<offset].elementsEqual(address[addressIndex..<addressIndex + length]) {
                while offset < pattern.count &&
                      pattern[offset] != closeBrace &&
                      pattern[offset] != slash {
                    offset += 1
                }
                // A braced list that never closes is malformed and cannot match.
                if patternIndex + length == pattern.count ||
                    offset == pattern.count ||
                    pattern[offset] != closeBrace {
                    patternIndex = startIndex
                    return false
                }
                addressIndex += length - 1
                patternIndex = offset
                return true
            } else {
                offset += 1
                patternIndex = offset
            }
        }
        patternIndex = startIndex
        return false
    }

}
