// Ombi
// RequestError.swift
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

/// An error produced by a `RequestManager`
///
/// - Tag: RequestError
public enum RequestError<T>: LocalizedError, CustomStringConvertible where T: Error {

    /// Malformed Request
    case malformedRequest

    /// Decoding
    case decodingError(Error)

    /// Unknown
    case unknownError

    /// Response validation error
    case validationError(T)

    /// Session failed error
    case urlSessionFailed(_ error: URLError)

    /// SLA Exceeded
    case slaExceeded

    /// Timeout
    case timedOut

    // MARK: - LocalizedError

    public var errorDescription: String? {
        description
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        switch self {
        case .malformedRequest:
            return "The request was malformed. Check the URL or the body content"
        case let .decodingError(error):
            return "Couldn't decode the response body content: \(error)"
        case .unknownError:
            return "The request failed for an unknown reason"
        case let .validationError(error):
            return "The request failed validation: \(error)"
        case let .urlSessionFailed(error):
            return "The URL session failed: \(error)"
        case .slaExceeded:
            return "The request exceeded the provided sla"
        case .timedOut:
            return "The request timed out"
        }
    }
}

/// Basic validation error
public enum HTTPError: LocalizedError, CustomStringConvertible {

    // MARK: - Initializers

    /// Create an `HTTPError` based on a status code
    /// - Parameter code: The code
    public init?(_ code: Int) {
        guard code < 200 || code >= 300 else {
            return nil
        }
        switch code {
        case 400: self = .badRequest
        case 401: self = .unauthorized
        case 403: self = .forbidden
        case 404: self = .notFound
        case 402, 405 ... 499: self = .error4xx(code)
        case 500: self = .serverError
        case 501 ... 599: self = .error5xx(code)
        default: self = .unknownErrorCode(code)
        }
    }

    // MARK: - API

    /// Bad request (400)
    case badRequest

    /// Authorization error (401)
    case unauthorized

    /// Forbidden error (403)
    case forbidden

    /// Not found error (404)
    case notFound

    /// Custom 4xx error
    case error4xx(_ code: Int)

    /// Server error (500)
    case serverError

    /// Custom 5xx error
    case error5xx(_ code: Int)

    /// Other http error
    case unknownErrorCode(_ code: Int)

    // MARK: - LocalizedError

    public var errorDescription: String? {
        description
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        switch self {
        case .badRequest:
            return "Bad Request(400)"
        case .unauthorized:
            return "Unauthorized (401)"
        case .forbidden:
            return "Forbidden (403)"
        case .notFound:
            return "Not Found (404)"
        case let .error4xx(code):
            return "Error (\(code))"
        case .serverError:
            return "Server Error (500)"
        case let .error5xx(code):
            return "Errpr (\(code))"
        case let .unknownErrorCode(code):
            return "Unknown Error (\(code))"
        }
    }

}
