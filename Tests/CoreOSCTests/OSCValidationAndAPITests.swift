//
//  OSCValidationAndAPITests.swift
//  CoreOSCTests
//
//  Copyright © 2026 Sam Smallman. https://github.com/SammySmallman
//
//  This file is part of CoreOSC
//
//  CoreOSC is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Affero General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  CoreOSC is distributed in the hope that it will be useful
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Affero General Public License for more details.
//
//  You should have received a copy of the GNU Affero General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import CoreOSC

final class OSCValidationAndAPITests: XCTestCase {

    // MARK: - Validation parity
    // The byte-loop and cached-regex validators must accept and reject exactly
    // what the previous per-init NSPredicate regexes did.

    func testAddressPatternValidationParity() {
        XCTAssertNoThrow(try OSCAddressPattern("/core/osc/*"))
        XCTAssertNoThrow(try OSCAddressPattern("/a"))
        XCTAssertNoThrow(try OSCAddressPattern("//"))
        XCTAssertNoThrow(try OSCAddressPattern("/{a,b}/[c-d]/?"))
        XCTAssertThrowsError(try OSCAddressPattern("/"))
        XCTAssertThrowsError(try OSCAddressPattern(""))
        XCTAssertThrowsError(try OSCAddressPattern("core/osc"))
        XCTAssertThrowsError(try OSCAddressPattern("/core osc"))
        XCTAssertThrowsError(try OSCAddressPattern("/core#osc"))
        XCTAssertThrowsError(try OSCAddressPattern("/cöre/osc"))
    }

    func testAddressValidationParity() {
        XCTAssertNoThrow(try OSCAddress("/core/osc/method"))
        XCTAssertNoThrow(try OSCAddress("/a"))
        XCTAssertThrowsError(try OSCAddress("/"))
        XCTAssertThrowsError(try OSCAddress(""))
        XCTAssertThrowsError(try OSCAddress("core/osc"))
        XCTAssertThrowsError(try OSCAddress("/core osc"))
        XCTAssertThrowsError(try OSCAddress("/core#osc"))
        XCTAssertThrowsError(try OSCAddress("/core/osc/*"))
        XCTAssertThrowsError(try OSCAddress("/core,osc"))
        XCTAssertThrowsError(try OSCAddress("/core/osc?"))
        XCTAssertThrowsError(try OSCAddress("/core/[oa]sc"))
        XCTAssertThrowsError(try OSCAddress("/core/{a,b}"))
        XCTAssertThrowsError(try OSCAddress("/cöre"))
    }

    func testFilterAddressValidationParity() {
        XCTAssertNoThrow(try OSCFilterAddress("/core/#/method"))
        XCTAssertNoThrow(try OSCFilterAddress("/#"))
        XCTAssertThrowsError(try OSCFilterAddress("/core/os#c"))
        XCTAssertThrowsError(try OSCFilterAddress("/core osc"))
        XCTAssertThrowsError(try OSCFilterAddress("/"))
    }

    func testRefractingAddressValidationParity() {
        XCTAssertNoThrow(try OSCRefractingAddress("/osc/#1/theory"))
        XCTAssertNoThrow(try OSCRefractingAddress("/#2"))
        XCTAssertThrowsError(try OSCRefractingAddress("/osc/#0/theory"))
        XCTAssertThrowsError(try OSCRefractingAddress("/osc theory"))
        XCTAssertThrowsError(try OSCRefractingAddress("/"))
    }

    // MARK: - Codable

    func testAddressTypesRoundTripThroughCodable() throws {
        let address = try OSCAddress("/core/osc/method")
        let decodedAddress = try JSONDecoder().decode(OSCAddress.self, from: JSONEncoder().encode(address))
        XCTAssertEqual(decodedAddress, address)

        let filter = try OSCFilterAddress("/core/#/method")
        let decodedFilter = try JSONDecoder().decode(OSCFilterAddress.self, from: JSONEncoder().encode(filter))
        XCTAssertEqual(decodedFilter, filter)

        let refracting = try OSCRefractingAddress("/osc/#1/theory")
        let decodedRefracting = try JSONDecoder().decode(OSCRefractingAddress.self, from: JSONEncoder().encode(refracting))
        XCTAssertEqual(decodedRefracting, refracting)
    }

    // MARK: - Sendable
    // Compile-time proof: these calls fail to build if a conformance is dropped.

    func testValueTypesAreSendable() {
        func requireSendable<Value: Sendable>(_ type: Value.Type) {}
        requireSendable(OSCAddress.self)
        requireSendable(OSCFilterAddress.self)
        requireSendable(OSCRefractingAddress.self)
        requireSendable(OSCAddressStore.self)
        requireSendable(OSCFilterAddressStore.self)
        requireSendable(OSCStore.self)
        requireSendable(OSCPatternMatch.self)
    }

    // MARK: - Short-circuiting store matches

    func testAddressStoreMatchesAgreesWithCount() throws {
        let store = OSCAddressStore(addresses: [
            try OSCAddress("/core/osc/one"),
            try OSCAddress("/core/osc/two")
        ])
        let matching = OSCAddressPattern(raw: "/core/osc/*")
        let missing = OSCAddressPattern(raw: "/core/other/*")
        XCTAssertTrue(store.matches(with: matching))
        XCTAssertEqual(store.count(with: matching) > 0, store.matches(with: matching))
        XCTAssertFalse(store.matches(with: missing))
        XCTAssertEqual(store.count(with: missing) > 0, store.matches(with: missing))
    }

    func testFilterAddressStoreMatchesAgreesWithCount() throws {
        let store = OSCFilterAddressStore(addresses: [
            try OSCFilterAddress("/core/#/one"),
            try OSCFilterAddress("/core/osc/two")
        ])
        let matching = OSCAddressPattern(raw: "/core/anything/one")
        let missing = OSCAddressPattern(raw: "/core/osc/three")
        XCTAssertTrue(store.matches(with: matching))
        XCTAssertEqual(store.count(with: matching) > 0, store.matches(with: matching))
        XCTAssertFalse(store.matches(with: missing))
        XCTAssertEqual(store.count(with: missing) > 0, store.matches(with: missing))
    }

    func testOSCStoreMatchesBothCases() throws {
        let addressStore = OSCStore.address([try OSCAddress("/core/osc/one")])
        XCTAssertTrue(addressStore.matches(with: OSCAddressPattern(raw: "/core/osc/one")))
        XCTAssertFalse(addressStore.matches(with: OSCAddressPattern(raw: "/core/osc/two")))

        let filterStore = OSCStore.filter([try OSCFilterAddress("/core/#/one")])
        XCTAssertTrue(filterStore.matches(with: OSCAddressPattern(raw: "/core/anything/one")))
        XCTAssertFalse(filterStore.matches(with: OSCAddressPattern(raw: "/core/anything/two")))
    }

}
