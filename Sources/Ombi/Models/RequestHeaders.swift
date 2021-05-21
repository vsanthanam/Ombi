// Ombi
// RequestHeaders.swift
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

/// `RequestHeaders` is a value type that stores mapping of header keys an their values.
/// It is sent with a `Request` and recieved with a `RequestResponse`
///
/// See the the nested `Key` and `Value` types for more detailed information.
/// You can create a `RequestHeaders` using a dictionary litera containing those types.
public struct RequestHeaders: ExpressibleByDictionaryLiteral, Equatable, Hashable, CustomStringConvertible {

    // MARK: - Initializers

    /// Create an empty header with no keys and values
    public init() {
        headers = [:]
    }

    // MARK: - API

    /// # Key
    ///
    /// A `RequestHeaders.Key` is a value type used to describe keys in a header dictionary.
    ///
    /// You can create headers in a few ways:
    ///
    /// - Using any type that conforms to `RawRepresentable` where `RawValue` is `String`
    /// - Using any type that conforms to `CustomStringConvertible`
    /// - Using strings or string literals
    ///
    /// Commonly used values and additional factory methods are declared in an extension to reduce boilerplate and increase type safety.
    public struct Key: ExpressibleByStringLiteral, Equatable, Hashable, CustomStringConvertible {

        // MARK: - Initializers

        /// Create a `Key` from a `CustomStringConvertible`
        /// - Parameter value: The string convertible value
        public init<T>(_ value: T) where T: CustomStringConvertible {
            self = .init(description: value.description)
        }

        /// Create a `Key` from a `RawRepresentable`
        /// - Parameter value: The raw representable value
        public init<T>(_ value: T) where T: RawRepresentable, T.RawValue == String {
            self = .init(description: value.rawValue)
        }

        /// Create a `Key` from a `String`
        /// - Parameter value: The string
        public init(_ value: String) {
            self = .init(description: value)
        }

        // MARK: - ExpressibleByStringLiteral

        public typealias StringLiteralType = String

        public init(stringLiteral value: StringLiteralType) {
            self = .init(description: value)
        }

        // MARK: - Hashable

        public func hash(into hasher: inout Hasher) {
            hasher.combine(description)
        }

        // MARK: - Equatable

        public static func == (lhs: Key, rhs: Key) -> Bool {
            lhs.description == rhs.description
        }

        // MARK: - CustomStringConvertible

        public let description: String

        // MARK: - Private

        private init(description: String) {
            self.description = description
        }
    }

    /// # Value
    ///
    /// A `RequestHeaders.Value` is a value type used to describe values in a header dictionary.
    ///
    /// You can create values in a few ways:
    /// - Using any type that conforms to `RawRepresentable` where `RawValue` is `String`
    /// - Using any type that conforms to `CustomStringConvertible`
    /// - Using strings or string literals
    /// - Using integer literals
    /// - Using floating point literals
    ///
    /// Commonly used values and additional factory methods are declared in an extension to reduce boilerplate and increase type safety.
    public struct Value: ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, CustomStringConvertible, Equatable, Hashable {

        // MARK: - Initializers

        /// Create a `Value` from a `CustomStringConvertible`
        /// - Parameter value: The string convertible value
        public init<T>(_ value: T) where T: CustomStringConvertible {
            self = .init(description: value.description)
        }

        /// Create a `Value` from a `RawRepresentable`
        /// - Parameter value: The raw representable value
        public init<T>(_ value: T) where T: RawRepresentable, T.RawValue == String {
            self = .init(description: value.rawValue)
        }

        /// Create a `Value` from a `String`
        /// - Parameter value: The string
        public init(_ value: String) {
            self = .init(description: value)
        }

        // MARK: - CustomStringConvertibble

        public let description: String

        // MARK: - ExpressibleByStringLiteral

        public typealias StringLiteralType = String

        public init(stringLiteral value: String) {
            self = .string(value)
        }

        // MARK: - ExpressibleByIntegerLiteral

        public typealias IntegerLiteralType = Int

        public init(integerLiteral value: Int) {
            self = .int(value)
        }

        // MARK: - ExpressibleByFloatLiteral

        public typealias FloatLiteralType = Double

        public init(floatLiteral value: Double) {
            self = .double(value)
        }

        // MARK: - Hashable

        public func hash(into hasher: inout Hasher) {
            hasher.combine(description)
        }

        // MARK: - Equatable

        public static func == (lhs: Value, rhs: Value) -> Bool {
            lhs.description == rhs.description
        }

        // MARK: - Private

        private init(description: String) {
            self.description = description
        }

    }

    /// Retrieve the current value for a key
    /// - Parameter key: The key
    /// - Returns: The value for the key, if one exists
    public func value(for key: Key) -> Value? {
        headers[key]
    }

    /// Set the value for a key
    /// - Parameters:
    ///   - value: The new value
    ///   - key: The key
    /// - Note: Any previous value wil be discarded
    public mutating func set(value: Value?, forKey key: Key) {
        headers[key] = value
    }

    /// Remove a value for a key
    /// - Parameter key: The key
    public mutating func removeValue(forKey key: Key) {
        set(value: nil, forKey: key)
    }

    /// Returns the result of combining the elements of the sequence using the given closure.
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value. `initialResult` is passed to `nextPartialResult` the first time the closure is executed.
    ///   - nextPartialResult: A closure that combines an accumulating value and an element of the sequence into a new accumulating value, to be used in the next call of the `nextPartialResult` closure or returned to the caller.
    /// - Throws: Error from the reduction closure
    /// - Returns: The reduced value
    public func reduce<Result>(_ initialResult: Result,
                               _ nextPartialResult: (Result, (key: Key, value: Value)) throws -> Result) rethrows -> Result {
        try headers.reduce(initialResult, nextPartialResult)
    }

    // MARK: - Subscripting

    public subscript(key: Key) -> Value? {
        get {
            value(for: key)
        }
        set {
            set(value: newValue, forKey: key)
        }
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        headers.description
    }

    // MARK: - ExpressibleByDictionaryLiteral

    public init(dictionaryLiteral elements: (Key, Value)...) {
        headers = .init(elements, uniquingKeysWith: { lhs, rhs in lhs })
    }

    // MARK: - Equatable

    public static func == (lhs: RequestHeaders, rhs: RequestHeaders) -> Bool {
        lhs.headers == rhs.headers
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(headers)
    }

    // MARK: - Private

    private var headers = [Key: Value]()

}
