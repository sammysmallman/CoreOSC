import XCTest
@testable import CoreOSC

class OSCRefractingAddressTests: XCTestCase {

    static var allTests = [
        ("testInitializingOSCRefractingAddressSucceeds", testInitializingOSCRefractingAddressSucceeds),
        ("testInitializingOSCRefractingAddressFails", testInitializingOSCRefractingAddressFails),
        ("testParts", testParts),
        ("testMethodName", testMethodName),
        ("testRefracting", testRefracting)
    ]

    func testInitializingOSCRefractingAddressSucceeds() {
        XCTAssertNoThrow(try OSCRefractingAddress("/core/#1/osc"))
        XCTAssertNoThrow(try OSCRefractingAddress("/#1"))
        XCTAssertNoThrow(try OSCRefractingAddress("//#1"))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/*"))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/,"))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/?"))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/["))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/]"))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/{"))
        XCTAssertNoThrow(try OSCRefractingAddress("/core/osc/}"))
    }

    func testInitializingOSCRefractingAddressFails() {
        XCTAssertThrowsError(try OSCRefractingAddress(""))
        XCTAssertThrowsError(try OSCRefractingAddress("/"))
        XCTAssertThrowsError(try OSCRefractingAddress("/#0"))
        XCTAssertThrowsError(try OSCRefractingAddress("/#1/"))
        XCTAssertThrowsError(try OSCRefractingAddress("core/osc"))
        XCTAssertThrowsError(try OSCRefractingAddress("/core/osc/"))
        XCTAssertThrowsError(try OSCRefractingAddress("/core/osc/#"))
        XCTAssertThrowsError(try OSCRefractingAddress("/core/osc/#100"))
        XCTAssertThrowsError(try OSCRefractingAddress("/core/osc/#1abc"))
    }

    func testParts() throws {
        let address = try OSCRefractingAddress("/core/#1/#2")
        XCTAssertEqual(address.parts.count, 3)
        XCTAssertEqual(address.parts[0], "core")
        XCTAssertEqual(address.parts[1], "#1")
        XCTAssertEqual(address.parts[2], "#2")
    }

    func testMethodName() throws {
        let address = try OSCRefractingAddress("/core/osc/#3")
        XCTAssertEqual(address.methodName, "#3")
    }
    
    func testRefracting() throws {
        let address = try OSCAddress("/core/osc/refracting/test")
        let refractingAddress1 = try OSCRefractingAddress("/core/#2/#4")
        var refractedAddress = try refractingAddress1.refract(address: address)
        XCTAssertEqual(refractedAddress.fullPath, "/core/osc/test")
        
        let refractingAddress2 = try OSCRefractingAddress("/#4/#3/#2/#1")
        refractedAddress = try refractingAddress2.refract(address: address)
        XCTAssertEqual(refractedAddress.fullPath, "/test/refracting/osc/core")
        
        let refractingAddress3 = try OSCRefractingAddress("/#3/#1/#4/#2")
        refractedAddress = try refractingAddress3.refract(address: address)
        XCTAssertEqual(refractedAddress.fullPath, "/refracting/core/test/osc")
        
        let refractingAddress4 = try OSCRefractingAddress("/core/osc/test")
        refractedAddress = try refractingAddress4.refract(address: address)
        XCTAssertEqual(refractedAddress.fullPath, "/core/osc/test")
        
        let refractingAddress5 = try OSCRefractingAddress("/core/osc/#5")
        XCTAssertThrowsError(try refractingAddress5.refract(address: address))
    }

}
