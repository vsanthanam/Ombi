// Ombi
// AnyJSON.swift
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

/// A generic JSON value type that can be expressed with Swift Literals
///
/// - Tag: AnyJSON
public struct AnyJSON: ExpressibleByStringLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByBooleanLiteral {

    // MARK: - Initializers

    /// Create an `AnyJSON` from any type
    /// - Parameter obj: The object
    public init(_ obj: Any) {
        if !JSONSerialization.isValidJSONObject(obj) {
            assertionFailure("Attempting to wrap an invalid object using AnyJSON wrapper! This could lead to undefined behavior in production")
        }
        self.obj = obj
    }

    // MARK: - API

    /// The object wrapped by this `AnyJSON` wrapper
    public private(set) var obj: Any

    // MARK: - ExpressibleByDictionaryLiteral

    public typealias Key = AnyHashable

    public typealias Value = Any

    public init(dictionaryLiteral elements: (AnyHashable, Any)...) {
        var dict = [AnyHashable: Any]()
        for pair in elements {
            let (key, value) = pair
            dict[key] = value
        }
        self = .init(dict)
    }

    // MARK: - ExpressibleByStringLiteral

    public typealias StringLiteralType = String

    public init(stringLiteral value: String) {
        obj = value
    }

    // MARK: - ExpressibleByArrayLiteral

    public typealias ArrayLiteralElement = AnyJSON

    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self = .init([elements])
    }

    // MARK: - ExpressibleByFloatLiteral

    public typealias FloatLiteralType = Double

    public init(floatLiteral value: Double) {
        self = .init(value)
    }

    // MARK: - ExpressibleByIntegerLiteral

    public typealias IntegerLiteralType = Int

    public init(integerLiteral value: Int) {
        self = .init(value)
    }

    // MARK: - ExpressibleByBooleanLiteral

    public typealias BooleanLiteralType = Bool

    public init(booleanLiteral value: Bool) {
        self = .init(value)
    }

    // MARK: - Subscripting

    public subscript(key: AnyHashable) -> AnyJSON {
        get {
            guard let dict = obj as? [AnyHashable: Any] else {
                fatalError("Value cannot be subscripted")
            }
            guard let val = dict[key] else {
                fatalError("Invalid subscript")
            }
            return .init(val)
        }
        set {
            guard var dict = obj as? [AnyHashable: Any] else {
                fatalError("Value cannot be subscripted")
            }
            dict[key] = newValue
            obj = dict
        }
    }

    public subscript(index: Int) -> AnyJSON {
        get {
            guard let array = obj as? [Any] else {
                fatalError("Value cannot be subscripted")
            }
            return .init(array[index])
        }
        set {
            guard var array = obj as? [Any] else {
                fatalError("Value cannot be subscripted")
            }
            array[index] = newValue
            obj = array
        }
    }
}
