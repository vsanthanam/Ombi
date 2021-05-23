// Ombi
// RequestMethod.swift
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

/// An enumeration defining HTTP methods as detailed in [RFC 7231 §4.3](https://datatracker.ietf.org/doc/html/rfc7231#section-4.3)
///
/// - Tag: RequestMethod
public enum RequestMethod: String, Equatable, Hashable, CustomStringConvertible {

    // MARK: - API

    /// The "GET" method
    case get = "GET"

    /// The "POST" method
    case post = "POST"

    /// The "PUT" method
    case put = "PUT"

    /// The "DELETE" method
    case delete = "DELETE"

    /// The "CONNECT" method
    case connect = "CONNECT"

    /// The "HEAD" method
    case head = "HEAD"

    /// The "OPTIONS" method
    case options = "OPTIONS"

    /// The "PATCH" method
    case patch = "PATCH"

    /// The "TRACE" method
    case trace = "TRACE"

    // MARK: - Equatable

    public static func == (lhs: RequestMethod, rhs: RequestMethod) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        rawValue
    }
}
