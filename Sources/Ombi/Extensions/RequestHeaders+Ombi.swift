//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

extension RequestHeaders.Key {
    
    // MARK: - Factory Methods
    
    /// The `Accept` header
    public static let acceptType: RequestHeaders.Key          = "Accept"
    
    /// The `Accept-Encoding` header
    public static let acceptEncoding: RequestHeaders.Key      = "Accept-Encoding"
    
    /// The `Accept-Language` header
    public static let acceptLanguage: RequestHeaders.Key      = "Accept-Language"
    
    /// The `Authorization` header
    public static let authorization: RequestHeaders.Key      = "Authorization"
    
    /// The `Content-Type` header
    public static let contentType: RequestHeaders.Key         = "Content-Type"
    
    /// The `Cache-Control` header
    public static let cacheControl: RequestHeaders.Key        = "Cache-Control"
    
    /// The `Content-Disposition` header
    public static let contentDisposition: RequestHeaders.Key  = "Content-Disposition"
    
    /// The `Content-Length` header
    public static let contentLength: RequestHeaders.Key       = "Content-Length"
    
    /// The `Host` header
    public static let host: RequestHeaders.Key                = "Host"
    
    /// The `Location` header
    public static let location: RequestHeaders.Key            = "Location"
    
    /// The `Origin` header
    public static let origin: RequestHeaders.Key              = "Origin"
    
    /// The `Referer` header
    public static let referer: RequestHeaders.Key             = "Referer"
    
    /// The `User-Agent` header
    public static let userAgent: RequestHeaders.Key           = "User-Agent"

}

extension RequestHeaders.Value {
    
    // MARK: - Factory Methods
    
    public static func string(_ value: String) -> RequestHeaders.Value {
        .init(value.description)
    }
    
    public static func int(_ value: Int) -> RequestHeaders.Value {
        .init(value.description)
    }
    
    public static func double(_ value: Double) -> RequestHeaders.Value {
        .init(value.description)
    }
    
    /// A value for the `Content-Type` header field
    /// - Parameter contentType: The content type value
    /// - Returns: The header value
    public static func contentType(_ contentType: ContentType) -> RequestHeaders.Value {
        .string(contentType.rawValue)
    }
    
    /// A value for the `Authorization` header field
    /// - Parameters:
    ///   - type: The type of authorization
    ///   - value: The value used to authenticate
    /// - Returns: The header value
    public static func authorization(type: AuthorizationType, value: String) -> RequestHeaders.Value {
        .string(type.description + " " + value)
    }
    
    /// A value for the `Authorization` header field based on a user and a password
    /// - Parameters:
    ///   - username: The username
    ///   - password: The password
    /// - Returns: The header value
    public static func authorization(username: String, password: String) -> RequestHeaders.Value {
        .string("Basic \(Data((username + ":" + password).utf8).base64EncodedString())")
    }
    
    /// A value for the `Cache-Control` header field
    /// - Parameter type: The cache control typr
    /// - Returns: The header value
    public static func cacheControlType(_ type: CacheControlType) -> RequestHeaders.Value {
        .string(type.description)
    }
    
    // MARK: - API
    
    /// Available content types
    public enum ContentType: String, CustomStringConvertible, Equatable, Hashable {
        
        // MARK: - API
        
        /// JSON content
        case json = "application/json"
        
        /// XML content
        case xml = "application/xml"
        
        /// Form urlencoded content
        case urlencoded = "application/x-www-form-urlencoded; charset=utf-8"
        
        // MARK: - CustomStringConvertible
        
        public var description: String {
            rawValue
        }
        
        // MARK: - Equatable
        
        public static func == (lhs: RequestHeaders.Value.ContentType, rhs: RequestHeaders.Value.ContentType) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
        
        // MARK: - Hashable
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
    
    /// Available Authorization Types
    public enum AuthorizationType: ExpressibleByStringLiteral, CustomStringConvertible, Equatable, Hashable {
        
        // MARK: - API
        
        /// Basic authorization
        case basic
        
        /// Bearer token authorization
        case bearer
        
        /// Digest token authorizatoin
        case digest
        
        /// Hoba token authorization
        case hoba
        
        /// Mutal authorization
        case mutual
        
        /// Aws authorization
        case aws
        
        /// Custom authorization type
        case custom(_ value: String)
        
        // MARK: - CustomStringConvertible
        
        public var description: String {
            switch self {
            case .basic:
                return "Basic"
            case .bearer:
                return "Bearer"
            case .digest:
                return "Digest"
            case .hoba:
                return "HOBA"
            case .mutual:
                return "Mutual"
            case .aws:
                return "AWS4-HMAC-SHA256"
            case .custom(let value):
                return value
            }
        }
        
        // MARK: - ExpressibleByStringLiteral
        
        public typealias StringLiteralType = String
        
        public init(stringLiteral value: String) {
            self = .custom(value)
        }
        
        // MARK: - Equatable
        
        public static func == (lhs: RequestHeaders.Value.AuthorizationType, rhs: RequestHeaders.Value.AuthorizationType) -> Bool {
            lhs.description == rhs.description
        }
        
        // MARK: - Hashable
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(description)
        }
    }
    
    /// Available cache control types
    public enum CacheControlType: ExpressibleByStringLiteral, CustomStringConvertible, Equatable, Hashable {
        
        /// No cache
        case noCache
        
        /// No store
        case noStore
        
        /// No transform
        case noTransform
        
        /// Only if cached
        case onlyIfCached
        
        /// Maximum age
        case maxAge(seconds: Int)
        
        /// Maximum stale
        case maxStale(seconds: Int?)
        
        /// Minimum Fresh
        case minFresh(seconds: Int)
        
        /// Custcom cache control
        case custom(_ value: String)
        
        // MARK: - CustomStringConvertibble
        
        public var description: String {
            switch self {
            case .noCache:
                return "no-cache"
            case .noStore:
                return "no-store"
            case .noTransform:
                return "no-transform"
            case .onlyIfCached:
                return "only-if-cached"
            case .maxAge(let seconds):
                return "max-age=\(seconds)"
            case .maxStale(let seconds):
                if let seconds = seconds {
                    return "max-stale=\(seconds)"
                } else {
                    return "max-stale"
                }
            case .minFresh(let seconds):
                return "min-fresh=\(seconds)"
            case .custom(let value):
                return value
            }
        }
        
        // MARK: - ExpressibleByStringLiteral
        
        public typealias StringLiteralType = String
        
        public init(stringLiteral value: String) {
            self = .custom(value)
        }
        
        // MARK: - Equatable
        
        public static func == (lhs: RequestHeaders.Value.CacheControlType, rhs: RequestHeaders.Value.CacheControlType) -> Bool {
            lhs.description == rhs.description
        }
        
        // MARK: - Hashable
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(description)
        }
    }
}
