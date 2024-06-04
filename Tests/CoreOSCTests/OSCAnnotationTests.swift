//
//  OSCAnnotationTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 26/07/2021.
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
        XCTAssertEqual(message?.arguments[0], .int32(1))
        XCTAssertEqual(message?.arguments[1], .float32(3.142))
        XCTAssertEqual(message?.arguments[2], .string("a string with spaces"))
        XCTAssertEqual(message?.arguments[3], .string("string"))
        XCTAssertEqual(message?.arguments[4], .true)
    }

    func testAnnotationToMessageEqualsCommaStyle() {
        let annotation = "/core/osc=1,3.142,\"a string with spaces\",string,true"
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, style: .equalsComma))
        let message = OSCAnnotation.message(for: annotation, style: .equalsComma)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 5)
        XCTAssertEqual(message?.arguments[0], .int32(1))
        XCTAssertEqual(message?.arguments[1], .float32(3.142))
        XCTAssertEqual(message?.arguments[2], .string("a string with spaces"))
        XCTAssertEqual(message?.arguments[3], .string("string"))
        XCTAssertEqual(message?.arguments[4], .true)
    }

    func testAnnotationToMessageSpaceStyleSingleStringWithSpacesArgument() {
        let annotation = "/core/osc \"this should be a single string argument\""
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, style: .spaces))
        let message = OSCAnnotation.message(for: annotation, style: .spaces)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 1)
        XCTAssertEqual(message?.arguments[0], .string("this should be a single string argument"))
    }

    func testAnnotationToMessageEqualsCommaStyleSingleStringWithSpacesArgument() {
        let annotation = "/core/osc=\"this should be a single string argument\""
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, style: .equalsComma))
        let message = OSCAnnotation.message(for: annotation, style: .equalsComma)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 1)
        XCTAssertEqual(message?.arguments[0], .string("this should be a single string argument"))
    }
    
    func testAnnotationToMessageSpaceStyleQuotedTypes() {
        let annotation = "/core/osc 1 \"1\" 3.142 \"3.142\" true \"true\" false \"false\" nil \"nil\" impulse \"impulse\""
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, style: .spaces))
        let message = OSCAnnotation.message(for: annotation, style: .spaces)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 12)
        XCTAssertEqual(message?.arguments[0], .int32(1))
        XCTAssertEqual(message?.arguments[1], .string("1"))
        XCTAssertEqual(message?.arguments[2], .float32(3.142))
        XCTAssertEqual(message?.arguments[3], .string("3.142"))
        XCTAssertEqual(message?.arguments[4], .true)
        XCTAssertEqual(message?.arguments[5], .string("true"))
        XCTAssertEqual(message?.arguments[6], .false)
        XCTAssertEqual(message?.arguments[7], .string("false"))
        XCTAssertEqual(message?.arguments[8], .nil)
        XCTAssertEqual(message?.arguments[9], .string("nil"))
        XCTAssertEqual(message?.arguments[10], .impulse)
        XCTAssertEqual(message?.arguments[11], .string("impulse"))
    }
    
    func testAnnotationToMessageEqualsCommaStyleQuotedTypes() {
        let annotation = "/core/osc=1,\"1\",3.142,\"3.142\",true,\"true\",false,\"false\",nil,\"nil\",impulse,\"impulse\""
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, style: .equalsComma))
        let message = OSCAnnotation.message(for: annotation, style: .equalsComma)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 12)
        XCTAssertEqual(message?.arguments[0], .int32(1))
        XCTAssertEqual(message?.arguments[1], .string("1"))
        XCTAssertEqual(message?.arguments[2], .float32(3.142))
        XCTAssertEqual(message?.arguments[3], .string("3.142"))
        XCTAssertEqual(message?.arguments[4], .true)
        XCTAssertEqual(message?.arguments[5], .string("true"))
        XCTAssertEqual(message?.arguments[6], .false)
        XCTAssertEqual(message?.arguments[7], .string("false"))
        XCTAssertEqual(message?.arguments[8], .nil)
        XCTAssertEqual(message?.arguments[9], .string("nil"))
        XCTAssertEqual(message?.arguments[10], .impulse)
        XCTAssertEqual(message?.arguments[11], .string("impulse"))
    }
    
    func testAnnotationToMessageSpaceStyleWithSingleDecimalStringArgument() {
        let annotation = "/core/osc 127.0.0.1"
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, style: .spaces))
        let message = OSCAnnotation.message(for: annotation, style: .spaces)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 1)
        XCTAssertEqual(message?.arguments[0], .string("127.0.0.1"))
    }
    
    func testAnnotationToMessageEqualsCommaStyleWithSingleDecimalStringArgument() {
        let annotation = "/core/osc=127.0.0.1"
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, style: .equalsComma))
        let message = OSCAnnotation.message(for: annotation, style: .equalsComma)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 1)
        XCTAssertEqual(message?.arguments[0], .string("127.0.0.1"))
    }

}
