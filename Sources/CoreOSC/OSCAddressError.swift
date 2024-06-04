//
//  OSCAddressError.swift
//  CoreOSC
//
//  Created by Sam Smallman on 29/07/2021.
//  Copyright © 2021 Sam Smallman. https://github.com/SammySmallman
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
