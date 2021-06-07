// Ombi
// RequestParameters.swift
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

/// `RequestParameters` are a type used to express values as a URL encoded form.
public struct RequestParameters: Equatable, Hashable, CustomStringConvertible, ExpressibleByDictionaryLiteral {

    // MARK: - Initializers

    public init(parameters: [ParameterName: ParameterValue] = [:]) {
        dict = parameters
    }

    // MARK: - API

    public struct ParameterName: Equatable, Hashable, ExpressibleByStringLiteral, CustomStringConvertible {

        // MARK: - Initializers

        public init(name: String) {
            self.name = name
        }

        // MARK: - ExpressibleByStringLiteral

        public typealias StringLiteralType = String

        public init(stringLiteral value: String) {
            self = .init(name: value)
        }

        // MARK: - Equatable

        public static func == (lhs: ParameterName, rhs: ParameterName) -> Bool {
            lhs.name == rhs.name
        }

        // MARK: - Hashable

        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }

        // MARK: - CustomStringConvertible

        public var description: String { name }

        // MARK: - Private

        private let name: String
    }

    public enum ParameterValue: Equatable, Hashable, ExpressibleByStringLiteral, ExpressibleByBooleanLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, CustomStringConvertible {

        // MARK: - API

        /// Int parameter value
        case int(_ int: Int)

        /// String parameter value
        case string(_ string: String)

        /// Double parameter value
        case double(_ double: Double)

        /// Bool parameter value
        case bool(_ bool: Bool)

        // MARK: - ExpressibleByStringLiteral

        public typealias StringLiteralType = String

        public init(stringLiteral value: String) {
            self = .string(value)
        }

        // MARK: - ExpressibleByBooleanLiteral

        public typealias BooleanLiteralType = Bool

        public init(booleanLiteral value: Bool) {
            self = .bool(value)
        }

        // MARK: - ExpressibleByFloatLiteral

        public typealias FloatLiteralType = Double

        public init(floatLiteral value: Double) {
            self = .double(value)
        }

        // MARK: - ExpressibleByIntegerLiteral

        public typealias IntegerLiteralType = Int

        public init(integerLiteral value: Int) {
            self = .int(value)
        }

        // MARK: - CustomStringConvertible

        public var description: String {
            switch self {
            case let .bool(value):
                return value.description
            case let .string(value):
                return value.description
            case let .double(value):
                return value.description
            case let .int(value):
                return value.description
            }
        }

        // MARK: - Hashable

        public func hash(into hasher: inout Hasher) {
            hasher.combine(description)
        }

        // MARK: - Equatable

        public static func == (lhs: ParameterValue, rhs: ParameterValue) -> Bool {
            lhs.description == rhs.description
        }
    }

    public var allParameters: [ParameterName] {
        .init(dict.keys)
    }

    // MARK: - ExpressibleByDictionaryLiteral

    public typealias Key = ParameterName

    public typealias Value = ParameterValue

    public init(dictionaryLiteral elements: (ParameterName, ParameterValue)...) {
        dict = elements.reduce([:]) { dict, pair in
            var next = dict
            let (key, value) = pair
            next[key] = value
            return next
        }
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(dict)
    }

    // MARK: - CustomStringConvertible

    public var description: String { dict.description }

    // MARK: - Subscripting

    subscript(key: ParameterName) -> ParameterValue? {
        get {
            dict[key]
        }
        set {
            dict[key] = newValue
        }
    }

    // MARK: - Private

    private var dict: [ParameterName: ParameterValue]
}
