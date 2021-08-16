//
//  OSCAnnotationTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 26/07/2021.
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

import XCTest
@testable import CoreOSC

final class OSCAnnotationTests: XCTestCase {

    static var allTests = [
        ("testMessageToAnnotationSpacesStyle",
         testMessageToAnnotationSpacesStyle),
        ("testMessageToAnnotationSpacesStyleWithoutType",
         testMessageToAnnotationSpacesStyleWithoutType),
        ("testMessageToAnnotationEqualsCommaStyle",
         testMessageToAnnotationEqualsCommaStyle),
        ("testMessageToAnnotationEqualsCommaStyleWithoutType",
         testMessageToAnnotationEqualsCommaStyleWithoutType),
        ("testAnnotationToMessageSpaceStyle",
         testAnnotationToMessageSpaceStyle),
        ("testAnnotationToMessageEqualsCommaStyle",
         testAnnotationToMessageEqualsCommaStyle),
        ("testAnnotationToMessageSpaceStyleSingleStringWithSpacesArgument",
         testAnnotationToMessageSpaceStyleSingleStringWithSpacesArgument),
        ("testAnnotationToMessageEqualsCommaStyleSingleStringWithSpacesArgument",
         testAnnotationToMessageEqualsCommaStyleSingleStringWithSpacesArgument)
    ]

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
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, with: .spaces))
        let message = OSCAnnotation.message(for: annotation, with: .spaces)
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
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, with: .equalsComma))
        let message = OSCAnnotation.message(for: annotation, with: .equalsComma)
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
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, with: .spaces))
        let message = OSCAnnotation.message(for: annotation, with: .spaces)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 1)
        let argument = message?.arguments[0] as? String
        XCTAssertEqual(argument, "this should be a single string argument")
    }

    func testAnnotationToMessageEqualsCommaStyleSingleStringWithSpacesArgument() {
        let annotation = "/core/osc=\"this should be a single string argument\""
        XCTAssertTrue(OSCAnnotation.evaluate(annotation, with: .equalsComma))
        let message = OSCAnnotation.message(for: annotation, with: .equalsComma)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 1)
        let argument = message?.arguments[0] as? String
        XCTAssertEqual(argument, "this should be a single string argument")
    }

}
