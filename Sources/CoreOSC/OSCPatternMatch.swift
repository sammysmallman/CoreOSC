//
//  OSCPatternMatch.swift
//  CoreOSC
//
//  Created by Sam Smallman on 11/08/2021.
//  Copyright © 2022 Sam Smallman. https://github.com/SammySmallman
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
