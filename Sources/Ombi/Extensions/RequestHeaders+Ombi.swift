// Ombi
// RequestHeaders+Ombi.swift
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

public extension RequestHeaders.Key {

    // MARK: - Factory Methods

    /// The `Accept` header
    static let acceptType: RequestHeaders.Key = "Accept"

    /// The `Accept-Encoding` header
    static let acceptEncoding: RequestHeaders.Key = "Accept-Encoding"

    /// The `Accept-Language` header
    static let acceptLanguage: RequestHeaders.Key = "Accept-Language"

    /// The `Authorization` header
    static let authorization: RequestHeaders.Key = "Authorization"

    /// The `Content-Type` header
    static let contentType: RequestHeaders.Key = "Content-Type"

    /// The `Cache-Control` header
    static let cacheControl: RequestHeaders.Key = "Cache-Control"

    /// The `Content-Disposition` header
    static let contentDisposition: RequestHeaders.Key = "Content-Disposition"

    /// The `Content-Length` header
    static let contentLength: RequestHeaders.Key = "Content-Length"

    /// The `Host` header
    static let host: RequestHeaders.Key = "Host"

    /// The `Location` header
    static let location: RequestHeaders.Key = "Location"

    /// The `Origin` header
    static let origin: RequestHeaders.Key = "Origin"

    /// The `Referer` header
    static let referer: RequestHeaders.Key = "Referer"

    /// The `User-Agent` header
    static let userAgent: RequestHeaders.Key = "User-Agent"

}

public extension RequestHeaders.Value {

    // MARK: - Factory Methods

    /// Create a header value from a `String`
    /// - Parameter value: The `String` value
    /// - Returns: The header value
    static func string(_ value: String) -> RequestHeaders.Value {
        .init(value.description)
    }

    /// Create a header from an `Int`
    /// - Parameter value: The `Int` value
    /// - Returns: The header value
    static func int(_ value: Int) -> RequestHeaders.Value {
        .init(value.description)
    }

    /// Create a header from a `Double`
    /// - Parameter value: The `Double` value
    /// - Returns: The header value
    static func double(_ value: Double) -> RequestHeaders.Value {
        .init(value.description)
    }

    /// A value for the `Content-Type` header field
    /// - Parameter contentType: The content type value
    /// - Returns: The header value
    static func contentType(_ contentType: ContentType) -> RequestHeaders.Value {
        .string(contentType.rawValue)
    }

    /// A value for the `Authorization` header field
    /// - Parameters:
    ///   - type: The type of authorization
    ///   - value: The value used to authenticate
    /// - Returns: The header value
    static func authorization(type: AuthorizationType, value: String) -> RequestHeaders.Value {
        .string(type.description + " " + value)
    }

    /// A value for the `Authorization` header field based on a user and a password
    /// - Parameters:
    ///   - username: The username
    ///   - password: The password
    /// - Returns: The header value
    static func authorization(username: String, password: String) -> RequestHeaders.Value {
        .string("Basic \(Data((username + ":" + password).utf8).base64EncodedString())")
    }

    /// A value for the `Cache-Control` header field
    /// - Parameter type: The cache control typr
    /// - Returns: The header value
    static func cacheControlType(_ type: CacheControlType) -> RequestHeaders.Value {
        .string(type.description)
    }

    // MARK: - API

    /// Available content types
    enum ContentType: String, CustomStringConvertible, Equatable, Hashable {

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
    enum AuthorizationType: ExpressibleByStringLiteral, CustomStringConvertible, Equatable, Hashable {

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
            case let .custom(value):
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
    enum CacheControlType: ExpressibleByStringLiteral, CustomStringConvertible, Equatable, Hashable {

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
            case let .maxAge(seconds):
                return "max-age=\(seconds)"
            case let .maxStale(seconds):
                if let seconds = seconds {
                    return "max-stale=\(seconds)"
                } else {
                    return "max-stale"
                }
            case let .minFresh(seconds):
                return "min-fresh=\(seconds)"
            case let .custom(value):
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
