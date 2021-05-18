//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

public struct RequestParameters: Equatable, Hashable, CustomStringConvertible, ExpressibleByDictionaryLiteral {
    
    // MARK: - Initializers

    public init(parameters: [ParameterName: ParameterValue] = [:]) {
        self.dict = parameters
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
        
        case int(_ int: Int)
        
        case string(_ string: String)
        
        case double(_ double: Double)
        
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
            case .bool(let value):
                return value.description
            case .string(let value):
                return value.description
            case .double(let value):
                return value.description
            case .int(let value):
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

    private var dict: [ParameterName : ParameterValue]
}
