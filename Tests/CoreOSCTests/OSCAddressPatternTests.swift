import XCTest
@testable import CoreOSC

class OSCAddressPatternTests: XCTestCase {

    static var allTests = [
        ("testInitializingOSCAddressPatternSucceeds", testInitializingOSCAddressPatternSucceeds),
        ("testInitializingOSCAddressPatternFails", testInitializingOSCAddressPatternFails),
        ("testParts", testParts),
        ("testMethodName", testMethodName)
    ]

    func testInitializingOSCAddressPatternSucceeds() {
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc"))
        XCTAssertNoThrow(try OSCAddressPattern("//osc"))
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/*"))
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/,"))
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/?"))
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/["))
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/]"))
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/{"))
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/}"))
    }

    func testInitializingOSCAddressPatternFails() {
        XCTAssertThrowsError(try OSCAddressPattern(""))
        XCTAssertThrowsError(try OSCAddressPattern("/"))
        XCTAssertThrowsError(try OSCAddressPattern("core/osc"))
        XCTAssertThrowsError(try OSCAddressPattern("/core/osc/"))
        XCTAssertThrowsError(try OSCAddressPattern("/core/osc/#"))
        XCTAssertThrowsError(try OSCAddressPattern("/core/osc/ "))
    }

    func testParts() throws {
        let address = try OSCAddressPattern("/core/osc/address")
        XCTAssertEqual(address.parts.count, 3)
        XCTAssertEqual(address.parts[0], "core")
        XCTAssertEqual(address.parts[1], "osc")
        XCTAssertEqual(address.parts[2], "address")
    }

    func testMethodName() throws {
        let address = try OSCAddressPattern("/core/osc/methodName")
        XCTAssertEqual(address.methodName, "methodName")
    }

}
