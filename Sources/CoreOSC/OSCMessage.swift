//
//  OSCMessage.swift
//  CoreOSC
//
//  Created by Sam Smallman on 22/107/2021.
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

public struct OSCMessage: OSCPacket {

    public private(set) var address: OSCAddress
    public let arguments: [OSCArgumentProtocol]

    public init(_ address: String, arguments: [OSCArgumentProtocol] = []) throws {
        let address = try OSCAddress(address)
        self.init(address, arguments: arguments)
    }

    public init(_ address: OSCAddress, arguments: [OSCArgumentProtocol] = []) {
        self.address = address
        self.arguments = arguments
    }

    public mutating func readdress(to address: OSCAddress) {
        self.address = address
    }

    public func data() -> Data {
        var result = address.fullPath.oscData
        result.append(",\(arguments.map { String($0.oscTypeTag) }.joined())".oscData)
        arguments.forEach { result.append($0.oscData) }
        return result
    }

}
