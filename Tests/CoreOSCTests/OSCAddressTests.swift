import XCTest
@testable import CoreOSC

class OSCAddressTests: XCTestCase {

    static var allTests = [
        ("testInitializingOSCAddressSucceeds", testInitializingOSCAddressSucceeds),
        ("testInitializingOSCAddressFails", testInitializingOSCAddressFails),
        ("testParts", testParts),
        ("testMethodName", testMethodName)
    ]

    func testInitializingOSCAddressSucceeds() {
        XCTAssertNoThrow(try OSCAddress("/core/osc"))
    }

    func testInitializingOSCAddressFails() {
        XCTAssertThrowsError(try OSCAddress("/"))
        XCTAssertThrowsError(try OSCAddress("core/osc"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/#"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/ "))
        XCTAssertThrowsError(try OSCAddress("/core/osc/*"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/,"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/?"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/["))
        XCTAssertThrowsError(try OSCAddress("/core/osc/]"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/{"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/}"))
    }

    func testParts() throws {
        let address = try OSCAddress("/core/osc/address")
        XCTAssertEqual(address.parts.count, 3)
        XCTAssertEqual(address.parts[0], "core")
        XCTAssertEqual(address.parts[1], "osc")
        XCTAssertEqual(address.parts[2], "address")
    }

    func testMethodName() throws {
        let address = try OSCAddress("/core/osc/methodName")
        XCTAssertEqual(address.methodName, "methodName")
    }

}
