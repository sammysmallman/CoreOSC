//
//  OSCParserError.swift
//  CoreOSC
//
//  Created by Sam Smallman on 13/08/2021.
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

public enum OSCParserError: Error {
    case unrecognisedData
    case cantParseAddressPattern
    case cantParseTypeTagString
    case cantParseOSCString
    case cantParseOSCInt
    case cantParseOSCFloat
    case cantParseOSCBlob
    case cantParseOSCTimeTag
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
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ADDRESS_PATTERN", bundle: .module, comment: "OSC Parser Error: Can't parse address pattern")
        case .cantParseTypeTagString:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_TYPE_TAG_STRING", bundle: .module, comment: "OSC Parser Error: Can't parse type tag string")
        case .cantParseOSCString:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ARGUMENT_STRING", bundle: .module, comment: "OSC Parser Error: Can't parse OSC string")
        case .cantParseOSCInt:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ARGUMENT_INT", bundle: .module, comment: "OSC Parser Error: Can't parse OSC integer")
        case .cantParseOSCFloat:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ARGUMENT_FLOAT", bundle: .module, comment: "OSC Parser Error: Can't parse OSC float")
        case .cantParseOSCBlob:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ARGUMENT_BLOB", bundle: .module, comment: "OSC Parser Error: Can't parse OSC blob")
        case .cantParseOSCTimeTag:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ARGUMENT_TIMETAG", bundle: .module, comment: "OSC Parser Error: Can't parse OSC time tag")
        case .cantParseSizeOfElement:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ELEMENT_SIZE", bundle: .module, comment: "OSC Parser Error: Can't parse size of element")
        case .cantParseTypeOfElement:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ELEMENT_TYPE", bundle: .module, comment: "OSC Parser Error: Can't parse type of element")
        case .cantParseBundleElement:
            return NSLocalizedString("OSC_PARSER_ERROR_CANT_PARSE_ELEMENT", bundle: .module, comment: "OSC Parser Error: Can't parse bundle element")
        }
    }
}
