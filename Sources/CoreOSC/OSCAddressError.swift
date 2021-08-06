//
//  OSCAddressError.swift
//  CoreOSC
//
//  Created by Sam Smallman on 29/07/2021.
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

public enum OSCAddressError: Error {
    case invalidAddress
    case invalidPartCount
    case forwardSlash
    case ascii
    case space
    case hash
    case asterisk
    case comma
    case questionMark
    case openBracket
    case closeBracket
    case openCurlyBrace
    case closeCurlyBrace
    case wildcards
}

extension OSCAddressError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidAddress:
            return NSLocalizedString("CORE_OSC_INVALID_ADDRESS", bundle: .module, comment: "Core OSC: Invalid Address")
        case .invalidPartCount:
            return NSLocalizedString("CORE_OSC_INVALID_PART_COUNT", bundle: .module, comment: "Core OSC: Invalid Part Count")
        case .forwardSlash:
            return NSLocalizedString("CORE_OSC_FORWARD_SLASH", bundle: .module, comment: "Core OSC: Begin with forward slash")
        case .ascii:
            return NSLocalizedString("CORE_OSC_ASCII", bundle: .module, comment: "Core OSC: ASCII")
        case .space:
            return NSLocalizedString("CORE_OSC_SPACE", bundle: .module, comment: "Core OSC: Space")
        case .hash:
            return NSLocalizedString("CORE_OSC_HASH", bundle: .module, comment: "Core OSC: Hash")
        case .asterisk:
            return NSLocalizedString("CORE_OSC_ASTERISK", bundle: .module, comment: "Core OSC: Asterisk")
        case .comma:
            return NSLocalizedString("CORE_OSC_COMMA", bundle: .module, comment: "Core OSC: Comma")
        case .questionMark:
            return NSLocalizedString("CORE_OSC_QUESTION_MARK", bundle: .module, comment: "Core OSC: Question Mark")
        case .openBracket:
            return NSLocalizedString("CORE_OSC_OPEN_BRACKET", bundle: .module, comment: "Core OSC: Open Bracket")
        case .closeBracket:
            return NSLocalizedString("CORE_OSC_CLOSE_BRACKET", bundle: .module, comment: "Core OSC: Close Bracket")
        case .openCurlyBrace:
            return NSLocalizedString("CORE_OSC_OPEN_CURLY_BRACE", bundle: .module, comment: "Core OSC: Open Curly Brace")
        case .closeCurlyBrace:
            return NSLocalizedString("CORE_OSC_CLOSE_CURLY_BRACE", bundle: .module, comment: "Core OSC: Close Curly Brace")
        case .wildcards:
            return NSLocalizedString("CORE_OSC_WILDCARDS", bundle: .module, comment: "Core OSC: Wildcards")
        }
    }
}
