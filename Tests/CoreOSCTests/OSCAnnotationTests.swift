//
//  OSCAnnotationTests.swift
//  
//
//  Created by Sam Smallman on 26/07/2021.
//

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
        let message = try OSCMessage("/core/osc", arguments: [1,
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
        let message = try OSCMessage("/core/osc", arguments: [1,
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
        let message = try OSCMessage("/core/osc", arguments: [1,
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
        let message = try OSCMessage("/core/osc", arguments: [1,
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
        XCTAssertTrue(OSCAnnotation.isValid(annotation: annotation, with: .spaces))
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
        XCTAssertTrue(OSCAnnotation.isValid(annotation: annotation, with: .equalsComma))
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
        XCTAssertTrue(OSCAnnotation.isValid(annotation: annotation, with: .spaces))
        let message = OSCAnnotation.message(for: annotation, with: .spaces)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 1)
        let argument = message?.arguments[0] as? String
        XCTAssertEqual(argument, "this should be a single string argument")
    }

    func testAnnotationToMessageEqualsCommaStyleSingleStringWithSpacesArgument() {
        let annotation = "/core/osc=\"this should be a single string argument\""
        XCTAssertTrue(OSCAnnotation.isValid(annotation: annotation, with: .equalsComma))
        let message = OSCAnnotation.message(for: annotation, with: .equalsComma)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.addressPattern.fullPath, "/core/osc")
        XCTAssertEqual(message?.arguments.count, 1)
        let argument = message?.arguments[0] as? String
        XCTAssertEqual(argument, "this should be a single string argument")
    }

}
