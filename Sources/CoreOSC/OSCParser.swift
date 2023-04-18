//
//  OSCParser.swift
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

/// An OSC Parser able to parse and create `OSCPacket`s from `Data`.
public enum OSCParser {
    
    /// Returns an `OSCPacket` from `Data`.
    /// - Parameter data: The `Data` to process.
    /// - Throws: An `OSCParserError` if the `Data` could not be parsed.
    /// - Returns: An `OSCPacket`.
    public static func packet(from data: Data) throws -> OSCPacket {
        guard let string = String(data: data.prefix(upTo: 1), encoding: .utf8) else {
            throw OSCParserError.unrecognisedData
        }
        if string == "/" { // OSC Messages begin with /
            return try process(message: data)
        } else if string == "#" { // OSC Bundles begin with #
            return try process(bundle: data)
        } else {
            throw OSCParserError.unrecognisedData
        }
    }
    
    /// Returns an `OSCMessage` as an `OSCPacket` from `Data`.
    /// - Parameter data: The `Data` to process.
    /// - Throws: An `OSCParserError` if the `Data` could not be parsed.
    /// - Returns: An `OSCPacket`.
    private static func process(message data: Data) throws -> OSCPacket {
        var startIndex = 0
        return try parseOSCMessage(with: data, startIndex: &startIndex)
    }

    /// Returns an `OSCBundle` as an `OSCPacket` from `Data`.
    /// - Parameter data: The `Data` to process.
    /// - Throws: An `OSCParserError` if the `Data` could not be parsed.
    /// - Returns: An `OSCPacket`.
    private static func process(bundle data: Data) throws -> OSCPacket {
        return try parseOSCBundle(with: data)
    }
    
    /// Parse `OSCMessage` data.
    /// - Parameters:
    ///   - data: The `Data` to parse.
    ///   - startIndex: The index of where to start parsing the `Data` from.
    /// - Throws: An `OSCParserError` if the `Data` could not be parsed.
    /// - Returns: An `OSCMessage`.
    private static func parseOSCMessage(with data: Data, startIndex: inout Int) throws -> OSCMessage {
        guard let addressPattern = parse(string: data,
                                         startIndex: &startIndex) else {
            throw OSCParserError.cantParseAddressPattern
        }

        guard var typeTagString = parse(string: data,
                                        startIndex: &startIndex) else {
            throw OSCParserError.cantParseTypeTagString
        }

        // If the Type Tag String starts with "," and has 1 or more characters after,
        // we possibly have some arguments.
        var arguments: [OSCArgumentProtocol] = []
        if typeTagString.first == "," && typeTagString.count > 1 {
            // Remove "," as we will iterate over the different type of tags.
            typeTagString.removeFirst()
            for type in typeTagString {
                switch type {
                case .oscTypeTagString:
                    guard let stringArgument = parse(string: data,
                                                     startIndex: &startIndex) else {
                        throw OSCParserError.cantParseString
                    }
                    arguments.append(stringArgument)
                case .oscTypeTagInt:
                    guard let intArgument = parse(int32: data,
                                                  startIndex: &startIndex) else {
                        throw OSCParserError.cantParseInt32
                    }
                    arguments.append(intArgument)
                case .oscTypeTagFloat:
                    guard let floatArgument = parse(float32: data,
                                                    startIndex: &startIndex) else {
                        throw OSCParserError.cantParseFloat32
                    }
                    arguments.append(floatArgument)
                case .oscTypeTagBlob:
                    guard let blobArgument = parse(blob: data,
                                                   startIndex: &startIndex) else {
                        throw OSCParserError.cantParseBlob
                    }
                    arguments.append(blobArgument)
                case .oscTypeTagTimeTag:
                    guard let timeTagArgument = parse(timeTag: data,
                                                      startIndex: &startIndex) else {
                        throw OSCParserError.cantParseTimeTag
                    }
                    arguments.append(timeTagArgument)
                case .oscTypeTagTrue:
                    arguments.append(true)
                case .oscTypeTagFalse:
                    arguments.append(false)
                case .oscTypeTagNil:
                    arguments.append(OSCArgument.nil)
                case .oscTypeTagImpulse:
                    arguments.append(OSCArgument.impulse)
                default:
                    continue
                }
            }
        }
        return OSCMessage(raw: addressPattern, arguments: arguments)
    }
    
    /// Parse `OSCBundle` data.
    /// - Parameters:
    ///   - data: The `Data` to parse.
    /// - Throws: An `OSCParserError` if the `Data` could not be parsed.
    /// - Returns: An `OSCBundle`.
    private static func parseOSCBundle(with data: Data) throws -> OSCBundle {
        // Check the Bundle has a string prefix of "#bundle"
        if "#bundle".oscData == data.subdata(in: Range(0...7)) {
            var startIndex = 8
            // All Bundles have a Time Tag, even if its just immedietly - Seconds 0, Fractions 1.
            guard let timeTag = parse(timeTag: data,
                                      startIndex: &startIndex) else {
                throw OSCParserError.cantParseTimeTag
            }
            // Does the Bundle have any data in it? Bundles could be empty with no messages or bundles within.
            if startIndex < data.endIndex {
                let bundleData = data.subdata(in: startIndex..<data.endIndex)
                let size = Int32(data.count - startIndex)
                let elements = try parseBundleElements(with: 0,
                                                       data: bundleData,
                                                       size: size)
                return OSCBundle(elements,
                                 timeTag: timeTag)
            } else {
                return OSCBundle(timeTag: timeTag)
            }
        } else {
            throw OSCParserError.unrecognisedData
        }
    }
    
    /// Parse `OSCBundle` elements.
    /// - Parameters:
    ///   - index: The index of where to start parsing `OSCBundle` elements from in the `Data`.
    ///   - data: The `Data` to parse.
    ///   - size: The size of the `OSCBundle` containing the elements.
    /// - Throws: An `OSCParserError` if the `Data` could not be parsed.
    /// - Returns: An `Array` of `OSCPacket`s representing the elements the `OSCBundle` contains.
    private static func parseBundleElements(with index: Int, data: Data, size: Int32) throws -> [OSCPacket] {
        var elements: [OSCPacket] = []
        var startIndex = 0
        var buffer: Int32 = 0
        repeat {
            guard let elementSize = parse(int32: data,
                                          startIndex: &startIndex) else {
                throw OSCParserError.cantParseSizeOfElement
            }
            buffer += 4
            guard let string = String(data: data.subdata(in: startIndex..<data.endIndex).prefix(upTo: 1),
                                      encoding: .utf8) else {
                throw OSCParserError.cantParseTypeOfElement
            }
            if string == "/" { // OSC Messages begin with /
                let newElement = try parseOSCMessage(with: data,
                                                     startIndex: &startIndex)
                elements.append(newElement)
            } else if string == "#" { // OSC Bundles begin with #
                // #bundle takes up 8 bytes
                startIndex += 8
                // All Bundles have a Time Tag, even if its just immedietly - Seconds 0, Fractions 1.
                guard let timeTag = parse(timeTag: data,
                                          startIndex: &startIndex) else {
                    throw OSCParserError.cantParseTimeTag
                }
                if startIndex < size {
                    let bundleData = data.subdata(in: startIndex..<startIndex + Int(elementSize) - 16)
                    let bundleElements = try parseBundleElements(with: index,
                                                                    data: bundleData,
                                                                    size: Int32(bundleData.count))
                    elements.append(OSCBundle(bundleElements,
                                              timeTag: timeTag))
                } else {
                    elements.append(OSCBundle(timeTag: timeTag))
                }
            } else {
                throw OSCParserError.unrecognisedData
            }
            buffer += elementSize
            startIndex = index + Int(buffer)
        } while buffer < size
        return elements
    }
    
    /// Parse OSC string data.
    /// - Parameters:
    ///   - data: The `Data` to parse.
    ///   - startIndex: The index of where to start parsing from in the `Data`.
    /// - Returns: A `String` or nil if an OSC string could not be parsed with the given data.
    private static func parse(string data: Data, startIndex: inout Int) -> String? {
        // Read the data from the start index until you hit a zero, the part before will be the string data.
        for (index, byte) in data[startIndex...].enumerated() where byte == 0x0 {
            guard let result = String(data: data[startIndex..<(startIndex + index)],
                                      encoding: .utf8) else { return nil }
             // An OSC String is a sequence of non-null ASCII characters followed by a null,
             // followed by 0-3 additional null characters to make the total number
             // of bits a multiple of 32 Bits, 4 Bytes.
            let bytesRead = startIndex + index + 1 // Include the Null bytes we found.
            if bytesRead.isMultiple(of: 4) {
                startIndex = bytesRead
            } else {
                let number = (Double(bytesRead) / 4.0).rounded(.up)
                startIndex = Int(4.0 * number)
            }
            return result
        }
        return nil
    }

    /// Parse OSC integer 32 data.
    /// - Parameters:
    ///   - data: The `Data` to parse.
    ///   - startIndex: The index of where to start parsing from in the `Data`.
    /// - Returns: A `Int32` or nil if a integer 32 could not be parsed with the given data.
    private static func parse(int32 data: Data, startIndex: inout Int) -> Int32? {
        // An OSC Int is a 32-bit big-endian two's complement integer.
        let result = data.subdata(in: startIndex..<startIndex + 4)
            .withUnsafeBytes { $0.load(as: Int32.self) }
            .bigEndian
        startIndex += 4
        return result
    }

    /// Parse OSC float 32 data.
    /// - Parameters:
    ///   - data: The `Data` to parse.
    ///   - startIndex: The index of where to start parsing from in the `Data`.
    /// - Returns: A `Float32` or nil if a float 32 could not be parsed with the given data.
    private static func parse(float32 data: Data, startIndex: inout Int) -> Float32? {
        // An OSC Float is a 32-bit big-endian IEEE 754 floating point number.
        let result = data.subdata(in: startIndex..<startIndex + 4)
            .withUnsafeBytes { CFConvertFloat32SwappedToHost($0.load(as: CFSwappedFloat32.self)) }
        startIndex += 4
        return result
    }

    /// Parse OSC blob data.
    /// - Parameters:
    ///   - data: The `Data` to parse.
    ///   - startIndex: The index of where to start parsing from in the `Data`.
    /// - Returns: A `Data` or nil if an OSC blob could not be parsed with the given data.
    private static func parse(blob data: Data, startIndex: inout Int) -> Data? {
         // An int32 size count, followed by that many 8-bit bytes of arbitrary binary data,
         // followed by 0-3 additional zero bytes to make the total number of bits a multiple of 32, 4 bytes
        guard let size = parse(int32: data, startIndex: &startIndex) else { return nil }
        let intSize = Int(size)
        let result = data.subdata(in: startIndex..<startIndex + intSize)
        let total = startIndex + intSize
        if total.isMultiple(of: 4) {
            startIndex = total
        } else {
            let number = (Double(total) / 4.0).rounded(.up)
            startIndex = Int(4.0 * number)
        }
        return result
    }

    /// Parse OSC time tag data.
    /// - Parameters:
    ///   - data: The `Data` to parse.
    ///   - startIndex: The index of where to start parsing from in the `Data`.
    /// - Returns: A `OSCTimeTag` or nil if one could not be parsed with the given data.
    private static func parse(timeTag data: Data, startIndex: inout Int) -> OSCTimeTag? {
        let timeTagData = data[startIndex..<startIndex + 8]
        startIndex += 8
        return OSCTimeTag(data: timeTagData)
    }

}
