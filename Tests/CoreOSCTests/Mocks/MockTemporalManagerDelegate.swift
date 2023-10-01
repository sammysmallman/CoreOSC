//
//  MockTemporalManagerDelegate.swift
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


import Foundation
@testable import CoreOSC

internal class MockTemporalManagerDelegate: OSCTemporalManagerDelegate {

    internal let invokeWithMessageClosure: ((_ manager: OSCTemporalManager,
                                             _ message: OSCMessage,
                                             _ userInfo: [AnyHashable : Any]?) -> Void)?

    internal init(
        invokeWithMessageClosure: ((OSCTemporalManager, OSCMessage, [AnyHashable : Any]?) -> Void)? = nil
    ) {
        self.invokeWithMessageClosure = invokeWithMessageClosure
    }

    internal func temporalManager(_ manager: OSCTemporalManager,
                                  invokeWithMessage message: OSCMessage,
                                  userInfo: [AnyHashable : Any]?) {
        guard let closure = invokeWithMessageClosure else { return }
        closure(manager, message, userInfo)

    }

}
