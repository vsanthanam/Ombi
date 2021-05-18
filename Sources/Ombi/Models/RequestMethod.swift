//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/8/21.
//

import Foundation

/// # RequestMethod
///
/// An enumeration defining HTTP methods as detailed in [RFC 7231 §4.3](https://datatracker.ietf.org/doc/html/rfc7231#section-4.3)
public enum RequestMethod: String, Equatable, Hashable, CustomStringConvertible {
    
    // MARK: - API
    
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
    case connect = "CONNECT"
    case head    = "HEAD"
    case options = "OPTIONS"
    case patch   = "PATCH"
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
