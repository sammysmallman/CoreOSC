//
//  CoreOSCTests.swift
//  CoreOSCTests
//
//  Created by Sam Smallman on 03/02/2021.
//  Copyright © 2021 Sam Smallman. https://github.com/SammySmallman
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

import XCTest
@testable import CoreOSC

class CoreOSCTests: XCTestCase {

    func testVersion() {
        XCTAssertEqual(CoreOSC.version, "2.0.0")
        XCTAssertEqual(NSLocalizedString("OSC_VERSION", bundle: .module, comment: "OSC Version"), CoreOSC.version)
    }
    
    func testLicense() {
        let license = CoreOSC.license
        XCTAssertTrue(license.hasPrefix("Copyright © 2021 Sam Smallman. https://github.com/SammySmallman"))
        XCTAssertTrue(license.hasSuffix("<https://www.gnu.org/licenses/why-not-lgpl.html>.\n"))
    }
    
}
