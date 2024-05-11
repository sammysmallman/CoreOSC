//
//  OSCArgumentError.swift
//  CoreOSC
//
//  Created by Sam Smallman on 26/02/2024.
//  Copyright © 2024 Sam Smallman. https://github.com/SammySmallman
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

public enum OSCArgumentError: Error {
    case invalidArgument
}

extension OSCArgumentError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidArgument:
            return NSLocalizedString("OSC_ARGUMENT_ERROR_INVALID_ARGUMENT", bundle: .module, comment: "OSC Argument Error: Invalid Argument")
        }
    }
}

