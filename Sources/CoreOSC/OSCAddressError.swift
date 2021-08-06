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
            return NSLocalizedString("OSC_ADDRESS_ERROR_INVALID_ADDRESS", bundle: .module, comment: "OSC Address Error: Invalid Address")
        case .invalidPartCount:
            return NSLocalizedString("OSC_ADDRESS_ERROR_INVALID_PART_COUNT", bundle: .module, comment: "OSC Address Error: Invalid Part Count")
        case .forwardSlash:
            return NSLocalizedString("OSC_ADDRESS_ERROR_FORWARD_SLASH", bundle: .module, comment: "OSC Address Error: Begin with forward slash")
        case .ascii:
            return NSLocalizedString("OSC_ADDRESS_ERROR_ASCII", bundle: .module, comment: "OSC Address Error: ASCII")
        case .space:
            return NSLocalizedString("OSC_ADDRESS_ERROR_SPACE", bundle: .module, comment: "OSC Address Error: Space")
        case .hash:
            return NSLocalizedString("OSC_ADDRESS_ERROR_HASH", bundle: .module, comment: "OSC Address Error: Hash")
        case .asterisk:
            return NSLocalizedString("OSC_ADDRESS_ERROR_ASTERISK", bundle: .module, comment: "OSC Address Error: Asterisk")
        case .comma:
            return NSLocalizedString("OSC_ADDRESS_ERROR_COMMA", bundle: .module, comment: "OSC Address Error: Comma")
        case .questionMark:
            return NSLocalizedString("OSC_ADDRESS_ERROR_QUESTION_MARK", bundle: .module, comment: "OSC Address Error: Question Mark")
        case .openBracket:
            return NSLocalizedString("OSC_ADDRESS_ERROR_OPEN_BRACKET", bundle: .module, comment: "OSC Address Error: Open Bracket")
        case .closeBracket:
            return NSLocalizedString("OSC_ADDRESS_ERROR_CLOSE_BRACKET", bundle: .module, comment: "OSC Address Error: Close Bracket")
        case .openCurlyBrace:
            return NSLocalizedString("OSC_ADDRESS_ERROR_OPEN_CURLY_BRACE", bundle: .module, comment: "OSC Address Error: Open Curly Brace")
        case .closeCurlyBrace:
            return NSLocalizedString("OSC_ADDRESS_ERROR_CLOSE_CURLY_BRACE", bundle: .module, comment: "OSC Address Error: Close Curly Brace")
        case .wildcards:
            return NSLocalizedString("OSC_ADDRESS_ERROR_WILDCARDS", bundle: .module, comment: "OSC Address Error: Wildcards")
        }
    }
}
