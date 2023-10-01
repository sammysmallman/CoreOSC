//
//  OSCTemporalManager.swift
//  CoreOSC
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

public protocol OSCTemporalManagerDelegate: AnyObject {

    func temporalManager(_ manager: OSCTemporalManager,
                         invokeWithMessage message: OSCMessage,
                         userInfo: [AnyHashable : Any]?)

}

public struct OSCTemporalManager {

    let timeTagHandler: () -> OSCTimeTag
    let discardLateMessages: Bool
    weak var delegate: OSCTemporalManagerDelegate?

    internal init(
        timeTagHandler: @escaping () -> OSCTimeTag,
        discardLateMessages: Bool = false,
        delegate: OSCTemporalManagerDelegate? = nil
    ) {
        self.timeTagHandler = timeTagHandler
        self.discardLateMessages = discardLateMessages
        self.delegate = delegate
    }

    /// Invoke with a bundle.
    /// - Parameters:
    ///   - bundle: An OSC Bundle to invoke.
    ///   - userInfo: The user information dictionary stores any additional objects that the invoking action might use.
    public func invoke(with bundle: OSCBundle,
                       userInfo: [AnyHashable : Any]? = nil) {
        let timeTag = timeTagHandler()
        invoke(with: bundle, timeTag: timeTag, userInfo: userInfo)
    }

    public func invoke(with bundle: OSCBundle,
                       timeTag: OSCTimeTag,
                       userInfo: [AnyHashable : Any]?) {
        if discardLateMessages {
            if bundle.timeTag <= timeTag {
                for packet in bundle.elements where packet is OSCBundle {
                    invoke(with: packet as! OSCBundle, timeTag: timeTag, userInfo: userInfo)
                }
            } else {
                invokeUsingTimer(with: bundle, timeTag: timeTag, userInfo: userInfo)
            }
        } else {
            if bundle.timeTag <= timeTag {
                for packet in bundle.elements {
                    if let message = packet as? OSCMessage {
                        // Message is late but not discarded.
                        delegate?.temporalManager(self, invokeWithMessage: message, userInfo: userInfo)
                    } else if let subBundle = packet as? OSCBundle {
                        invoke(with: subBundle, timeTag: timeTag, userInfo: userInfo)
                    }
                }
            } else {
                invokeUsingTimer(with: bundle, timeTag: timeTag, userInfo: userInfo)
            }
        }
    }

    private func invokeUsingTimer(with bundle: OSCBundle,
                                  timeTag: OSCTimeTag,
                                  userInfo: [AnyHashable : Any]?) {
        var messages: [OSCMessage] = []
        for packet in bundle.elements {
            if let message = packet as? OSCMessage {
                messages.append(message)
            } else if let subBundle = packet as? OSCBundle {
                guard bundle.timeTag >= subBundle.timeTag else {
                    print("Invalid sub bundle time tag - dropping bundle and its contained elements.")
                    continue
                }
                invoke(with: subBundle, timeTag: timeTag, userInfo: userInfo)
            }
        }
        if !messages.isEmpty {
            // TODO: Start dealing with invoking the messages using the bundles timetag.
            messages.forEach {
                delegate?.temporalManager(self, invokeWithMessage: $0, userInfo: userInfo)
            }
        }
    }

}
