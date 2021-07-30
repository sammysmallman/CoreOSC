import XCTest
@testable import CoreOSC

class OSCAddressTests: XCTestCase {

    static var allTests = [
        ("testInitializingOSCAddressPatternSucceeds", testInitializingOSCAddressPatternSucceeds),
        ("testInitializingOSCAddressPatternFails", testInitializingOSCAddressPatternFails),
        ("testParts", testParts),
        ("testMethodName", testMethodName)
    ]

    func testInitializingOSCAddressPatternSucceeds() {
        XCTAssertNoThrow(try OSCAddress("/core/osc"))
    }

    func testInitializingOSCAddressPatternFails() {
        XCTAssertThrowsError(try OSCAddress(""))
        XCTAssertThrowsError(try OSCAddress("/"))
        XCTAssertThrowsError(try OSCAddress("core/osc"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/ "))
        XCTAssertThrowsError(try OSCAddress("/core/osc/#"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/*"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/,"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/?"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/["))
        XCTAssertThrowsError(try OSCAddress("/core/osc/]"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/{"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/}"))
    }

    func testParts() throws {
        let address = try OSCAddress("/core/osc/address/pattern")
        XCTAssertEqual(address.parts.count, 4)
        XCTAssertEqual(address.parts[0], "core")
        XCTAssertEqual(address.parts[1], "osc")
        XCTAssertEqual(address.parts[2], "address")
        XCTAssertEqual(address.parts[3], "pattern")
    }

    func testMethodName() throws {
        let address = try OSCAddress("/core/osc/methodName")
        XCTAssertEqual(address.methodName, "methodName")
    }

}
