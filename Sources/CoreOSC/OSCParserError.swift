//
//  OSCParserError.swift
//  CoreOSC
//
//  Created by Sam Smallman on 13/08/2021.
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

public enum OSCParserError: Error {
    case unrecognisedData
    case cantParseAddressPattern
    case cantParseTypeTagString
    case cantParseString
    case cantParseInt32
    case cantParseFloat32
    case cantParseBlob
    case cantParseTimeTag
    case cantParseSizeOfElement
    case cantParseTypeOfElement
    case cantParseBundleElement
}

extension OSCParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unrecognisedData:
            return NSLocalizedString("OSC_PARSER_ERROR_UNRECOGNIZED_DATA", bundle: .module, comment: "OSC Parser Error: Unrecognized data")
        case .cantParseAddressPattern:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ADDRESS_PATTERN", bundle: .module, comment: "OSC Parser Error: Can't parse Address Pattern")
        case .cantParseTypeTagString:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_TYPE_TAG_STRING", bundle: .module, comment: "OSC Parser Error: Can't parse Type Tag String")
        case .cantParseString:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ARGUMENT_STRING", bundle: .module, comment: "OSC Parser Error: Can't parse String")
        case .cantParseInt32:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ARGUMENT_INT32", bundle: .module, comment: "OSC Parser Error: Can't parse Int32")
        case .cantParseFloat32:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ARGUMENT_FLOAT32", bundle: .module, comment: "OSC Parser Error: Can't parse Float32")
        case .cantParseBlob:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ARGUMENT_BLOB", bundle: .module, comment: "OSC Parser Error: Can't parse Blob")
        case .cantParseTimeTag:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ARGUMENT_TIMETAG", bundle: .module, comment: "OSC Parser Error: Can't parse Time Tag")
        case .cantParseSizeOfElement:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ELEMENT_SIZE", bundle: .module, comment: "OSC Parser Error: Can't parse size of element")
        case .cantParseTypeOfElement:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ELEMENT_TYPE", bundle: .module, comment: "OSC Parser Error: Can't parse type of element")
        case .cantParseBundleElement:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ELEMENT", bundle: .module, comment: "OSC Parser Error: Can't parse bundle element")
        }
    }
}
