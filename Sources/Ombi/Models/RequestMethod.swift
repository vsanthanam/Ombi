//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/8/21.
//

import Foundation

/// An enumeration defining HTTP methods as detailed in [RFC 7231 §4.3](https://datatracker.ietf.org/doc/html/rfc7231#section-4.3)
public enum RequestMethod: String, Equatable, Hashable, CustomStringConvertible {
    
    // MARK: - API
    
    /// The "GET" method
    case get     = "GET"
    
    /// The "POST" method
    case post    = "POST"
    
    /// The "PUT" method
    case put     = "PUT"
    
    /// The "DELETE" method
    case delete  = "DELETE"
    
    /// The "CONNECT" method
    case connect = "CONNECT"
    
    /// The "HEAD" method
    case head    = "HEAD"
    
    /// The "OPTIONS" method
    case options = "OPTIONS"
    
    /// The "PATCH" method
    case patch   = "PATCH"
    
    /// The "TRACE" method
    case trace   = "TRACE"
    
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
