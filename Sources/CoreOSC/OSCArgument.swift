//
//  OSCArgumentProtocol.swift
//  CoreOSC
//
//  Created by Sam Smallman on 26/07/2021.
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

/// An OSC Argument.
public protocol OSCArgumentProtocol {
    
    /// The OSC data representation for the argument conforming to the protocol.
    var oscData: Data { get }
    
    /// The OSC type tag chracter for the argument conforming to the protocol.
    var oscTypeTag: Character { get }
    
    /// The OSC annotation for the argument conforming to the protocol.
    func oscAnnotation(withType type: Bool) -> String
    
}

public enum OSCArgument: OSCArgumentProtocol, CustomStringConvertible {

    case `nil`
    case impulse

    public var description: String {
        switch self {
        case .nil: return "nil"
        case .impulse: return "impulse"
        }
    }

    public var oscData: Data { Data() }

    public var oscTypeTag: Character {
        switch self {
        case .nil: return .oscTypeTagNil
        case .impulse: return .oscTypeTagImpulse
        }
    }

    public func oscAnnotation(withType type: Bool) -> String {
        "\(self)\(type ? "(\(oscTypeTag))" : "")"
    }

}

extension Int32: OSCArgumentProtocol {

    public var oscData: Data { self.bigEndian.data }

    public var oscTypeTag: Character { .oscTypeTagInt }

    public func oscAnnotation(withType type: Bool = true) -> String {
        "\(self)\(type ? "(\(oscTypeTag))" : "")"
    }

}

extension Int: OSCArgumentProtocol {

    public var oscData: Data {
        guard let int = Int32(exactly: self) else {
            return Int32(0).bigEndian.data
        }
        return int.bigEndian.data
    }

    public var oscTypeTag: Character { .oscTypeTagInt }

    public func oscAnnotation(withType type: Bool = true) -> String {
        let int = Int32(exactly: self) ?? 0
        return "\(int)\(type ? "(\(oscTypeTag))" : "")"
    }

}

extension Float32: OSCArgumentProtocol {

    public var oscData: Data {
        var float: CFSwappedFloat32 = CFConvertFloatHostToSwapped(self)
        let size: Int = MemoryLayout<CFSwappedFloat32>.size
        let result: [UInt8] = withUnsafePointer(to: &float) {
            $0.withMemoryRebound(to: UInt8.self, capacity: size) {
                Array(UnsafeBufferPointer(start: $0, count: size))
            }
        }
        return Data(result)
    }

    public var oscTypeTag: Character { .oscTypeTagFloat }

    public func oscAnnotation(withType type: Bool = true) -> String {
        "\(self)\(type ? "(\(oscTypeTag))" : "")"
    }

}

extension Double: OSCArgumentProtocol {

    public var oscData: Data {
        let floatFromDouble = Float32(exactly: self) ?? Float32(0)
        var float: CFSwappedFloat32 = CFConvertFloatHostToSwapped(floatFromDouble)
        let size: Int = MemoryLayout<CFSwappedFloat32>.size
        let result: [UInt8] = withUnsafePointer(to: &float) {
            $0.withMemoryRebound(to: UInt8.self, capacity: size) {
                Array(UnsafeBufferPointer(start: $0, count: size))
            }
        }
        return Data(result)
    }

    public var oscTypeTag: Character { .oscTypeTagFloat }

    public func oscAnnotation(withType type: Bool = true) -> String {
        "\(self)\(type ? "(\(oscTypeTag))" : "")"
    }

}

extension String: OSCArgumentProtocol {

    public var oscData: Data {
        var argumentData = data(using: .utf8)!
        for _ in 1...4 - argumentData.count % 4 {
            var null = UInt8(0)
            argumentData.append(&null, count: 1)
        }
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

}

extension Bool: OSCArgumentProtocol {

    public var oscData: Data { Data() }

    public var oscTypeTag: Character { self == true ? .oscTypeTagTrue : .oscTypeTagFalse }

    public func oscAnnotation(withType type: Bool = true) -> String {
        "\(self)\(type ? "(\(oscTypeTag))" : "")"
    }

}
