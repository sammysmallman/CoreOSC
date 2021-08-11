//
//  OSCPatternMatch.swift
//  CoreOSC
//
//  Created by Sam Smallman on 11/08/2021.
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

    /// The result of matching an OSC Address Pattern with an OSC Address.
    public enum Matching: Int {
        
        /// The pattern and address failed to match.
        case unmatched
        
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
