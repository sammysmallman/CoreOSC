//
//  OSCBundleTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 14/08/2023.
//  Copyright © 2023 Sam Smallman. https://github.com/SammySmallman
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

final class OSCABundleTests: XCTestCase {

    func testSimpleFlatten() throws {
        let messages = [
                try! OSCMessage(with: "/core/osc/1"),
                try! OSCMessage(with: "/core/osc/2"),
                try! OSCMessage(with: "/core/osc/3")
        ]
        let bundle = OSCBundle(
            messages.map { .message($0) },
            timeTag: .immediate
        )
        XCTAssertEqual(bundle.flatten(), messages)
    }

    func testRecursiveFlatten() throws {
        let bundle = OSCBundle(
            [
                .message(try! OSCMessage(with: "/core/osc/1")),
                .message(try! OSCMessage(with: "/core/osc/2")),
                .message(try! OSCMessage(with: "/core/osc/3")),
                .bundle(OSCBundle(
                    [
                        .message(try! OSCMessage(with: "/core/osc/4")),
                        .message(try! OSCMessage(with: "/core/osc/5")),
                        .message(try! OSCMessage(with: "/core/osc/6")),
                        .bundle(OSCBundle(
                            [
                                .message(try! OSCMessage(with: "/core/osc/7")),
                                .message(try! OSCMessage(with: "/core/osc/8")),
                                .message(try! OSCMessage(with: "/core/osc/9")),

                            ],
                            timeTag: .immediate
                        ))
                    ],
                    timeTag: .immediate
                ))
            ],
            timeTag: .immediate
        )
        XCTAssertEqual(bundle.flatten(), [
            try! OSCMessage(with: "/core/osc/1"),
            try! OSCMessage(with: "/core/osc/2"),
            try! OSCMessage(with: "/core/osc/3"),
            try! OSCMessage(with: "/core/osc/4"),
            try! OSCMessage(with: "/core/osc/5"),
            try! OSCMessage(with: "/core/osc/6"),
            try! OSCMessage(with: "/core/osc/7"),
            try! OSCMessage(with: "/core/osc/8"),
            try! OSCMessage(with: "/core/osc/9")
        ])
    }

}
