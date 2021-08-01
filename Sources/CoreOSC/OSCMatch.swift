//
//  OSCMatch.swift
//  CoreOSC
//
//  Created by Sam Smallman on 31/07/2021.
//

import Foundation

public struct OSCPatternMatch: Equatable {

    public enum Matching: Int {
        
        /// The pattern and address failed to match.
        case unmatched = 0
        
        /// A partial match where all address characters were matched,
        /// but there still remained pattern characters.
        case partialAddress
        
        /// A partial match where all address pattern characters were matched,
        /// but there still remained address characters.
        case partialPattern
        
        /// A full match of all pattern and address characters.
        case fullMatch
    }
    
    /// The result of matching a OSC Address Pattern with a OSC Address
    public let match: Matching
    
    /// The number of pattern chatacters successfully matched.
    public let patternCharactersMatched: Int
    
    /// The number of address chatacters successfully matched.
    public let addressCharactersMatched: Int
    
    public init(match: OSCPatternMatch.Matching, patternCharactersMatched: Int, addressCharactersMatched: Int) {
        self.match = match
        self.patternCharactersMatched = patternCharactersMatched
        self.addressCharactersMatched = addressCharactersMatched
    }
}

public struct OSCMatch {
    
    static func match(pattern: String, address: String) -> OSCPatternMatch {
        
        if pattern.compare(address, options: .literal) == .orderedSame {
            return OSCPatternMatch(match: .fullMatch,
                                   patternCharactersMatched: pattern.count,
                                   addressCharactersMatched: address.count)
        }
        
//        var patternStart: Character?
//        var addressStart: Character?
//        
//        var patternOffset: Int
//        var addressOffset: Int

        var patternCharacterOffset: String.Index = address.startIndex
        var addressCharacterOffset: String.Index = pattern.startIndex
        while patternCharacterOffset != pattern.endIndex &&
              addressCharacterOffset != address.endIndex {
            if pattern[patternCharacterOffset] == "*" {
                if matchAsterisk(pattern: pattern,
                                 patternCharacterOffset: &patternCharacterOffset,
                                 address: address,
                                 addressCharacterOffset: &addressCharacterOffset) == 0 {
                    return OSCPatternMatch(match: .unmatched,
                                           patternCharactersMatched: pattern.distance(from: pattern.startIndex, to: patternCharacterOffset),
                                           addressCharactersMatched: address.distance(from: address.startIndex, to: addressCharacterOffset))
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
                let n = matchSingleChar(pattern: pattern,
                                        patternCharacterOffset: &patternCharacterOffset,
                                        address: address,
                                        addressCharacterOffset: &addressCharacterOffset)
                if n == 0 {
                    return OSCPatternMatch(match: .unmatched,
                                           patternCharactersMatched: pattern.distance(from: pattern.startIndex, to: patternCharacterOffset),
                                           addressCharactersMatched: address.distance(from: address.startIndex, to: addressCharacterOffset))
                }
                if pattern[patternCharacterOffset] == "[" {
                    while pattern[patternCharacterOffset] != "]" {
                        patternCharacterOffset = pattern.index(after: patternCharacterOffset)
                    }
                    patternCharacterOffset = pattern.index(after: patternCharacterOffset)
                    addressCharacterOffset = address.index(after: addressCharacterOffset)
                } else if pattern[patternCharacterOffset] == "{" {
                    while pattern[patternCharacterOffset] != "}" {
                        patternCharacterOffset = pattern.index(after: patternCharacterOffset)
                    }
                    patternCharacterOffset = pattern.index(after: patternCharacterOffset)
                    addressCharacterOffset = address.index(addressCharacterOffset, offsetBy: n)
                } else {
                    patternCharacterOffset = pattern.index(after: patternCharacterOffset)
                    addressCharacterOffset = address.index(after: addressCharacterOffset)
                }
            }
        }

        
        var r = OSCPatternMatch.Matching.unmatched.rawValue
        
        if addressCharacterOffset == address.endIndex {
            r |= OSCPatternMatch.Matching.partialAddress.rawValue
        }
    
        if patternCharacterOffset == pattern.endIndex {
            r |= OSCPatternMatch.Matching.partialPattern.rawValue
        }

        guard let matching = OSCPatternMatch.Matching(rawValue: r) else {
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
    
    private static func matchAsterisk(pattern: String,
                                      patternCharacterOffset: inout String.Index,
                                      address: String,
                                      addressCharacterOffset: inout String.Index) -> Int {
        var numberOfAsterisks = 0
        if addressCharacterOffset == address.endIndex { return 0 }
        while addressCharacterOffset != address.endIndex &&
              address[addressCharacterOffset] != "/" {
            print("Address test: \(address[addressCharacterOffset]) Index: \(address.distance(from: address.startIndex, to: addressCharacterOffset))")
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
        print("Address 1: \(address[addressCharacterOffset]) Index: \(address.distance(from: address.startIndex, to: addressCharacterOffset))")
        print("Pattern 2: \(pattern[patternCharacterOffset]) Index: \(pattern.distance(from: pattern.startIndex, to: patternCharacterOffset))")
        switch numberOfAsterisks {
        case 1:
            // TODO: Work this part out.
            var casePatternCharacterOffset: String.Index = patternCharacterOffset
            var caseAddressCharacterOffsetStart: String.Index = addressCharacterOffset
            while pattern[casePatternCharacterOffset] != "*" {
                if matchSingleChar(pattern: pattern,
                                   patternCharacterOffset: &casePatternCharacterOffset,
                                   address: address,
                                   addressCharacterOffset: &caseAddressCharacterOffsetStart) == 0 {
                    return 0
                }
                if pattern[casePatternCharacterOffset] == "]" || pattern[casePatternCharacterOffset] == "}" {
                    while pattern[casePatternCharacterOffset] != "[" && pattern[casePatternCharacterOffset] != "{" {
                        casePatternCharacterOffset = pattern.index(before: casePatternCharacterOffset)
                    }
                }
                casePatternCharacterOffset = pattern.index(before: casePatternCharacterOffset)
                caseAddressCharacterOffsetStart = address.index(before: caseAddressCharacterOffsetStart)
            }
            break
        default: return 0
        }
        return 1
    }
    
    private static func matchSingleChar(pattern: String,
                                        patternCharacterOffset: inout String.Index,
                                        address: String,
                                        addressCharacterOffset: inout String.Index) -> Int {
        switch pattern[patternCharacterOffset] {
        case "[":
            return matchSquareBracket(pattern: pattern,
                                      patternCharacterOffset: &patternCharacterOffset,
                                      address: address,
                                      addressCharacterOffset: &addressCharacterOffset)
        case "]":
            while pattern[patternCharacterOffset] != "[" {
                patternCharacterOffset = pattern.index(before: patternCharacterOffset)
            }
            return matchSquareBracket(pattern: pattern,
                                      patternCharacterOffset: &patternCharacterOffset,
                                      address: address,
                                      addressCharacterOffset: &addressCharacterOffset)
        case "{": return 0
        case "}": return 0
        case "?": return 1
        default:
            return pattern[patternCharacterOffset] == address[addressCharacterOffset] ? 1 : 0
        }
    }
    
    private static func matchSquareBracket(pattern: String,
                                     patternCharacterOffset: inout String.Index,
                                     address: String,
                                     addressCharacterOffset: inout String.Index) -> Int {
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
                   address[addressCharacterOffset].asciiValue! <= pattern[pattern.index(patternCharacterOffset, offsetBy: 2)].asciiValue! {
                    matched = val
                    break
                } else {
                    patternCharacterOffset = pattern.index(patternCharacterOffset, offsetBy: 3)
                }
            } else {
                if pattern[patternCharacterOffset] == address[addressCharacterOffset] {
                    matched = val
                    break
                }
                patternCharacterOffset = pattern.index(after: patternCharacterOffset)
            }
        }
        return matched ? 1 : 0
    }
}
