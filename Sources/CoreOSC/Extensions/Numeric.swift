//
//  Numeric.swift
//  CoreOSC
//
//  Created by Sam Smallman on 18/07/2021.
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

extension UInt32 {

    var data: Data {
        var source = self
        return Data(bytes: &source, count: MemoryLayout<UInt32>.size)
    }

}

extension Int32 {

    var data: Data {
        var source = self
        return Data(bytes: &source, count: MemoryLayout<Int32>.size)
    }

}
