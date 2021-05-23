// Ombi
// AutomaticBodyCoding.swift
//
// MIT License
//
// Copyright (c) 2021 Varun Santhanam
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
//
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

/// Types that are both `AutomaticBodyEncoding` and `AutomaticBodyDecoding`
public typealias AutomaticBodyCoding = AutomaticBodyEncoding & AutomaticBodyDecoding

/// A protocol for types that can be expressed as  `Data`
/// - Tag: AutomaticBodyEncoding
public protocol AutomaticBodyEncoding {

    /// Convert `self` into `Data?`, or throw and error
    func asData() throws -> Data?
}

/// A protocol for types that can be initialized from  `Data` provided by a network response
/// - Tag: AutomaticBodyDecoding
public protocol AutomaticBodyDecoding {

    /// Create `Self` from `Data?`, or throw an error
    /// - Parameter fromData: The data to decode
    init?(fromData: Data?) throws
}
