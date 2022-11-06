//
//  OSCAnnotationTests.swift
//  CoreOSCTests
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

import XCTest
@testable import CoreOSC

final class OSCAnnotationTests: XCTestCase {

    func testMessageToAnnotationSpacesStyle() throws {
        let message = try OSCMessage(with: "/core/osc", arguments: [1,
                                                                    3.142,
                                                                    "a string with spaces",
                                                                    "string",
                                                                    true,
                                                                    false,
                                                                    OSCArgument.nil,
                                                                    OSCArgument.impulse])
        let annotation = OSCAnnotation.annotation(for: message,
                                                  style: .spaces,
                                                  type: true)
        XCTAssertEqual(annotation,
                       """
                       /core/osc \
                       1(i) \
                       3.142(f) \
                       \"a string with spaces\"(s) \
                       string(s) \
                       true(T) \
                       false(F) \
                       nil(N) \
                       impulse(I)
                       """)
    }

    func testMessageToAnnotationSpacesStyleWithoutType() throws {
        let message = try OSCMessage(with: "/core/osc", arguments: [1,
                                                                    3.142,
                                                                    "a string with spaces",
                                                                    "string",
                                                                    true,
                                                                    false,
                                                                    OSCArgument.nil,
                                                                    OSCArgument.impulse])
        let annotation = OSCAnnotation.annotation(for: message,
                                                  style: .spaces,
                                                  type: false)
        XCTAssertEqual(annotation,
                       """
                       /core/osc \
                       1 \
                       3.142 \
                       \"a string with spaces\" \
                       string \
                       true \
                       false \
                       nil \
                       impulse
                       """)
    }

    func testMessageToAnnotationEqualsCommaStyle() throws {
        let message = try OSCMessage(with: "/core/osc", arguments: [1,
                                                                    3.142,
                                                                    "a string with spaces",
                                                                    "string",
                                                                    true,
                                                                    false,
                                                                    OSCArgument.nil,
                                                                    OSCArgument.impulse])
        let annotation = OSCAnnotation.annotation(for: message,
                                                  style: .equalsComma,
                                                  type: true)
        XCTAssertEqual(annotation,
                       """
                       /core/osc=\
                       1(i),\
                       3.142(f),\
                       \"a string with spaces\"(s),\
                       string(s),\
                       true(T),\
                       false(F),\
                       nil(N),\
                       impulse(I)
                       """)
    }

    func testMessageToAnnotationEqualsCommaStyleWithoutType() throws {
        let message = try OSCMessage(with: "/core/osc", arguments: [1,
                                                                    3.142,
                                                                    "a string with spaces",
                                                                    "string",
                                                                    true,
                                                                    false,
                                                                    OSCArgument.nil,
                                                                    OSCArgument.impulse])
        let annotation = OSCAnnotation.annotation(for: message,
                                                  style: .equalsComma,
                                                  type: false)
        XCTAssertEqual(annotation,
                       """
                       /core/osc=\
                       1,\
                       3.142,\
                       \"a string with spaces\",\
                       string,\
                       true,\
                       false,\
                       nil,\
                       impulse
                       """)
    }

    func testAnnotationToMessageSpaceStyle() {
        let annotation = "/core/osc 1 3.142 \"a string with spaces\" string true"
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, style: .spaces))
        let message = OSCAnnotation.message(for: annotation, style: .spaces)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 5)
        let argument1 = message?.arguments[0] as? Int32
        XCTAssertEqual(argument1, 1)
        let argument2 = message?.arguments[1] as? Float32
        XCTAssertEqual(argument2, 3.142)
        let argument3 = message?.arguments[2] as? String
        XCTAssertEqual(argument3, "a string with spaces")
        let argument4 = message?.arguments[3] as? String
        XCTAssertEqual(argument4, "string")
        let argument5 = message?.arguments[4] as? Bool
        XCTAssertEqual(argument5, true)
    }

    func testAnnotationToMessageEqualsCommaStyle() {
        let annotation = "/core/osc=1,3.142,\"a string with spaces\",string,true"
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, style: .equalsComma))
        let message = OSCAnnotation.message(for: annotation, style: .equalsComma)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 5)
        let argument1 = message?.arguments[0] as? Int32
        XCTAssertEqual(argument1, 1)
        let argument2 = message?.arguments[1] as? Float32
        XCTAssertEqual(argument2, 3.142)
        let argument3 = message?.arguments[2] as? String
        XCTAssertEqual(argument3, "a string with spaces")
        let argument4 = message?.arguments[3] as? String
        XCTAssertEqual(argument4, "string")
        let argument5 = message?.arguments[4] as? Bool
        XCTAssertEqual(argument5, true)
    }

    func testAnnotationToMessageSpaceStyleSingleStringWithSpacesArgument() {
        let annotation = "/core/osc \"this should be a single string argument\""
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, style: .spaces))
        let message = OSCAnnotation.message(for: annotation, style: .spaces)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 1)
        let argument = message?.arguments[0] as? String
        XCTAssertEqual(argument, "this should be a single string argument")
    }

    func testAnnotationToMessageEqualsCommaStyleSingleStringWithSpacesArgument() {
        let annotation = "/core/osc=\"this should be a single string argument\""
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, style: .equalsComma))
        let message = OSCAnnotation.message(for: annotation, style: .equalsComma)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 1)
        let argument = message?.arguments[0] as? String
        XCTAssertEqual(argument, "this should be a single string argument")
    }
    
    func testAnnotationToMessageSpaceStyleQuotedTypes() {
        let annotation = "/core/osc 1 \"1\" 3.142 \"3.142\" true \"true\" false \"false\" nil \"nil\" impulse \"impulse\""
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, style: .spaces))
        let message = OSCAnnotation.message(for: annotation, style: .spaces)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 12)
        let argument1 = message?.arguments[0] as? Int32
        XCTAssertEqual(argument1, 1)
        let argument2 = message?.arguments[1] as? String
        XCTAssertEqual(argument2, "1")
        let argument3 = message?.arguments[2] as? Float32
        XCTAssertEqual(argument3, 3.142)
        let argument4 = message?.arguments[3] as? String
        XCTAssertEqual(argument4, "3.142")
        let argument5 = message?.arguments[4] as? Bool
        XCTAssertEqual(argument5, true)
        let argument6 = message?.arguments[5] as? String
        XCTAssertEqual(argument6, "true")
        let argument7 = message?.arguments[6] as? Bool
        XCTAssertEqual(argument7, false)
        let argument8 = message?.arguments[7] as? String
        XCTAssertEqual(argument8, "false")
        let argument9 = message?.arguments[8] as? OSCArgument
        XCTAssertEqual(argument9, OSCArgument.nil)
        let argument10 = message?.arguments[9] as? String
        XCTAssertEqual(argument10, "nil")
        let argument11 = message?.arguments[10] as? OSCArgument
        XCTAssertEqual(argument11, OSCArgument.impulse)
        let argument12 = message?.arguments[11] as? String
        XCTAssertEqual(argument12, "impulse")
    }
    
    func testAnnotationToMessageEqualsCommaStyleQuotedTypes() {
        let annotation = "/core/osc=1,\"1\",3.142,\"3.142\",true,\"true\",false,\"false\",nil,\"nil\",impulse,\"impulse\""
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, style: .equalsComma))
        let message = OSCAnnotation.message(for: annotation, style: .equalsComma)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 12)
        let argument1 = message?.arguments[0] as? Int32
        XCTAssertEqual(argument1, 1)
        let argument2 = message?.arguments[1] as? String
        XCTAssertEqual(argument2, "1")
        let argument3 = message?.arguments[2] as? Float32
        XCTAssertEqual(argument3, 3.142)
        let argument4 = message?.arguments[3] as? String
        XCTAssertEqual(argument4, "3.142")
        let argument5 = message?.arguments[4] as? Bool
        XCTAssertEqual(argument5, true)
        let argument6 = message?.arguments[5] as? String
        XCTAssertEqual(argument6, "true")
        let argument7 = message?.arguments[6] as? Bool
        XCTAssertEqual(argument7, false)
        let argument8 = message?.arguments[7] as? String
        XCTAssertEqual(argument8, "false")
        let argument9 = message?.arguments[8] as? OSCArgument
        XCTAssertEqual(argument9, OSCArgument.nil)
        let argument10 = message?.arguments[9] as? String
        XCTAssertEqual(argument10, "nil")
        let argument11 = message?.arguments[10] as? OSCArgument
        XCTAssertEqual(argument11, OSCArgument.impulse)
        let argument12 = message?.arguments[11] as? String
        XCTAssertEqual(argument12, "impulse")
    }

}
