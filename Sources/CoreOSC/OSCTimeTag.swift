//
//  OSCTimeTag.swift
//  CoreOSC
//
//  Created by Sam Smallman on 22/07/2021.
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

/// An OSC Time Tag.
public struct OSCTimeTag: OSCArgumentProtocol, Equatable {
    
    /// The OSC data representation for the argument.
    public var oscData: Data { Data(seconds.bigEndian.data + fraction.bigEndian.data) }

    /// The OSC type tag chracter for the argument.
    public var oscTypeTag: Character { Character.oscTypeTagTimeTag }
    
    /// The OSC annotation for the argument.
    public func oscAnnotation(withType type: Bool = true) -> String {
        "\(self.hex())\(type ? "(\(oscTypeTag))" : "")"
    }
    
    /// Creates an OSC Time Tag initialized to immediately.
    public static let immediate: OSCTimeTag = OSCTimeTag()

    public let seconds: UInt32
    public let fraction: UInt32
    public let immediate: Bool

    public init?(data: Data) {
        guard data.count == 8 else { return nil }
        let secondsNumber = data.subdata(in: data.startIndex ..< data.startIndex + 4)
            .withUnsafeBytes { $0.load(as: UInt32.self) }
            .byteSwapped
        let fractionNumber = data.subdata(in: data.startIndex + 4 ..< data.startIndex + 8)
            .withUnsafeBytes { $0.load(as: UInt32.self) }
            .byteSwapped
        self.seconds = secondsNumber
        self.fraction = fractionNumber
        self.immediate = secondsNumber == 0 && fractionNumber == 1
    }

    public init(date: Date) {
        // OSCTimeTags uses 1900 as it's marker.
        // We need to get the seconds from 1900 not 1970 which Apple's Date Object gets.
        // Seconds between 1900 and 1970 = 2208988800
        let secondsSince1900 = date.timeIntervalSince1970 + 2208988800
        // Bitwise AND operator to get the first 32 bits of secondsSince1900 which is cast from a double to UInt64
        self.seconds = UInt32(UInt64(secondsSince1900) & 0xffffffff)
        let fractionsPerSecond = Double(0xffffffff)
        self.fraction = UInt32(fmod(secondsSince1900, 1.0) * fractionsPerSecond)
        self.immediate = false
    }

    // immediate Time Tag
    internal init() {
        self.seconds = 0
        self.fraction = 1
        self.immediate = true
    }

    public func date() -> Date {
        let date1900 = Date(timeIntervalSince1970: -2208988800)
        var interval = TimeInterval(seconds)
        interval += TimeInterval(Double(fraction) / 0xffffffff)
        return date1900.addingTimeInterval(interval)
    }

    public func hex() -> String {
        let secondsHex = seconds.byteArray()
            .map { String(format: "%02X", $0) }
            .joined()
        let frationHex = fraction.byteArray()
            .map { String(format: "%02X", $0) }
            .joined()
        return secondsHex + frationHex
    }

}
