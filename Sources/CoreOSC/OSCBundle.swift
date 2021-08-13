//
//  OSCBundle.swift
//  CoreOSC
//
//  Created by Sam Smallman on 22/07/2021.
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

/// An OSC Bundle.
public struct OSCBundle: OSCPacket {

    public var timeTag: OSCTimeTag
    public var elements: [OSCPacket]

    public init(with elements: [OSCPacket] = [], timeTag: OSCTimeTag = .immediate) {
        self.timeTag = timeTag
        self.elements = elements
    }

    /// The OSC Packet data for the bundle.
    public func data() -> Data {
        var result = "#bundle".oscData
        result.append(timeTag.oscData)
        for element in elements {
            if let message = element as? OSCMessage {
                let data = message.data()
                let size = withUnsafeBytes(of: Int32(data.count).bigEndian) { Data($0) }
                result.append(size)
                result.append(data)
                continue
            }
            if let bundle = element as? OSCBundle {
                let data = bundle.data()
                let size = withUnsafeBytes(of: Int32(data.count).bigEndian) { Data($0) }
                result.append(size)
                result.append(data)
                continue
            }
        }
        return result
    }

}
