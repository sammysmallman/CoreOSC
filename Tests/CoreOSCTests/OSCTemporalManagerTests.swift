//
//  OSCTemporalManagerTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 15/08/2023.
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

class OSCTemporalManagerTests: XCTestCase {

    func testInvokeLateBundles() throws {

        let expectation = expectation(description: "OSC Message is invoked")

        let message = try OSCMessage(with: "/core/osc")
        let mock = MockTemporalManagerDelegate(
            invokeWithMessageClosure: { manager, invokedMessage, userInfo in
                guard message == invokedMessage else {
                    return
                }
                expectation.fulfill()
            }
        )
        let date = Date.now
        let manager = OSCTemporalManager(
            timeTagHandler: { OSCTimeTag(date: date) },
            discardLateMessages: false,
            delegate: mock
        )
        manager.invoke(with: OSCBundle([message],timeTag: OSCTimeTag(date: date - 1)))

        waitForExpectations(timeout: 0)
    }

    func testInvokeLateRecursiveBundles() throws {

        let expectation1 = expectation(description: "OSC Message 1 is invoked")
        let expectation2 = expectation(description: "OSC Message 2 is invoked")

        let message1 = try OSCMessage(with: "/core/osc/1")
        let message2 = try OSCMessage(with: "/core/osc/2")
        let mock = MockTemporalManagerDelegate(
            invokeWithMessageClosure: { manager, invokedMessage, userInfo in
                if invokedMessage == message1 {
                    expectation1.fulfill()
                }
                if invokedMessage == message2 {
                    expectation2.fulfill()
                }
            }
        )
        let date = Date.now
        let manager = OSCTemporalManager(
            timeTagHandler: { OSCTimeTag(date: date) },
            discardLateMessages: false,
            delegate: mock
        )
        let timeTag = OSCTimeTag(date: date - 1)
        manager.invoke(with: OSCBundle(
            [
                message1,
                OSCBundle(
                    [message2],
                    timeTag: OSCTimeTag(date: date + 0.1)
                )
            ],
            timeTag:timeTag)
        )

        waitForExpectations(timeout: 0.2)
    }

    func testDiscardLateBundles() throws {
        let expectation = expectation(description: "OSC Message is not invoked")
        expectation.isInverted = true
        let message = try OSCMessage(with: "/core/osc")
        let mock = MockTemporalManagerDelegate(
            invokeWithMessageClosure: { manager, invokedMessage, userInfo in
                print("invoked")
                guard message == invokedMessage else {
                    return
                }
                expectation.fulfill()
            }
        )
        let date = Date.now
        let manager = OSCTemporalManager(
            timeTagHandler: { OSCTimeTag(date: date) },
            discardLateMessages: true,
            delegate: mock
        )
        manager.invoke(with: OSCBundle([message],timeTag: OSCTimeTag(date: date - 1)))

        waitForExpectations(timeout: 0)
    }

    func testDiscardLateRecursiveBundles() throws {

        let expectation1 = expectation(description: "OSC Message 1 is invoked")
        expectation1.isInverted = true
        let expectation2 = expectation(description: "OSC Message 2 is invoked")

        let message1 = try OSCMessage(with: "/core/osc/1")
        let message2 = try OSCMessage(with: "/core/osc/2")
        let mock = MockTemporalManagerDelegate(
            invokeWithMessageClosure: { manager, invokedMessage, userInfo in
                if invokedMessage == message1 {
                    expectation1.fulfill()
                }
                if invokedMessage == message2 {
                    expectation2.fulfill()
                }
            }
        )
        let date = Date.now
        let manager = OSCTemporalManager(
            timeTagHandler: { OSCTimeTag(date: date) },
            discardLateMessages: true,
            delegate: mock
        )
        let timeTag = OSCTimeTag(date: date - 1)
        manager.invoke(with: OSCBundle(
            [
                message1,
                OSCBundle(
                    [message2],
                    timeTag: OSCTimeTag(date: date + 0.1)
                )
            ],
            timeTag:timeTag)
        )

        waitForExpectations(timeout: 0.5)
    }

}
