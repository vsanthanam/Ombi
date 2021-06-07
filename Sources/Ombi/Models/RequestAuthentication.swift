// Ombi
// RequestAuthentication.swift
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

public enum RequestAuthentication: Equatable, Hashable {

    // MARK: - API

    public enum TokenType: RawRepresentable, CustomStringConvertible, ExpressibleByStringLiteral, Equatable, Hashable {

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

        /// Custom Token Type
        case custom(String)

        // MARK: - RawRepresentable

        public init?(rawValue: String) {
            self = .custom(rawValue)
        }

        public typealias RawValue = String

        public var rawValue: RawValue {
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

        // MARK: - CustomStringConvertible

        public var description: String {
            rawValue
        }

        // MARK: - Hashable

        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }

        // MARK: - Equatable

        public static func == (lhs: TokenType, rhs: TokenType) -> Bool {
            lhs.rawValue == rhs.rawValue
        }

        // MARK: - ExpressibleByStringLiteral

        public typealias StringLiteralType = String

        public init(stringLiteral value: String) {
            self = .custom(value)
        }

    }

    case basic(username: String, password: String)

    case token(type: TokenType, value: String)

    public var headerKey: RequestHeaders.Key {
        .authorization
    }

    public var headerValue: RequestHeaders.Value {
        switch self {
        case let .basic(username, password):
            return .string(TokenType.basic.rawValue + Data((username + ":" + password).utf8).base64EncodedString())
        case let .token(type, value):
            return .string(type.rawValue + " " + value)
        }
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(headerKey)
        hasher.combine(headerValue)
    }

    // MARK: - Equatable

    public static func == (lhs: RequestAuthentication, rhs: RequestAuthentication) -> Bool {
        lhs.headerKey == rhs.headerKey && lhs.headerValue == rhs.headerValue
    }

}
