//
//  OSCAddressFilter.swift
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

internal class OSCAddressMethodMatch: Equatable {

    let method: OSCFilterMethod
    var strings: Int
    var wildcards: Int

    init(method: OSCFilterMethod, strings: Int = 0, wildcards: Int = 0) {
        self.method = method
        self.strings = strings
        self.wildcards = wildcards
    }

    static func == (lhs: OSCAddressMethodMatch, rhs: OSCAddressMethodMatch) -> Bool {
        return lhs.method.address == rhs.method.address
    }
}

public enum OSCAddressSpaceMatchPriority {
    case string
    case wildcard
    case none
}

public class OSCAddressFilter {

    public var methods: Set<OSCFilterMethod> = []

    public init(addressSpace: Set<OSCFilterMethod> = []) {
        self.methods = addressSpace
    }

    // MARK: - Pattern Matching
    private func matches(for address: String,
                         priority: OSCAddressSpaceMatchPriority = .none) -> Set<OSCFilterMethod> {
        var parts = address.components(separatedBy: "/")
        parts.removeFirst()
        var matchedAddresses = methods.map { OSCAddressMethodMatch(method: $0) }
        // 1. The OSC Address and the OSC Address Pattern contain the same number of parts; and
        let matchedAddressesWithEqualPartsCount = matchedAddresses.filter {
            parts.count == $0.method.address.parts.count
        }
        matchedAddresses = matchedAddressesWithEqualPartsCount
        // 2. Each part of the OSC Address Pattern matches the corresponding part of the OSC Address.
        for (index, part) in parts.enumerated() {
            matchedAddressesWithEqualPartsCount.forEach { match in
                switch match.method.match(part: part, atIndex: index) {
                case .string:
                    match.strings += 1
                case .wildcard:
                    match.wildcards += 1
                case .different:
                    matchedAddresses = matchedAddresses.filter { match != $0 }
                }
            }
        }
        switch priority {
        case .none: return Set(matchedAddresses.map { $0.method })
        case .string:
            let sorted = matchedAddresses
                .sorted { $0.strings > $1.strings }
                .map { $0.method }
            guard let first = sorted.first else { return [] }
            return [first]
        case .wildcard:
            let sorted = matchedAddresses
                .sorted { $0.wildcards > $1.wildcards }
                .map { $0.method }
            guard let first = sorted.first else { return [] }
            return [first]
        }
    }

    public func complete(with message: OSCMessage,
                         priority: OSCAddressSpaceMatchPriority = .none) -> Bool {
        let methods = matches(for: message.addressPattern.fullPath, priority: priority)
        guard !methods.isEmpty else { return false }
        methods.forEach { $0.completionHandler(message) }
        return true
    }

}