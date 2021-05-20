//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/17/21.
//

import Foundation

/// A generic JSON value type that can be expressed with Swift Literals
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
        self.obj = value
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
            self.obj = dict
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
            self.obj = array
        }
    }
}
