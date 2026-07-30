//
//  OSCArgumentProtocol.swift
//  CoreOSC
//
//  Created by Sam Smallman on 26/07/2021.
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

/// An OSC Argument.
public protocol OSCArgumentProtocol: Sendable {

    /// The OSC data representation for the argument conforming to the protocol.
    var oscData: Data { get }

    /// The OSC type tag chracter for the argument conforming to the protocol.
    var oscTypeTag: Character { get }

    /// The OSC annotation for the argument conforming to the protocol.
    func oscAnnotation(withType type: Bool) -> String

    /// Encodes the argument's OSC data representation by appending it to the given buffer.
    /// - Parameter buffer: The buffer to append the argument's bytes to.
    func encode(into buffer: inout Data)

}

extension OSCArgumentProtocol {

    /// Appends the argument's `oscData` to the given buffer.
    public func encode(into buffer: inout Data) {
        buffer.append(oscData)
    }

}

public enum OSCArgument: OSCArgumentProtocol, CustomStringConvertible, Equatable, Codable {

    case int32(Int32)
    case float32(Float32)
    case string(String)
    case blob(Data)
    case `true`
    case `false`
    case `nil`
    case impulse
    case timeTag(OSCTimeTag)

    public var description: String {
        switch self {
        case let .int32(value): return value.description
        case let .float32(value): return value.description
        case let .string(value): return value
        case let .blob(value): return value.description
        case .true: return "true"
        case .false: return "false"
        case .nil: return "nil"
        case .impulse: return "impulse"
        case let .timeTag(value): return value.description
        }
    }

    public var oscData: Data {
        switch self {
        case .int32(let value):
            return value.oscData
        case .float32(let value):
            return value.oscData
        case .string(let value):
            return value.oscData
        case .blob(let value):
            return value.oscData
        case .true:
            return Data()
        case .false:
            return Data()
        case .nil:
            return Data()
        case .impulse:
            return Data()
        case let .timeTag(value):
            return value.oscData
        }
    }

    /// Encodes the argument's OSC data representation by appending it to the given buffer.
    /// - Parameter buffer: The buffer to append the argument's bytes to.
    public func encode(into buffer: inout Data) {
        switch self {
        case let .int32(value):
            value.encode(into: &buffer)
        case let .float32(value):
            value.encode(into: &buffer)
        case let .string(value):
            value.encode(into: &buffer)
        case let .blob(value):
            value.encode(into: &buffer)
        case .true, .false, .nil, .impulse:
            break
        case let .timeTag(value):
            value.encode(into: &buffer)
        }
    }

    /// The number of bytes `encode(into:)` appends for the argument.
    var oscEncodedSize: Int {
        switch self {
        case .int32, .float32:
            return 4
        case let .string(value):
            return value.oscEncodedSize
        case let .blob(value):
            return 4 + (value.count + 3) / 4 * 4
        case .true, .false, .nil, .impulse:
            return 0
        case .timeTag:
            return 8
        }
    }

    public var oscTypeTag: Character {
        switch self {
        case .int32: return .oscTypeTagInt32
        case .float32: return .oscTypeTagFloat32
        case .string: return .oscTypeTagString
        case .blob: return .oscTypeTagBlob
        case .true: return .oscTypeTagTrue
        case .false: return .oscTypeTagFalse
        case .nil: return .oscTypeTagNil
        case .impulse: return .oscTypeTagImpulse
        case .timeTag: return .oscTypeTagTimeTag
        }
    }

    public func oscAnnotation(withType type: Bool) -> String {
        switch self {
        case let .int32(int32):
            return int32.oscAnnotation(withType: type)
        case let .float32(float32):
            return float32.oscAnnotation(withType: type)
        case let .string(string):
            return string.oscAnnotation(withType: type)
        case let .blob(data):
            return data.oscAnnotation(withType: type)
        case .true:
            return "true\(type ? "(\(Character.oscTypeTagTrue))" : "")"
        case .false:
            return "false\(type ? "(\(Character.oscTypeTagFalse))" : "")"
        case .nil:
            return "nil\(type ? "(\(Character.oscTypeTagNil))" : "")"
        case .impulse:
            return "impulse\(type ? "(\(Character.oscTypeTagImpulse))" : "")"
        case let .timeTag(timeTag):
            return timeTag.oscAnnotation(withType: type)
        }
    }

    public var bool: Bool? {
        switch self {
        case .true:
            true
        case .false:
            false
        default: nil
        }
    }

}

extension Int32: OSCArgumentProtocol {

    public var oscData: Data { self.bigEndian.data }

    public var oscTypeTag: Character { .oscTypeTagInt32 }

    public func oscAnnotation(withType type: Bool = true) -> String {
        "\(self)\(type ? "(\(oscTypeTag))" : "")"
    }

    /// Appends the integer's 4 big-endian bytes to the given buffer.
    public func encode(into buffer: inout Data) {
        buffer.append(bigEndian: self)
    }

}

extension Int: OSCArgumentProtocol {

    /// Values outside the range of `Int32` — OSC's only required integer
    /// type — are clamped to `Int32.min`/`Int32.max`.
    public var oscData: Data {
        Int32(clamping: self).bigEndian.data
    }

    public var oscTypeTag: Character { .oscTypeTagInt32 }

    public func oscAnnotation(withType type: Bool = true) -> String {
        let int = Int32(clamping: self)
        return "\(int)\(type ? "(\(oscTypeTag))" : "")"
    }

    /// Appends the clamped `Int32` value's 4 big-endian bytes to the given buffer.
    public func encode(into buffer: inout Data) {
        buffer.append(bigEndian: Int32(clamping: self))
    }

}

extension Float32: OSCArgumentProtocol {

    public var oscData: Data {
        withUnsafeBytes(of: bitPattern.bigEndian) { Data($0) }
    }

    public var oscTypeTag: Character { .oscTypeTagFloat32 }

    public func oscAnnotation(withType type: Bool = true) -> String {
        "\(self)\(type ? "(\(oscTypeTag))" : "")"
    }

    /// Appends the float's 4 big-endian bytes to the given buffer.
    public func encode(into buffer: inout Data) {
        buffer.append(bigEndian: bitPattern)
    }

}

extension Double: OSCArgumentProtocol {

    /// The value is truncated to the nearest `Float32` — OSC has no 64-bit
    /// float in the 1.1 required types.
    public var oscData: Data { Float32(self).oscData }

    public var oscTypeTag: Character { .oscTypeTagFloat32 }

    public func oscAnnotation(withType type: Bool = true) -> String {
        "\(self)\(type ? "(\(oscTypeTag))" : "")"
    }

    /// Appends the truncated `Float32` value's 4 big-endian bytes to the given buffer.
    public func encode(into buffer: inout Data) {
        Float32(self).encode(into: &buffer)
    }

}

extension CGFloat: OSCArgumentProtocol {

    /// The value is truncated to the nearest `Float32` — OSC has no 64-bit
    /// float in the 1.1 required types.
    public var oscData: Data { Float32(self).oscData }

    public var oscTypeTag: Character { .oscTypeTagFloat32 }

    public func oscAnnotation(withType type: Bool = true) -> String {
        "\(self)\(type ? "(\(oscTypeTag))" : "")"
    }

    /// Appends the truncated `Float32` value's 4 big-endian bytes to the given buffer.
    public func encode(into buffer: inout Data) {
        Float32(self).encode(into: &buffer)
    }

}

extension String: OSCArgumentProtocol {

    public var oscData: Data {
        var argumentData = data(using: .utf8)!
        // 1-4 null bytes: at least one terminator, padded to a 4-byte boundary.
        argumentData.append(contentsOf: repeatElement(0, count: 4 - argumentData.count % 4))
        return argumentData
    }

    public var oscTypeTag: Character { .oscTypeTagString }

    public func oscAnnotation(withType type: Bool = true) -> String {
        if self.contains(" ") {
            return "\"\(self)\"\(type ? "(\(oscTypeTag))" : "")"
        } else {
            return "\(self)\(type ? "(\(oscTypeTag))" : "")"
        }
    }

    /// Appends the string's UTF-8 bytes and 1-4 null bytes of padding to the given buffer.
    public func encode(into buffer: inout Data) {
        let utf8View = utf8
        let appended: Void? = utf8View.withContiguousStorageIfAvailable { bytes in
            buffer.append(bytes)
        }
        if appended == nil {
            buffer.append(contentsOf: utf8View)
        }
        buffer.append(contentsOf: repeatElement(0, count: 4 - utf8View.count % 4))
    }

    /// The number of bytes `encode(into:)` appends: the UTF-8 bytes plus
    /// 1-4 null bytes of padding.
    var oscEncodedSize: Int {
        let utf8Count = utf8.count
        return utf8Count + 4 - utf8Count % 4
    }

}

extension Data: OSCArgumentProtocol {

    public var oscData: Data {
        let length = UInt32(count)
        var argumentData = Data()
        argumentData.append(length.bigEndian.data)
        argumentData.append(self)
        while argumentData.count % 4 != 0 {
            var null = UInt8(0)
            argumentData.append(&null, count: 1)
        }
        return argumentData
    }

    public var oscTypeTag: Character { .oscTypeTagBlob }

    public func oscAnnotation(withType type: Bool = true) -> String {
        "\(self.count)\(type ? "(\(oscTypeTag))" : "")"
    }

    /// Appends the blob's 4-byte big-endian length, its bytes, and 0-3 null
    /// bytes of padding to the given buffer.
    public func encode(into buffer: inout Data) {
        buffer.append(bigEndian: UInt32(count))
        buffer.append(self)
        let remainder = count % 4
        if remainder != 0 {
            buffer.append(contentsOf: repeatElement(0, count: 4 - remainder))
        }
    }

}

extension Bool: OSCArgumentProtocol {

    public var oscData: Data { Data() }

    public var oscTypeTag: Character { self == true ? .oscTypeTagTrue : .oscTypeTagFalse }

    public func oscAnnotation(withType type: Bool = true) -> String {
        "\(self)\(type ? "(\(oscTypeTag))" : "")"
    }

    /// Appends nothing: booleans are encoded entirely by their type tag.
    public func encode(into buffer: inout Data) {}

}
